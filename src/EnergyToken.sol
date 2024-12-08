// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
/**
 * @title EnergyToken - Fractional Investment Token for Renewable Energy Projects
 * @author Adam Cryptab
 * @notice This contract implements the ERC20 token used for fractional investment in renewable energy projects.
 *         Each token represents a share of ownership in a specific renewable energy project, with the token price
 *         and expected returns determined at deployment. Investors can mint tokens by sending ETH, and will be
 *         eligible for returns based on their token holdings once the project generates revenue.
 */
contract EnergyToken is ERC20, Ownable {
    error EnergyToken__InsufficientFunds();
    error EnergyToken__ZeroTokens();
    error EnergyToken__ExceedsMaxSupply();
    error EnergyToken__WithdrawalFailed();


    address public projectOwner;
    uint256 public expectedReturn;
    uint256 public totalInvestment;
    uint256 public currentTokenPrice;

    event TokensMinted(address indexed buyer, uint256 amount, uint256 cost);

    constructor(address _projectOwner, uint256 _expectedReturn, uint256 _initialPrice) ERC20("EnergyToken", "ET") Ownable(_projectOwner) {
        projectOwner = _projectOwner;
        expectedReturn = _expectedReturn;
        currentTokenPrice = _initialPrice;
    }

    /**
     * @notice Mints tokens to the caller based on the amount of ETH sent.
     * @dev The number of tokens minted is determined by the ETH sent divided by the current token price.
     *      If the ETH sent is less than the current token price, the function will revert.
     */
    function mintTokens() external payable {
        uint256 tokensToMint = msg.value / currentTokenPrice;
        if (msg.value < currentTokenPrice) {
            revert EnergyToken__InsufficientFunds();
        }

        totalInvestment += msg.value;
        _mint(msg.sender, tokensToMint);

        emit TokensMinted(msg.sender, tokensToMint, msg.value);
    }

    function withdraw() external onlyOwner {
        uint256 amount = address(this).balance;
        (bool success, ) = payable(projectOwner).call{value: amount}("");
        if (!success) revert EnergyToken__WithdrawalFailed();
    }

    receive() external payable {}
}
