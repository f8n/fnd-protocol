---
title: FNDMiddleware
description: Convenience methods to ease integration with other contracts.
---


This will aggregate calls and format the output per the needs of our frontend or other consumers.



## Methods

### getAccountInfo

```solidity
function getAccountInfo(address account) external view returns (uint256 ethBalance, uint256 availableFethBalance, uint256 lockedFethBalance, string ensName)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| account | `address` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| ethBalance | `uint256` |  |
| availableFethBalance | `uint256` |  |
| lockedFethBalance | `uint256` |  |
| ensName | `string` |  |

### getFees

```solidity
function getFees(address nftContract, uint256 tokenId, uint256 price) external view returns (struct FNDMiddleware.FeeWithRecipient protocol, struct FNDMiddleware.Fee creator, struct FNDMiddleware.FeeWithRecipient owner, struct FNDMiddleware.RevSplit[] creatorRevSplit)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` |  |
| tokenId | `uint256` |  |
| price | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| protocol | `FNDMiddleware.FeeWithRecipient` |  |
| creator | `FNDMiddleware.Fee` |  |
| owner | `FNDMiddleware.FeeWithRecipient` |  |
| creatorRevSplit | `FNDMiddleware.RevSplit[]` |  |

### getNFTDetailString

```solidity
function getNFTDetailString(address nftContract, uint256 tokenId) external view returns (string details)
```

Retrieves details about the current state of an NFT in the FND Market as a string.

*This API is for investigations &amp; convenience, it is not meant to be consumed by an app directly.      Future upgrades may not be backwards compatible.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` |  |
| tokenId | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| details | `string` |  |

### getNFTDetails

```solidity
function getNFTDetails(address nftContract, uint256 tokenId) external view returns (address owner, bool isInEscrow, address auctionBidder, uint256 auctionEndTime, uint256 auctionPrice, uint256 auctionId, uint256 buyPrice, uint256 offerAmount, address offerBuyer, uint256 offerExpiration)
```

Retrieves details about the current state of an NFT in the FND Market.



**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` | The address of the NFT contract. |
| tokenId | `uint256` | The id of the NFT. |

**Returns**

| Name | Type | Description |
|---|---|---|
| owner | `address` | The account which currently holds the NFT or has listed it for sale. |
| isInEscrow | `bool` | True if the NFT is currently held in escrow by the Market (for an auction or buy price). |
| auctionBidder | `address` | The current highest bidder for the auction, or address(0) if there&#39;s not an active auction. |
| auctionEndTime | `uint256` | The time at which this auction will not accept any new bids,                        this is `0` until the first bid is placed. |
| auctionPrice | `uint256` | The latest price of the NFT in this auction.                      This is set to the reserve price, and then to the highest bid once the auction has started.                      Returns `0` if there&#39;s no auction for this NFT. |
| auctionId | `uint256` | The id of the auction, or 0 if no auction is found. |
| buyPrice | `uint256` | The price at which you could buy this NFT.                  Returns max uint256 if there is no buy price set for this NFT (since a price of 0 is supported). |
| offerAmount | `uint256` | The amount being offered for this NFT.                     Returns `0` if there is no offer or the most recent offer has expired. |
| offerBuyer | `address` | The address of the buyer that made the current highest offer.                    Returns `address(0)` if there is no offer or the most recent offer has expired. |
| offerExpiration | `uint256` | The timestamp that the current highest offer expires.                         Returns `0` if there is no offer or the most recent offer has expired. |

### getSellerOrOwnerOf

```solidity
function getSellerOrOwnerOf(address nftContract, uint256 tokenId) external view returns (address payable ownerOrSeller)
```

Checks who the seller for an NFT is, checking both markets or returning the current owner.



**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` |  |
| tokenId | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| ownerOrSeller | `address payable` |  |

### getSplitShareLength

```solidity
function getSplitShareLength(address payable recipient) external view returns (uint256 count)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| recipient | `address payable` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| count | `uint256` |  |

### getTokenCreator

```solidity
function getTokenCreator(address nftContract, uint256 tokenId) external view returns (address creatorAddress)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` |  |
| tokenId | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| creatorAddress | `address` |  |

### probeNFT

```solidity
function probeNFT(address nftContract, uint256 tokenId) external payable returns (bytes32)
```

Checks an NFT to confirm it will function correctly with our marketplace.

*This should be called with as `call` to simulate the tx; never `sendTransaction`.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| nftContract | `address` |  |
| tokenId | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `bytes32` | 0 if the NFT is supported, otherwise a hash of the error reason. |




