---
description: >-
  Learn about how to build and integrate with Foundation's smart contracts and
  protocol.
---

# Getting Started

![](https://user-images.githubusercontent.com/14855515/171161481-4d745b25-b947-4df4-a801-179637d5ebe6.png)

Welcome to Foundation’s developer docs! Here you can learn about all of the ways that you can currently plug into and build using our open source code.

How to get involved:&#x20;

* Follow FoundationOS on [Twitter](https://twitter.com/FoundationOS) for announcements and updates on our docs and tools.
* Explore our growing ecosystem of integrations at [os.foundation.app](https://os.foundation.app/).&#x20;
* View our code on Github.

## Integrations FAQ

**Why Should I Integrate?**

Integrators can tap into the [lucrative](https://dune.xyz/foundation/foundation) FND Market and be rewarded for the volume and liquidity they generate on the blockchain layer.

**What Type of Rewards Do I Receive?**

We offer buyer side incentives on all our market tools (BuyNow, Auctions, Offers). Any NFT purchase initiated with a referral will get 20% of the FND Protocol Fee (1% of the total sale amount).

**How Are Rewards Paid Out?**

Rewards (in ETH) will be automatically deposited to the referrer address provided as part of the buy transaction.

**What’s Next?**

We’re planning to expand referral programs to our seller side listings.

**Final Notes**

None of the above rates/mechanisms should be interpreted as final and are subject to change at anytime.

## Integration Details

### Frontend Integration

Contracts from this repo are published to [`@f8n/fnd-protocol`](https://www.npmjs.com/package/@f8n/fnd-protocol).

To get you started here’s an example BuyNow call with a referral incentive address.

```
const txArgs: BuyNowArgs = [
      contractAddress,  // The contract address of the NFT with a buy price set on FND
      tokenId,  // The id for the token.
      buyNowPrice,  // The buy price.
      payableReferrerAddress,  // The payable referrer address that would get the 1% kick-back.
    ];
const txOptions: PayableOverrides = {
      value: buyNowPrice
    };
await nftMarketContract.buyV2(...txArgs, txOptions);
```

The above example can be extended for Offers and Auctions as well:

```
// Offers.
const txArgsForOffer: MakeOfferArgs = [...];
await nftMarketContract.makeOfferV2(...txArgsForOffer, txOptions);

// Auctions.
const txArgsForBid: BidArgs = [...];
await nftMarketContract.placeBidV2(...txArgsForBid, txOptions);
```

### Smart Contract Integration

See our [examples repo](https://github.com/f8n/fnd-protocol-examples) to see how you can build on these contracts.

### Backend Integration

Foundation is fully on-chain and the easiest way to retrieve any event emitted from our contract is through the hosted [subgraph](https://thegraph.com/hosted-service/subgraph/f8n/fnd). In fact this is what our backend that powers [foundation.app](https://github.com/f8n/fnd-protocol/blob/main/foundation.app) does as well!

To integrate you can use the endpoints below:

* **playground:** https://thegraph.com/hosted-service/subgraph/f8n/fnd
* **mainnet:** https://api.thegraph.com/subgraphs/name/f8n/fnd
* **goerli:** https://api.thegraph.com/subgraphs/name/f8n/fnd-goerli

To get you started here are some example queries:

_Retrieve a list of BuyNows:_

```
{
 nftMarketBuyNows(
   first: 100) {
    id,
    nft {
      id,
      tokenId,
      dateMinted,
    },
    nftContract {
      id,
      name,
      symbol
    },
    status,
    seller {
      id
    },
    amountInETH,
  }
}
```

_Retrieve historical BuyNow Events:_

```
{
  nftHistories(
    where: {buyNow_not: null},
    first: 100,
    orderBy: date,
    orderDirection: asc) {
      id,
      contractAddress,
      nft {
        id,
        tokenId,
        dateMinted,
      },
      buyNow {
        id,
        status,
        dateCreated,
        dateCanceled,
        dateAccepted,
        dateInvalidated,
        seller{
          id
        },
        buyer {
          id
        },
        buyReferrer {
          id
        },
        buyReferrerProtocolFee
      },
    }
}
```

###

## Bounty Program

If you find a security issue impacting contracts deployed to mainnet, please report them via our [Immunefi bounty program](https://immunefi.com/bounty/foundation/).

Other questions or issues can be reported via [GitHub `Issues`](https://github.com/f8n/fnd-protocol/issues) or ask in [`Discussions`](https://github.com/f8n/fnd-protocol/discussions).

## Testing

```
yarn
yarn build
yarn test
```

Note that our full test suite is not included here at this time. The tests are meant to demonstrate how to work with our contracts and a few of the core features.

## Code conventions

### Data sizes

Where possible we should be consistent on the size of fields used. Even if it offers no immediate benefit, it will leave room for packing new fields in the future.

* When uints are used as a mapping key, there is no known benefit to compressing so uint256 is preferred.
* External APIs and events should always use uint256. Benefits of compressing are small and 256 is industry standard so integration should be easier.
* Math in Solidity always operates in 256 bit form, so best to cast to the smaller size only at the time of storage.
* Solidity does not check for overflows when down casting, explicit checks should be added when assumptions are made about user inputs.

Recommendations:

* ETH: uint96
  * Circulating supply is currently 119,440,269 ETH (119440269000000000000000000 wei / 1.2 \* 10^26).
  * Max uint96 is 7.9 \* 10^28.
  * Therefore any value capped by msg.value should never overflow uint96 assuming ETH total supply remains under 70,000,000,000 ETH.
    * There is currently \~2% inflation in ETH total supply (which fluctuates) and this value is expected to do down. We expect Ether will become deflationary before the supply reaches more than 500x current values.
  * 96 bits packs perfectly into a single slot with an address.
* Dates: uint32
  * Current date in seconds is 1643973923 (1.6 \* 10^9).
  * Max uint32 is 4 \* 10^9.
  * Dates will not overflow uint32 until 2104.
  * To ensure we don't behave unexpectedly in the future, we should require dates are <= max uint32.
  * uint40 would allow enough space for any date, but it's an awkward size to pack with.
* Sequence ID indexes: uint32
  * Our max sequence ID today is 149,819 auctions.
  * Max uint32 is 4 \* 10^9.
  * Indexes will not overflow uint32 until we see >28,000x growth. This is the equiv to \~300 per block for every block in Ethereum to date.
* Basis points: uint16
  * Numbers which are by definition lower than the max uint value can be compressed appropriately.
  * Basis points is <= 10,000 which fits into uint16 (max of 65,536)
