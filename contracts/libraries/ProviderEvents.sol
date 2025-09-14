// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

library ProviderEvents {
    event ProviderRegistered(
        bytes32 indexed providerId,
        address indexed owner,
        uint256 registrationFee,
        uint256 monthlyFee
    );

    event ProviderRemoved(bytes32 indexed providerId, address indexed owner);

    event ProviderEarningsWithdrawn(address indexed provider, uint256 amount, uint256 usdValue);

    event ProviderStateChanged(bytes32 indexed providerId, address indexed provider, bool isActive);

    event SubscriberRegistered(
        bytes32 indexed subscriberId,
        address indexed subscriberOwner,
        uint256 depositAmount,
        uint256 usdValue
    );

    event SubscriberDeposit(
        bytes32 indexed subscriberId,
        address indexed caller,
        uint256 depositAmount,
        uint256 usdValue
    );

    event SubscribedToProvider(
        bytes32 indexed subscriberId,
        bytes32 indexed providerId,
        uint256 monthlyFee,
        uint256 blockNumber
    );

    event SubscriptionPaused(bytes32 indexed subscriberId, bytes32 indexed providerId, uint256 blockNumber);

    event SubscriptionUnpaused(bytes32 indexed subscriberId, bytes32 indexed providerId, uint256 blockNumber);

    event SubscriberDebtUpdated(bytes32 indexed subscriberId, bytes32 indexed providerId, uint256 debtAmount);

    event SubscriptionDebtPaid(
        bytes32 indexed subscriberId,
        bytes32 indexed providerId,
        uint256 amountPaid,
        uint256 remainingDebt
    );

    event ProviderBalanceUpdated(bytes32 indexed providerId, uint256 newBalance, uint256 amountChanged);
}
