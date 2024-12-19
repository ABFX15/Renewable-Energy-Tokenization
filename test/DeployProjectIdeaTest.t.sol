// SPDX-License-Identifier: MIT
pragma solidity ^0.8.22;

import {Test, console} from "forge-std/Test.sol";
import {DeployProjectIdeas} from "../src/DeployProjectIdeas.sol";
import {EnergyNFT} from "../src/EnergyNFT.sol";

contract DeployProjectIdeasTest is Test {
    DeployProjectIdeas public projectIdeas;
    address public projectOwner = makeAddr("projectOwner");
    EnergyNFT public energyNFT;

    function setUp() public {
        energyNFT = new EnergyNFT("test");
        projectIdeas = new DeployProjectIdeas(projectOwner, address(energyNFT));

        vm.prank(projectOwner);
        uint256 tokenId = energyNFT.mintNFT(projectOwner);
        console.log("NFT tokenId:", tokenId);
        console.log("NFT balance:", energyNFT.balanceOf(projectOwner));
    }

    function testCanCreateProject() public {
        vm.prank(projectOwner);
        DeployProjectIdeas.ProjectCreationParams memory params = DeployProjectIdeas.ProjectCreationParams({
            projectName: "Test Project",
            projectURI: "https://test.com/test",
            projectReturns: 10,
            fundingGoal: 100,
            stakingDuration: 100,
            rewardRate: 10
        });
        projectIdeas.createProject(params);

        DeployProjectIdeas.Project memory project = projectIdeas.getProject(1);
        assertEq(project.projectName, "Test Project");
        assertEq(project.projectURI, "https://test.com/test");
        assertEq(project.projectReturns, 10);
        assertEq(project.fundingGoal, 100);
        assertEq(project.stakingStartTime, block.timestamp);
        assertEq(project.stakingEndTime, block.timestamp + 100);
        assertEq(project.rewardRate, 10);
    }
}
