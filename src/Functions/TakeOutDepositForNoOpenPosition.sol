// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import "../StateVariables.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract TakeOutDepositForNoOpenPosition is StateVariables {
    // takeOutDepositForNoOpenPosition function lets users withdraw their deposits when they have no open position using takeOutDeposit function
    function takeOutDepositForNoOpenPosition(
        address traderAddress,
        int256 amountToBeWithdrawn
    ) internal {
        // Check the validity of amount to be withdrawn
        require(
            amountToBeWithdrawn > 0 &&
                amountToBeWithdrawn <= traderDepositHashmap[traderAddress],
            string(
                abi.encodePacked(
                    "The amount that you can withdraw is 0 to ",
                    Strings.toString(
                        uint256(traderDepositHashmap[traderAddress])
                    ),
                    ", but you are requesting to withdraw: ",
                    Strings.toString(uint256(amountToBeWithdrawn))
                )
            )
        );

        // All checks are done

        // Give the trader their deposit and update wei pool & deposit hashmap
        (bool success, ) = payable(traderAddress).call{
            value: uint256(amountToBeWithdrawn)
        }("");
        require(success, "Transfer failed");

        numberOfWeiInWeiPool -= amountToBeWithdrawn;
        traderDepositHashmap[traderAddress] -= amountToBeWithdrawn;
    }
}
