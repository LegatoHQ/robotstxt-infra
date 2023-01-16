// SPDX-License-Identifier: UNLICENSED
/**
 * 
                    $$\                  $$\                        $$\                 $$\                                       
                    $$ |                 $$ |                       $$ |                $$ |                                      
 $$$$$$\   $$$$$$\  $$$$$$$\   $$$$$$\ $$$$$$\    $$$$$$$\        $$$$$$\   $$\   $$\ $$$$$$\       $$\   $$\ $$\   $$\ $$$$$$$$\ 
$$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\\_$$  _|  $$  _____|$$$$$$\\_$$  _|  \$$\ $$  |\_$$  _|      \$$\ $$  |$$ |  $$ |\____$$  |
$$ |  \__|$$ /  $$ |$$ |  $$ |$$ /  $$ | $$ |    \$$$$$$\  \______| $$ |     \$$$$  /   $$ |         \$$$$  / $$ |  $$ |  $$$$ _/ 
$$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ | $$ |$$\  \____$$\          $$ |$$\  $$  $$<    $$ |$$\      $$  $$<  $$ |  $$ | $$  _/   
$$ |      \$$$$$$  |$$$$$$$  |\$$$$$$  | \$$$$  |$$$$$$$  |         \$$$$  |$$  /\$$\   \$$$$  |$$\ $$  /\$$\ \$$$$$$$ |$$$$$$$$\ 
\__|       \______/ \_______/  \______/   \____/ \_______/           \____/ \__/  \__|   \____/ \__|\__/  \__| \____$$ |\________|
                                                                                                              $$\   $$ |          
                                                                                                              \$$$$$$  |          
                                                                                                               \______/           

A robots.txt file tells search engine crawlers which URLs the crawler can access on your site.
In web3, we can use this robots-txt registry contract to let aggregators anyone else that scape the the blockchain and IPFs 
know what default rights we are giving them regarding our content.

How this works:
-------------------
You (or a contract) can only set a license URI for your own address, 
or for a contract that has an "owner()" function that returns your address.


call setDefaultLicense(address _for, string memory _licenseUri) to set a license for your address or a contract you own.
call getDefaultLicense(address _address) to get the license for an address. if none is set, it will return an empty string.

by Roy Osherove
 */
pragma solidity ^0.8.13;
import "openzeppelin/utils/Counters.sol";
import "openzeppelin/access/Ownable.sol";

interface IOwnable {
    function owner() external view returns (address);
}

contract RobotsTxt is Ownable {
    mapping(address => string) licenses;
    mapping(address => address[]) licensedAddressesForOwner;
    using Counters for Counters.Counter;

    event LicenseSet(
        address indexed _by,
        address indexed _for,
        string _licenseUri
    );

    Counters.Counter private _totalLicenseActions;

    function getLicenseActionsCount() public view returns (uint256) {
        return _totalLicenseActions.current();
    }
    function getOwnerOf(address _for) private view returns (address) {
        return IOwnable(_for).owner();
    }

    function _checkOwnership(address _owned) public view {
        require(
            msg.sender == _owned || msg.sender == getOwnerOf(_owned),
            "Not owner"
        );
    }

    modifier senderMustBeOwnerOf(address _owned) {
        _checkOwnership(_owned);
        _;
    }

    function setDefaultLicense(
        address _for,
        string memory _licenseUri
    ) public senderMustBeOwnerOf(_for) {
        licenses[_for] = _licenseUri;
        licensedAddressesForOwner[msg.sender].push(_for);
        _totalLicenseActions.increment();
        emit LicenseSet(msg.sender, _for, _licenseUri);
    }

    function getDefaultLicense(
        address _address
    ) public view returns (string memory) {
        return licenses[_address];
    }
}
