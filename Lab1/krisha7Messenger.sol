// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract krisha7Messenger {

    string public message;
    uint256 public changeCounter = 0;
    address private owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can update the message");
        _;
    }

    constructor(string memory _initialMessage) {
        message = _initialMessage;
        owner = msg.sender;
    }

    function updateMessage(string memory _newMessage) public onlyOwner {
        message = _newMessage;
        changeCounter += 1;
    }
}
