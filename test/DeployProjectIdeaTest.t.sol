// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {DeployProjectIdeas} from "../src/DeployProjectIdeas.sol";

contract DeployProjectIdeasTest is Test {
    DeployProjectIdeas public projectIdeas;
    address public projectOwner = makeAddr("projectOwner");

    function setUp() public {
        projectIdeas = new DeployProjectIdeas(projectOwner, address(this));
    }

    function testCanCreateProject() public {
        vm.prank(projectOwner);
    }
}
