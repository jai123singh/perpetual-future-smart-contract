// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../StateVariables.sol";
import "../Utility/CircularVector.sol";

contract CalculateTwap is StateVariables {
    using CircularVectorLib for CircularVector;
    function calculateTwap() internal view returns (int256) {
        int256 summationOfTimeWeightedPrice = 0;
        int256 summationOfTimeInterval = 0;

        (
            int256[10] memory lastTenPerpPrices,
            int256[10] memory correspondingDuration
        ) = lastTenPerpPriceWithTimestamp
                .getPerpPriceVectorAndTimestampVector();

        for (uint256 i = 0; i < 10; i++) {
            summationOfTimeWeightedPrice +=
                lastTenPerpPrices[i] *
                correspondingDuration[i];
            summationOfTimeInterval += correspondingDuration[i];
        }
        return summationOfTimeWeightedPrice / summationOfTimeInterval;
    }
}
