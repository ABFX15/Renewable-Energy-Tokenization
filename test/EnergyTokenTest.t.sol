// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {EnergyToken} from "../src/EnergyToken.sol";
import {Test, console} from "forge-std/Test.sol";

contract EnergyTokenTest is Test {
    EnergyToken public energyToken;
    address public user;
    address public user2;
    uint256 public constant INITIAL_DEPOSIT_PRICE = 1e18; // 1 ETH
    uint256 public constant EXPECTED_RETURN = 10; // 10%
    uint256 public constant INSUFFICIENT_FUNDS = 0.001 ether;

    event TokensMinted(address indexed buyer, uint256 amount, uint256 cost);

    function setUp() public {
        user = makeAddr("user");
        user2 = makeAddr("user2");
        vm.deal(user, 10 ether);
        energyToken = new EnergyToken(user, EXPECTED_RETURN, INITIAL_DEPOSIT_PRICE);
    }

    function testMintingTokens() public {
        vm.prank(user);
        energyToken.mintTokens{value: INITIAL_DEPOSIT_PRICE}();
        assertEq(energyToken.balanceOf(user), 1);
        console.log('total supply: %s', energyToken.totalSupply());
        console.log('Tokens minted: %s', energyToken.balanceOf(user));
    }

    function testEmitsTokensMinted() public {
        vm.expectEmit(true, true, false, true);
        emit TokensMinted(user, 1, INITIAL_DEPOSIT_PRICE);
        vm.prank(user);
        energyToken.mintTokens{value: INITIAL_DEPOSIT_PRICE}();
    }

    function testRevertsIfInsufficientFunds() public {
        vm.prank(user2);
        vm.deal(user2, INSUFFICIENT_FUNDS);
        vm.expectRevert(EnergyToken.EnergyToken__InsufficientFunds.selector);
        energyToken.mintTokens{value: INSUFFICIENT_FUNDS}();
        assertEq(energyToken.balanceOf(user2), 0);
    }

}