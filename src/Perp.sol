// SPDX-License-Identifier: MIT

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
        totalPlatformFeeCollected = 0;
        lastFundingRate = 0;
        lastFundingTime = int256(block.timestamp);
        nextFundingTime = lastFundingTime + int256(8 hours);
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
        emit Events.FundingRateSettlement(
            lastFundingRate,
            int256(block.timestamp)
        );
    }

    // following function can only be called by owner, and it changes the backend address
    function changeBackend(address _backend) external onlyOwner {
        backend = _backend;
    }

    // following function can only be called by owner, and it changes the beneficiary address
    function changeBeneficiary(address _beneficiary) external onlyOwner {
        beneficiary = _beneficiary;
    }

    // following function can only be called by owner, and it changes owner of the smart contract
    function changeOwner(address _owner) external onlyOwner {
        owner = _owner;
    }

    // Following functions are used to receive eth in case someone sends eth without calling any function or a function that doesnt exist
    // For following two functions, the ether sent would be counted in numberOfWeiInWeiPool and not in totalPlatformFeeCollected. Hence it wont add up to the profit of owner, instead it is being used to add wei in wei pool, so that , incase of emergency (extreme volatality , very biased trader positions such that contract bears net loss during funding rate etc etc) the wei pool is able to handle it.

    // receive function will be triggered when Ether is sent with no data
    receive() external payable {
        if (msg.value > 0) {
            numberOfWeiInWeiPool += int256(msg.value);
        }
    }

    // fallback function will be triggered when:
    // - A non-existent function is called
    // - Ether is sent with data
    fallback() external payable {
        if (msg.value > 0) {
            numberOfWeiInWeiPool += int256(msg.value);
        }
    }

    // withdrawNetProfit is used by owner to withdraw net profit generated by platform by collecting platform fee
    function withdrawNetProfit() external onlyBeneficiary {
        require(
            totalPlatformFeeCollected >= 0,
            "Something went wrong in perp fee collection as net fee collected is lesser than 0"
        );
        require(
            totalPlatformFeeCollected > 0,
            "No platform fee has been collected till now"
        );

        uint256 amount = uint256(totalPlatformFeeCollected);
        totalPlatformFeeCollected = 0;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Something went wrong while transferring the amount.");
    }
}
