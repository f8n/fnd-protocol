<img width="1200" alt="Repo — Protocol" src="https://user-images.githubusercontent.com/14855515/171161481-4d745b25-b947-4df4-a801-179637d5ebe6.png">

# Documentation

See the [documentation](https://docs.foundation.app/docs/protocol).

# Bounty Program

If you find a security issue impacting contracts deployed to mainnet, please report them via our [Immunefi bounty program](https://immunefi.com/bounty/foundation/).

Other issues can be reported via [GitHub Issues](https://github.com/f8n/fnd-protocol/issues). Questions? Ask in [Discussions](https://github.com/f8n/fnd-protocol/discussions).

# Testing

```
yarn
yarn build
yarn test
```

Note that our full test suite is not included here at this time. The tests are meant to demonstrate how to work with our contracts and a few of the core features.

# Code conventions

## Data sizes

Where possible we should be consistent on the size of fields used. Even if it offers no immediate benefit, it will leave room for packing new fields in the future.

- When uints are used as a mapping key, there is no known benefit to compressing so uint256 is preferred.
- External APIs and events should always use uint256. Benefits of compressing are small and 256 is industry standard so integration should be easier.
- Math in Solidity always operates in 256 bit form, so best to cast to the smaller size only at the time of storage.
- Solidity does not check for overflows when down casting, explicit checks should be added when assumptions are made about user inputs.

Recommendations:

- ETH: uint96
  - Circulating supply is currently 119,440,269 ETH (119440269000000000000000000 wei / 1.2 \* 10^26).
  - Max uint96 is 7.9 \* 10^28.
  - Therefore any value capped by msg.value should never overflow uint96 assuming ETH total supply remains under 70,000,000,000 ETH.
    - There is currently ~2% inflation in ETH total supply (which fluctuates) and this value is expected to do down. We expect Ether will become deflationary before the supply reaches more than 500x current values.
  - 96 bits packs perfectly into a single slot with an address.
- Dates: uint32
  - Current date in seconds is 1643973923 (1.6 \* 10^9).
  - Max uint32 is 4 \* 10^9.
  - Dates will not overflow uint32 until 2104.
  - To ensure we don't behave unexpectedly in the future, we should require dates are <= max uint32.
  - uint40 would allow enough space for any date, but it's an awkward size to pack with.
- Sequence ID indexes: uint32
  - Our max sequence ID today is 149,819 auctions.
  - Max uint32 is 4 \* 10^9.
  - Indexes will not overflow uint32 until we see >28,000x growth. This is the equiv to ~300 per block for every block in Ethereum to date.
- Basis points: uint16
  - Numbers which are by definition lower than the max uint value can be compressed appropriately.
  - Basis points is <= 10,000 which fits into uint16 (max of 65,536)
