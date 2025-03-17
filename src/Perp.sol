// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Functions/SNXPriceInWei.sol";
import "./Events.sol";
import "./StateVariables.sol";
import "./Utility/CircularVector.sol";
import "./Functions/Buy.sol";
import "./Functions/Sell.sol";
import "./Functions/AddMoreMarginToOpenPosition.sol";
import "./Functions/Deposit.sol";
import "./Functions/TakeOutDeposit.sol";
import "./Functions/CloseOpenPosition.sol";
import "./Functions/ExecuteFundingRateMechanism.sol";
import "./Functions/GetterFunctions.sol";

contract Perp is
    SNXPriceInWei,
    StateVariables,
    Buy,
    Sell,
    Deposit,
    AddMoreMarginToOpenPosition,
    TakeOutDeposit,
    CloseOpenPosition,
    ExecuteFundingRateMechanism,
    GetterFunctions
{
    //numberOfPerpInLiquidityPool must always be an integer , and should not be a decimal number, else, u will get error msg from solidity
    using CircularVectorLib for CircularVector;
    constructor(int256 _numberOfPerpInLiquidityPool) payable {
        numberOfPerpInLiquidityPool = _numberOfPerpInLiquidityPool;
        lastFundingRate = 0;
        lastFundingTime = block.timestamp;
        nextFundingTime = lastFundingRate + 8 hours;
        currentPriceOfPerp = getSNXPriceInWei();
        numberOfWeiInLiquidityPool =
            numberOfPerpInLiquidityPool *
            currentPriceOfPerp;
        numberOfWeiInWeiPool = int256(msg.value);
        lastTenPerpPriceWithTimestamp.push(
            currentPriceOfPerp,
            int256(block.timestamp)
        );
        emit Events.PerpPriceUpdated(
            currentPriceOfPerp,
            int256(block.timestamp)
        );
    }
}
