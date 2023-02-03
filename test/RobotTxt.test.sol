// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RobotTxt.sol";
import "../src/token/Robot.sol";

contract RobotTxtTest is Test {
    error NotOwner();
    error ZeroValue();
    error ZeroAddress();
    error LicenseAlreadyRegistered();
    error LicenseNotRegistered();

    event LicenseSet(address indexed _by, address indexed _for, string _licenseUri);
    event LicenseRemoved(address indexed _by, address indexed _for);

    struct LicensesData {
        uint256 count;
        address[] licenses;
        mapping(address => string) licenseUri;
    }

    RobotTxt public robotTxt;
    Robot public robotToken;

    address OWNER = address(9);
    address USER1 = address(1);
    address USER2 = address(2);

    OwnedContract public user1Owned1;
    OwnedContract public user1Owned2;
    OwnedContract public user2Owned1;

    string public constant EXAMPLE_URI = "https://example.com/robotTxt.txt";

    function setUp() public {
        vm.startPrank(OWNER);

        robotToken = new Robot("Legato Robot Token", "LRT");
        robotTxt = new RobotTxt(address(robotToken));
        robotToken.setRobotTxt(address(robotTxt));

        vm.stopPrank();

        vm.startPrank(USER1);
        user1Owned1 = new OwnedContract();
        user1Owned2 = new OwnedContract();
        vm.stopPrank();

        vm.startPrank(USER2);
        user2Owned1 = new OwnedContract();
        vm.stopPrank();
    }

    /// getDefaultLicense()

    function testGetDefaultLicense() public {
        _setupLicenses();

        string memory user1Owned1Uri = robotTxt.uris(address(user1Owned1));
        string memory user1Owned2Uri = robotTxt.uris(address(user1Owned2));

        assertEq(user1Owned1Uri, EXAMPLE_URI);
        assertEq(user1Owned2Uri, EXAMPLE_URI);
    }

    function testGetDefaultLicenseEmpty() public {
        assertEq(robotTxt.uris(address(0)), "");
        assertEq(robotTxt.uris(address(user1Owned1)), "");
    }

    /// setDefaultLicense()

    function testSetDefaultLicense() public {
        uint256 totalLicenseCountBefore = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountBefore = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenBalance = robotToken.balanceOf(USER1);

        vm.expectEmit(true, true, false, true);
        emit LicenseSet(USER1, address(user1Owned1), EXAMPLE_URI);
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(user1Owned1), EXAMPLE_URI);

        uint256 totalLicenseCountAfter = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountAfter = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenAfter = robotToken.balanceOf(USER1);

        assertEq(totalLicenseCountAfter, totalLicenseCountBefore + 1);
        assertEq(user1LicenseCountAfter, user1LicenseCountBefore + 1);
        assertEq(robotTxt.uris(address(user1Owned1)), EXAMPLE_URI);
        assertEq(user1TokenAfter, user1TokenBalance + 1);
        assertEq(robotToken.totalSupply(), 1);
    }

    function testCannotSetDefaultLicenseZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector));
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(0), EXAMPLE_URI);
    }

    function testCannotSetDefaultLicenseNotOwner() public {
        vm.expectRevert(abi.encodeWithSelector(NotOwner.selector));
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(user2Owned1), EXAMPLE_URI);
    }

    function testCannotSetDefaultLicenseNotOwnable() public {
        vm.expectRevert();
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(666), EXAMPLE_URI);
    }

    function testCannotSetDefaultLicenseLicenseAlreadyRegistered() public {
        _setupLicenses();
        vm.expectRevert(abi.encodeWithSelector(LicenseAlreadyRegistered.selector));
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(user1Owned1), EXAMPLE_URI);
    }

    /// removeDefaultLicense()

    function testRemoveDefaultLicense() public {
        _setupLicenses();

        uint256 totalLicenseCountBefore = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountBefore = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenBalance = robotToken.balanceOf(USER1);
        uint256 robotTokenSupplyBefore = robotToken.totalSupply();

        vm.prank(USER1);
        robotToken.approve(address(robotTxt), 1);

        vm.expectEmit(true, true, false, true);
        emit LicenseRemoved(USER1, address(user1Owned1));
        vm.prank(USER1);
        robotTxt.removeDefaultLicense(address(user1Owned1));

        uint256 totalLicenseCountAfter = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountAfter = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenAfter = robotToken.balanceOf(USER1);
        uint256 robotTokenSupplyAfter = robotToken.totalSupply();

        assertEq(totalLicenseCountAfter, totalLicenseCountBefore - 1);
        assertEq(user1LicenseCountAfter, user1LicenseCountBefore - 1);
        assertEq(robotTxt.uris(address(user1Owned1)), "");
        assertEq(user1TokenAfter, user1TokenBalance - 1);
        assertEq(robotTokenSupplyAfter, robotTokenSupplyBefore - 1);
    }

    function testCannotRemoveDefaultLicenseZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector));
        vm.prank(USER1);
        robotTxt.removeDefaultLicense(address(0));
    }

    function testCannotRemoveDefaultLicenseNotOwner() public {
        vm.expectRevert(abi.encodeWithSelector(NotOwner.selector));
        vm.prank(USER1);
        robotTxt.removeDefaultLicense(address(user2Owned1));
    }

    function testCannotRemoveDefaultLicenseNotRegistered() public {
        vm.expectRevert(abi.encodeWithSelector(LicenseNotRegistered.selector));
        vm.prank(USER1);
        robotTxt.removeDefaultLicense(address(user1Owned1));
    }

    /// private functions

    function _setupLicenses() private {
        assertEq(robotTxt.uris(address(user1Owned1)), "");
        assertEq(robotTxt.uris(address(user1Owned2)), "");

        vm.startPrank(USER1);

        robotTxt.setDefaultLicense(address(user1Owned1), EXAMPLE_URI);
        robotTxt.setDefaultLicense(address(user1Owned2), EXAMPLE_URI);

        vm.stopPrank();
    }
}

contract OwnedContract {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    function setOwner(address _owner) public {
        owner = _owner;
    }
}
