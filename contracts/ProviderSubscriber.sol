// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "./interfaces/IProviderSubscriber.sol";
import "./libraries/ChainlinkPriceFeed.sol";
import "./libraries/ProviderErrors.sol";
import "./libraries/ProviderEvents.sol";

abstract contract ProviderSubscriber is
    Initializable,
    UUPSUpgradeable,
    OwnableUpgradeable,
    ReentrancyGuardUpgradeable,
    IProviderSubscriber
{
    using ChainlinkPriceFeed for AggregatorV3Interface;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    struct ProviderStorage {
        uint256 maxProviders;
        uint256 minFeeUsd;
        uint256 minDepositUsd;
        uint256 monthDuration;
        IERC20 paymentToken;
        AggregatorV3Interface aggregator;
        mapping(bytes32 => Provider) providers;
        mapping(bytes32 => Subscriber) subscribers;
        mapping(bytes32 => ProviderSubscriber) providerActiveSubscribers; // subscriptionKey => ProviderSubscriber data (active)
        mapping(bytes32 => ProviderSubscriber) providerPausedSubscribers; // subscriptionKey => ProviderSubscriber data (paused)
        uint256 providerCount;
    }

    bytes32 private constant PROVIDER_STORAGE_LOCATION =
        0xb1d2ee2caaf48f7af5bc4381215c393eddb4a09cec94b38c90344a4367230500;

    function _getProviderStorage() internal pure returns (ProviderStorage storage $) {
        assembly {
            $.slot := PROVIDER_STORAGE_LOCATION
        }
    }

    modifier onlyProviderOwner(bytes32 providerId) {
        ProviderStorage storage $ = _getProviderStorage();
        if ($.providers[providerId].owner != _msgSender()) {
            revert ProviderErrors.NotProviderOwner();
        }
        _;
    }

    modifier providerExists(bytes32 providerId) {
        ProviderStorage storage $ = _getProviderStorage();
        if ($.providers[providerId].owner == address(0)) {
            revert ProviderErrors.ProviderDoesNotExist();
        }
        _;
    }

    modifier activeProvider(bytes32 providerId) {
        ProviderStorage storage $ = _getProviderStorage();
        if ($.providers[providerId].pausedBlockNumber != 0) {
            revert ProviderErrors.ProviderNotActive();
        }
        _;
    }

    modifier subscriberExists(bytes32 subscriberId) {
        ProviderStorage storage $ = _getProviderStorage();
        if ($.subscribers[subscriberId].owner == address(0)) {
            revert ProviderErrors.SubscriberDoesNotExist();
        }
        _;
    }

    function __Provider_init(
        address _paymentToken,
        address _priceFeed,
        uint256 _minFeeUsd,
        uint256 _minDepositUsd,
        uint256 _maxProviders,
        uint256 _monthDurationInBlocks
    ) internal onlyInitializing {
        __Ownable_init(_msgSender());
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __Provider_init_unchained(_paymentToken, _priceFeed, _minFeeUsd, _minDepositUsd, _maxProviders, _monthDurationInBlocks);
    }

    function __Provider_init_unchained(
        address _paymentToken,
        address _priceFeed,
        uint256 _minFeeUsd,
        uint256 _minDepositUsd,
        uint256 _maxProviders,
        uint256 _monthDurationInBlocks  // Duration in blocks (ETH: ~216,000 blocks per month)
    ) internal onlyInitializing {
        ProviderStorage storage $ = _getProviderStorage();

        $.paymentToken = IERC20(_paymentToken);
        $.aggregator = AggregatorV3Interface(_priceFeed);
        $.maxProviders = _maxProviders;
        $.minFeeUsd = _minFeeUsd;
        $.minDepositUsd = _minDepositUsd;
        $.monthDuration = _monthDurationInBlocks;
        $.providerCount = 0;
    }

    function registerProvider(bytes32 providerId, uint256 monthlyFeeInTokens, uint8 plan) external nonReentrant {
        ProviderStorage storage $ = _getProviderStorage();

        address providerOwner = _msgSender();

        Provider memory provider = $.providers[providerId];

        if (provider.owner != address(0)) {
            revert ProviderErrors.ProviderAlreadyRegistered();
        }

        if ($.providerCount >= $.maxProviders) {
            revert ProviderErrors.MaximumProvidersReached();
        }

        if (monthlyFeeInTokens == 0) {
            revert ProviderErrors.InvalidMonthlyFee();
        }

        uint256 monthlyFeeInUSD = $.aggregator.getTokenValueInUSD(monthlyFeeInTokens, address($.paymentToken));

        if (monthlyFeeInUSD == 0) {
            revert ProviderErrors.InvalidMonthlyFee();
        }

        if (monthlyFeeInUSD < $.minFeeUsd) {
            revert ProviderErrors.MonthlyFeeBelowMinimum(monthlyFeeInUSD, $.minFeeUsd);
        }

        provider.owner = providerOwner;
        provider.monthlyFeeInTokens = monthlyFeeInTokens;
        provider.pausedBlockNumber = 0; // Not paused
        provider.balance = 0;
        provider.plan = plan;
        $.providers[providerId] = provider;

        $.providerCount++;

        emit ProviderEvents.ProviderRegistered(providerId, providerOwner, 0, monthlyFeeInTokens);
    }

    function removeProvider(
        bytes32 providerId
    ) external nonReentrant onlyProviderOwner(providerId) providerExists(providerId) {
        ProviderStorage storage $ = _getProviderStorage();

        Provider memory provider = $.providers[providerId];
        address providerOwner = provider.owner;

        // Transfer provider's accumulated balance
        if (provider.balance > 0) {
            $.paymentToken.transfer(providerOwner, provider.balance);
        }

        delete $.providers[providerId];

        $.providerCount--;

        emit ProviderEvents.ProviderRemoved(providerId, providerOwner);
    }

    function registerSubscriber(bytes32 subscriberId) external nonReentrant {
        ProviderStorage storage $ = _getProviderStorage();
        address subscriberOwner = _msgSender();

        if ($.subscribers[subscriberId].owner != address(0)) {
            revert ProviderErrors.SubscriberAlreadyRegistered();
        }

        $.subscribers[subscriberId] = Subscriber({
            owner: subscriberOwner,
            balance: 0,
            activeProviders: new bytes32[](0)
        });

        emit ProviderEvents.SubscriberRegistered(subscriberId, subscriberOwner, 0, 0);
    }

    function deposit(bytes32 subscriberId, uint256 amount) external nonReentrant subscriberExists(subscriberId) {
        ProviderStorage storage $ = _getProviderStorage();
        address caller = _msgSender();

        if (amount == 0) {
            revert ProviderErrors.InvalidAmount();
        }

        if (!$.paymentToken.transferFrom(caller, address(this), amount)) {
            revert ProviderErrors.TransferFailed();
        }

        $.subscribers[subscriberId].balance += amount;

        uint256 usdValue = $.aggregator.getTokenValueInUSD(amount, address($.paymentToken));

        emit ProviderEvents.SubscriberDeposit(subscriberId, caller, amount, usdValue);
    }

    function subscribeProvider(
        bytes32 subscriberId,
        bytes32 providerId
    )
        external
        nonReentrant
        subscriberExists(subscriberId)
        activeProvider(providerId)
        returns (bytes32 subscriptionKey)
    {
        ProviderStorage storage $ = _getProviderStorage();
        address subscriberOwner = _msgSender();
        Subscriber memory subscriber = $.subscribers[subscriberId];
        if (subscriber.owner != subscriberOwner) {
            revert ProviderErrors.NotSubscriberOwner();
        }

        subscriptionKey = _generateSubscriptionKey(subscriberId, providerId);

        if ($.providerActiveSubscribers[subscriptionKey].subscriberId != bytes32(0)) {
            revert ProviderErrors.AlreadySubscribed();
        }

        uint256 currentDepositUSD = $.aggregator.getTokenValueInUSD(
            $.subscribers[subscriberId].balance,
            address($.paymentToken)
        );

        uint256 minRequiredDepositUSD = 100 * 10**8;
        if (currentDepositUSD < minRequiredDepositUSD) {
            revert ProviderErrors.InsufficientDeposit(currentDepositUSD, minRequiredDepositUSD);
        }

        if ($.providerPausedSubscribers[subscriptionKey].subscriberId != bytes32(0)) {
            ProviderSubscriber memory pausedSubscription = $.providerPausedSubscribers[subscriptionKey];
            pausedSubscription.pausedBlockNumber = 0; // Mark as active
            $.providerActiveSubscribers[subscriptionKey] = pausedSubscription;
            delete $.providerPausedSubscribers[subscriptionKey];

            $.subscribers[subscriberId].activeProviders.push(subscriptionKey);

            emit ProviderEvents.SubscriptionUnpaused(subscriberId, providerId, block.number);
            return subscriptionKey;
        }

        if ($.providers[providerId].pausedBlockNumber != 0) {
            revert ProviderErrors.ProviderNotActive();
        }

        $.providerActiveSubscribers[subscriptionKey] = ProviderSubscriber({
            providerId: providerId,
            subscriberId: subscriberId,
            subscribedBlockNumber: block.number,
            pausedBlockNumber: 0, // Not paused
            lastChargedBlock: block.number // Initialize to current block
        });

        $.subscribers[subscriberId].activeProviders.push(subscriptionKey);

        emit ProviderEvents.SubscribedToProvider(
            subscriberId,
            providerId,
            $.providers[providerId].monthlyFeeInTokens,
            block.number
        );
    }

    function pauseSubscription(
        bytes32 subscriptionKey
    ) external nonReentrant {
        _validateSubscriptionAccess(subscriptionKey);

        ProviderStorage storage $ = _getProviderStorage();

        if ($.providerActiveSubscribers[subscriptionKey].subscriberId == bytes32(0)) {
            revert ProviderErrors.SubscriptionNotFound();
        }

        ProviderSubscriber memory subscription = $.providerActiveSubscribers[subscriptionKey];

        (,uint256 currentDebt) = estimateSubscriptionCost(subscriptionKey);
        if (currentDebt > 0) {
            if ($.subscribers[subscription.subscriberId].balance < currentDebt) {
                revert ProviderErrors.InsufficientDeposit($.subscribers[subscription.subscriberId].balance, currentDebt);
            }
            $.subscribers[subscription.subscriberId].balance -= currentDebt;
            $.providers[subscription.providerId].balance += currentDebt;
            $.providerActiveSubscribers[subscriptionKey].lastChargedBlock = block.number;
        }
        
        subscription.pausedBlockNumber = block.number;
        $.providerPausedSubscribers[subscriptionKey] = subscription;
        delete $.providerActiveSubscribers[subscriptionKey];

        emit ProviderEvents.SubscriptionPaused(subscription.subscriberId, subscription.providerId, block.number);
    }

    function withdrawProviderEarnings(
        bytes32 providerId
    ) external nonReentrant onlyProviderOwner(providerId) providerExists(providerId) {
        ProviderStorage storage $ = _getProviderStorage();

        Provider storage provider = $.providers[providerId];

        uint256 availableBalance = provider.balance;

        if (availableBalance == 0) {
            revert ProviderErrors.NoEarningsToWithdraw();
        }

        uint256 usdValue = $.aggregator.getTokenValueInUSD(availableBalance, address($.paymentToken));

        provider.balance = 0; // Reset balance after withdrawal

        $.paymentToken.transfer(provider.owner, availableBalance);

        emit ProviderEvents.ProviderEarningsWithdrawn(provider.owner, availableBalance, usdValue);

        emit ProviderEvents.ProviderBalanceUpdated(providerId, 0, availableBalance);
    }

    function setProviderStatus(bytes32 providerId, bool active) external onlyOwner providerExists(providerId) {
        ProviderStorage storage $ = _getProviderStorage();

        Provider storage provider = $.providers[providerId];

        if (active) {
            provider.pausedBlockNumber = 0; // Unpause
        } else {
            provider.pausedBlockNumber = block.number; // Pause
        }

        emit ProviderEvents.ProviderStateChanged(providerId, provider.owner, active);
    }

    function getProvider(bytes32 providerId) external view returns (Provider memory provider) {
        ProviderStorage storage $ = _getProviderStorage();
        return $.providers[providerId];
    }

    function getProviderState(bytes32 providerId) external view returns (bool exists, bool active) {
        ProviderStorage storage $ = _getProviderStorage();
        Provider memory provider = $.providers[providerId];

        exists = provider.owner != address(0);
        active = provider.pausedBlockNumber == 0;
    }

    function getProviderEarnings(bytes32 providerId) external view returns (uint256 tokenAmount, uint256 usdValue) {
        ProviderStorage storage $ = _getProviderStorage();
        Provider memory provider = $.providers[providerId];

        tokenAmount = provider.balance;
        usdValue = $.aggregator.getTokenValueInUSD(tokenAmount, address($.paymentToken));
    }

    function getProviderCount() external view returns (uint256 count) {
        ProviderStorage storage $ = _getProviderStorage();
        return $.providerCount;
    }

    function getMaxProviders() external view returns (uint256) {
        ProviderStorage storage $ = _getProviderStorage();
        return $.maxProviders;
    }

    function getMinFeeUsd() external view returns (uint256) {
        ProviderStorage storage $ = _getProviderStorage();
        return $.minFeeUsd;
    }

    function canWithdraw(bytes32 providerId) external view returns (bool) {
        ProviderStorage storage $ = _getProviderStorage();
        Provider memory provider = $.providers[providerId];

        // Provider can withdraw if they have a balance
        return provider.balance > 0;
    }

    function getMonthDurationInBlocks() external view returns (uint256) {
        ProviderStorage storage $ = _getProviderStorage();
        return $.monthDuration;
    }

    function getSubscriberState(
        bytes32 subscriberId
    ) external view returns (address owner, uint256 balance, bytes32[] memory activeProviders) {
        ProviderStorage storage $ = _getProviderStorage();
        Subscriber memory sub = $.subscribers[subscriberId];
        return (sub.owner, sub.balance, sub.activeProviders);
    }

    function getSubscriberDepositValueUSD(bytes32 subscriberId) external view returns (uint256) {
        ProviderStorage storage $ = _getProviderStorage();
        return $.aggregator.getTokenValueInUSD($.subscribers[subscriberId].balance, address($.paymentToken));
    }

    function getProviderDetailedState(
        bytes32 providerId
    )
        external
        view
        returns (
            address owner,
            uint256 monthlyFeeInTokens,
            uint256 pausedBlockNumber,
            uint256 balance,
            uint256 subscriberCount,
            bool isActive
        )
    {
        ProviderStorage storage $ = _getProviderStorage();
        Provider memory provider = $.providers[providerId];

        return (
            provider.owner,
            provider.monthlyFeeInTokens,
            provider.pausedBlockNumber,
            provider.balance,
            provider.activeSubscribers.length,
            provider.pausedBlockNumber == 0
        );
    }

    function getMinDepositUsd() external view returns (uint256) {
        ProviderStorage storage $ = _getProviderStorage();
        return $.minDepositUsd;
    }

    function getProviderBalance(bytes32 providerId) external view returns (uint256) {
        ProviderStorage storage $ = _getProviderStorage();
        return $.providers[providerId].balance;
    }

    function processBillingCycle(bytes32 providerId) external nonReentrant providerExists(providerId) {
        ProviderStorage storage $ = _getProviderStorage();
        Provider storage provider = $.providers[providerId];

        uint256 monthlyEarnings = provider.activeSubscribers.length * provider.monthlyFeeInTokens;

        if (monthlyEarnings > 0) {
            provider.balance += monthlyEarnings;
            emit ProviderEvents.ProviderBalanceUpdated(providerId, provider.balance, monthlyEarnings);
        }
    }

    function estimateSubscriptionCost(
        bytes32 subscriptionId
    ) public view virtual returns (uint256 tokensPerBlock, uint256 estimatedCost) {
        ProviderStorage storage $ = _getProviderStorage();
        ProviderSubscriber memory subscription = $.providerActiveSubscribers[subscriptionId];
        if (subscription.subscriberId == bytes32(0)) {
            revert ProviderErrors.SubscriptionDoesNotExist();
        }

        Provider memory provider = $.providers[subscription.providerId];
        if (provider.owner == address(0)) {
            revert ProviderErrors.ProviderDoesNotExist();
        }

        uint256 precision = 10**18;
        tokensPerBlock = (provider.monthlyFeeInTokens * precision) / $.monthDuration;

        uint256 blocksSinceSubscription = block.number - subscription.subscribedBlockNumber;
        estimatedCost = (blocksSinceSubscription * tokensPerBlock) / precision;
    }

    function getProviderSubscriber(
        bytes32 subscriptionKey
    ) external view returns (ProviderSubscriber memory) {
        ProviderStorage storage $ = _getProviderStorage();

        ProviderSubscriber memory subscription = $.providerActiveSubscribers[subscriptionKey];

        // If not found in active, check paused subscribers
        if (subscription.subscriberId == bytes32(0)) {
            subscription = $.providerPausedSubscribers[subscriptionKey];
        }

        if (subscription.subscriberId == bytes32(0)) {
            revert ProviderErrors.SubscriptionDoesNotExist();
        }

        return subscription;
    }

    function _validateSubscriptionAccess(bytes32 subscriptionKey) internal view {
        ProviderStorage storage $ = _getProviderStorage();
        address caller = _msgSender();

        // Get subscription to extract subscriber ID
        ProviderSubscriber memory subscription = $.providerActiveSubscribers[subscriptionKey];
        if (subscription.subscriberId == bytes32(0)) {
            subscription = $.providerPausedSubscribers[subscriptionKey];
        }

        if (subscription.subscriberId == bytes32(0)) {
            revert ProviderErrors.SubscriptionDoesNotExist();
        }

        // Verify the caller owns this subscriber ID
        if ($.subscribers[subscription.subscriberId].owner != caller) {
            revert ProviderErrors.NotSubscriberOwner();
        }
    }

    function _subscriptionExists(bytes32 subscriptionKey) internal view returns (bool) {
        ProviderStorage storage $ = _getProviderStorage();
        return
            $.providerActiveSubscribers[subscriptionKey].subscriberId != bytes32(0) ||
            $.providerPausedSubscribers[subscriptionKey].subscriberId != bytes32(0);
    }

    function _calculateSubscriptionDebt(bytes32 subscriptionKey) internal view returns (uint256 debt) {
        ProviderStorage storage $ = _getProviderStorage();

        ProviderSubscriber memory subscription = $.providerActiveSubscribers[subscriptionKey];

        // If not found in active, check paused subscribers
        if (subscription.subscriberId == bytes32(0)) {
            subscription = $.providerPausedSubscribers[subscriptionKey];
        }

        if (subscription.subscriberId == bytes32(0)) {
            return 0;
        }

        Provider memory provider = $.providers[subscription.providerId];
        uint256 subscribedBlock = subscription.subscribedBlockNumber;
        uint256 pausedBlock = subscription.pausedBlockNumber;

        uint256 endBlock = pausedBlock > 0 ? pausedBlock : block.number;

        uint256 blocksUsed = endBlock - subscribedBlock;

        return (blocksUsed * provider.monthlyFeeInTokens) / $.monthDuration;
    }
    function _generateSubscriptionKey(bytes32 subscriberId, bytes32 providerId) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked(subscriberId, providerId));
    }
}
