// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {EnergyToken} from "./EnergyToken.sol";
import {DeployProjectIdeas} from "./DeployProjectIdeas.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FundProjects is Ownable {
    /*//////////////////////////////////////////////////////////////
                                 ERRORS
    //////////////////////////////////////////////////////////////*/
    error FundProjects__InvalidProjectIdeasAddress();
    error FundProjects__ProjectDoesNotExist();
    error FundProjects__InvalidInvestmentAmount();
    error FundProjects__FailedToSendEther();
    error FundProjects__ExceedsFundingGoal();
    error FundProjects__NoRewardToClaim();
    error FundProjects__StakingPeriodEnded();
    error FundProjects__NoStake();

    /*//////////////////////////////////////////////////////////////
                                 STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    DeployProjectIdeas public projectIdeas;

    uint256 public constant INVESTMENT_TIME = 12 * 30 days;

    /*//////////////////////////////////////////////////////////////
                                MAPPINGS
    //////////////////////////////////////////////////////////////*/
    mapping(uint256 => mapping(address => uint256)) public projectStakes;
    mapping(uint256 => mapping(address => bool)) public projectDeposited;

    /*//////////////////////////////////////////////////////////////
                                 EVENTS
    //////////////////////////////////////////////////////////////*/
    event ProjectStakingAdded(uint256 indexed _projectId, address indexed _sender, uint256 _amount);
    event RewardClaimed(uint256 indexed _projectId, address indexed _sender, uint256 _amount);

    /*//////////////////////////////////////////////////////////////
                               FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    constructor(address _projectIdeas) Ownable(msg.sender) {
        if (_projectIdeas == address(0)) revert FundProjects__InvalidProjectIdeasAddress();
        projectIdeas = DeployProjectIdeas(_projectIdeas);
    }

    modifier projectExists(uint256 _projectId) {
        if (_projectId == 0 || _projectId > projectIdeas.s_totalProjects()) {
            revert FundProjects__ProjectDoesNotExist();
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function depositProject(uint256 _projectId) external projectExists(_projectId) {
        // check the project exists and is not funded
        if (projectIdeas.getProject(_projectId).projectStatus != DeployProjectIdeas.ProjectStatus.FUNDED) {
            revert FundProjects__ProjectDoesNotExist();
        }
        projectIdeas.safeTransferFrom(msg.sender, address(this), _projectId);
        projectDeposited[_projectId][msg.sender] = true;
    }
    /**
     * @notice Stakes in a project by selecting the projectID and the amount of ether to stake in the project.
     * @param _projectId The ID of the project to stake in.
     */

    function stakeInProject(uint256 _projectId) external payable projectExists(_projectId) {
        DeployProjectIdeas.Project memory project = projectIdeas.getProject(_projectId);

        if (msg.value < project.minInvestment || msg.value > project.maxInvestment) {
            revert FundProjects__InvalidInvestmentAmount();
        }
        if (block.timestamp > project.stakingEndTime) {
            revert FundProjects__StakingPeriodEnded();
        }
        // send the ether to the project owner
        (bool success,) = payable(project.projectOwner).call{value: msg.value}("");
        if (!success) revert FundProjects__FailedToSendEther();

        // update the staking progress
        updateStakingProgress(_projectId);

        // emit the event
        emit ProjectStakingAdded(_projectId, msg.sender, msg.value);
    }

    /**
     * @notice Updates the staking progress of a project.
     * @param _projectId The ID of the project to update.
     */
    function updateStakingProgress(uint256 _projectId) internal {
        projectStakes[_projectId][msg.sender] += msg.value;
        if (projectStakes[_projectId][msg.sender] == projectIdeas.getProject(_projectId).fundingGoal) {
            projectIdeas.updateStatus(_projectId, DeployProjectIdeas.ProjectStatus.FUNDED);
        }
    }

    function calculateReward(uint256 _projectId, address _staker) public view returns (uint256) {
        DeployProjectIdeas.Project memory project = projectIdeas.getProject(_projectId);
        uint256 stake = projectStakes[_projectId][_staker];
        uint256 timeStaked = block.timestamp - project.stakingStartTime;
        uint256 reward = (stake * project.rewardRate * timeStaked) / (INVESTMENT_TIME * 100);
        return reward;
    }

    function claimReward(uint256 _projectId) external {
        if (projectStakes[_projectId][msg.sender] == 0) revert FundProjects__NoStake();
        uint256 reward = calculateReward(_projectId, msg.sender);
        if (reward <= 0) revert FundProjects__NoRewardToClaim();

        projectStakes[_projectId][msg.sender] = 0;
        (bool success,) = payable(msg.sender).call{value: reward}("");
        if (!success) revert FundProjects__FailedToSendEther();
        emit RewardClaimed(_projectId, msg.sender, reward);
    }

    /**
     * @notice Retrieves the staking progress of a project.
     * @param _projectId The ID of the project to retrieve.
     * @return The staking progress of the project.
     */
    function getProjectStakingProgress(uint256 _projectId, address _sender) external view returns (uint256) {
        return projectStakes[_projectId][_sender];
    }
}
