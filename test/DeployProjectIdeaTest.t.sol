// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {DeployProjectIdeas} from "../src/DeployProjectIdeas.sol";

contract DeployProjectIdeasTest is Test {
    DeployProjectIdeas public deployProjectIdeas;
    address public projectOwner = makeAddr("projectOwner");

    function setUp() public {
        deployProjectIdeas = new DeployProjectIdeas(projectOwner);
    }
}
