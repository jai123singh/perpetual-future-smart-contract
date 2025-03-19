// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {Perp} from "../src/Perp.sol";

contract CounterScript is Script {
    Perp public counter;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        counter = new Perp(1000000);

        vm.stopBroadcast();
    }
}
