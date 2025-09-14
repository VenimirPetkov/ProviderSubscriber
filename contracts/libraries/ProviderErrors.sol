// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

library ProviderErrors {
    error NotProviderOwner();
    error ProviderDoesNotExist();
    error ProviderNotActive();
    error ProviderAlreadyRegistered();
    error MaximumProvidersReached();
    error InvalidMonthlyFee();
    error MonthlyFeeBelowMinimum(uint256 currentFee, uint256 minimumFee);
    error AlreadyWithdrawnThisMonth();
    error InsufficientDeposit(uint256 currentDeposit, uint256 minimumDeposit);
    error AlreadySubscribed();
    error SubscriberDoesNotExist();
    error TransferFailed();
    error InvalidAmount();
    error SubscriberAlreadyRegistered();
    error NotSubscriberOwner();
    error NoEarningsToWithdraw();
    error SubscriptionDoesNotExist();
    error SubscriptionAlreadyPaused();
    error SubscriptionNotPaused();
    error SubscriptionNotFound();
}
