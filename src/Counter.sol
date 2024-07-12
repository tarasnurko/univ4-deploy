// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;


import {PoolKey} from "v4-core/src/types/PoolKey.sol";
import {BalanceDelta} from "v4-core/src/types/BalanceDelta.sol";
import {IPoolManager} from "v4-core/src/interfaces/IPoolManager.sol";
import {BeforeSwapDelta} from "v4-core/src/types/BeforeSwapDelta.sol";
import {IHooks} from "v4-core/src/interfaces/IHooks.sol";

import {OnlyPoolManager} from "./OnlyPoolManager.sol";

/*
  Permissions:
    - beforeAddLiquidity
    - beforeRemoveLiquidity
    - beforeSwap
    - beforeDonate

*/
contract Counter is OnlyPoolManager, IHooks {
    uint256 public swapCounter;
    uint256 public liquidityCounter;
    uint256 public donateCounter;

    constructor(address _poolManager) OnlyPoolManager(_poolManager) {}

    function beforeInitialize(address sender, PoolKey calldata key, uint160 sqrtPriceX96, bytes calldata hookData)
        external
        returns (bytes4)
    {}

    function afterInitialize(
        address sender,
        PoolKey calldata key,
        uint160 sqrtPriceX96,
        int24 tick,
        bytes calldata hookData
    ) external returns (bytes4) {}

    function beforeAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata hookData
    ) external onlyPoolManager returns (bytes4) {
        ++liquidityCounter;
        return IHooks.beforeAddLiquidity.selector;
    }

    function afterAddLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) external returns (bytes4, BalanceDelta) {}

    function beforeRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        bytes calldata hookData
    ) external onlyPoolManager returns (bytes4) {
        ++liquidityCounter;
        return IHooks.beforeRemoveLiquidity.selector;
    }

    function afterRemoveLiquidity(
        address sender,
        PoolKey calldata key,
        IPoolManager.ModifyLiquidityParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) external returns (bytes4, BalanceDelta) {}

    function beforeSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        bytes calldata hookData
    ) external onlyPoolManager returns (bytes4, BeforeSwapDelta, uint24) {
        ++swapCounter;
        return (IHooks.beforeSwap.selector, BeforeSwapDelta.wrap(0), 0);
    }

    function afterSwap(
        address sender,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata params,
        BalanceDelta delta,
        bytes calldata hookData
    ) external returns (bytes4, int128) {}

    function beforeDonate(
        address sender,
        PoolKey calldata key,
        uint256 amount0,
        uint256 amount1,
        bytes calldata hookData
    ) external onlyPoolManager returns (bytes4) {
        ++donateCounter;
        return IHooks.beforeDonate.selector;
    }

    function afterDonate(
        address sender,
        PoolKey calldata key,
        uint256 amount0,
        uint256 amount1,
        bytes calldata hookData
    ) external returns (bytes4) {}
}
