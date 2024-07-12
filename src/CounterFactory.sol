// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {Counter} from "./Counter.sol";

contract CounterFactory {
    constructor() {}

    function deployCounter(address poolManagerAddr, bytes32 salt)
        external
        returns (address)
    {
        Counter counter = new Counter{salt: salt}(poolManagerAddr);

        return address(counter);
    }

}
