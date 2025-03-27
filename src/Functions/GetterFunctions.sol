// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../StateVariables.sol";
import "../Utility/MaxHeap.sol";
import "../Utility/MinHeap.sol";
import "../Modifiers.sol";

contract GetterFunctions is StateVariables, Modifiers {
    using MaxHeapLib for MaxHeap;
    using MinHeapLib for MinHeap;

    // following function gives totalPlatformFeeCollected. It can only be called by owner.
    function getTotalPlatformFeeCollected()
        external
        view
        onlyOwner
        returns (int256)
    {
        return totalPlatformFeeCollected;
    }

    // following function can only be owner. It gives the total wei in wei pool. It useful incase of extreme situtations. If uder extreme situtals wei in wei pool number becomes lesser than 0, so in order for the contract to function properly , owner would send some wei to the contract.
    function getAmountOfWeiInWeiPool()
        external
        view
        onlyOwner
        returns (int256)
    {
        return numberOfWeiInWeiPool;
    }

    // Following function gives the maximum number of perps that can be sold or bought
    function getMaxNumberOfTradablePerp() external view returns (int256) {
        return (numberOfPerpInLiquidityPool - 1);
    }

    // following function returns , how much deposit is present of a trader in the perp contract
    function getAmountOfTraderDepositPresentInContract(
        address traderAddress
    ) external view checkUserValidity(traderAddress) returns (int256) {
        return traderDepositHashmap[traderAddress];
    }

    // following function returns the leverage that trader used to open the current position
    function getLeverageUsedByTrader(
        address traderAddress
    ) external view checkUserValidity(traderAddress) returns (int256) {
        require(
            marginOfLongPositionTraderHashmap[traderAddress] != 0 ||
                marginOfShortPositionTraderHashmap[traderAddress] != 0,
            "You do not have any open position."
        );
        return leverageUsedByTraderHashMap[traderAddress];
    }

    // Following function gives the number of perp in short or long position of a specific trader
    function getNumberOfPerpInOpenPositionOfTrader(
        address traderAddress
    ) external view checkUserValidity(traderAddress) returns (int256) {
        require(
            marginOfLongPositionTraderHashmap[traderAddress] != 0 ||
                marginOfShortPositionTraderHashmap[traderAddress] != 0,
            "You do not have any open position."
        );
        if (marginOfLongPositionTraderHashmap[traderAddress] != 0) {
            return perpCountOfTraderWithLongPositionHashmap[traderAddress];
        } else {
            return perpCountOfTraderWithShortPositionHashmap[traderAddress];
        }
    }

    // Following function gives the perp Price at which a trader entered a trade
    function getPerpPriceAtWhichTraderEnteredTheTrade(
        address traderAddress
    ) external view checkUserValidity(traderAddress) returns (int256) {
        require(
            marginOfLongPositionTraderHashmap[traderAddress] != 0 ||
                marginOfShortPositionTraderHashmap[traderAddress] != 0,
            "You do not have any open position."
        );
        if (marginOfLongPositionTraderHashmap[traderAddress] != 0) {
            return priceAtWhichPerpWasBoughtHashmap[traderAddress];
        } else {
            return priceAtWhichPerpWasSoldHashmap[traderAddress];
        }
    }

    // Following function gives the margin of the trader
    function getMarginOfTrader(
        address traderAddress
    ) external view checkUserValidity(traderAddress) returns (int256) {
        require(
            marginOfLongPositionTraderHashmap[traderAddress] != 0 ||
                marginOfShortPositionTraderHashmap[traderAddress] != 0,
            "You do not have any open position."
        );
        if (marginOfLongPositionTraderHashmap[traderAddress] != 0) {
            return marginOfLongPositionTraderHashmap[traderAddress];
        } else {
            return marginOfShortPositionTraderHashmap[traderAddress];
        }
    }

    // Following function gives the maintenance margin of the trader
    function getMaintenanceMarginOfTrader(
        address traderAddress
    ) external view checkUserValidity(traderAddress) returns (int256) {
        require(
            marginOfLongPositionTraderHashmap[traderAddress] != 0 ||
                marginOfShortPositionTraderHashmap[traderAddress] != 0,
            "You do not have any open position."
        );
        if (marginOfLongPositionTraderHashmap[traderAddress] != 0) {
            return maintenanceMarginOfLongPositionTraderHashmap[traderAddress];
        } else {
            return maintenanceMarginOfShortPositionTraderHashmap[traderAddress];
        }
    }

    // Following function gives the trigger price of liquidation for open position traders
    function getTriggerPriceOfTrader(
        address traderAddress
    ) external view checkUserValidity(traderAddress) returns (int256) {
        require(
            marginOfLongPositionTraderHashmap[traderAddress] != 0 ||
                marginOfShortPositionTraderHashmap[traderAddress] != 0,
            "You do not have any open position."
        );
        if (marginOfLongPositionTraderHashmap[traderAddress] != 0) {
            int256 index = triggerPriceForLongPositionLiquidationHeap.indexMap[
                traderAddress
            ] - 1;
            return
                triggerPriceForLongPositionLiquidationHeap
                    .heap[uint256(index)]
                    .triggerPrice;
        } else {
            int256 index = triggerPriceForShortPositionLiquidationHeap.indexMap[
                traderAddress
            ] - 1;
            return
                triggerPriceForShortPositionLiquidationHeap
                    .heap[uint256(index)]
                    .triggerPrice;
        }
    }
}
