// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/token/Robot.sol";

contract RobotTxtTest is Test {
    error ZeroAddress();
    error SameAddress();
    error NotRobotTxt();

    event RobotTxtUpdated(address indexed robotTxt);

    Robot public robotToken;

    address OWNER = address(9);
    address USER1 = address(1);
    address ROBOT_TXT = address(2);

    function setUp() public {
        vm.startPrank(OWNER);
        robotToken = new Robot("Legato Robot Token", "LRT");
        robotToken.setRobotTxt(ROBOT_TXT);
        vm.stopPrank();
    }

    /// mintOne()

    function testMintOne() public {
        uint256 user1BalanceBefore = robotToken.balanceOf(USER1);
        uint256 robotTokenSupplyBefore = robotToken.totalSupply();

        vm.prank(ROBOT_TXT);
        robotToken.mintOne(USER1);

        uint256 user1BalanceAfter = robotToken.balanceOf(USER1);
        uint256 robotTokenSupplyAfter = robotToken.totalSupply();

        assertEq(user1BalanceAfter, user1BalanceBefore + 1);
        assertEq(robotTokenSupplyAfter, robotTokenSupplyBefore + 1);
    }

    function testCannotMintOneNotRobotTxt() public {
        vm.expectRevert(abi.encodeWithSelector(NotRobotTxt.selector));
        robotToken.mintOne(USER1);
    }

    /// burnOne()

    function testBurnOne() public {
        testMintOne();

        uint256 user1BalanceBefore = robotToken.balanceOf(USER1);
        uint256 robotTokenSupplyBefore = robotToken.totalSupply();

        vm.prank(USER1);
        robotToken.approve(ROBOT_TXT, 1);

        vm.prank(ROBOT_TXT);
        robotToken.burnOne(USER1);

        uint256 user1BalanceAfter = robotToken.balanceOf(USER1);
        uint256 robotTokenSupplyAfter = robotToken.totalSupply();

        assertEq(user1BalanceAfter, user1BalanceBefore - 1);
        assertEq(robotTokenSupplyAfter, robotTokenSupplyBefore - 1);
    }

    function testCannotBurnOneNotRobotTxt() public {
        vm.expectRevert(abi.encodeWithSelector(NotRobotTxt.selector));
        robotToken.burnOne(USER1);
    }

    /// setRobotTxt()

    function testSetRobotTxt() public {
        vm.expectEmit(true, false, false, true);
        emit RobotTxtUpdated(USER1);
        vm.prank(OWNER);
        robotToken.setRobotTxt(USER1);

        assertEq(robotToken.robotTxt(), USER1);
    }

    function testCannotSetRobotTxtNotOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        robotToken.setRobotTxt(USER1);
    }

     function testCannotSetRobotTxtZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector));
        vm.prank(OWNER);
        robotToken.setRobotTxt(address(0));
    }

    function testCannotSetRobotTxtSameAddress() public {
        vm.expectRevert(abi.encodeWithSelector(SameAddress.selector));
        vm.prank(OWNER);
        robotToken.setRobotTxt(ROBOT_TXT);
    }
}
