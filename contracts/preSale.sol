// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TokenPresale {
    IERC20 public token;
    address public owner;
    uint256 public rate; // Number of tokens per ETH
    uint256 public startTime;
    uint256 public endTime;

    event TokensPurchased(address indexed buyer, uint256 amount);

    constructor(address tokenAddress) {
        token = IERC20(tokenAddress);
        owner = msg.sender;
        rate = 1000; // Example: 1000 tokens per 1 ETH
        startTime = block.timestamp; // Presale starts immediately
        endTime = block.timestamp + 30 days; // Presale ends in 30 days
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier isPresaleActive() {
        require(block.timestamp >= startTime && block.timestamp <= endTime, "Presale is not active");
        _;
    }

    function buyTokens() public payable isPresaleActive {
        uint256 tokenAmount = msg.value * rate;
        require(token.balanceOf(address(this)) >= tokenAmount, "Not enough tokens in the contract");
        
        token.transfer(msg.sender, tokenAmount);
        emit TokensPurchased(msg.sender, tokenAmount);
    }

    function endPresale() public onlyOwner {
        require(block.timestamp > endTime, "Presale period has not ended");
        
        // Transfer remaining tokens back to the owner
        uint256 remainingTokens = token.balanceOf(address(this));
        if (remainingTokens > 0) {
            token.transfer(owner, remainingTokens);
        }
        
        // Transfer raised funds to the owner
        payable(owner).transfer(address(this).balance);
    }
}