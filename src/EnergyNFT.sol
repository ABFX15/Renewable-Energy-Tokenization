// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title EnergyNFT - Base NFT implementation for renewable energy projects
 * @author Adam Cryptab
 * @notice This contract implements the base NFT functionality for renewable energy projects.
 *         It provides minting capabilities and URI management for project NFTs.
 *         The contract is designed to work with the DeployProjectIdeas platform
 *         to enable tokenization of renewable energy initiatives.
 */
contract EnergyNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 private currentTokenId;
    string public baseURI;

    constructor(string memory _baseURI) ERC721("EnergyNFT", "ENFT") Ownable(msg.sender) {
        baseURI = _baseURI;
        currentTokenId = 1;
    }

    /**
     * @notice Mints a new NFT to the specified address.
     * @param to The address to mint the NFT to.
     * @return The ID of the newly minted NFT.
     */
    function mintNFT(address to) public onlyOwner returns (uint256) {
        uint256 newTokenId = currentTokenId;
        currentTokenId++;
        _safeMint(to, newTokenId);
        return newTokenId;
    }

    // Required overrides
    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
