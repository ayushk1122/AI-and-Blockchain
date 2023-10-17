// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract krisha7SimpleBank {

    mapping(address => uint256) private balances;
    address private owner;

    modifier hasEnoughBalance(uint256 _amount) {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function deposit() public payable {
        balances[msg.sender] += msg.value;
    }

    function getBalance() public view returns (uint256) {
        return balances[msg.sender];
    }

    function withdraw(uint256 _amount) public hasEnoughBalance(_amount) {
        payable(msg.sender).transfer(_amount);
        balances[msg.sender] -= _amount;
    }

    function withdrawAll() public {
        uint256 balance = balances[msg.sender];
        payable(msg.sender).transfer(balance);
        balances[msg.sender] = 0;
    }
}
