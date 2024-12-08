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

    uint256 public s_projectId;
    uint256 public s_totalProjects;
    address[] public s_projectOwners;
    bool public s_isProjectActive;
    EnergyNFT public energyNFT;

    uint256 public constant MIN_INVESTMENT = 1e18;
    uint256 public constant MAX_INVESTMENT = 100e18;

    struct Project {
        address projectOwner;
        string projectName;
        string projectURI;
        uint256 projectId;
        uint256 minInvestment;
        uint256 maxInvestment;
        uint256 projectReturns;
        ProjectStatus projectStatus;
    }

    mapping(uint256 => Project) public projects;

    enum ProjectStatus {
        ACTIVE,
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

    /**
     * @notice Creates a new renewable energy project as an NFT.
     * @param _projectName The name of the project.
     * @param _projectURI The URI of the project.
     * @param projectReturns The returns of the project.
     */
    function createProject(string memory _projectName, string memory _projectURI, uint256 projectReturns)
        external
        validateProjectCreation(_projectName, _projectURI, projectReturns)
    {
        s_projectId++;
        uint256 newProjectId = s_projectId;

        Project memory newProject = Project({
            projectOwner: msg.sender,
            projectName: _projectName,
            projectURI: _projectURI,
            projectId: newProjectId,
            minInvestment: MIN_INVESTMENT,
            maxInvestment: MAX_INVESTMENT,
            projectReturns: projectReturns,
            projectStatus: ProjectStatus.ACTIVE
        });
        projects[newProjectId] = newProject;
        s_totalProjects++;
        s_projectOwners.push(msg.sender);
        energyNFT.mintNFT(msg.sender);

        emit ProjectCreated(newProjectId, msg.sender, _projectName, _projectURI, projectReturns);
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
        uint256 ownerProjectCount = 0;
        for (uint256 i = 1; i <= s_totalProjects; i++) {
            if (projects[i].projectOwner == _projectOwner) {
                ownerProjectCount++;
            }
        }

        Project[] memory projectsByOwner = new Project[](ownerProjectCount);
        uint256 currentIndex = 0;

        for (uint256 i = 1; i <= s_totalProjects; i++) {
            if (projects[i].projectOwner == _projectOwner) {
                projectsByOwner[currentIndex] = projects[i];
                currentIndex++;
            }
        }

        return projectsByOwner;
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
