// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;
import {EnergyNFT} from "./EnergyNFT.sol";
import {EnergyToken} from "./EnergyToken.sol";

contract ProjectVault {
    EnergyNFT public nft;

    mapping(uint256 => EnergyToken) public projectTokens;  // NFT ID => ERC20 token
    uint256 public constant PRECISION_FACTOR = 1e18;

    function fractionalize(
        uint256 nftId, 
        uint256 investmentAmount,
        uint256 pricePerShare
    ) external {
        uint256 shares = (investmentAmount * PRECISION_FACTOR) / pricePerShare;
        
        // Create new ERC20 token for shares
        EnergyToken newToken = new EnergyToken(
            msg.sender,           // project owner
            shares,              // total supply based on investment
            pricePerShare       // price per token
        );

        projectTokens[nftId] = newToken;
        
        // Mint initial tokens to the investor (msg.sender from FundProjects)
        newToken.mintTokens{value: investmentAmount}();
    }

    function buyShares(uint256 nftId) external payable {
        EnergyToken token = projectTokens[nftId];
        require(address(token) != address(0), "Project not fractionalized");
        token.mintTokens{value: msg.value}();
    }
} 