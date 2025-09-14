// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.28;

import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

library ChainlinkPriceFeed {
    error InvalidPriceFeedData();
    error PriceFeedUnavailable();
    error InvalidPriceValue();
    error FailedToGetTokenDecimals();
    error InvalidTokenAmount();

    function getTokenValueInUSD(
        AggregatorV3Interface priceFeed,
        uint256 tokenAmount,
        address tokenAddress
    ) internal view returns (uint256 usdValue) {
        if (tokenAmount == 0) {
            revert InvalidTokenAmount();
        }

        uint8 tokenDecimals = _getTokenDecimals(tokenAddress);
        (uint256 price, uint8 priceDecimals) = getLatestPrice(priceFeed);

        usdValue = (tokenAmount * price) / (10 ** (tokenDecimals + priceDecimals - 8));
    }

    function getLatestPrice(AggregatorV3Interface priceFeed) internal view returns (uint256 price, uint8 decimals) {
        try priceFeed.latestRoundData() returns (uint80, int256 rawPrice, uint256, uint256, uint80) {
            if (rawPrice <= 0) {
                revert InvalidPriceValue();
            }

            price = uint256(rawPrice);
            decimals = priceFeed.decimals();
        } catch {
            revert PriceFeedUnavailable();
        }
    }

    function getPriceFeedDecimals(AggregatorV3Interface priceFeed) internal view returns (uint8 decimals) {
        return priceFeed.decimals();
    }

    function getPriceFeedDescription(
        AggregatorV3Interface priceFeed
    ) internal view returns (string memory description) {
        try priceFeed.description() returns (string memory desc) {
            return desc;
        } catch {
            return "Unknown price feed";
        }
    }

    function getPriceFeedVersion(AggregatorV3Interface priceFeed) internal view returns (uint256 version) {
        try priceFeed.version() returns (uint256 ver) {
            return ver;
        } catch {
            return 0;
        }
    }

    function _getTokenDecimals(address tokenAddress) private view returns (uint8 decimals) {
        (bool success, bytes memory data) = tokenAddress.staticcall(abi.encodeWithSignature("decimals()"));

        if (!success || data.length < 32) {
            revert FailedToGetTokenDecimals();
        }

        decimals = abi.decode(data, (uint8));
        require(decimals > 0 && decimals <= 18, "Invalid token decimals");

        return decimals;
    }
}
