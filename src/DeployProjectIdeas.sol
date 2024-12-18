// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {ERC721Enumerable} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import {ERC721URIStorage} from "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EnergyNFT} from "./EnergyNFT.sol";

/**
 * @title DeployProjectIdeas - A decentralized platform for renewable energy project funding
 * @author Adam Cryptab
 * @notice This contract enables project owners to create renewable energy projects as NFTs.
 *         Each project is represented as a unique NFT that can be fractionalized,
 *         allowing investors to purchase shares and earn returns from the project.
 *         Project owners can create and manage their projects, while investors can
 *         buy fractions of project NFTs to participate in the returns.
 *
 * @dev The contract uses ERC721 with Enumerable and URIStorage extensions to manage
 *      project NFTs. Each NFT represents a complete project, which can then be
 *      fractionalized for investment purposes.
 */
contract DeployProjectIdeas is ERC721, ERC721Enumerable, ERC721URIStorage, Ownable {
    error DeployProjectIdeas__NotProjectOwner();
    error DeployProjectIdeas__ProjectDoesNotExist();
    error DeployProjectIdeas__InvalidProjectName();
    error DeployProjectIdeas__InvalidProjectURI();
    error DeployProjectIdeas__InvalidProjectReturns();
    error DeployProjectIdeas__MintFailed();

    uint256 public constant MIN_INVESTMENT = 0.01 ether;
    uint256 public constant MAX_INVESTMENT = 100 ether;

    uint256 public s_projectId;
    uint256 public s_totalProjects;
    address[] public s_projectOwners;
    bool public s_isProjectActive;
    EnergyNFT public energyNFT;
    address public energyNFTAddress;

    struct Project {
        address projectOwner;
        string projectName;
        string projectURI;
        uint256 projectId;
        uint256 projectReturns;
        uint256 fundingGoal;
        uint256 totalStaked;
        uint256 stakingStartTime;
        uint256 stakingEndTime;
        uint256 rewardRate;
        uint256 tokenId;
        ProjectStatus projectStatus;
        uint256 minInvestment;
        uint256 maxInvestment;
    }

    mapping(uint256 => Project) public projects;

    enum ProjectStatus {
        ACTIVE,
        STAKING,
        FUNDED,
        COMPLETED
    }

    event ProjectCreated(
        uint256 indexed projectId,
        address indexed projectOwner,
        string projectName,
        string projectURI,
        uint256 projectReturns
    );

    constructor(address _projectOwner, address _energyNFT)
        ERC721("ProjectIdeas", "PID")
        ERC721Enumerable()
        ERC721URIStorage()
        Ownable(_projectOwner)
    {
        s_projectId = 0;
        s_totalProjects = 0;
        s_isProjectActive = true;
        s_projectOwners.push(_projectOwner);
        energyNFTAddress = _energyNFT;
        energyNFT = EnergyNFT(_energyNFT);
    }

    modifier onlyProjectOwner(uint256 _projectId) {
        if (projects[_projectId].projectOwner != msg.sender) {
            revert DeployProjectIdeas__NotProjectOwner();
        }
        _;
    }

    modifier validateProjectCreation(string memory _projectName, string memory _projectURI, uint256 _projectReturns) {
        if (bytes(_projectName).length == 0) revert DeployProjectIdeas__InvalidProjectName();
        if (bytes(_projectURI).length == 0) revert DeployProjectIdeas__InvalidProjectURI();
        if (_projectReturns == 0) revert DeployProjectIdeas__InvalidProjectReturns();
        _;
    }

    struct ProjectCreationParams {
        string projectName;
        string projectURI;
        uint256 projectReturns;
        uint256 fundingGoal;
        uint256 stakingDuration;
        uint256 rewardRate;
    }

    /**
     * @notice Creates a new renewable energy project as an NFT.
     * @param params The parameters for creating a project.
     */
    function createProject(ProjectCreationParams memory params)
        external
        validateProjectCreation(params.projectName, params.projectURI, params.projectReturns)
    {
        uint256 newProjectId = ++s_projectId;
        uint256 tokenId = energyNFT.mintNFT(msg.sender);
        if (tokenId == 0) revert DeployProjectIdeas__MintFailed();

        projects[newProjectId] = Project({
            projectOwner: msg.sender,
            projectName: params.projectName,
            projectURI: params.projectURI,
            projectId: newProjectId,
            projectReturns: params.projectReturns,
            fundingGoal: params.fundingGoal,
            totalStaked: 0,
            stakingStartTime: block.timestamp,
            stakingEndTime: block.timestamp + params.stakingDuration,
            rewardRate: params.rewardRate,
            tokenId: tokenId,
            projectStatus: ProjectStatus.ACTIVE,
            minInvestment: MIN_INVESTMENT,
            maxInvestment: MAX_INVESTMENT
        });

        s_totalProjects++;

        emit ProjectCreated(newProjectId, msg.sender, params.projectName, params.projectURI, params.projectReturns);
    }

    /**
     * @notice Updates the status of a project.
     * @param _projectId The ID of the project to update.
     * @param _projectStatus The new status of the project.
     */
    function updateStatus(uint256 _projectId, ProjectStatus _projectStatus) external onlyProjectOwner(_projectId) {
        projects[_projectId].projectStatus = _projectStatus;
    }

    /**
     * @notice Retrieves information about a specific project.
     * @param _projectId The ID of the project to retrieve.
     * @return A Project struct containing the project's details.
     */
    function getProject(uint256 _projectId) external view returns (Project memory) {
        return projects[_projectId];
    }

    /**
     * @notice Retrieves all projects created by a specific owner.
     * @param _projectOwner The address of the project owner.
     * @return An array of Project structs containing the projects' details.
     */
    function getProjectsByOwner(address _projectOwner) external view returns (Project[] memory) {
        // Create a dynamic array with maximum possible size
        Project[] memory projectsByOwner = new Project[](s_totalProjects);
        uint256 currentIndex = 0;

        // Single loop through all projects
        for (uint256 i = 1; i <= s_totalProjects; i++) {
            if (projects[i].projectOwner == _projectOwner) {
                projectsByOwner[currentIndex] = projects[i];
                currentIndex++;
            }
        }

        // Create final array with exact size
        Project[] memory result = new Project[](currentIndex);
        for (uint256 i = 0; i < currentIndex; i++) {
            result[i] = projectsByOwner[i];
        }

        return result;
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
