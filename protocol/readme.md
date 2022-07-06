---
description: >-
  Learn how to build and integrate with Foundation's smart contracts and
  protocol.
---

# Getting Started

![](https://user-images.githubusercontent.com/14855515/171161481-4d745b25-b947-4df4-a801-179637d5ebe6.png)

## Integrations FAQ

**Why Should I Integrate?**

Integrators can tap into the [lucrative](https://dune.xyz/foundation/foundation) FND Market and be rewarded for the volume and liquidity they generate on the blockchain layer.

**What Type of Rewards Do I Receive?**

We offer buyer-side incentives on all our market tools (BuyNow, Auctions, Offers). Any NFT purchase initiated with a referral will get 20% of the FND Protocol Fee (1% of the total sale amount).

**How Are Rewards Paid Out?**

Rewards (in ETH) will be automatically deposited to the referrer address provided as part of the buy transaction.

**What’s Next?**

We’re planning to expand referral programs to our seller-side listings.

**Final Notes**

None of the above rates/mechanisms should be interpreted as final and are subject to change at anytime.

## Integration Details

### Frontend Integration

Contracts from this repo are published to [`@f8n/fnd-protocol`](https://www.npmjs.com/package/@f8n/fnd-protocol).

To get started, here’s an example BuyNow call with a referral incentive address.

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

- \***\*[**playground**](https://thegraph.com/hosted-service/subgraph/f8n/fnd)\*\***
- \***\*[**mainnet**](https://api.thegraph.com/subgraphs/name/f8n/fnd)\*\***
- \***\*[**goerli**](https://api.thegraph.com/subgraphs/name/f8n/fnd-goerli)\*\***

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

## Testing

```
yarn
yarn build
yarn test
```

Note that our full test suite is not included here at this time. The tests are meant to demonstrate how to work with our contracts and a few of the core features.
