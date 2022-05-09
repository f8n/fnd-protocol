![FND Github-Protocol](https://user-images.githubusercontent.com/14855515/161173574-4479b891-f0b1-4c95-8cf7-6e4ba06e36fb.png)

If you find a security issue impacting contracts deployed to mainnet, please report them via our [Immunefi bounty program](https://immunefi.com/bounty/foundation/).

Other questions or issues can be reported via [GitHub `Issues`](https://github.com/f8n/fnd-protocol/issues) or ask in [`Discussions`](https://github.com/f8n/fnd-protocol/discussions).

## Testing

```
yarn
yarn build
yarn test
```

Note that our full test suite is not included here at this time. The tests are meant to demonstrate how to work with our contracts and a few of the core features.

## Integrations

#### Why Should I Integrate?

Integrators can tap into the [lucrative](https://dune.xyz/foundation/foundation) FND Market and be rewarded for the volume and liquidity they generate on the blockchain layer.

#### What Type of Rewards Do I Receive?

We offer buyer side incentives on all our market tools (BuyNow, Auctions, Offers). Any NFT purchase initiated with a referral will get 20% of the FND Protocol Fee (1% of the total sale amount).

#### How Are Rewards Paid Out?

Rewards (in ETH) will be automatically deposited to the referrer address provided as part of the buy transaction.

#### What’s Next?

We’re planning to expand referral programs to our seller side listings.

#### Final Notes

None of the above rates/mechanisms should be interpreted as final and are subject to change at anytime.

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
const txArgsForBids: MakeOfferArgs = [...];
await nftMarketContract.placeBidV2(...txArgsForBids, txOptions);

```

### Smart Contract Integration

See our [examples repo](https://github.com/f8n/fnd-protocol-examples) to see how you can build on these contracts.

### Backend Integration

Foundation is fully on-chain and the easiest way to retrieve any event emitted from our contract is through the hosted [subgraph](https://thegraph.com/hosted-service/subgraph/f8n/fnd). In fact this is what our backend that powers [foundation.app](foundation.app) does as well!

To integrate you can use the endpoints below:

- **playground:** https://thegraph.com/hosted-service/subgraph/f8n/fnd
- **mainnet:** https://api.thegraph.com/subgraphs/name/f8n/fnd
- **goerli:** https://api.thegraph.com/subgraphs/name/f8n/fnd-goerli

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

## Contract Documentation

### Marketplace

- [Market](/docs/FNDNFTMarket.md)

  The Foundation marketplace is a contract which allows traders to buy and sell NFTs.

  - Auctions last for 24 hours. The NFT is escrowed in the market contract when it's listed. As soon as a bid is received the NFT cannot be withdrawn, guaranteeing that the sale will go through and the highest bidder gets the NFT. If a bid is placed in the final minutes of an auction, the countdown timer resets to 15-minutes remaining.
  - Private Sales use a EIP-712 signature from the seller to authorize the trade to a specific buyer / price point. The buyer has 24 hours to accept the offer to buy the NFT before the signature expires.
  - Buy Price allows the owner of an NFT to list it for sale at a specific price point. The NFT is escrowed in the market contract when the price is set. Once a collector buys at the price set, the NFT is instantly transferred and revenue is distributed.
  - Offers allow collectors to make an offer for an NFT. The seller has 24-25 hours to accept the offer. During this time, the collector's funds are locked in the FETH ERC-20 contract - ensuring that an offer remains valid until its expiration. If a higher offer is made, the original user's FETH balance is unlocked and they can use those funds elsewhere (or withdraw the ETH).

  All sales in the Foundation market will pay the creator 10% royalties on secondary sales. This is not specific to NFTs minted on Foundation, it should work for any NFT. If royalty information was not defined when the NFT was originally deployed, it may be added using the [Royalty Registry](https://royaltyregistry.xyz/) which will be respected by our market contract.

- [FETH](/docs/FETH.md)

  FETH is an [ERC-20 token](https://eips.ethereum.org/EIPS/eip-20) modeled after [WETH9](https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code). It has the added ability to lockup tokens for 24-25 hours - during this time they may not be transferred or withdrawn, except by our market contract which requested the lockup in the first place.

  We strive to offer strong guarantees for both buyers and sellers, this is why a seller cannot back out of an auction once the first bid has been placed.

  For making offers, this means once a collector has made an offer for an NFT - those funds must remain available for a period of time so the seller has a reasonable window to consider and accept it without worrying that the collector might just withdraw their funds, making the offer invalid.

  We implement this feature in the FETH token contract, allowing funds to be locked up for 24-25 hours while the seller considers accepting the offer.

  Once the offer expires, the FETH tokens become available again. Their `balanceOf` automatically increases at the time it expires and they can then transfer or withdraw those funds -- or they can use them to place another offer!

  Since after lockups expire, FETH is just another wrapped ETH token contract - we allow using your available FETH balance with all the other market tools: place a bid with FETH, buy now with FETH, or buy from a private sale using FETH.

#### Marketplace State Machine

Below is a diagram depicting the marketplace states and transitions for the various market tools.

![Flowchart 1-Marketplace State Machine](https://user-images.githubusercontent.com/14855515/161260593-2bc20f67-4c70-4450-b3a2-eea5a7cd45ff.png)

### NFTs

- [Shared NFT](/docs/FNDNFT721.md)
  - The original NFT contract on Foundation.
  - A single contract allowing any creator to mint an NFT.
- [Collection Factory](/docs/FNDCollectionFactory.md)
  - A factory allowing a creator to create an ERC-1167 proxy contract for a collection of NFTs by a single creator.
- [Collection Contract Template](/docs/CollectionContract.md)
  - The implementation template used by all collection contracts created with the Collection Factory.
  - Collection contracts are immutable, so the latest template is only leveraged by newly created contracts.
- [Percent Splits](/docs/PercentSplitETH.md)
  - Allows anyone to create a contract which will forward ETH received to a list of recipients, splitting the payment between them according to the split's configuration defined in basis points.
  - Also supports ERC-20 tokens, but tokens are not automatically forwarded like with ETH - someone must trigger the distribution of the current holdings.
  - Arbitrary proxy calls may be made by any of the split recipients, in case another asset needs to be claimed or recovered (such as an NFT).

### Other

- [Treasury](/docs/FoundationTreasury.md)

  The Foundation Treasury contract collects revenue from each sale on Foundation.

- [Middleware](/docs/FNDMiddleware.md)

  The Foundation Middleware contract is a convenience contract leveraged by our frontend and/or backend in order to batch RPC calls into a single call, and maybe clean up the results so that they are easier to consume.

### Dependencies

- [OpenZeppelin Contracts](https://openzeppelin.com/contracts/)

  The OpenZeppelin contract library is heavily leveraged by our contracts. It includes several well tested, reusable libraries.

- [Royalty Registry](https://royaltyregistry.xyz/)

  The Royalty Registry is leveraged to allow collection owners to define or update royalty information for their NFTs.

## Mixins

In order to maintain readability as our contracts grow in complexity, we separate responsibilities into different abstract contracts which we call 'mixins'. We try not to create too many interdependencies between mixins, shared logic may be defined in `NFTMarketCore` so mixins do not need to call each other directly.

## Contract UML

Below is a diagram depicting the relationships between various contracts.

![Flowchart 2-Contract UML](https://user-images.githubusercontent.com/14855515/161260681-64774e18-d429-46ba-8c35-52efa0eb92e3.png)

## Market Tool Interactions

Each of the market tools have dependencies and interactions with the others. The goal of these interactions is to do what's most likely intended or expected by the user -- and avoid leaving either the buyer or seller in an awkward state. For instance:

- In progress auctions must go to the highest bidder. This means that a buy price is not valid, it cannot be accepted. And since both offers and auctions last for 24 hours, the offer cannot be accepted so we should free those FETH tokens for the collector to use elsewhere.
- Auto-buy: If you make an offer above the current buy now price, process the purchase immediately.
- Auto-accept-offer: Similarly if you set a buy price lower than the highest offer, accept that offer instead.

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
