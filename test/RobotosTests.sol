// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";
import "../src/RobotsTxt.sol";

contract RobotsTest is Test {
    RobotsTxt robots;

    function setUp() public {
        robots = new RobotsTxt();
    }

    function test_setDefaultLicense_OnSelf_works() public {
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

    function test_CheckCOuntOfLicenseActions () public {
        assertEq(robots.getTotalLicenseActions(), 0);
        robots.setDefaultLicense(address(this), "https://example.com/robots.txt");
        robots.setDefaultLicense(address(this), "https://example.com/robots.txt");
        assertEq(robots.getTotalLicenseActions(), 2);
    }
    function test_CheckLicensedAddressesBy() public {
        assertEq(robots.getLicensedAddressesByOwner(address(this)).length, 0);
        robots.setDefaultLicense(address(this), "https://example.com/robots.txt");
        robots.setDefaultLicense(address(this), "https://example.com/robots.txt");
        assertEq(robots.getLicensedAddressesByOwner(address(this)).length, 2);
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

