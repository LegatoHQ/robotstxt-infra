// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

interface IRobotTxt {
    error NotOwner();
    error ZeroValue();
    error ZeroAddress();
    error LicenseAlreadyRegistered();
    error LicenseNotRegistered();
    error AlreadyWhitelisted();
    error NotWhitelisted();

    event LicenseSet(address indexed _by, address indexed _for, string _licenseUri);
    event LicenseRemoved(address indexed _by, address indexed _for);
    event ContractWhitelisted(address indexed owner, address indexed contractAddress);
    event ContractDelisted(address indexed owner, address indexed contractAddress);

    function setDefaultLicense(address _for, string memory _licenseUri) external;
    function getOwnerLicenseCount(address owner) external view returns (uint256);
    function whitelistOwnerContract(address owner, address contractAddress) external;
    function delistOwnerContract(address owner, address contractAddress) external;
}
