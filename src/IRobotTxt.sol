// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

interface IRobotTxt {
    error NotOwner();
    error ZeroValue();
    error ZeroAddress();
    error LicenseAlreadyRegistered();
    error LicenseNotRegistered();

    event LicenseSet(address indexed _by, address indexed _for, string _licenseUri);
    event LicenseRemoved(address indexed _by, address indexed _for);

    function setDefaultLicense(address _for, string memory _licenseUri) external;
    function getOwnerLicenseCount(address owner) external view returns (uint256);
}
