// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "./ProviderSubscriber.sol";

/**
 * @title ProviderSubscriberSystem
 * @dev Concrete implementation of the ProviderSubscriber abstract contract
 * This contract provides the public initialize function required for deployment
 */
contract ProviderSubscriberSystem is ProviderSubscriber {
    /**
     * @dev Initialize the ProviderSubscriberSystem contract
     * @param _paymentToken Address of the ERC20 token used for payments
     * @param _priceFeed Address of the Chainlink price feed aggregator
     * @param _minFeeUsd Minimum monthly fee in USD (e.g., 50 * 10^8 for $50)
     * @param _minDepositUsd Minimum subscriber deposit in USD (e.g., 100 * 10^8 for $100)
     * @param _maxProviders Maximum number of providers allowed (200 as per assignment)
     * @param _monthDurationInBlocks Duration of a month in blocks (ETH: ~216,000 blocks per month)
     */
    function initialize(
        address _paymentToken,
        address _priceFeed,
        uint256 _minFeeUsd,
        uint256 _minDepositUsd,
        uint256 _maxProviders,
        uint256 _monthDurationInBlocks
    ) public initializer {
        __Provider_init(
            _paymentToken,
            _priceFeed,
            _minFeeUsd,
            _minDepositUsd,
            _maxProviders,
            _monthDurationInBlocks
        );
    }

    /**
     * @dev Authorize upgrades (only owner can upgrade)
     */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
