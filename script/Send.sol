// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";

contract Send is Script {
    uint256 DEPLOYER_PRIVATE_KEY = vm.envUint("PRIVATE_KEY");
    address addr = 0x1Fd1893f7AB1774958EA0fB24232dC4E9A0578c2;
    uint256 value = 0.0001e18;

    function run() public {
        vm.startBroadcast(DEPLOYER_PRIVATE_KEY);
        addr.call{value: value}("");
        vm.stopBroadcast();
    }
}
