// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract EnergyNFT is ERC721, ERC721URIStorage, Ownable {
    uint256 private currentTokenId;
    string public baseURI;

    constructor(string memory _baseURI) ERC721("EnergyNFT", "ENFT") Ownable(msg.sender) {
        baseURI = _baseURI;
    }

    function mintNFT(address to) public onlyOwner returns (uint256) {
        uint256 newTokenId = currentTokenId;
        _safeMint(to, newTokenId);
        currentTokenId++;
        return newTokenId;
    }

    // Required overrides
    function supportsInterface(bytes4 interfaceId)
        public view override(ERC721, ERC721URIStorage) returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function tokenURI(uint256 tokenId)
        public view override(ERC721, ERC721URIStorage) returns (string memory)
    {
        return super.tokenURI(tokenId);
    }
}
