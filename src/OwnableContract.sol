// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "lib/openzeppelin-contracts/contracts//access/Ownable.sol";
// import "forge-std/console.sol";
//forge console

contract OwnableContract is Ownable {
    constructor(address _newOwner) {
        _transferOwnership(_newOwner);
    }
}
