// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTDutchAuction is ERC721Enumerable, Ownable {
    using SafeMath for uint256;

    uint256 public auctionTokenId;
    uint256 public startPrice;
    uint256 public endPrice;
    uint256 public duration;
    uint256 public startTime;
    uint256 public priceDropInterval;

    bool public auctionStarted = false;

    constructor() ERC721("DutchAuctionNFT", "DANFT") {}

    function mintNFT() external onlyOwner {
        uint256 tokenId = totalSupply() + 1;
        _mint(owner(), tokenId);
        auctionTokenId = tokenId;
    }

    function startAuction(
        uint256 _startPrice,
        uint256 _endPrice,
        uint256 _duration
    ) external onlyOwner {
        require(!auctionStarted, "Auction already started");
        require(auctionTokenId != 0, "No NFT available for auction");

        startPrice = _startPrice;
        endPrice = _endPrice;
        duration = _duration;
        startTime = block.timestamp;
        priceDropInterval = duration.div(startPrice.sub(endPrice));
        auctionStarted = true;
    }

    function getCurrentPrice() public view returns (uint256) {
        require(auctionStarted, "Auction hasn't started yet");
        uint256 elapsedTime = block.timestamp - startTime;
        if (elapsedTime >= duration) {
            return endPrice;
        }
        uint256 priceDrop = (startPrice - endPrice).mul(elapsedTime).div(duration);
        return startPrice.sub(priceDrop);
    }

    function buyNow() external payable {
        require(auctionStarted, "Auction hasn't started yet");
        require(block.timestamp <= startTime + duration, "Auction is over");
        require(msg.value == getCurrentPrice(), "Incorrect ether sent");

        // Transfer ownership of the NFT.
        _transfer(owner(), msg.sender, auctionTokenId);

        // Transfer the bid amount to the owner.
        payable(owner()).transfer(msg.value);

        // End the auction.
        auctionStarted = false;
    }
}
