// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {EnergyNFT} from "../src/EnergyNFT.sol";
import {Test, console} from "forge-std/Test.sol";

contract EnergyNFTTest is Test {
    EnergyNFT energyNFT;
    address user;
    string baseURI;

    function setUp() public {
        energyNFT = new EnergyNFT(baseURI);
        user = makeAddr("user");
        vm.deal(user, 10 ether);
    }

    function testMintNFT() public {
        vm.prank(address(this));
        energyNFT.mintNFT(user);
        assertEq(energyNFT.balanceOf(user), 1);
    }
}
