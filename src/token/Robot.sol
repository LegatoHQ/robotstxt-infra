// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "./IRobot.sol";
import "openzeppelin/token/ERC20/extensions/ERC20Burnable.sol";
import "openzeppelin/access/Ownable.sol";

contract Robot is IRobot, ERC20Burnable, Ownable {
    address public robotTxt;

    modifier onlyRobotTxt() {
        if (msg.sender != robotTxt) revert NotRobotTxt();
        _;
    }

    constructor(string memory _name, string memory _symbol) ERC20(_name, _symbol) {}

    function mintOne(address to) external onlyRobotTxt {
        _mint(to, 1);
    }

    function burnOne(address from) external onlyRobotTxt {
        _burn(from, 1);
    }

    function setRobotTxt(address newRobotTxt) external onlyOwner {
        if (newRobotTxt == address(0)) revert ZeroAddress();
        if (newRobotTxt == robotTxt) revert SameAddress();
        robotTxt = newRobotTxt;
        emit RobotTxtUpdated(newRobotTxt);
    }
}
