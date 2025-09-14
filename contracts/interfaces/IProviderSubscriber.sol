// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "../libraries/ProviderErrors.sol";
import "../libraries/ProviderEvents.sol";

interface IProviderSubscriber {
    struct Provider {
        address owner;
        uint256 monthlyFeeInTokens;
        uint256 pausedBlockNumber; // 0 = not paused, >0 = paused at this block
        uint256 balance;
        bytes32[] activeSubscribers; // Array of active subscription keys (keccak256(subscriberId, providerId))
        uint8 plan;
    }

    struct Subscriber {
        address owner;
        uint256 balance;
        bytes32[] activeProviders; // Array of active subscription keys (keccak256(subscriberId, providerId))
    }

    struct ProviderSubscriber {
        bytes32 providerId;
        bytes32 subscriberId;
        uint256 subscribedBlockNumber;
        uint256 pausedBlockNumber; // 0 = not paused, >0 = paused at this block
        uint256 lastChargedBlock; // Last block when this subscription was charged
    }

    function registerProvider(bytes32 providerId, uint256 monthlyFeeInTokens) external;

    function removeProvider(bytes32 providerId) external;

    function registerSubscriber(bytes32 subscriberId) external;

    function subscribeProvider(bytes32 subscriberId, bytes32 providerId) external returns (bytes32 subscriptionKey);

    function pauseSubscription(bytes32 subscriptionKey) external;

    function deposit(bytes32 subscriberId, uint256 amount) external;

    function withdrawProviderEarnings(bytes32 providerId) external;

    function setProviderStatus(bytes32 providerId, bool active) external;

    function getProviderCount() external view returns (uint256 count);

    function getProviderState(bytes32 providerId) external view returns (bool exists, bool active);

    function getProviderEarnings(bytes32 providerId) external view returns (uint256 tokenAmount, uint256 usdValue);

    function getMaxProviders() external view returns (uint256);

    function getMinFeeUsd() external view returns (uint256);

    function canWithdraw(bytes32 providerId) external view returns (bool);

    function getMonthDurationInBlocks() external view returns (uint256);

    function getSubscriberState(
        bytes32 subscriberId
    ) external view returns (address owner, uint256 balance, bytes32[] memory activeProviders);

    function getMinDepositUsd() external view returns (uint256);

    function estimateSubscriptionCost(
        uint256 monthlyFeeInTokens,
        uint256 startBlock
    ) external view returns (uint256 tokensPerBlock, uint256 estimatedCost);


    function getSubscriberDebt(bytes32 subscriptionKey) external view returns (uint256);

    function paySubscriptionDebt(bytes32 subscriptionKey, uint256 amount) external;

    function getProviderSubscriber(
        bytes32 subscriptionKey
    ) external view returns (ProviderSubscriber memory);

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
        );

    function getSubscriberDepositValueUSD(bytes32 subscriberId) external view returns (uint256);

    function getProviderBalance(bytes32 providerId) external view returns (uint256);

    function processBillingCycle(bytes32 providerId) external;
}
