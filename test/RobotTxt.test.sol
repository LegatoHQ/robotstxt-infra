// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RobotTxt.sol";
import "../src/token/Robot.sol";

contract RobotTxtTest is Test {
    error NotOwner();
    error ZeroValue();
    error ZeroAddress();
    error LicenseNotRegistered();
    error AlreadyWhitelisted();
    error NotWhitelisted();

    event LicenseSet(address indexed _by, address indexed _for, string _licenseUri, string _info);
    event LicenseRemoved(address indexed _by, address indexed _for);
    event ContractWhitelisted(address indexed owner, address indexed contractAddress);
    event ContractDelisted(address indexed owner, address indexed contractAddress);

    struct LicenseData {
        string uri;
        string info;
    }

    RobotTxt public robotTxt;
    Robot public robotToken;

    address OWNER = address(9);
    address USER1 = address(1);
    address USER2 = address(2);

    OwnedContract public user1Owned1;
    OwnedContract public user1Owned2;
    OwnedContract public user2Owned1;
    NotOwnedContract public user1NotOwned1;

    string public constant EXAMPLE_URI = "https://example.com/robotTxt.txt";
    string public constant EXAMPLE_URI2 = "https://example.com/robotTxt1.txt";
    string public constant EXAMPLE_INFO = "https://info.com/robotTxt.txt";
    string public constant EXAMPLE_INFO2 = "https://info.com/robotTxt1.txt";

    function setUp() public {
        vm.startPrank(OWNER);

        robotToken = new Robot("Legato Robot Token", "LRT");
        robotTxt = new RobotTxt(address(robotToken));
        robotToken.setRobotTxt(address(robotTxt));

        vm.stopPrank();

        vm.startPrank(USER1);
        user1Owned1 = new OwnedContract();
        user1Owned2 = new OwnedContract();
        user1NotOwned1 = new NotOwnedContract();
        vm.stopPrank();

        vm.startPrank(USER2);
        user2Owned1 = new OwnedContract();
        vm.stopPrank();
    }

    /// setDefaultLicense()

    function testSetDefaultLicenseOwned() public {
        uint256 totalLicenseCountBefore = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountBefore = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenBalance = robotToken.balanceOf(USER1);

        vm.expectEmit(true, true, false, true);
        emit LicenseSet(USER1, address(user1Owned1), EXAMPLE_URI, EXAMPLE_INFO);
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(user1Owned1), EXAMPLE_URI, EXAMPLE_INFO);

        uint256 totalLicenseCountAfter = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountAfter = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenAfter = robotToken.balanceOf(USER1);
        (string memory uri, string memory info) = robotTxt.licenseOf(address(user1Owned1));

        assertEq(totalLicenseCountAfter, totalLicenseCountBefore + 1);
        assertEq(user1LicenseCountAfter, user1LicenseCountBefore + 1);
        assertEq(uri, EXAMPLE_URI);
        assertEq(info, EXAMPLE_INFO);
        assertEq(user1TokenAfter, user1TokenBalance + 1);
        assertEq(robotToken.totalSupply(), 1);
    }

    function testSetDefaultLicenseOwnedUpdate() external {
        _setupLicenses();

        uint256 totalLicenseCountBefore = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountBefore = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenBalance = robotToken.balanceOf(USER1);

        vm.expectEmit(true, true, false, true);
        emit LicenseSet(USER1, address(user1Owned1), EXAMPLE_URI2, EXAMPLE_INFO2);
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(user1Owned1), EXAMPLE_URI2, EXAMPLE_INFO2);

        uint256 totalLicenseCountAfter = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountAfter = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenAfter = robotToken.balanceOf(USER1);
        (string memory uri, string memory info) = robotTxt.licenseOf(address(user1Owned1));

        assertEq(totalLicenseCountAfter, totalLicenseCountBefore);
        assertEq(user1LicenseCountAfter, user1LicenseCountBefore);
        assertEq(uri, EXAMPLE_URI2);
        assertEq(info, EXAMPLE_INFO2);
        assertEq(user1TokenAfter, user1TokenBalance);
    }

    function testSetDefaultLicenseWhitelisted() public {
        vm.prank(OWNER);
        robotTxt.whitelistOwnerContract(USER1, address(user1NotOwned1));

        uint256 totalLicenseCountBefore = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountBefore = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenBalance = robotToken.balanceOf(USER1);

        vm.expectEmit(true, true, false, true);
        emit LicenseSet(USER1, address(user1NotOwned1), EXAMPLE_URI, EXAMPLE_INFO);
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(user1NotOwned1), EXAMPLE_URI, EXAMPLE_INFO);

        uint256 totalLicenseCountAfter = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountAfter = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenAfter = robotToken.balanceOf(USER1);
        (string memory uri, string memory info) = robotTxt.licenseOf(address(user1NotOwned1));

        assertEq(totalLicenseCountAfter, totalLicenseCountBefore + 1);
        assertEq(user1LicenseCountAfter, user1LicenseCountBefore + 1);
        assertEq(uri, EXAMPLE_URI);
        assertEq(info, EXAMPLE_INFO);
        assertEq(user1TokenAfter, user1TokenBalance + 1);
        assertEq(robotToken.totalSupply(), 1);
    }

    function testCannotSetDefaultLicenseZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector));
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(0), EXAMPLE_URI, EXAMPLE_INFO);
    }

    function testCannotSetDefaultLicenseNotOwner() public {
        vm.expectRevert(abi.encodeWithSelector(NotOwner.selector));
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(user2Owned1), EXAMPLE_URI, EXAMPLE_INFO);
    }

    function testCannotSetDefaultLicenseNotOwnable() public {
        vm.expectRevert();
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(666), EXAMPLE_URI, EXAMPLE_INFO);
    }

    function testCannotSetDefaultLicenseNotOwnedNotWhitelisted() public {
        vm.expectRevert(abi.encodeWithSelector(NotWhitelisted.selector));
        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(user1NotOwned1), EXAMPLE_URI, EXAMPLE_INFO);
    }

    /// removeDefaultLicense()

    function testRemoveDefaultLicenseOwned() public {
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
        (string memory uri, string memory info) = robotTxt.licenseOf(address(user1Owned1));

        assertEq(totalLicenseCountAfter, totalLicenseCountBefore - 1);
        assertEq(user1LicenseCountAfter, user1LicenseCountBefore - 1);
        assertEq(uri, "");
        assertEq(info, "");
        assertEq(user1TokenAfter, user1TokenBalance - 1);
        assertEq(robotTokenSupplyAfter, robotTokenSupplyBefore - 1);
    }

    function testRemoveDefaultLicenseWhiteListed() public {
        _setupNotOwned();

        uint256 totalLicenseCountBefore = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountBefore = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenBalance = robotToken.balanceOf(USER1);
        uint256 robotTokenSupplyBefore = robotToken.totalSupply();

        vm.prank(USER1);
        robotToken.approve(address(robotTxt), 1);

        vm.expectEmit(true, true, false, true);
        emit LicenseRemoved(USER1, address(user1NotOwned1));
        vm.prank(USER1);
        robotTxt.removeDefaultLicense(address(user1NotOwned1));

        uint256 totalLicenseCountAfter = robotTxt.totalLicenseCount();
        uint256 user1LicenseCountAfter = robotTxt.getOwnerLicenseCount(USER1);
        uint256 user1TokenAfter = robotToken.balanceOf(USER1);
        uint256 robotTokenSupplyAfter = robotToken.totalSupply();
        (string memory uri, string memory info) = robotTxt.licenseOf(address(user1Owned1));

        assertEq(totalLicenseCountAfter, totalLicenseCountBefore - 1);
        assertEq(user1LicenseCountAfter, user1LicenseCountBefore - 1);
        assertEq(uri, "");
        assertEq(info, "");
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

    /// whitelistOwnerContract()

    function testWhitelistOwnerContract() public {
        vm.expectEmit(true, true, false, true);
        emit ContractWhitelisted(USER1, address(user1NotOwned1));
        vm.prank(OWNER);
        robotTxt.whitelistOwnerContract(USER1, address(user1NotOwned1));

        assertEq(robotTxt.contractAddressToOwnerWhitelist(address(user1NotOwned1)), USER1);
    }

    function testWhitelistOwnerContractZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector));
        vm.prank(OWNER);
        robotTxt.whitelistOwnerContract(address(0), address(user1NotOwned1));

        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector));
        vm.prank(OWNER);
        robotTxt.whitelistOwnerContract(USER1, address(0));

        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector));
        vm.prank(OWNER);
        robotTxt.whitelistOwnerContract(address(0), address(0));
    }

    function testWhitelistOwnerContractAlreadyWhitelisted() public {
        _setupNotOwned();
        vm.expectRevert(abi.encodeWithSelector(AlreadyWhitelisted.selector));
        vm.prank(OWNER);
        robotTxt.whitelistOwnerContract(USER1, address(user1NotOwned1));
    }

    /// delistOwnerContract()

    function testDelistOwnerContract() public {
        _setupNotOwned();

        vm.expectEmit(true, true, false, true);
        emit ContractDelisted(USER1, address(user1NotOwned1));
        vm.prank(OWNER);
        robotTxt.delistOwnerContract(USER1, address(user1NotOwned1));

        assertEq(robotTxt.contractAddressToOwnerWhitelist(address(user1NotOwned1)), address(0));
    }

    function testDelistOwnerContractZeroAddress() public {
        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector));
        vm.prank(OWNER);
        robotTxt.delistOwnerContract(address(0), address(user1NotOwned1));

        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector));
        vm.prank(OWNER);
        robotTxt.delistOwnerContract(USER1, address(0));

        vm.expectRevert(abi.encodeWithSelector(ZeroAddress.selector));
        vm.prank(OWNER);
        robotTxt.delistOwnerContract(address(0), address(0));
    }

    function testDelistOwnerContractNotWhitelisted() public {
        vm.expectRevert(abi.encodeWithSelector(NotWhitelisted.selector));
        vm.prank(OWNER);
        robotTxt.delistOwnerContract(USER1, address(user1NotOwned1));
    }

    /// private functions

    function _setupLicenses() private {
        vm.startPrank(USER1);

        robotTxt.setDefaultLicense(address(user1Owned1), EXAMPLE_URI, EXAMPLE_INFO);
        robotTxt.setDefaultLicense(address(user1Owned2), EXAMPLE_URI, EXAMPLE_INFO);

        vm.stopPrank();
    }

    function _setupNotOwned() public {
        vm.prank(OWNER);
        robotTxt.whitelistOwnerContract(USER1, address(user1NotOwned1));

        vm.prank(USER1);
        robotTxt.setDefaultLicense(address(user1NotOwned1), EXAMPLE_URI, EXAMPLE_INFO);
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

contract NotOwnedContract {
    constructor() {}
}
