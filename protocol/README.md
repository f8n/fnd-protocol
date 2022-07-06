# Protocol

## Contracts Overview

### Marketplace

#### [Market](fndnftmarket.md)

The Foundation marketplace is a contract which allows traders to buy and sell NFTs. Details on each market mechanic below.

- Auctions last for 24 hours. The NFT is escrowed in the market contract when it's listed. As soon as a bid is received the NFT cannot be withdrawn, guaranteeing that the sale will go through and the highest bidder gets the NFT. If a bid is placed in the final minutes of an auction, the countdown timer resets to 15-minutes remaining.
- Private Sales use a EIP-712 signature from the seller to authorize the trade to a specific buyer / price point. The buyer has 24 hours to accept the offer to buy the NFT before the signature expires.
- Buy Price allows the owner of an NFT to list it for sale at a specific price point. The NFT is escrowed in the market contract when the price is set. Once a collector buys at the price set, the NFT is instantly transferred and revenue is distributed.
- Offers allow collectors to make an offer for an NFT. The seller has \~24 hours to accept the offer. During this time, the collector's funds are locked in the FETH ERC-20 contract - ensuring that an offer remains valid until its expiration. If a higher offer is made, the original user's FETH balance is unlocked and they can use those funds elsewhere (or withdraw the ETH).

All sales in the Foundation market will pay the creator 10% royalties on secondary sales. This is not specific to NFTs minted on Foundation, it should work for any NFT. If royalty information was not defined when the NFT was originally deployed, it may be added using the [Royalty Registry](https://royaltyregistry.xyz/) which will be respected by our market contract.

#### [FETH](feth.md)

FETH is an [ERC-20 token](https://eips.ethereum.org/EIPS/eip-20) modeled after [WETH9](https://etherscan.io/address/0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2#code), with the added ability to lockup tokens for \~24 hours. During this time they may not be transferred or withdrawn, except by the market contract which requested the lockup in the first place.

This functionality is used for offers in the Foundation market - funds used for offers must remain available for \~24 hours so the seller has a reasonable window to consider and accept it. This protects sellers against collectors invalidating offers or withdrawing funds.

Once the offer expires, the FETH tokens become available again. Their `balanceOf` automatically increases at the time it expires and they can then transfer or withdraw those funds -- or they can use them to place another offer!

Because FETH is a wrapped ETH token contract, your balance can be used for other transactions such as placing a bid.

#### **Marketplace State Machine**

Below is a diagram depicting the marketplace states and transitions for the various market tools.

![Flowchart 1-Marketplace State Machine](https://user-images.githubusercontent.com/14855515/161260593-2bc20f67-4c70-4450-b3a2-eea5a7cd45ff.png)

### NFTs

- [Shared NFT](fndnft721.md)
  - The original NFT contract on Foundation.
  - A single contract allowing any creator to mint an NFT.
- [Collection Factory](fndcollectionfactory.md)
  - A factory allowing a creator to create an ERC-1167 proxy contract for a collection of NFTs by a single creator.
- [Collection Contract Template](collectioncontract.md)
  - The implementation template used by all collection contracts created with the Collection Factory.
  - Collection contracts are immutable, so the latest template is only leveraged by newly created contracts.
- [Percent Splits](percentspliteth.md)
  - Allows anyone to create a contract which will forward ETH received to a list of recipients, splitting the payment between them according to the split's configuration defined in basis points.
  - Also supports ERC-20 tokens, but tokens are not automatically forwarded like with ETH - someone must trigger the distribution of the current holdings.
  - Arbitrary proxy calls may be made by any of the split recipients, in case another asset needs to be claimed or recovered (such as an NFT).

### Other

- [Treasury](foundationtreasury.md)

  The Foundation Treasury contract collects revenue from each sale on Foundation.

- [Middleware](fndmiddleware.md)

  The Foundation Middleware contract is a convenience contract leveraged by our frontend and/or backend in order to batch RPC calls into a single call, and maybe clean up the results so that they are easier to consume.

### Dependencies

- [OpenZeppelin Contracts](https://openzeppelin.com/contracts/)

  The OpenZeppelin contract library is heavily leveraged by our contracts. It includes several well-tested reusable libraries.

- [Royalty Registry](https://royaltyregistry.xyz/)

  The Royalty Registry is leveraged to allow collection owners to define or update royalty information for their NFTs.

### Mixins

In order to maintain readability as our contracts grow in complexity, we separate responsibilities into different abstract contracts which we call 'mixins'. To prevent interdependencies between mixins, shared logic may be defined in `NFTMarketCore`.

## Contract UML

Below is a diagram depicting the relationships between various contracts.

![Flowchart 2-Contract UML](https://user-images.githubusercontent.com/14855515/161260681-64774e18-d429-46ba-8c35-52efa0eb92e3.png)

## Market Tool Interactions

Each of the market tools has dependencies and interactions with the others. The goal of these interactions is to do what's most likely intended or expected by the user -- and to avoid leaving either the buyer or seller in an awkward state. For instance:

- In progress auctions must go to the highest bidder. Buy prices & offers are invalidated when an auction begins.
- Auto-buy: If an offer is made above the buy now price, the purchase is processed immediately.
- Auto-accept-offer: If a buy price is set lower than the highest offer, the offer is accepted.
