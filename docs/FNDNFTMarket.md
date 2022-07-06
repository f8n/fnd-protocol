# FNDNFTMarket



> A market for NFTs on Foundation.

The Foundation marketplace is a contract which allows traders to buy and sell NFTs. It supports buying and selling via auctions, private sales, buy price, and offers.

*All sales in the Foundation market will pay the creator 10% royalties on secondary sales. This is not specific to NFTs minted on Foundation, it should work for any NFT. If royalty information was not defined when the NFT was originally deployed, it may be added using the [Royalty Registry](https://royaltyregistry.xyz/) which will be respected by our market contract.*

## Methods

### acceptOffer

```solidity
function acceptOffer(address nftContract, uint256 tokenId, address offerFrom, uint256 minAmount) external nonpayable
```

Accept the highest offer for an NFT.

*The offer must not be expired and the NFT owned + approved by the seller or available in the market contract&#39;s escrow.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |
| offerFrom | address | The address of the collector that you wish to sell to. If the current highest offer is not from this user, the transaction will revert. This could happen if a last minute offer was made by another collector, and would require the seller to try accepting again. |
| minAmount | uint256 | The minimum value of the highest offer for it to be accepted. If the value is less than this amount, the transaction will revert. This could happen if the original offer expires and is replaced with a smaller offer. |

### adminCancelOffers

```solidity
function adminCancelOffers(address[] nftContracts, uint256[] tokenIds, string reason) external nonpayable
```

Allows Foundation to cancel offers. This will unlock the funds in the FETH ERC-20 contract for the highest offer and prevent the offer from being accepted.

*This should only be used for extreme cases such as DMCA takedown requests.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContracts | address[] | The addresses of the NFT contracts to cancel. This must be the same length as `tokenIds`. |
| tokenIds | uint256[] | The ids of the NFTs to cancel. This must be the same length as `nftContracts`. |
| reason | string | The reason for the cancellation (a required field). |

### adminCancelReserveAuction

```solidity
function adminCancelReserveAuction(uint256 auctionId, string reason) external nonpayable
```

Allows Foundation to cancel an auction, refunding the bidder and returning the NFT to the seller (if not active buy price set). This should only be used for extreme cases such as DMCA takedown requests.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | The id of the auction to cancel. |
| reason | string | The reason for the cancellation (a required field). |

### buy

```solidity
function buy(address nftContract, uint256 tokenId, uint256 maxPrice) external payable
```

Buy the NFT at the set buy price. `msg.value` must be &lt;= `maxPrice` and any delta will be taken from the account&#39;s available FETH balance.

*`maxPrice` protects the buyer in case a the price is increased but allows the transaction to continue when the price is reduced (and any surplus funds provided are refunded).*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |
| maxPrice | uint256 | The maximum price to pay for the NFT. |

### buyV2

```solidity
function buyV2(address nftContract, uint256 tokenId, uint256 maxPrice, address payable referrer) external payable
```

Buy the NFT at the set buy price. `msg.value` must be &lt;= `maxPrice` and any delta will be taken from the account&#39;s available FETH balance.

*`maxPrice` protects the buyer in case a the price is increased but allows the transaction to continue when the price is reduced (and any surplus funds provided are refunded).*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |
| maxPrice | uint256 | The maximum price to pay for the NFT. |
| referrer | address payable | The address of the referrer. |

### cancelBuyPrice

```solidity
function cancelBuyPrice(address nftContract, uint256 tokenId) external nonpayable
```

Removes the buy price set for an NFT.

*The NFT is transferred back to the owner unless it&#39;s still escrowed for another market tool, e.g. listed for sale in an auction.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |

### cancelReserveAuction

```solidity
function cancelReserveAuction(uint256 auctionId) external nonpayable
```

If an auction has been created but has not yet received bids, it may be canceled by the seller.

*The NFT is transferred back to the owner unless there is still a buy price set.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | The id of the auction to cancel. |

### createReserveAuction

```solidity
function createReserveAuction(address nftContract, uint256 tokenId, uint256 reservePrice) external nonpayable
```

Creates an auction for the given NFT. The NFT is held in escrow until the auction is finalized or canceled.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |
| reservePrice | uint256 | The initial reserve price for the auction. |

### finalizeReserveAuction

```solidity
function finalizeReserveAuction(uint256 auctionId) external nonpayable
```

Once the countdown has expired for an auction, anyone can settle the auction. This will send the NFT to the highest bidder and distribute revenue for this sale.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | The id of the auction to settle. |

### getBuyPrice

```solidity
function getBuyPrice(address nftContract, uint256 tokenId) external view returns (address seller, uint256 price)
```

Returns the buy price details for an NFT if one is available.

*If no price is found, seller will be address(0) and price will be max uint256.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |

#### Returns

| Name | Type | Description |
|---|---|---|
| seller | address | The address of the owner that listed a buy price for this NFT. Returns `address(0)` if there is no buy price set for this NFT. |
| price | uint256 | The price of the NFT. Returns `0` if there is no buy price set for this NFT. |

### getFeesAndRecipients

```solidity
function getFeesAndRecipients(address nftContract, uint256 tokenId, uint256 price) external view returns (uint256 protocolFee, uint256 creatorRev, address payable[] creatorRecipients, uint256[] creatorShares, uint256 sellerRev, address payable owner)
```

Returns how funds will be distributed for a sale at the given price point.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |
| price | uint256 | The sale price to calculate the fees for. |

#### Returns

| Name | Type | Description |
|---|---|---|
| protocolFee | uint256 | How much will be sent to the Foundation treasury. |
| creatorRev | uint256 | How much will be sent across all the `creatorRecipients` defined. |
| creatorRecipients | address payable[] | The addresses of the recipients to receive a portion of the creator fee. |
| creatorShares | uint256[] | The percentage of the creator fee to be distributed to each `creatorRecipient`. If there is only one `creatorRecipient`, this may be an empty array. Otherwise `creatorShares.length` == `creatorRecipients.length`. |
| sellerRev | uint256 | How much will be sent to the owner/seller of the NFT. If the NFT is being sold by the creator, this may be 0 and the full revenue will appear as `creatorRev`. |
| owner | address payable | The address of the owner of the NFT. If `sellerRev` is 0, this may be `address(0)`. |

### getFethAddress

```solidity
function getFethAddress() external view returns (address fethAddress)
```

Gets the FETH contract used to escrow offer funds.




#### Returns

| Name | Type | Description |
|---|---|---|
| fethAddress | address | The FETH contract address. |

### getFoundationTreasury

```solidity
function getFoundationTreasury() external view returns (address payable treasuryAddress)
```

Gets the Foundation treasury contract.

*This call is used in the royalty registry contract.*


#### Returns

| Name | Type | Description |
|---|---|---|
| treasuryAddress | address payable | The address of the Foundation treasury contract. |

### getImmutableRoyalties

```solidity
function getImmutableRoyalties(address nftContract, uint256 tokenId) external view returns (address payable[] recipients, uint256[] splitPerRecipientInBasisPoints)
```

For internal use only.

*This function is external to allow using try/catch but is not intended for external use. If ERC2981 royalties (or getRoyalties) are defined by the NFT contract, allow this standard to define immutable royalties that cannot be later changed via the royalty registry.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | undefined |
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| recipients | address payable[] | undefined |
| splitPerRecipientInBasisPoints | uint256[] | undefined |

### getMinBidAmount

```solidity
function getMinBidAmount(uint256 auctionId) external view returns (uint256 minimum)
```

Returns the minimum amount a bidder must spend to participate in an auction. Bids must be greater than or equal to this value or they will revert.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | The id of the auction to check. |

#### Returns

| Name | Type | Description |
|---|---|---|
| minimum | uint256 | The minimum amount for a bid to be accepted. |

### getMinOfferAmount

```solidity
function getMinOfferAmount(address nftContract, uint256 tokenId) external view returns (uint256 minimum)
```

Returns the minimum amount a collector must offer for this NFT in order for the offer to be valid.

*Offers for this NFT which are less than this value will revert. Once the previous offer has expired smaller offers can be made.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |

#### Returns

| Name | Type | Description |
|---|---|---|
| minimum | uint256 | The minimum amount that must be offered for this NFT. |

### getMutableRoyalties

```solidity
function getMutableRoyalties(address nftContract, uint256 tokenId, address payable creator) external view returns (address payable[] recipients, uint256[] splitPerRecipientInBasisPoints)
```

For internal use only.

*This function is external to allow using try/catch but is not intended for external use. This checks for royalties defined in the royalty registry or via a non-standard royalty API.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | undefined |
| tokenId | uint256 | undefined |
| creator | address payable | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| recipients | address payable[] | undefined |
| splitPerRecipientInBasisPoints | uint256[] | undefined |

### getOffer

```solidity
function getOffer(address nftContract, uint256 tokenId) external view returns (address buyer, uint256 expiration, uint256 amount)
```

Returns details about the current highest offer for an NFT.

*Default values are returned if there is no offer or the offer has expired.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |

#### Returns

| Name | Type | Description |
|---|---|---|
| buyer | address | The address of the buyer that made the current highest offer. Returns `address(0)` if there is no offer or the most recent offer has expired. |
| expiration | uint256 | The timestamp that the current highest offer expires. Returns `0` if there is no offer or the most recent offer has expired. |
| amount | uint256 | The amount being offered for this NFT. Returns `0` if there is no offer or the most recent offer has expired. |

### getOfferReferrer

```solidity
function getOfferReferrer(address nftContract, uint256 tokenId) external view returns (address payable referrer)
```

Returns the current highest offer&#39;s referral for an NFT.

*Default value of `payable(0)` is returned if there is no offer, the offer has expired or does not have a referral.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |

#### Returns

| Name | Type | Description |
|---|---|---|
| referrer | address payable | The payable address of the referrer for the offer. |

### getReserveAuction

```solidity
function getReserveAuction(uint256 auctionId) external view returns (struct NFTMarketReserveAuction.ReserveAuction auction)
```

Returns auction details for a given auctionId.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | The id of the auction to lookup. |

#### Returns

| Name | Type | Description |
|---|---|---|
| auction | NFTMarketReserveAuction.ReserveAuction | undefined |

### getReserveAuctionBidReferrer

```solidity
function getReserveAuctionBidReferrer(uint256 auctionId) external view returns (address payable referrer)
```

Returns the referrer for the current highest bid in the auction, or address(0).



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| referrer | address payable | undefined |

### getReserveAuctionIdFor

```solidity
function getReserveAuctionIdFor(address nftContract, uint256 tokenId) external view returns (uint256 auctionId)
```

Returns the auctionId for a given NFT, or 0 if no auction is found.

*If an auction is canceled, it will not be returned. However the auction may be over and pending finalization.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |

#### Returns

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | The id of the auction, or 0 if no auction is found. |

### getRoyaltyRegistry

```solidity
function getRoyaltyRegistry() external view returns (address registry)
```

Returns the address of the registry allowing for royalty configuration overrides.




#### Returns

| Name | Type | Description |
|---|---|---|
| registry | address | The address of the royalty registry contract. |

### getTokenCreator

```solidity
function getTokenCreator(address nftContract, uint256 tokenId) external view returns (address payable creator)
```

For internal use only.

*This function is external to allow using try/catch but is not intended for external use. This checks the token creator.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | undefined |
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| creator | address payable | undefined |

### initialize

```solidity
function initialize() external nonpayable
```

Called once to configure the contract after the initial proxy deployment.

*This farms the initialize call out to inherited contracts as needed to initialize mutable variables.*


### makeOffer

```solidity
function makeOffer(address nftContract, uint256 tokenId, uint256 amount) external payable returns (uint256 expiration)
```

[DEPRECATED] Please use `makeOfferV2`.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | undefined |
| tokenId | uint256 | undefined |
| amount | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| expiration | uint256 | undefined |

### makeOfferV2

```solidity
function makeOfferV2(address nftContract, uint256 tokenId, uint256 amount, address payable referrer) external payable returns (uint256 expiration)
```

Make an offer for any NFT which is valid for 24-25 hours. The funds will be locked in the FETH token contract and become available once the offer is outbid or has expired.

*An offer may be made for an NFT before it is minted, although we generally not recommend you do that. If there is a buy price set at this price or lower, that will be accepted instead of making an offer. `msg.value` must be &lt;= `amount` and any delta will be taken from the account&#39;s available FETH balance.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |
| amount | uint256 | The amount to offer for this NFT. |
| referrer | address payable | The refrerrer address for the offer. |

#### Returns

| Name | Type | Description |
|---|---|---|
| expiration | uint256 | The timestamp for when this offer will expire. This is provided as a return value in case another contract would like to leverage this information, user&#39;s should refer to the expiration in the `OfferMade` event log. If the buy price is accepted instead, `0` is returned as the expiration since that&#39;s n/a. |

### placeBid

```solidity
function placeBid(uint256 auctionId) external payable
```

Place a bid in an auction. A bidder may place a bid which is at least the value defined by `getMinBidAmount`. If this is the first bid on the auction, the countdown will begin. If there is already an outstanding bid, the previous bidder will be refunded at this time and if the bid is placed in the final moments of the auction, the countdown may be extended.

*This API is deprecated and will be removed in the future, `placeBidV2` should be used instead.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | The id of the auction to bid on. |

### placeBidV2

```solidity
function placeBidV2(uint256 auctionId, uint256 amount, address payable referrer) external payable
```

Place a bid in an auction. A bidder may place a bid which is at least the amount defined by `getMinBidAmount`. If this is the first bid on the auction, the countdown will begin. If there is already an outstanding bid, the previous bidder will be refunded at this time and if the bid is placed in the final moments of the auction, the countdown may be extended.

*`amount` - `msg.value` is withdrawn from the bidder&#39;s FETH balance.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | The id of the auction to bid on. |
| amount | uint256 | The amount to bid, if this is more than `msg.value` funds will be withdrawn from your FETH balance. |
| referrer | address payable | undefined |

### setBuyPrice

```solidity
function setBuyPrice(address nftContract, uint256 tokenId, uint256 price) external nonpayable
```

Sets the buy price for an NFT and escrows it in the market contract. A 0 price is acceptable and valid price you can set, enabling a giveaway to the first collector that calls `buy`.

*If there is an offer for this amount or higher, that will be accepted instead of setting a buy price.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the NFT contract. |
| tokenId | uint256 | The id of the NFT. |
| price | uint256 | The price at which someone could buy this NFT. |

### updateReserveAuction

```solidity
function updateReserveAuction(uint256 auctionId, uint256 reservePrice) external nonpayable
```

If an auction has been created but has not yet received bids, the reservePrice may be changed by the seller.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | The id of the auction to change. |
| reservePrice | uint256 | The new reserve price for this auction. |



## Events

### BuyPriceAccepted

```solidity
event BuyPriceAccepted(address indexed nftContract, uint256 indexed tokenId, address indexed seller, address buyer, uint256 protocolFee, uint256 creatorFee, uint256 sellerRev)
```

Emitted when an NFT is bought by accepting the buy price, indicating that the NFT has been transferred and revenue from the sale distributed.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |
| seller `indexed` | address | undefined |
| buyer  | address | undefined |
| protocolFee  | uint256 | undefined |
| creatorFee  | uint256 | undefined |
| sellerRev  | uint256 | undefined |

### BuyPriceCanceled

```solidity
event BuyPriceCanceled(address indexed nftContract, uint256 indexed tokenId)
```

Emitted when the buy price is removed by the owner of an NFT.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |

### BuyPriceInvalidated

```solidity
event BuyPriceInvalidated(address indexed nftContract, uint256 indexed tokenId)
```

Emitted when a buy price is invalidated due to other market activity.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |

### BuyPriceSet

```solidity
event BuyPriceSet(address indexed nftContract, uint256 indexed tokenId, address indexed seller, uint256 price)
```

Emitted when a buy price is set by the owner of an NFT.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |
| seller `indexed` | address | undefined |
| price  | uint256 | undefined |

### BuyReferralPaid

```solidity
event BuyReferralPaid(address indexed nftContract, uint256 indexed tokenId, address buyReferrer, uint256 buyReferrerProtocolFee, uint256 buyReferrerSellerFee)
```

Emitted when a NFT sold with a referrer.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |
| buyReferrer  | address | undefined |
| buyReferrerProtocolFee  | uint256 | undefined |
| buyReferrerSellerFee  | uint256 | undefined |

### Initialized

```solidity
event Initialized(uint8 version)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| version  | uint8 | undefined |

### OfferAccepted

```solidity
event OfferAccepted(address indexed nftContract, uint256 indexed tokenId, address indexed buyer, address seller, uint256 protocolFee, uint256 creatorFee, uint256 sellerRev)
```

Emitted when an offer is accepted, indicating that the NFT has been transferred and revenue from the sale distributed.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |
| buyer `indexed` | address | undefined |
| seller  | address | undefined |
| protocolFee  | uint256 | undefined |
| creatorFee  | uint256 | undefined |
| sellerRev  | uint256 | undefined |

### OfferCanceledByAdmin

```solidity
event OfferCanceledByAdmin(address indexed nftContract, uint256 indexed tokenId, string reason)
```

Emitted when an offer is canceled by a Foundation admin.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |
| reason  | string | undefined |

### OfferInvalidated

```solidity
event OfferInvalidated(address indexed nftContract, uint256 indexed tokenId)
```

Emitted when an offer is invalidated due to other market activity. When this occurs, the collector which made the offer has their FETH balance unlocked and the funds are available to place other offers or to be withdrawn.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |

### OfferMade

```solidity
event OfferMade(address indexed nftContract, uint256 indexed tokenId, address indexed buyer, uint256 amount, uint256 expiration)
```

Emitted when an offer is made.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |
| buyer `indexed` | address | undefined |
| amount  | uint256 | undefined |
| expiration  | uint256 | undefined |

### ReserveAuctionBidPlaced

```solidity
event ReserveAuctionBidPlaced(uint256 indexed auctionId, address indexed bidder, uint256 amount, uint256 endTime)
```

Emitted when a bid is placed.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId `indexed` | uint256 | undefined |
| bidder `indexed` | address | undefined |
| amount  | uint256 | undefined |
| endTime  | uint256 | undefined |

### ReserveAuctionCanceled

```solidity
event ReserveAuctionCanceled(uint256 indexed auctionId)
```

Emitted when an auction is cancelled.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId `indexed` | uint256 | undefined |

### ReserveAuctionCanceledByAdmin

```solidity
event ReserveAuctionCanceledByAdmin(uint256 indexed auctionId, string reason)
```

Emitted when an auction is canceled by a Foundation admin.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId `indexed` | uint256 | undefined |
| reason  | string | undefined |

### ReserveAuctionCreated

```solidity
event ReserveAuctionCreated(address indexed seller, address indexed nftContract, uint256 indexed tokenId, uint256 duration, uint256 extensionDuration, uint256 reservePrice, uint256 auctionId)
```

Emitted when an NFT is listed for auction.



#### Parameters

| Name | Type | Description |
|---|---|---|
| seller `indexed` | address | undefined |
| nftContract `indexed` | address | undefined |
| tokenId `indexed` | uint256 | undefined |
| duration  | uint256 | undefined |
| extensionDuration  | uint256 | undefined |
| reservePrice  | uint256 | undefined |
| auctionId  | uint256 | undefined |

### ReserveAuctionFinalized

```solidity
event ReserveAuctionFinalized(uint256 indexed auctionId, address indexed seller, address indexed bidder, uint256 protocolFee, uint256 creatorFee, uint256 sellerRev)
```

Emitted when an auction that has already ended is finalized, indicating that the NFT has been transferred and revenue from the sale distributed.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId `indexed` | uint256 | undefined |
| seller `indexed` | address | undefined |
| bidder `indexed` | address | undefined |
| protocolFee  | uint256 | undefined |
| creatorFee  | uint256 | undefined |
| sellerRev  | uint256 | undefined |

### ReserveAuctionInvalidated

```solidity
event ReserveAuctionInvalidated(uint256 indexed auctionId)
```

Emitted when an auction is invalidated due to other market activity.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId `indexed` | uint256 | undefined |

### ReserveAuctionUpdated

```solidity
event ReserveAuctionUpdated(uint256 indexed auctionId, uint256 reservePrice)
```

Emitted when the auction&#39;s reserve price is changed.



#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId `indexed` | uint256 | undefined |
| reservePrice  | uint256 | undefined |

### WithdrawalToFETH

```solidity
event WithdrawalToFETH(address indexed user, uint256 amount)
```

Emitted when escrowed funds are withdrawn to FETH.



#### Parameters

| Name | Type | Description |
|---|---|---|
| user `indexed` | address | undefined |
| amount  | uint256 | undefined |



## Errors

### FoundationTreasuryNode_Address_Is_Not_A_Contract

```solidity
error FoundationTreasuryNode_Address_Is_Not_A_Contract()
```






### FoundationTreasuryNode_Caller_Not_Admin

```solidity
error FoundationTreasuryNode_Caller_Not_Admin()
```






### NFTMarketBuyPrice_Cannot_Buy_At_Lower_Price

```solidity
error NFTMarketBuyPrice_Cannot_Buy_At_Lower_Price(uint256 buyPrice)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| buyPrice | uint256 | The current buy price set for this NFT. |

### NFTMarketBuyPrice_Cannot_Buy_Unset_Price

```solidity
error NFTMarketBuyPrice_Cannot_Buy_Unset_Price()
```






### NFTMarketBuyPrice_Cannot_Cancel_Unset_Price

```solidity
error NFTMarketBuyPrice_Cannot_Cancel_Unset_Price()
```






### NFTMarketBuyPrice_Only_Owner_Can_Cancel_Price

```solidity
error NFTMarketBuyPrice_Only_Owner_Can_Cancel_Price(address owner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | The current owner of this NFT. |

### NFTMarketBuyPrice_Only_Owner_Can_Set_Price

```solidity
error NFTMarketBuyPrice_Only_Owner_Can_Set_Price(address owner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | The current owner of this NFT. |

### NFTMarketBuyPrice_Price_Already_Set

```solidity
error NFTMarketBuyPrice_Price_Already_Set()
```






### NFTMarketBuyPrice_Price_Too_High

```solidity
error NFTMarketBuyPrice_Price_Too_High()
```






### NFTMarketBuyPrice_Seller_Mismatch

```solidity
error NFTMarketBuyPrice_Seller_Mismatch(address seller)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| seller | address | The current owner of this NFT. |

### NFTMarketCore_FETH_Address_Is_Not_A_Contract

```solidity
error NFTMarketCore_FETH_Address_Is_Not_A_Contract()
```






### NFTMarketCore_Only_FETH_Can_Transfer_ETH

```solidity
error NFTMarketCore_Only_FETH_Can_Transfer_ETH()
```






### NFTMarketCore_Seller_Not_Found

```solidity
error NFTMarketCore_Seller_Not_Found()
```






### NFTMarketFees_Address_Does_Not_Support_IRoyaltyRegistry

```solidity
error NFTMarketFees_Address_Does_Not_Support_IRoyaltyRegistry()
```






### NFTMarketOffer_Cannot_Be_Made_While_In_Auction

```solidity
error NFTMarketOffer_Cannot_Be_Made_While_In_Auction()
```






### NFTMarketOffer_Offer_Below_Min_Amount

```solidity
error NFTMarketOffer_Offer_Below_Min_Amount(uint256 currentOfferAmount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| currentOfferAmount | uint256 | The current highest offer available for this NFT. |

### NFTMarketOffer_Offer_Expired

```solidity
error NFTMarketOffer_Offer_Expired(uint256 expiry)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| expiry | uint256 | The time at which the offer had expired. |

### NFTMarketOffer_Offer_From_Does_Not_Match

```solidity
error NFTMarketOffer_Offer_From_Does_Not_Match(address currentOfferFrom)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| currentOfferFrom | address | The address of the collector which has made the current highest offer. |

### NFTMarketOffer_Offer_Must_Be_At_Least_Min_Amount

```solidity
error NFTMarketOffer_Offer_Must_Be_At_Least_Min_Amount(uint256 minOfferAmount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| minOfferAmount | uint256 | The minimum amount that must be offered in order for it to be accepted. |

### NFTMarketOffer_Provided_Contract_And_TokenId_Count_Must_Match

```solidity
error NFTMarketOffer_Provided_Contract_And_TokenId_Count_Must_Match()
```






### NFTMarketOffer_Reason_Required

```solidity
error NFTMarketOffer_Reason_Required()
```






### NFTMarketReserveAuction_Already_Listed

```solidity
error NFTMarketReserveAuction_Already_Listed(uint256 auctionId)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| auctionId | uint256 | The already listed auctionId for this NFT. |

### NFTMarketReserveAuction_Bid_Must_Be_At_Least_Min_Amount

```solidity
error NFTMarketReserveAuction_Bid_Must_Be_At_Least_Min_Amount(uint256 minAmount)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| minAmount | uint256 | The minimum amount that must be bid in order for it to be accepted. |

### NFTMarketReserveAuction_Cannot_Admin_Cancel_Without_Reason

```solidity
error NFTMarketReserveAuction_Cannot_Admin_Cancel_Without_Reason()
```






### NFTMarketReserveAuction_Cannot_Bid_Lower_Than_Reserve_Price

```solidity
error NFTMarketReserveAuction_Cannot_Bid_Lower_Than_Reserve_Price(uint256 reservePrice)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| reservePrice | uint256 | The current reserve price. |

### NFTMarketReserveAuction_Cannot_Bid_On_Ended_Auction

```solidity
error NFTMarketReserveAuction_Cannot_Bid_On_Ended_Auction(uint256 endTime)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| endTime | uint256 | The timestamp at which the auction had ended. |

### NFTMarketReserveAuction_Cannot_Bid_On_Nonexistent_Auction

```solidity
error NFTMarketReserveAuction_Cannot_Bid_On_Nonexistent_Auction()
```






### NFTMarketReserveAuction_Cannot_Cancel_Nonexistent_Auction

```solidity
error NFTMarketReserveAuction_Cannot_Cancel_Nonexistent_Auction()
```






### NFTMarketReserveAuction_Cannot_Finalize_Already_Settled_Auction

```solidity
error NFTMarketReserveAuction_Cannot_Finalize_Already_Settled_Auction()
```






### NFTMarketReserveAuction_Cannot_Finalize_Auction_In_Progress

```solidity
error NFTMarketReserveAuction_Cannot_Finalize_Auction_In_Progress(uint256 endTime)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| endTime | uint256 | The timestamp at which the auction will end. |

### NFTMarketReserveAuction_Cannot_Rebid_Over_Outstanding_Bid

```solidity
error NFTMarketReserveAuction_Cannot_Rebid_Over_Outstanding_Bid()
```






### NFTMarketReserveAuction_Cannot_Update_Auction_In_Progress

```solidity
error NFTMarketReserveAuction_Cannot_Update_Auction_In_Progress()
```






### NFTMarketReserveAuction_Exceeds_Max_Duration

```solidity
error NFTMarketReserveAuction_Exceeds_Max_Duration(uint256 maxDuration)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| maxDuration | uint256 | The maximum configuration for a duration of the auction, in seconds. |

### NFTMarketReserveAuction_Less_Than_Extension_Duration

```solidity
error NFTMarketReserveAuction_Less_Than_Extension_Duration(uint256 extensionDuration)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| extensionDuration | uint256 | The extension duration, in seconds. |

### NFTMarketReserveAuction_Must_Set_Non_Zero_Reserve_Price

```solidity
error NFTMarketReserveAuction_Must_Set_Non_Zero_Reserve_Price()
```






### NFTMarketReserveAuction_Not_Matching_Seller

```solidity
error NFTMarketReserveAuction_Not_Matching_Seller(address seller)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| seller | address | The current owner of the NFT. |

### NFTMarketReserveAuction_Only_Owner_Can_Update_Auction

```solidity
error NFTMarketReserveAuction_Only_Owner_Can_Update_Auction(address owner)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| owner | address | The current owner of the NFT. |

### NFTMarketReserveAuction_Price_Already_Set

```solidity
error NFTMarketReserveAuction_Price_Already_Set()
```






### NFTMarketReserveAuction_Too_Much_Value_Provided

```solidity
error NFTMarketReserveAuction_Too_Much_Value_Provided()
```







