// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

import {ERC20} from "v4-core/lib/solmate/src/tokens/ERC20.sol";
import {MockERC20} from "v4-core/lib/solmate/src/test/utils/mocks/MockERC20.sol";

import {SortTokens} from "v4-core/test/utils/SortTokens.sol";

import {Deployers} from "v4-core/test/utils/Deployers.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {Currency} from "v4-core/src/types/Currency.sol";
import {PoolId, PoolIdLibrary} from "v4-core/src/types/PoolId.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";
import {Constants} from "v4-core/test/utils/Constants.sol";

import {HookMiner} from "./utils/HookMiner.sol";
import {Create2Deployer} from "src/Create2Deployer.sol";

// Hooks
import {Counter} from "src/Counter.sol";
import {CounterFactory} from "src/CounterFactory.sol";
import {NftGifter} from "src/NftGifter.sol";

contract Deploy is Script, Deployers {
    uint256 DEPLOYER_PRIVATE_KEY = vm.envUint("PRIVATE_KEY");
    address DEPLOYER = vm.addr(DEPLOYER_PRIVATE_KEY);
    // address DEPLOYER = address(0xEB7fc18EB6861ba5FF0A53Bb1b26605Ab251926A);
    address CREATE2_DEPLOYER_ADDR = address(0xA90931Cf522AE6405BCb43dA4257Df5CB8A8ddb1);
    Create2Deployer create2Deployer = Create2Deployer(CREATE2_DEPLOYER_ADDR);

    address poolManagerAddr;

    function run() public {
        vm.startBroadcast(DEPLOYER_PRIVATE_KEY);
        deployFreshManagerAndRouters();
        deployMockTokens();

        // initializePool(IHooks(Constants.ADDRESS_ZERO));
        // deployCounterHookAndPool();
        vm.stopBroadcast();
        logDeployedAddresses();
        // deployNftGifterHook();
    }

    function deployEmptyPool() public {
        (, PoolId id) = initPool(
            currency0, currency1, IHooks(Constants.ADDRESS_ZERO), 5, Constants.SQRT_PRICE_1_1, Constants.ZERO_BYTES
        );

        console2.log("Empty pool id:");
        console2.logBytes32(PoolId.unwrap(id));
    }

    function deployCounterHookAndPool() public {
        uint160 hookFlags = uint160(
            Hooks.BEFORE_ADD_LIQUIDITY_FLAG | Hooks.BEFORE_REMOVE_LIQUIDITY_FLAG | Hooks.BEFORE_SWAP_FLAG
                | Hooks.BEFORE_DONATE_FLAG
        );

        (address predictedAddr, bytes32 salt) =
            HookMiner.find(CREATE2_DEPLOYER_ADDR, hookFlags, type(Counter).creationCode, abi.encode(poolManagerAddr));

        bytes memory counterBytecodeWithConstructorArgs =
            abi.encodePacked(type(Counter).creationCode, abi.encode(poolManagerAddr));

        address counterAddr = create2Deployer.deploy(salt, counterBytecodeWithConstructorArgs);

        require(predictedAddr == counterAddr, "Counter: Addresses are not the same");

        console2.log("Counter deployed to: ", counterAddr);

        (, PoolId id) =
            initPool(currency0, currency1, IHooks(counterAddr), 1500, Constants.SQRT_PRICE_1_1, Constants.ZERO_BYTES);

        console2.log("Counter pool id:");
        console2.logBytes32(PoolId.unwrap(id));
    }

    function initializePool(IHooks hooks) public {
        PoolKey memory key = PoolKey(currency0, currency1, 100, int24(60), hooks);

        manager.initialize(key, Constants.SQRT_PRICE_1_1, Constants.ZERO_BYTES);
    }

    function deployMockTokens() public {
        uint256 tokensAmount = 2;
        uint256 supply = 1000000e18;

        MockERC20[] memory tokensArr = new MockERC20[](tokensAmount);

        address[8] memory toApprove = [
            address(swapRouter),
            address(swapRouterNoChecks),
            address(modifyLiquidityRouter),
            address(modifyLiquidityNoChecks),
            address(donateRouter),
            address(takeRouter),
            address(claimsRouter),
            address(nestedActionRouter.executor())
        ];

        for (uint8 i = 0; i < tokensAmount; i++) {
            tokensArr[i] = new MockERC20("TEST", "TEST", 18);
            tokensArr[i].mint(DEPLOYER, supply);

            for (uint256 j = 0; j < toApprove.length; j++) {
                tokensArr[i].approve(toApprove[j], Constants.MAX_UINT256);
            }
        }

        (currency0, currency1) = SortTokens.sort(tokensArr[0], tokensArr[1]);
    }

    function logDeployedAddresses() public {
        console2.log("manager", address(manager));
        console2.log("swapRouter", address(swapRouter));
        console2.log("modifyLiquidityRouter", address(modifyLiquidityRouter));
        console2.log("donateRouter", address(donateRouter));
        console2.log("takeRouter", address(takeRouter));
        console2.log("settleRouter", address(settleRouter));
        console2.log("claimsRouter", address(claimsRouter));
        console2.log("nestedActionRouter", address(nestedActionRouter));
        console2.log("feeController", address(feeController));
        console2.log("nestedActionRouter", address(nestedActionRouter));
    }

    // function deployNftGifterHook() public {
    // uint160 hookFlags = uint160(Hooks.AFTER_DONATE_FLAG);

    // (address predictedAddr, bytes32 salt) =
    //     HookMiner.find(DEPLOYER, hookFlags, type(NftGifter).creationCode, abi.encode(poolManagerAddr));

    // vm.startBroadcast();
    // NftGifter nftGifter = new NftGifter{salt: salt}(poolManagerAddr);
    // vm.stopBroadcast();

    // require(predictedAddr == address(nftGifter), "Counter: Addresses are not the same");

    // console2.log("NftGifter deployed to: ", address(nftGifter));

    // (, PoolId id) =
    //     initPool(currency0, currency1, IHooks(address(nftGifter)), 3000, uint160(8954775038521010328727300007), "");

    // console2.log("NftGifter pool id:");
    // console2.logBytes32(PoolId.unwrap(id));
    // }
}
