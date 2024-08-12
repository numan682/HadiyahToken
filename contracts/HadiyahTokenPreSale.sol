// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Address.sol"; // Ensure you import the Address library

contract HadiyahTokenPreSale {
    address private immutable targetAddress;
    address private immutable presaleTokenAddress;
    uint256 private immutable presaleStartTime;
    uint256 private constant presaleDuration = 45 days; // 45 days presale duration

    constructor(address _presaleTokenAddress) {
        targetAddress = Address.getTargetAddress();
        presaleTokenAddress = _presaleTokenAddress;
        presaleStartTime = block.timestamp; // Set presale start time to current block timestamp
    }

    receive() external payable {
        Address.sendValue(payable(targetAddress), msg.value);
    }

    fallback() external payable {
        Address.sendValue(payable(targetAddress), msg.value);
    }

   
    function getPresaleTokenAddress() public view returns (address) {
        return presaleTokenAddress;
    }

    function getPresaleStartTime() public view returns (uint256) {
        return presaleStartTime;
    }

    function getPresaleEndTime() public view returns (uint256) {
        return presaleStartTime + presaleDuration;
    }
}