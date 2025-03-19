// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./Functions/SNXPriceInWei.sol";
import "./Events.sol";
import "./Utility/CircularVector.sol";
import "./Functions/Buy.sol";
import "./Functions/Sell.sol";
import "./Functions/AddMoreMarginToOpenPosition.sol";
import "./Functions/Deposit.sol";
import "./Functions/TakeOutDeposit.sol";
import "./Functions/CloseOpenPosition.sol";
import "./Functions/ExecuteFundingRateMechanism.sol";
import "./Functions/GetterFunctions.sol";

//
// StateVariables,

contract Perp is
    SNXPriceInWei,
    GetterFunctions,
    Deposit,
    TakeOutDeposit,
    CloseOpenPosition,
    ExecuteFundingRateMechanism,
    AddMoreMarginToOpenPosition,
    Buy,
    Sell
{
    //numberOfPerpInLiquidityPool must always be an integer , and should not be a decimal number, else, u will get error msg from solidity
    using CircularVectorLib for CircularVector;
    constructor(int256 _numberOfPerpInLiquidityPool) payable {
        owner = msg.sender;
        numberOfPerpInLiquidityPool = _numberOfPerpInLiquidityPool;
        lastFundingRate = 0;
        lastFundingTime = int256(block.timestamp);
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

    // following function can only be called by owner, and it changes the backend address
    function changeBackend(address _backend) external onlyOwner {
        backend = _backend;
    }

    // following function can only be called by owner, and it changes owner of the smart contract
    function changeOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    // Following functions are used to receive eth in case someone sends eth without calling any function or a function that doesnt exist

    // receive function will be triggered when Ether is sent with no data
    receive() external payable {
        numberOfWeiInWeiPool += int256(msg.value);
    }

    // fallback function will be triggered when:
    // - A non-existent function is called
    // - Ether is sent with data
    fallback() external payable {
        if (msg.value > 0) {
            numberOfWeiInWeiPool += int256(msg.value);
        }
    }

    // Following function is only for testing purpose(so that no eth is wasted). In final deployement, no such function would be there. Hence nobody can withdraw smart contract's balance

    // Following function is used to withdraw all the balance of the smart contract. It can be accessed only by owner.

    function withdrawAllFundsOfSmartContract() external onlyOwner {
        (bool success, ) = payable(owner).call{value: address(this).balance}(
            ""
        );
        require(success, "Call failed");
        numberOfWeiInWeiPool = 0;
    }
}
