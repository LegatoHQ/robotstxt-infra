// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts//access/Ownable.sol";
// import "forge-std/console.sol";
//forge console

contract OwnableContract {
    address public owner;

    constructor(address _newOwner) {
        owner = _newOwner;
    }
}
