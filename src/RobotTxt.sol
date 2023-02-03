// SPDX-License-Identifier: UNLICENSED
/**
 *
 *                     $$\                  $$\                        $$\                 $$\
 *                     $$ |                 $$ |                       $$ |                $$ |
 *  $$$$$$\   $$$$$$\  $$$$$$$\   $$$$$$\ $$$$$$\    $$$$$$$\        $$$$$$\   $$\   $$\ $$$$$$\       $$\   $$\ $$\   $$\ $$$$$$$$\
 * $$  __$$\ $$  __$$\ $$  __$$\ $$  __$$\\_$$  _|  $$  _____|$$$$$$\\_$$  _|  \$$\ $$  |\_$$  _|      \$$\ $$  |$$ |  $$ |\____$$  |
 * $$ |  \__|$$ /  $$ |$$ |  $$ |$$ /  $$ | $$ |    \$$$$$$\  \______| $$ |     \$$$$  /   $$ |         \$$$$  / $$ |  $$ |  $$$$ _/
 * $$ |      $$ |  $$ |$$ |  $$ |$$ |  $$ | $$ |$$\  \____$$\          $$ |$$\  $$  $$<    $$ |$$\      $$  $$<  $$ |  $$ | $$  _/
 * $$ |      \$$$$$$  |$$$$$$$  |\$$$$$$  | \$$$$  |$$$$$$$  |         \$$$$  |$$  /\$$\   \$$$$  |$$\ $$  /\$$\ \$$$$$$$ |$$$$$$$$\
 * \__|       \______/ \_______/  \______/   \____/ \_______/           \____/ \__/  \__|   \____/ \__|\__/  \__| \____$$ |\________|
 *                                                                                                               $$\   $$ |
 *                                                                                                               \$$$$$$  |
 *                                                                                                                \______/
 *
 * A robots.txt file tells search engine crawlers which URLs the crawler can access on your site.
 * In web3, we can use this robots-txt registry contract to let aggregators anyone else that scape the the blockchain and IPFs
 * know what default rights we are giving them regarding our content.
 *
 * How this works:
 * -------------------
 * You (or a contract) can only set a license URI _for your own address,
 * or _for a contract that has an "owner()" function that returns your address.
 *
 *
 * call setDefaultLicense(address _for, string memory _licenseUri) to set a license _for your address or a contract you own.
 * call getDefaultLicense(address _address) to get the license _for an address. if none is set, it will return an empty string.
 *
 * by Roy Osherove
 */
pragma solidity ^0.8.13;

import "openzeppelin/access/Ownable.sol";
import "./token/IRobot.sol";
import "./IRobotTxt.sol";

contract RobotTxt is IRobotTxt, Ownable {
    IRobot public robot;
    mapping(address => string) public uris;
    mapping(address => address[]) public ownerLicenses;
    uint256 public totalLicenseCount;

    modifier senderMustBeOwnerOf(address _owned) {
        if (_owned == address(0)) revert ZeroAddress();
        if (msg.sender != Ownable(_owned).owner()) revert NotOwner();
        _;
    }

    /// @param robotAddress address of the legato robot token contract
    constructor(address robotAddress) {
        if (robotAddress == address(0)) revert ZeroAddress();
        robot = IRobot(robotAddress);
    }

    /// @notice registers a new license URI _for a license owned by the license owner
    /// @param _for the address of the license to register
    /// @param _licenseUri the URI of the license
    function setDefaultLicense(address _for, string memory _licenseUri) public senderMustBeOwnerOf(_for) {
        if (bytes(_licenseUri).length == 0) revert ZeroValue();

        /// if the license is already registered, revert
        if (bytes(uris[_for]).length != 0) revert LicenseAlreadyRegistered();

        ownerLicenses[msg.sender].push(_for);
        uris[_for] = _licenseUri;

        robot.mintOne(msg.sender);

        totalLicenseCount++;

        emit LicenseSet(msg.sender, _for, _licenseUri);
    }

    /// @notice returns a license count for a given owner
    /// @param owner the owner of the licenses
    /// @return licenseCount
    function getOwnerLicenseCount(address owner) external view returns (uint256) {
        return ownerLicenses[owner].length;
    }

    /// @notice remove a license URI _for a license owned by the license owner
    /// @param _for the address of the license to register
    function removeDefaultLicense(address _for) public senderMustBeOwnerOf(_for) {
        if (bytes(uris[_for]).length == 0) revert LicenseNotRegistered();
        uris[_for] = "";

        address[] memory licenses = ownerLicenses[msg.sender];
        delete ownerLicenses[msg.sender];

        for (uint256 i = 0; i < licenses.length; i++) {
            if (licenses[i] != _for) {
                ownerLicenses[msg.sender].push(licenses[i]);
            }
        }

        robot.burnOne(msg.sender);
        totalLicenseCount--;

        emit LicenseRemoved(msg.sender, _for);
    }
}
