```shell
$ forge install
```

### Deploy

Set environment variables

```shell
  source .env
```

Deploy mock tokens:

```shell
  forge create --rpc-url base_sepolia --private-key $PRIVATE_KEY --verify lib/v4-template/script/mocks/mUNI.sol:MockUNI
```

Can not verify because of this: https://github.com/foundry-rs/foundry/issues/7411

```shell
$ forge script script/Counter.s.sol:CounterScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

forge script script/Deploy.sol:Deploy --rpc-url base_sepolia --private-key $PRIVATE_KEY --verify

forge script script/Send.sol:Send --rpc-url base_sepolia --private-key $PRIVATE_KEY
