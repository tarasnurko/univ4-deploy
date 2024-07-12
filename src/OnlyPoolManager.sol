// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract OnlyPoolManager {
    address public poolManager;

    constructor(address _poolManager) {
        poolManager = _poolManager;
    }

    modifier onlyPoolManager() {
        require(msg.sender == poolManager, "Only PoolManager");
        _;
    }
}
