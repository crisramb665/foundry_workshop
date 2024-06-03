// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4; //Do not change the solidity version as it negativly impacts submission grading

import {ExampleExternalContract} from "./ExampleExternalContract.sol";
import {Owned} from "solmate/auth/Owned.sol";

contract Staker is
    Owned //2
{
    ExampleExternalContract public exampleExternalContract;

    uint256 public threshold = 2 ether;
    uint256 public deadline = block.timestamp + 96 hours;

    mapping(address => uint256) public balances;

    event Stake(address caller, uint256 amount);

    modifier deadlineReached(bool executed) {
        uint256 timeRemaining = timeLeft();
        if (executed) {
            require(timeRemaining == 0, "El deadline no ha pasado");
        } else {
            require(timeRemaining > 0, "Ya se acabo el tiempo");
        }
        _;
    }

    modifier stakeNotCompleted() {
        bool completed = exampleExternalContract.completed();
        require(
            completed == false,
            "el tiempo para hacer el stake ya se ha completado"
        );
        _;
    }

    constructor(address owner, address exampleExternalContractAddress)
        Owned(owner)
    {
        exampleExternalContract =
            ExampleExternalContract(exampleExternalContractAddress);
    }

    // Only owner can make this update!
    function updateThreshold(uint256 _newThreshold)
        public
        onlyOwner
        returns (bool)
    {
        threshold = _newThreshold;
        return true;
    }

    function updateDeadline(uint256 _newDeadline)
        public
        onlyOwner
        returns (bool)
    {
        deadline = _newDeadline;
        return true;
    }

    // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
    // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
    function stake() public payable deadlineReached(false) {
        balances[msg.sender] += msg.value;
        emit Stake(msg.sender, msg.value);
    }

    function execute() public payable deadlineReached(false) {
        uint256 contractBalance = address(this).balance;
        require(contractBalance >= threshold, "No se ha alcanzado el threshold");

        (bool success,) = address(exampleExternalContract).call{
            value: contractBalance
        }(abi.encodeWithSignature("complete()"));
        require(success, "Transaccion no exitosa");
    }

    // After some `deadline` allow anyone to call an `execute()` function
    // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`

    // If the `threshold` was not met, allow everyone to call a `withdraw()` function to withdraw their balance
    function withdraw()
        public
        payable
        deadlineReached(true)
        stakeNotCompleted
    {
        uint256 userBalance = balances[msg.sender];
        require(userBalance > 0, "No tienes balance");

        balances[msg.sender] = 0;
        (bool success,) = msg.sender.call{value: userBalance}("");

        require(success, "Retiro fallido");
    }

    // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
    function timeLeft() public view returns (uint256) {
        if (block.timestamp < deadline) {
            return deadline - block.timestamp;
        } else {
            return 0;
        }
    }

    // Add the `receive()` special function that receives eth and calls stake()
    receive() external payable {}
}
