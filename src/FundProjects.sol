// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {EnergyToken} from "./EnergyToken.sol";
import {DeployProjectIdeas} from "./DeployProjectIdeas.sol";
import {ProjectVault} from "./ProjectVault.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FundProjects is Ownable {
    error FundProjects__ProjectDoesNotExist();
    error FundProjects__InvalidInvestmentAmount();
    error FundProjects__FailedToSendEther();
    error FundProjects__ExceedsFundingGoal();

    DeployProjectIdeas public projectIdeas;
    ProjectVault public projectVault;

    mapping(uint256 => uint256) public projectFundingProgress;

    event ProjectFundingAdded(uint256 indexed _projectId, address indexed _sender, uint256 _amount);

    constructor(address _projectIdeas, address _projectVault) Ownable(msg.sender) {
        projectIdeas = DeployProjectIdeas(_projectIdeas);
        projectVault = ProjectVault(_projectVault);
    }

    function fundProject(uint256 _projectId, uint256 _amount) external payable {
        if (msg.value != _amount) revert FundProjects__InvalidInvestmentAmount();
        
        // select a project
        DeployProjectIdeas.Project memory project = projectIdeas.getProject(_projectId);

        if (project.projectOwner == address(0)) revert FundProjects__ProjectDoesNotExist();

        if (_amount < project.minInvestment || _amount > project.maxInvestment) revert FundProjects__InvalidInvestmentAmount();
        (bool success, ) = payable(project.projectOwner).call{value: _amount}("");
        if (!success) revert FundProjects__FailedToSendEther();

        uint256 newFundedAmount = projectFundingProgress[_projectId] + _amount;
        projectFundingProgress[_projectId] = newFundedAmount;

        if (newFundedAmount == project.projectReturns) {
            projectIdeas.updateStatus(_projectId, DeployProjectIdeas.ProjectStatus.FUNDED);
            projectVault.fractionalize(_projectId, _amount, project.projectReturns);
        } else {
            if (newFundedAmount > projectIdeas.getProject(_projectId).fundingGoal) revert FundProjects__ExceedsFundingGoal();
        }

        emit ProjectFundingAdded(_projectId, msg.sender, _amount);
    }
}
