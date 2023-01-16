// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

interface IOwnable {
    function owner() external view returns (address);
}

contract RobotsTxt {
    mapping(address => string) licenses;
    mapping(address=>address[]) licensedAddressesForOwner;

    function getOwner() public view returns (address) {
        return IOwnable(msg.sender).owner();
    }

    function _checkOwnership(address _owned) public view {
        require(msg.sender == _owned || msg.sender == getOwner(), "Not owner");
    }

    modifier onlyOwner(address _owned) {
        _checkOwnership(_owned);
        _;
    }

    function setDefaultLicense(address _for,string memory _licenseUri) 
    onlyOwner(msg.sender)
    public
     {
        licenses[_for] = _licenseUri;
        licensedAddressesForOwner[msg.sender].push(_for);
    }

    function getLicensedAddressesByOwner(address _owner) public view returns (address[] memory) {
        return licensedAddressesForOwner[_owner];
    }

    function getTotalLicensed(){
        return 
    }

    function getDefaultLicense(
        address _address
    ) public view returns (string memory) {
        return licenses[_address];
    }
}
