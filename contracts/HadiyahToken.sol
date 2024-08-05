// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract HadiyahToken is ERC20, Ownable {
    uint256 public tokenPriceInINR; // Price of one token in INR (Indian Rupees)
    address internal immutable developerAddress;
    address internal immutable liquidityAddress;
    address internal immutable marketingAddress;

    constructor(
    string memory tokenName,
    string memory tokenSymbol,
    uint256 totalSupply,
    address tokenOwnerAddress,
    address _developerAddress,
    address _liquidityAddress,
    address _marketingAddress,
    uint256 _tokenPriceInINR
) ERC20(tokenName, tokenSymbol) Ownable(tokenOwnerAddress)  {
        developerAddress = _developerAddress;
        liquidityAddress = _liquidityAddress;
        marketingAddress = _marketingAddress;
        tokenPriceInINR = _tokenPriceInINR;

        // Mint the initial supply to the token owner
        _mint(tokenOwnerAddress, totalSupply);
    }

    function initializeLiquidity(uint256 liquidityAmount) public onlyOwner {
        // Add tokens to the liquidity pool
        transfer(liquidityAddress, liquidityAmount * 10 ** decimals());
    }

    function setTokenPriceInINR(uint256 newPrice) public onlyOwner {
        tokenPriceInINR = newPrice;
    }

    function buyTokens() public payable {
        require(msg.value > 0, "Send ETH to buy tokens");

        uint256 tokensToBuy = (msg.value * tokenPriceInINR) / 10**18; // Adjust for decimals
        require(tokensToBuy <= balanceOf(address(this)), "Not enough tokens in the reserve");

        transfer(msg.sender, tokensToBuy);
    }

    function burn(uint256 value) public {
        _burn(msg.sender, value);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal   {
        require(from!= address(0), "ERC20: transfer from the zero address");
        require(to!= address(0), "ERC20: transfer to the zero address");

        uint256 developerFee = (amount * 5) / 100; // 5% developer fee
        uint256 liquidityFee = (amount * 5) / 100; // 5% liquidity fee
        uint256 marketingFee = (amount * 5) / 100; // 5% marketing fee
        uint256 burnFee = (amount * 1) / 100; // 1% burn fee


        if (developerFee > 0) {
            _transfer(from, developerAddress, developerFee);
        }
        if (liquidityFee > 0) {
            _transfer(from, liquidityAddress, liquidityFee);
        }
        if (marketingFee > 0) {
            _transfer(from, marketingAddress, marketingFee);
        }
        if (burnFee > 0) {
            _burn(from, burnFee);
        }
    }

    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, allowance(msg.sender, spender) + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        uint256 currentAllowance = allowance(msg.sender, spender);
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(msg.sender, spender, currentAllowance - subtractedValue);
        return true;
    }
}
