// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {Staker} from "../src/Staker.sol";
import {ExampleExternalContract} from "../src/ExampleExternalContract.sol";

contract StakerDeploy is Script {
    function run() public {
        vm.startBroadcast();

        address owner = vm.envAddress("OWNER");

        ExampleExternalContract exContract = new ExampleExternalContract();
        console.log("External contract deployed at: ", address(exContract));
        
        Staker staker = new Staker(owner, address(exContract));
        console.log("Staker contract deployed at: ", address(staker));

        vm.stopBroadcast();
    }
}
