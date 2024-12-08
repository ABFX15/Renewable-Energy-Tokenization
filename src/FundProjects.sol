// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

import {EnergyToken} from "./EnergyToken.sol";
import {DeployProjectIdeas} from "./DeployProjectIdeas.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract FundProjects is Ownable {
    constructor() Ownable(msg.sender) {}

    function fundProject(uint256 _projectId, uint256 _amount) external payable {}
}
