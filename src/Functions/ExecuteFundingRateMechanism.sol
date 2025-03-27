// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../StateVariables.sol";
import "./FundingRateMechanism.sol";
import "../Modifiers.sol";

contract ExecuteFundingRateMechanism is
    StateVariables,
    FundingRateMechanism,
    Modifiers
{
    // this function can be exclusively called by backend to intitiate funding rate mechanism
    function executeFundingRateMechanism() external onlyBackend {
        // we are using 15 second buffer period to account for inaccuracy of block.timestamp
        if ((int256(block.timestamp) + 15 seconds) >= nextFundingTime) {
            fundingRateMechanism();
        }
    }
}
