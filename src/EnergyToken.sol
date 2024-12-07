// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract EnergyToken is ERC20 {
    error EnergyToken__InsufficientFunds();
    error EnergyToken__ZeroTokens();
    error EnergyToken__ExceedsMaxSupply();

    event TokensMinted(address indexed buyer, uint256 amount, uint256 cost);

    address public projectOwner;
    uint256 public expectedReturn;
    uint256 public totalInvestment;
    uint256 public currentTokenPrice;

    constructor(
        address _projectOwner, 
        uint256 _expectedReturn, 
        uint256 _initialPrice
    ) ERC20("EnergyToken", "ET") {
        projectOwner = _projectOwner;
        expectedReturn = _expectedReturn;
        currentTokenPrice = _initialPrice;
    }

    function mintTokens() external payable {
        uint256 tokensToMint = msg.value / currentTokenPrice;
        if (msg.value < currentTokenPrice) {
            revert EnergyToken__InsufficientFunds();
        }

        totalInvestment += msg.value;
        _mint(msg.sender, tokensToMint);

        emit TokensMinted(msg.sender, tokensToMint, msg.value);
    }
}