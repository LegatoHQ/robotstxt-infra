// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RobotsTxt.sol";

contract RobotsTest is Test {
    RobotsTxt robots;

    function setUp() public {
        robots = new RobotsTxt();
    }
    function test_getDefaultLicense_withoutSettingitOnSelf_returnsEmpty() public {
        assertEq(robots.getDefaultLicense(address(this)), "");
    }
    function test_ownableRobots_getDefaultLicense_empty() public {
        assertEq(robots.getDefaultLicense(address(robots)), "");
        robots.setDefaultLicense(address(robots), "https://example.com/robots.txt");
        assertEq(robots.getDefaultLicense(address(robots)), "https://example.com/robots.txt");
    }

//actions count
    function  test_getLicenseActionsCount_withoutSettingitOnSelf_returnsZero() public {
        assertEq(robots.getLicenseActionsCount(), 0);
        robots.setDefaultLicense(address(this), "https://example.com/robots.txt");
        assertEq(robots.getLicenseActionsCount(), 1);
        robots.setDefaultLicense(address(this), "https://example.com/robots.txt");
        assertEq(robots.getLicenseActionsCount(), 2);
    }   

    function test_setDefaultLicense_OnSelf_works() public {
        assertEq(robots.getDefaultLicense(address(this)), "");
        robots.setDefaultLicense(address(this), "https://example.com/robots.txt");
        assertEq(robots.getDefaultLicense(address(this)), "https://example.com/robots.txt");
    }
    function test_setDefaultLicense_OnOtherAddress_Denied() public {
        vm.expectRevert();
        robots.setDefaultLicense(address(0x1), "https://example.com/robots.txt");
    }

    function test_OwnedContract_ownedOwnable_allowed() public {
        OwnedContract owned = new OwnedContract(address(this));
        robots.setDefaultLicense(address(owned), "https://example.com/robots.txt");
        assertEq(owned.owner(), address(this));
        assertEq(robots.getDefaultLicense(address(owned)), "https://example.com/robots.txt");
    }

    function test_OwnedContract_notOwnedOwnable_notAllowedToSeltLicense() public {
        OwnedContract notOwned = new OwnedContract(address(0x1));
        vm.expectRevert();
        robots.setDefaultLicense(address(notOwned), "https://example.com/robots.txt");
    }
}


contract OwnedContract {
    address public owner;

    constructor(address _owner) {
        owner = _owner;
    }

    function setOwner(address _owner) public {
        owner = _owner;
    }

}

