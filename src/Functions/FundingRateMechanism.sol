// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../StateVariables.sol";
import "../Utility/MaxHeap.sol";
import "../Utility/MinHeap.sol";
import "../Events.sol";
import "./CheckAndLiquidateLongPositions.sol";
import "./CheckAndLiquidateShortPositions.sol";
import "./CalculateTwap.sol";
import "./CalculateFundingRate.sol";
import "./ChangeMarginAndDepositAndTriggerPriceForLongPositionTraders.sol";
import "./ChangeMarginAndDepositAndTriggerPriceForShortPositionTraders.sol";

contract FundingRateMechanism is
    StateVariables,
    CheckAndLiquidateLongPositions,
    CheckAndLiquidateShortPositions,
    CalculateTwap,
    CalculateFundingRate,
    ChangeMarginAndDepositAndTriggerPriceForLongPositionTraders,
    ChangeMarginAndDepositAndTriggerPriceForShortPositionTraders
{
    // We need to determine how this function will be invoked.

    // We are going to use the following method:
    // The backend will call the smart contract every 8 hours.
    // The backend will store the timestamp of the last funding rate update and check if 8 hours have passed before calling the contract.
    // As a fallback method, user transactions will also check if 8 hours have passed. If they have, but the backend has not called the function,
    // it indicates an issue with the backend, and the funding rate mechanism will still be triggered.

    using MaxHeapLib for MaxHeap;
    using MinHeapLib for MinHeap;

    // Funding rate mechanism function
    //  this function uses these functions- calculateTwap,calculateFundingRate, changeMarginAndDepositAndTriggerPriceForLongPositionTraders,  changeMarginAndDepositAndTriggerPriceForShortPositionTraders, checkAndLiquidateLongPositions, checkAndLiquidateShortPositions

    // VVIMP- In real-world perpetual futures contracts, funding rate payments are typically deducted from the available deposit (account balance), not the margin allocated to a position.

    // Following is told by chatgpt, and we are making our perp based on this design only

    //     How Real-World Perpetuals Handle Funding Rate Payments
    // Margin Stays Intact:

    // The margin (used for maintaining the position) is not reduced by funding rate payments.
    // This ensures that the trader's position isn't liquidated due to funding rate payments alone.
    // Funding Rate Deducted from Available Balance:

    // The payment is taken from the trader’s available deposit (free balance).
    // If there is insufficient balance, the margin may be adjusted (which could lead to liquidation if it falls below maintenance margin).
    // If Deposit is Insufficient:

    // The system may try to deduct the funding rate from the margin, but this can lead to liquidation if the margin falls below maintenance requirements.

    function fundingRateMechanism() internal {
        // check if no position is open, then no need to do any funding rate mechanism
        if (
            triggerPriceForLongPositionLiquidationHeap.heap.length == 0 &&
            triggerPriceForShortPositionLiquidationHeap.heap.length == 0
        ) {
            return;
        }

        // Checks are done above

        // TWAP is the time-weighted average perp price
        int256 twap = calculateTwap();

        int256 fundingRate = calculateFundingRate(twap); // This function calculates the current funding rate

        if (fundingRate == 0) {
            return;
        }

        if (triggerPriceForLongPositionLiquidationHeap.heap.length > 0) {
            changeMarginAndDepositAndTriggerPriceForLongPositionTraders(
                fundingRate,
                twap
            );
            // This function changes the margin, deposits, and trigger price of long position traders with an open position. It handles both- ie if funding rate is positive, it will decrease long position tranders deposits , and if it is negative, it will increase depsoits of long position traders
        }

        if (triggerPriceForShortPositionLiquidationHeap.heap.length > 0) {
            changeMarginAndDepositAndTriggerPriceForShortPositionTraders(
                fundingRate,
                twap
            );
            // This function changes the margin, deposits, and trigger price of short position traders with an open position. It handles both- ie if funding rate is positive, it will increase short position tranders deposits , and if it is negative, it will decrease depsoits of short position traders
        }

        if (fundingRate > 0) {
            // Longs pay shorts, hence long position holders' margin might decrease.
            // Their trigger price may increase and may reach above the current price, possibly resulting in liquidation.
            checkAndLiquidateLongPositions();
        } else if (fundingRate < 0) {
            // Shorts pay longs, hence short position holders' margin might decrease.
            // Their trigger price may decrease and may reach below the current price, possibly resulting in liquidation.
            checkAndLiquidateShortPositions();
        }

        lastFundingTime = int256(block.timestamp);
        nextFundingTime = lastFundingTime + 8 hours;
        lastFundingRate = fundingRate;
        emit Events.FundingRateSettlement(fundingRate, int256(block.timestamp));
    }
}
