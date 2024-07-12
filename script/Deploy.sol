// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {MockUNI} from "v4-template/script/mocks/mUNI.sol";
import {MockUSDC} from "v4-template/script/mocks/mUSDC.sol";

import {Deployers} from "v4-core/test/utils/Deployers.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {HookMiner} from "./utils/HookMiner.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Constants} from "v4-core/test/utils/Constants.sol";

// Hooks
import {Counter} from "src/Counter.sol";
import {NftGifter} from "src/NftGifter.sol";

contract Deploy is Script, Deployers {
    // uint256 DEPLOYER_PRIVATE_KEY = vm.envUint("PRIVATE_KEY");
    // address DEPLOYER = vm.addr(DEPLOYER_PRIVATE_KEY);
    address DEPLOYER = address(0xEB7fc18EB6861ba5FF0A53Bb1b26605Ab251926A);

    address poolManagerAddr;

    function run() public {
        deployPoolManager();
        deployMintAndApprove2Currencies();
        deployEmptyPool();
        deployCounterHookAndPool();
        deployNftGifterHook();
    }

    function deployEmptyPool() public {
        (, PoolId id) = initPool(
            currency0, currency1, IHooks(Constants.ADDRESS_ZERO), 3000, uint160(14614467034852101032872730000), ""
        );

        console2.log("Empty pool id:");
        console2.logBytes32(PoolId.unwrap(id));
    }

    function deployPoolManager() public {
        deployFreshManagerAndRouters();

        poolManagerAddr = address(manager);
        console2.log("PoolManager deployed to: ", poolManagerAddr);
    }

    function deployCounterHookAndPool() public {
        uint160 hookFlags = uint160(
            Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG | Hooks.BEFORE_SWAP_FLAG
                | Hooks.BEFORE_DONATE_FLAG
        );

        (address predictedAddr, bytes32 salt) =
            HookMiner.find(DEPLOYER, hookFlags, type(Counter).creationCode, abi.encode(poolManagerAddr));

        vm.startBroadcast();
        Counter counter = new Counter{salt: salt}(poolManagerAddr);
        vm.stopBroadcast();

        require(predictedAddr == address(counter), "Counter: Addresses are not the same");

        console2.log("Counter deployed to: ", address(counter));

        (, PoolId id) =
            initPool(currency0, currency1, IHooks(address(counter)), 3000, uint160(446775034852101032872730000), "");

        console2.log("Counter pool id:");
        console2.logBytes32(PoolId.unwrap(id));
    }

    function deployNftGifterHook() public {
        uint160 hookFlags = uint160(Hooks.AFTER_DONATE_FLAG);

        (address predictedAddr, bytes32 salt) =
            HookMiner.find(DEPLOYER, hookFlags, type(NftGifter).creationCode, abi.encode(poolManagerAddr));

        vm.startBroadcast();
        NftGifter nftGifter = new NftGifter{salt: salt}(poolManagerAddr);
        vm.stopBroadcast();

        require(predictedAddr == address(nftGifter), "Counter: Addresses are not the same");

        console2.log("NftGifter deployed to: ", address(nftGifter));

        (, PoolId id) =
            initPool(currency0, currency1, IHooks(address(nftGifter)), 3000, uint160(8954775038521010328727300007), "");

        console2.log("NftGifter pool id:");
        console2.logBytes32(PoolId.unwrap(id));
    }
}
