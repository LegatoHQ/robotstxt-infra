// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

interface IRobot {
    error ZeroAddress();
    error SameAddress();
    error NotRobotTxt();

    event RobotTxtUpdated(address indexed robotTxt);

    function mintOne(address to) external;
    function burnOne(address from) external;
    function setRobotTxt(address newRobotTxt) external;
}
