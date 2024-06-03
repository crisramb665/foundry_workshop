// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import {ExampleExternalContract} from "../src/ExampleExternalContract.sol";
import {Staker} from "../src/Staker.sol";

contract StakerTest is
    Test //3
{
    address owner = address(0xABC);

    ExampleExternalContract public exContract;
    Staker public staker;

    function setUp() public {
        exContract = new ExampleExternalContract();
        staker = new Staker(owner, address(exContract));

        vm.startPrank(owner);
        staker.updateDeadline(1 days);
        vm.stopPrank();
    }

    function testSuccess_UpdateThreshold() public {
        uint256 currentThreshold = staker.threshold();
        assertEq(currentThreshold, 2 ether);

        uint256 newThreshold = 5 ether;

        vm.startPrank(owner);
        bool result = staker.updateThreshold(newThreshold);
        assertEq(result, true);
        assertEq(staker.threshold(), newThreshold);
    }

    function testSuccess_Stake() public {
        address userA = address(0xFFF);
        vm.deal(userA, 1 ether);

        uint256 amountToStake = 1 ether / 2;
        console.log(amountToStake);

        uint256 prevUserBalanceA = staker.balances(userA);
        assertEq(prevUserBalanceA, uint256(0));

        vm.startPrank(userA);
        (bool success,) = payable(address(staker)).call{value: amountToStake}(
            abi.encodeWithSignature("stake()")
        );
        assertEq(success, true);
        assertEq(staker.balances(userA), amountToStake);
    }

    function testFail_Withdraw_UserNoBalanceInContract() public {
        address userB = address(0x123456);
        // uint256 amountToWithdraw = 1 ether;
        uint256 deadlineReached = staker.deadline() + 1;

        vm.warp(deadlineReached);

        vm.startPrank(userB);
        // vm.expectRevert(bytes("No tienes balance"));
        (bool success,) =
            payable(address(staker)).call(abi.encodeWithSignature("withdraw()"));
        assert(!success);
        assertTrue(success, "No tienes balance");
    }

    function testSuccess_Execute() public {
        vm.deal(address(staker), 2.5 ether);
        uint256 stakerBalance = address(staker).balance;
        console.log(stakerBalance);
        console.log(block.timestamp);

        uint256 externalContractBalance = address(exContract).balance;
        assertEq(externalContractBalance, uint256(0));

        staker.execute();
        assertEq(address(staker).balance, uint256(0));
        assertEq(address(exContract).balance, stakerBalance);

        bool completed = exContract.completed();
        assertEq(completed, true);
    }

    function testFuzzSuccess_UpdateThreshold(uint256 _newThreshold) public {
        uint256 currentThreshold = staker.threshold();
        assertEq(currentThreshold, 2 ether);

        vm.startPrank(owner);
        staker.updateThreshold(_newThreshold);
        uint256 postThreshold = staker.threshold();
        assertEq(postThreshold, _newThreshold);
    }
}
