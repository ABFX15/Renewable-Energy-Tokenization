# Renewable Energy Project NFT Platform 🌱⚡

A decentralized platform enabling renewable energy project funding through NFT fractionalization.

## Overview

This platform allows renewable energy project owners to tokenize their projects as NFTs and enables investors to purchase fractions of these projects. By bridging the gap between renewable energy initiatives and decentralized finance, we're making green energy investment more accessible and efficient.

## Key Features

- **Project NFT Creation**: Project owners can create NFTs representing their renewable energy projects
- **Project Management**: Owners can update project status and manage project details
- **Transparent Tracking**: All project information is stored on-chain for maximum transparency
- **Fractional Investment** (Coming Soon): Investors will be able to purchase fractions of project NFTs
- **Return Distribution** (Coming Soon): Automated distribution of project returns to fractional owners

## Smart Contracts

### DeployProjectIdeas.sol
- Main contract for project NFT creation and management
- Handles project lifecycle and ownership
- Implements ERC721 with Enumerable and URIStorage extensions

### EnergyNFT.sol
- Base NFT implementation for energy projects
- Handles token minting and URI management

### Investment Contract (Coming Soon)
- Will handle fractional ownership of project NFTs
- Will manage investment limits and return distribution
- Will implement automated dividend distribution to investors

## Technical Details

- Built with Solidity ^0.8.22
- Uses OpenZeppelin contracts for secure implementation
- Implements ERC721 standard with additional extensions
- Comprehensive testing suite using Forge

## Getting Started

1. Clone the repository

