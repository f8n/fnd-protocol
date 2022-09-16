---
title: NFTDropMarket
description: A market for minting NFTs with Foundation.
---






## Methods

### MINTER_ROLE

```solidity
function MINTER_ROLE() external view returns (bytes32)
```

The `role` type used to validate drop collections have granted this market access to mint.




**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `bytes32` |  |

### createFixedPriceSale

```solidity
function createFixedPriceSale(address nftContract, uint80 price, uint16 limitPerAccount) external nonpayable
```

Create a fixed price sale drop.

*Notes:   a) The sale is final and can not be updated or canceled.   b) The sale is immediately kicked off.   c) Any collection that abides by `INFTDropCollectionMint` and `IAccessControl` is supported.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` | The address of the NFT drop collection. |
| price | `uint80` | The price per NFT minted. Set price to 0 for a first come first serve airdrop-like drop. |
| limitPerAccount | `uint16` | The max number of NFTs an account may have while minting. |

### getAvailableCountFromFixedPriceSale

```solidity
function getAvailableCountFromFixedPriceSale(address nftContract, address user) external view returns (uint256 numberThatCanBeMinted)
```

Returns the max number of NFTs a given account may mint.



**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` | The address of the NFT drop collection. |
| user | `address` | The address of the user which will be minting. |

**Returns**

| Name | Type | Description |
|---|---|---|
| numberThatCanBeMinted | `uint256` | How many NFTs the user can mint. |

### getFeesAndRecipients

```solidity
function getFeesAndRecipients(address nftContract, uint256 tokenId, uint256 price) external view returns (uint256 totalFees, uint256 creatorRev, address payable[] creatorRecipients, uint256[] creatorShares, uint256 sellerRev, address payable seller)
```

Returns how funds will be distributed for a sale at the given price point.



**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` | The address of the NFT contract. |
| tokenId | `uint256` | The id of the NFT. |
| price | `uint256` | The sale price to calculate the fees for. |

**Returns**

| Name | Type | Description |
|---|---|---|
| totalFees | `uint256` | How much will be sent to the Foundation treasury and/or referrals. |
| creatorRev | `uint256` | How much will be sent across all the `creatorRecipients` defined. |
| creatorRecipients | `address payable[]` | The addresses of the recipients to receive a portion of the creator fee. |
| creatorShares | `uint256[]` | The percentage of the creator fee to be distributed to each `creatorRecipient`. If there is only one `creatorRecipient`, this may be an empty array. Otherwise `creatorShares.length` == `creatorRecipients.length`. |
| sellerRev | `uint256` | How much will be sent to the owner/seller of the NFT. If the NFT is being sold by the creator, this may be 0 and the full revenue will appear as `creatorRev`. |
| seller | `address payable` | The address of the owner of the NFT. If `sellerRev` is 0, this may be `address(0)`. |

### getFethAddress

```solidity
function getFethAddress() external view returns (address fethAddress)
```

Gets the FETH contract used to escrow offer funds.




**Returns**

| Name | Type | Description |
|---|---|---|
| fethAddress | `address` | The FETH contract address. |

### getFixedPriceSale

```solidity
function getFixedPriceSale(address nftContract) external view returns (address payable seller, uint256 price, uint256 limitPerAccount, uint256 numberOfTokensAvailableToMint, bool marketCanMint)
```

Returns details for a drop collection&#39;s fixed price sale.



**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` | The address of the NFT drop collection. |

**Returns**

| Name | Type | Description |
|---|---|---|
| seller | `address payable` | The address of the seller which listed this drop for sale. This value will be address(0) if the collection is not listed or has sold out. |
| price | `uint256` | The price per NFT minted. |
| limitPerAccount | `uint256` | The max number of NFTs an account may have while minting. |
| numberOfTokensAvailableToMint | `uint256` | The total number of NFTs that may still be minted. |
| marketCanMint | `bool` | True if this contract has permissions to mint from the given collection. |

### getFoundationTreasury

```solidity
function getFoundationTreasury() external view returns (address payable treasuryAddress)
```

Gets the Foundation treasury contract.

*This call is used in the royalty registry contract.*


**Returns**

| Name | Type | Description |
|---|---|---|
| treasuryAddress | `address payable` | The address of the Foundation treasury contract. |

