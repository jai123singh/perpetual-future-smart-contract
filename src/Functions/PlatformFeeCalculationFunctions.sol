// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract PlatformFeeCalculationFunctions {
    function calculateOpeningANewPositionFee(
        int256 positionSize
    ) internal pure returns (int256) {
        return ((positionSize * 5) / 10000);
        // We are taking 0.05 percent of position size as the platform fee to buy or sell the perp
    }

    function calculateFundingRateMechanismFee(
        int256 amountChangeDueToFundingRateMechanism
    ) internal pure returns (int256) {
        int256 platformFeeForFundingRateMechanism;

        if (amountChangeDueToFundingRateMechanism <= 0) {
            platformFeeForFundingRateMechanism = ((-1 *
                amountChangeDueToFundingRateMechanism *
                10) / 100);
        } else if (amountChangeDueToFundingRateMechanism > 0) {
            platformFeeForFundingRateMechanism = ((amountChangeDueToFundingRateMechanism *
                10) / 100);
        }
        return platformFeeForFundingRateMechanism;
    }

    function calculateAutomatedLiquidationFee(
        int256 totalRemainingMargin
    ) internal pure returns (int256) {
        return ((totalRemainingMargin * 5) / 100);
        // we are taking 5 percent of total remaining margin as the platform fee for automated liquidation
    }
}
