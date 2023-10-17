// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// Import ERC20 token from OpenZeppelin.
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenSale {
    ERC20 public token;
    address public owner;
    uint256 public price; // Price in wei for 1 token.

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can execute this.");
        _;
    }

    constructor(address _tokenAddress, uint256 _price) {
        require(_tokenAddress != address(0), "Token address cannot be zero address.");
        require(_price > 0, "Price should be greater than zero.");

        token = ERC20(_tokenAddress);
        owner = msg.sender;
        price = _price;
    }

    function purchase() external payable {
        uint256 amountToPurchase = msg.value / price;
        require(amountToPurchase > 0, "Insufficient ether sent.");
        require(token.balanceOf(address(this)) >= amountToPurchase, "Insufficient tokens available for sale.");

        // Transfer the tokens to the buyer.
        token.transfer(msg.sender, amountToPurchase);
    }

    function setPrice(uint256 _newPrice) external onlyOwner {
        require(_newPrice > 0, "Price should be greater than zero.");
        price = _newPrice;
    }

    function withdrawFunds() external onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