### getRoyaltyRegistry

```solidity
function getRoyaltyRegistry() external view returns (address registry)
```

Returns the address of the registry allowing for royalty configuration overrides.

*See https://royaltyregistry.xyz/*


**Returns**

| Name | Type | Description |
|---|---|---|
| registry | `address` | The address of the royalty registry contract. |

### getSellerOf

```solidity
function getSellerOf(address nftContract, uint256 tokenId) external view returns (address payable seller)
```

Checks who the seller for an NFT is if listed in this market.



**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` | The address of the NFT contract. |
| tokenId | `uint256` | The id of the NFT. |

**Returns**

| Name | Type | Description |
|---|---|---|
| seller | `address payable` | The seller which listed this NFT for sale, or address(0) if not listed. |

### initialize

```solidity
function initialize() external nonpayable
```

Called once to configure the contract after the initial proxy deployment.

*This farms the initialize call out to inherited contracts as needed to initialize mutable variables.*


### internalGetImmutableRoyalties

```solidity
function internalGetImmutableRoyalties(address nftContract, uint256 tokenId) external view returns (address payable[] recipients, uint256[] splitPerRecipientInBasisPoints)
```

**For internal use only.**

*This function is external to allow using try/catch but is not intended for external use. If ERC2981 royalties (or getRoyalties) are defined by the NFT contract, allow this standard to define immutable royalties that cannot be later changed via the royalty registry.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` |  |
| tokenId | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| recipients | `address payable[]` |  |
| splitPerRecipientInBasisPoints | `uint256[]` |  |

### internalGetMutableRoyalties

```solidity
function internalGetMutableRoyalties(address nftContract, uint256 tokenId, address payable creator) external view returns (address payable[] recipients, uint256[] splitPerRecipientInBasisPoints)
```

**For internal use only.**

*This function is external to allow using try/catch but is not intended for external use. This checks for royalties defined in the royalty registry or via a non-standard royalty API.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` |  |
| tokenId | `uint256` |  |
| creator | `address payable` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| recipients | `address payable[]` |  |
| splitPerRecipientInBasisPoints | `uint256[]` |  |

### internalGetTokenCreator

```solidity
function internalGetTokenCreator(address nftContract, uint256 tokenId) external view returns (address payable creator)
```

**For internal use only.**

*This function is external to allow using try/catch but is not intended for external use. This checks the token creator.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` |  |
| tokenId | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| creator | `address payable` |  |

### mintFromFixedPriceSale

```solidity
function mintFromFixedPriceSale(address nftContract, uint16 count, address payable buyReferrer) external payable returns (uint256 firstTokenId)
```

Used to mint `count` number of NFTs from the collection.

*This call may revert if the collection has sold out, has an insufficient number of tokens available, or if the market&#39;s minter permissions were removed. If insufficient msg.value is included, the msg.sender&#39;s available FETH token balance will be used.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` | The address of the NFT drop collection. |
| count | `uint16` | The number of NFTs to mint. |
| buyReferrer | `address payable` | The address which referred this purchase, or address(0) if n/a. |

**Returns**

| Name | Type | Description |
|---|---|---|
| firstTokenId | `uint256` | The tokenId for the first NFT minted. The other minted tokens are assigned sequentially, so `firstTokenId` - `firstTokenId + count - 1` were minted. |



## Events

### BuyReferralPaid

```solidity
event BuyReferralPaid(address indexed nftContract, uint256 indexed tokenId, address buyReferrer, uint256 buyReferrerFee, uint256 buyReferrerSellerFee)
```

Emitted when an NFT sold with a referrer.



**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | `address` |  |
| tokenId `indexed` | `uint256` |  |
| buyReferrer  | `address` |  |
| buyReferrerFee  | `uint256` |  |
| buyReferrerSellerFee  | `uint256` |  |

### CreateFixedPriceSale

```solidity
event CreateFixedPriceSale(address indexed nftContract, address indexed seller, uint256 price, uint256 limitPerAccount)
```

Emitted when a collection is listed for sale.



**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | `address` |  |
| seller `indexed` | `address` |  |
| price  | `uint256` |  |
| limitPerAccount  | `uint256` |  |

### Initialized

