# FNDMiddleware

> Convenience methods to ease integration with other contracts.

This will aggregate calls and format the output per the needs of our frontend or other consumers.

## Methods

### getAccountInfo

```solidity
function getAccountInfo(address account) external view returns (uint256 ethBalance, uint256 availableFethBalance, uint256 lockedFethBalance, string ensName)
```

#### Parameters

| Name    | Type      |
| ------- | --------- |
| account | `address` |

#### Returns

| Name                 | Type      |
| -------------------- | --------- |
| ethBalance           | `uint256` |
| availableFethBalance | `uint256` |
| lockedFethBalance    | `uint256` |
| ensName              | `string`  |

### getFees

```solidity
function getFees(address nftContract, uint256 tokenId, uint256 price) external view returns (struct FNDMiddleware.FeeWithRecipient protocol, struct FNDMiddleware.Fee creator, struct FNDMiddleware.FeeWithRecipient owner, struct FNDMiddleware.RevSplit[] creatorRevSplit)
```

#### Parameters

| Name        | Type      |
| ----------- | --------- |
| nftContract | `address` |
| tokenId     | `uint256` |
| price       | `uint256` |

#### Returns

| Name            | Type                             |
| --------------- | -------------------------------- |
| protocol        | `FNDMiddleware.FeeWithRecipient` |
| creator         | `FNDMiddleware.Fee`              |
| owner           | `FNDMiddleware.FeeWithRecipient` |
| creatorRevSplit | `FNDMiddleware.RevSplit[]`       |

### getNFTDetailString

```solidity
function getNFTDetailString(address nftContract, uint256 tokenId) external view returns (string details)
```

#### Parameters

| Name        | Type      |
| ----------- | --------- |
| nftContract | `address` |
| tokenId     | `uint256` |

#### Returns

| Name    | Type     |
| ------- | -------- |
| details | `string` |

### getNFTDetails

```solidity
function getNFTDetails(address nftContract, uint256 tokenId) external view returns (address owner, bool isInEscrow, address auctionBidder, uint256 auctionEndTime, uint256 auctionPrice, uint256 auctionId, uint256 buyPrice, uint256 offerAmount, address offerBuyer, uint256 offerExpiration)
```

Retrieves details related to the NFT in the FND Market.

#### Parameters

| Name        | Type      | Description                             |
| ----------- | --------- | --------------------------------------- |
| nftContract | `address` | The address of the contract for the NFT |
| tokenId     | `uint256` | The id for the NFT in the contract.     |

#### Returns

| Name            | Type      |
| --------------- | --------- |
| owner           | `address` |
| isInEscrow      | `bool`    |
| auctionBidder   | `address` |
| auctionEndTime  | `uint256` |
| auctionPrice    | `uint256` |
| auctionId       | `uint256` |
| buyPrice        | `uint256` |
| offerAmount     | `uint256` |
| offerBuyer      | `address` |
| offerExpiration | `uint256` |

### getSplitShareLength

```solidity
function getSplitShareLength(address payable recipient) external view returns (uint256 count)
```

#### Parameters

| Name      | Type              |
| --------- | ----------------- |
| recipient | `address payable` |

#### Returns

| Name  | Type      |
| ----- | --------- |
| count | `uint256` |

### getTokenCreator

```solidity
function getTokenCreator(address nftContract, uint256 tokenId) external view returns (address creatorAddress)
```

#### Parameters

| Name        | Type      |
| ----------- | --------- |
| nftContract | `address` |
| tokenId     | `uint256` |

#### Returns

| Name           | Type      |
| -------------- | --------- |
| creatorAddress | `address` |

### probeNFT

```solidity
function probeNFT(address nftContract, uint256 tokenId) external payable returns (bytes32)
```

Checks an NFT to confirm it will function correctly with our marketplace.

_This should be called with as `call` to simulate the tx; never `sendTransaction`._

#### Parameters

| Name        | Type      |
| ----------- | --------- |
| nftContract | `address` |
| tokenId     | `uint256` |

#### Returns

| Name | Type      | Description                                                      |
| ---- | --------- | ---------------------------------------------------------------- |
| \_0  | `bytes32` | 0 if the NFT is supported, otherwise a hash of the error reason. |
