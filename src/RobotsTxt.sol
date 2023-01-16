// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
//import counters
import "openzeppelin/utils/Counters.sol";

interface IOwnable {
    function owner() external view returns (address);
}

contract RobotsTxt {
    mapping(address => string) licenses;
    mapping(address=>address[]) licensedAddressesForOwner;
    using Counters for Counters.Counter;

    event LicenseSet(address indexed _by,address indexed _for, string _licenseUri);

    Counters.Counter private _totalLicenseActions;

    function getOwner(address _for) public view returns (address) {
        return IOwnable(_for).owner();
    }

    function _checkOwnership(address _owned) public view {
        require(msg.sender == _owned || msg.sender == getOwner(_owned), "Not owner");
    }

    modifier onlyOwner(address _owned) {
        _checkOwnership(_owned);
        _;
    }

    function setDefaultLicense(address _for,string memory _licenseUri) 
    onlyOwner(_for)
    public
     {
        licenses[_for] = _licenseUri;
        licensedAddressesForOwner[msg.sender].push(_for);
        _totalLicenseActions.increment();
        emit LicenseSet(msg.sender,_for,_licenseUri);
    }

    function  getTotalLicenseActions() public view returns (uint256) {
        return _totalLicenseActions.current();
    }

    function getLicensedAddressesByOwner(address _owner) public view returns (address[] memory) {
        return licensedAddressesForOwner[_owner];
    }

    function getDefaultLicense( address _address )
     public view returns (string memory) {
        return licenses[_address];
    }
}