```solidity
event Initialized(uint8 version)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| version  | `uint8` |  |

### MintFromFixedPriceDrop

```solidity
event MintFromFixedPriceDrop(address indexed nftContract, address indexed buyer, uint256 indexed firstTokenId, uint256 count, uint256 totalFees, uint256 creatorRev)
```

Emitted when NFTs are minted from the drop.



**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract `indexed` | `address` |  |
| buyer `indexed` | `address` |  |
| firstTokenId `indexed` | `uint256` |  |
| count  | `uint256` |  |
| totalFees  | `uint256` |  |
| creatorRev  | `uint256` |  |

### WithdrawalToFETH

```solidity
event WithdrawalToFETH(address indexed user, uint256 amount)
```

Emitted when escrowed funds are withdrawn to FETH.



**Parameters**

| Name | Type | Description |
|---|---|---|
| user `indexed` | `address` |  |
| amount  | `uint256` |  |



## Errors

### FETHNode_FETH_Address_Is_Not_A_Contract

```solidity
error FETHNode_FETH_Address_Is_Not_A_Contract()
```






### FETHNode_Only_FETH_Can_Transfer_ETH

```solidity
error FETHNode_Only_FETH_Can_Transfer_ETH()
```






### FoundationTreasuryNode_Address_Is_Not_A_Contract

```solidity
error FoundationTreasuryNode_Address_Is_Not_A_Contract()
```






### NFTDropMarketFixedPriceSale_Cannot_Buy_More_Than_Limit

```solidity
error NFTDropMarketFixedPriceSale_Cannot_Buy_More_Than_Limit(uint256 limitPerAccount)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| limitPerAccount | `uint256` | The limit of tokens an account can purchase. |

### NFTDropMarketFixedPriceSale_Limit_Per_Account_Must_Be_Set

```solidity
error NFTDropMarketFixedPriceSale_Limit_Per_Account_Must_Be_Set()
```






### NFTDropMarketFixedPriceSale_Mint_Count_Mismatch

```solidity
error NFTDropMarketFixedPriceSale_Mint_Count_Mismatch(uint256 targetBalance)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| targetBalance | `uint256` |  |

### NFTDropMarketFixedPriceSale_Mint_Permission_Required

```solidity
error NFTDropMarketFixedPriceSale_Mint_Permission_Required()
```






### NFTDropMarketFixedPriceSale_Must_Buy_At_Least_One_Token

```solidity
error NFTDropMarketFixedPriceSale_Must_Buy_At_Least_One_Token()
```






### NFTDropMarketFixedPriceSale_Must_Have_Sale_In_Progress

```solidity
error NFTDropMarketFixedPriceSale_Must_Have_Sale_In_Progress()
```






### NFTDropMarketFixedPriceSale_Must_Not_Be_Sold_Out

```solidity
error NFTDropMarketFixedPriceSale_Must_Not_Be_Sold_Out()
```






### NFTDropMarketFixedPriceSale_Must_Not_Have_Pending_Sale

```solidity
error NFTDropMarketFixedPriceSale_Must_Not_Have_Pending_Sale()
```






### NFTDropMarketFixedPriceSale_Must_Support_Collection_Mint_Interface

```solidity
error NFTDropMarketFixedPriceSale_Must_Support_Collection_Mint_Interface()
```






### NFTDropMarketFixedPriceSale_Must_Support_ERC721

```solidity
error NFTDropMarketFixedPriceSale_Must_Support_ERC721()
```






### NFTDropMarketFixedPriceSale_Only_Callable_By_Collection_Owner

```solidity
error NFTDropMarketFixedPriceSale_Only_Callable_By_Collection_Owner()
```






### NFTDropMarketFixedPriceSale_Too_Much_Value_Provided

```solidity
error NFTDropMarketFixedPriceSale_Too_Much_Value_Provided(uint256 mintCost)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| mintCost | `uint256` | The total cost for this purchase. |

### NFTDropMarket_NFT_Already_Minted

```solidity
error NFTDropMarket_NFT_Already_Minted()
```






### NFTMarketFees_Address_Does_Not_Support_IRoyaltyRegistry

```solidity
error NFTMarketFees_Address_Does_Not_Support_IRoyaltyRegistry()
```






### NFTMarketFees_Invalid_Protocol_Fee

```solidity
error NFTMarketFees_Invalid_Protocol_Fee()
```







