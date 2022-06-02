# Docs

## Contracts Overview

### Marketplace

#### [Market](FNDNFTMarket.md)

The Foundation marketplace is a contract which allows traders to buy and sell NFTs.

Details on each market mechanic:

* Auctions last for 24 hours. The NFT is escrowed in the market contract when it's listed. As soon as a bid is received the NFT cannot be withdrawn, guaranteeing that the sale will go through and the highest bidder gets the NFT. If a bid is placed in the final minutes of an auction, the countdown timer resets to 15-minutes remaining.
* Private Sales use a EIP-712 signature from the seller to authorize the trade to a specific buyer / price point. The buyer has 24 hours to accept the offer to buy the NFT before the signature expires.
* Buy Price allows the owner of an NFT to list it for sale at a specific price point. The NFT is escrowed in the market contract when the price is set. Once a collector buys at the price set, the NFT is instantly transferred and revenue is distributed.
* Offers allow collectors to make an offer for an NFT. The seller has 24-25 hours to accept the offer. During this time, the collector's funds are locked in the FETH ERC-20 contract - ensuring that an offer remains valid until its expiration. If a higher offer is made, the original user's FETH balance is unlocked and they can use those funds elsewhere (or withdraw the ETH).

All sales in the Foundation market will pay the creator 10% royalties on secondary sales. This is not specific to NFTs minted on Foundation, it should work for any NFT. If royalty information was not defined when the NFT was originally deployed, it may be added using the [Royalty Registry](https://royaltyregistry.xyz/) which will be respected by our market contract.

#### [FETH](FETH.md)

FETH is an [ERC-20 token](https://eips.ethereum.org/EIPS/eip-20) modeled after [WETH9](https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code). It has the added ability to lockup tokens for 24-25 hours - during this time they may not be transferred or withdrawn, except by the market contract which requested the lockup in the first place.

* We strive to offer strong guarantees for both buyers and sellers, which is why a seller cannot back out of an auction once the first bid has been placed.&#x20;
* For offers, this means once a collector has made an offer for an NFT - those funds must remain available for a period of time so the seller has a reasonable window to consider and accept it without worrying that the collector might just withdraw their funds, making the offer invalid.
* We implement this feature in the FETH token contract, allowing funds to be locked up for 24-25 hours while the seller considers accepting the offer.
* Once the offer expires, the FETH tokens become available again. Their `balanceOf` automatically increases at the time it expires and they can then transfer or withdraw those funds -- or they can use them to place another offer!
* Since after lockups expire, FETH is just another wrapped ETH token contract - we allow using your available FETH balance with all the other market tools: place a bid with FETH, buy now with FETH, or buy from a private sale using FETH.

#### **Marketplace State Machine**

Below is a diagram depicting the marketplace states and transitions for the various market tools.

![Flowchart 1-Marketplace State Machine](https://user-images.githubusercontent.com/14855515/161260593-2bc20f67-4c70-4450-b3a2-eea5a7cd45ff.png)

### NFTs

* [Shared NFT](FNDNFT721.md)
  * The original NFT contract on Foundation.
  * A single contract allowing any creator to mint an NFT.
* [Collection Factory](FNDCollectionFactory.md)
  * A factory allowing a creator to create an ERC-1167 proxy contract for a collection of NFTs by a single creator.
* [Collection Contract Template](CollectionContract.md)
  * The implementation template used by all collection contracts created with the Collection Factory.
  * Collection contracts are immutable, so the latest template is only leveraged by newly created contracts.
* [Percent Splits](PercentSplitETH.md)
  * Allows anyone to create a contract which will forward ETH received to a list of recipients, splitting the payment between them according to the split's configuration defined in basis points.
  * Also supports ERC-20 tokens, but tokens are not automatically forwarded like with ETH - someone must trigger the distribution of the current holdings.
  * Arbitrary proxy calls may be made by any of the split recipients, in case another asset needs to be claimed or recovered (such as an NFT).

### Other

*   [Treasury](FoundationTreasury.md)

    The Foundation Treasury contract collects revenue from each sale on Foundation.
*   [Middleware](FNDMiddleware.md)

    The Foundation Middleware contract is a convenience contract leveraged by our frontend and/or backend in order to batch RPC calls into a single call, and maybe clean up the results so that they are easier to consume.

### Dependencies

*   [OpenZeppelin Contracts](https://openzeppelin.com/contracts/)

    The OpenZeppelin contract library is heavily leveraged by our contracts. It includes several well tested, reusable libraries.
*   [Royalty Registry](https://royaltyregistry.xyz/)

    The Royalty Registry is leveraged to allow collection owners to define or update royalty information for their NFTs.

### Mixins

In order to maintain readability as our contracts grow in complexity, we separate responsibilities into different abstract contracts which we call 'mixins'. We try not to create too many interdependencies between mixins, shared logic may be defined in `NFTMarketCore` so mixins do not need to call each other directly.

## Contract UML

Below is a diagram depicting the relationships between various contracts.

![Flowchart 2-Contract UML](https://user-images.githubusercontent.com/14855515/161260681-64774e18-d429-46ba-8c35-52efa0eb92e3.png)

## Market Tool Interactions

Each of the market tools have dependencies and interactions with the others. The goal of these interactions is to do what's most likely intended or expected by the user -- and avoid leaving either the buyer or seller in an awkward state. For instance:

* In progress auctions must go to the highest bidder. This means that a buy price is not valid, it cannot be accepted. And since both offers and auctions last for 24 hours, the offer cannot be accepted so we should free those FETH tokens for the collector to use elsewhere.
* Auto-buy: If you make an offer above the current buy now price, process the purchase immediately.
* Auto-accept-offer: Similarly if you set a buy price lower than the highest offer, accept that offer instead.
