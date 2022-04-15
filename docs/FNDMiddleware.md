# FNDMiddleware



> Convenience methods to ease integration with other contracts.

This will aggregate calls and format the output per the needs of our frontend or other consumers.



## Methods

### getAccountInfo

```solidity
function getAccountInfo(address account) external view returns (uint256 ethBalance, uint256 availableFethBalance, uint256 lockedFethBalance, string ensName)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| ethBalance | uint256 | undefined |
| availableFethBalance | uint256 | undefined |
| lockedFethBalance | uint256 | undefined |
| ensName | string | undefined |

### getFees

```solidity
function getFees(address nftContract, uint256 tokenId, uint256 price) external view returns (struct FNDMiddleware.FeeWithRecipient protocol, struct FNDMiddleware.Fee creator, struct FNDMiddleware.FeeWithRecipient owner, struct FNDMiddleware.RevSplit[] creatorRevSplit)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | undefined |
| tokenId | uint256 | undefined |
| price | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| protocol | FNDMiddleware.FeeWithRecipient | undefined |
| creator | FNDMiddleware.Fee | undefined |
| owner | FNDMiddleware.FeeWithRecipient | undefined |
| creatorRevSplit | FNDMiddleware.RevSplit[] | undefined |

### getNFTDetailString

```solidity
function getNFTDetailString(address nftContract, uint256 tokenId) external view returns (string details)
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | undefined |
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| details | string | undefined |

### getNFTDetails

```solidity
function getNFTDetails(address nftContract, uint256 tokenId) external view returns (address owner, bool isInEscrow, address auctionBidder, uint256 auctionEndTime, uint256 auctionPrice, uint256 auctionId, uint256 buyPrice, uint256 offerAmount, address offerBuyer, uint256 offerExpiration)
```

Retrieves details related to the NFT in the FND Market.



#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | The address of the contract for the NFT |
| tokenId | uint256 | The id for the NFT in the contract. |

#### Returns

| Name | Type | Description |
|---|---|---|
| owner | address | undefined |
| isInEscrow | bool | undefined |
| auctionBidder | address | undefined |
| auctionEndTime | uint256 | undefined |
| auctionPrice | uint256 | undefined |
| auctionId | uint256 | undefined |
| buyPrice | uint256 | undefined |
| offerAmount | uint256 | undefined |
| offerBuyer | address | undefined |
| offerExpiration | uint256 | undefined |

### probeNFT

```solidity
function probeNFT(address nftContract, uint256 tokenId) external payable returns (bytes32)
```

Checks an NFT to confirm it will function correctly with our marketplace.

*This should be called with as `call` to simulate the tx; never `sendTransaction`.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| nftContract | address | undefined |
| tokenId | uint256 | undefined |

#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | bytes32 | 0 if the NFT is supported, otherwise a hash of the error reason. |




