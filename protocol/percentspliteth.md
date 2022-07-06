# PercentSplitETH

> Auto-forward ETH to a pre-determined list of addresses.

Deploys contracts which auto-forwards any ETH sent to it to a list of recipients considering their percent share of the payment received. ERC-20 tokens are also supported and may be split on demand by calling `splitERC20Tokens`. If another asset type is sent to this contract address such as an NFT, arbitrary calls may be made by one of the split recipients in order to recover them.

_Uses create2 counterfactual addresses so that the destination is known from the terms of the split._

## Methods

### createSplit

```solidity
function createSplit(PercentSplitETH.Share[] shares) external nonpayable returns (contract PercentSplitETH splitInstance)
```

#### Parameters

| Name   | Type                      |
| ------ | ------------------------- |
| shares | `PercentSplitETH.Share[]` |

#### Returns

| Name          | Type                       |
| ------------- | -------------------------- |
| splitInstance | `contract PercentSplitETH` |

### getPercentInBasisPointsByIndex

```solidity
function getPercentInBasisPointsByIndex(uint256 index) external view returns (uint256 percentInBasisPoints)
```

Returns a recipient's percent share in basis points.

#### Parameters

| Name  | Type      | Description                                     |
| ----- | --------- | ----------------------------------------------- |
| index | `uint256` | The index of the recipient to get the share of. |

#### Returns

| Name                 | Type      | Description                                                            |
| -------------------- | --------- | ---------------------------------------------------------------------- |
| percentInBasisPoints | `uint256` | The percent of the payment received by the recipient, in basis points. |

### getPredictedSplitAddress

```solidity
function getPredictedSplitAddress(PercentSplitETH.Share[] shares) external view returns (address splitInstance)
```

#### Parameters

| Name   | Type                     |
| ------ | ------------------------ |
| shares | PercentSplitETH.Share\[] |

#### Returns

| Name          | Type      |
| ------------- | --------- |
| splitInstance | `address` |

### getShareLength

```solidity
function getShareLength() external view returns (uint256 length)
```

Returns how many recipients are part of this split.

#### Returns

| Name   | Type      | Description                             |
| ------ | --------- | --------------------------------------- |
| length | `uint256` | The number of recipients in this split. |

### getShareRecipientByIndex

```solidity
function getShareRecipientByIndex(uint256 index) external view returns (address payable recipient)
```

Returns a recipient in this split.

#### Parameters

| Name  | Type      | Description                        |
| ----- | --------- | ---------------------------------- |
| index | `uint256` | The index of the recipient to get. |

#### Returns

| Name      | Type              | Description                       |
| --------- | ----------------- | --------------------------------- |
| recipient | `address payable` | The recipient at the given index. |

### getShares

```solidity
function getShares() external view returns (struct PercentSplitETH.Share[] shares)
```

Returns a tuple with the terms of this split.

#### Returns

| Name   | Type                      | Description                                                           |
| ------ | ------------------------- | --------------------------------------------------------------------- |
| shares | `PercentSplitETH.Share[]` | The list of recipients and their share of the payment for this split. |

### initialize

```solidity
function initialize(PercentSplitETH.Share[] shares) external nonpayable
```

#### Parameters

| Name   | Type                      |
| ------ | ------------------------- |
| shares | `PercentSplitETH.Share[]` |

### proxyCall

```solidity
function proxyCall(address payable target, bytes callData) external nonpayable
```

Allows the split recipients to make an arbitrary contract call.

_This is provided to allow recovering from unexpected scenarios, such as receiving an NFT at this address. It will first attempt a fair split of ERC20 tokens before proceeding. This contract is built to split ETH payments. The ability to attempt to make other calls is here just in case other assets were also sent so that they don't get locked forever in the contract._

#### Parameters

| Name     | Type              | Description                                |
| -------- | ----------------- | ------------------------------------------ |
| target   | `address payable` | The address of the contract to call.       |
| callData | `bytes`           | The data to send to the `target` contract. |

### splitERC20Tokens

```solidity
function splitERC20Tokens(contract IERC20 erc20Contract) external nonpayable
```

Anyone can call this function to split all available tokens at the provided address between the recipients.

_This contract is built to split ETH payments. The ability to attempt to split ERC20 tokens is here just in case tokens were also sent so that they don't get locked forever in the contract._

#### Parameters

| Name          | Type              | Description                                                  |
| ------------- | ----------------- | ------------------------------------------------------------ |
| erc20Contract | `contract IERC20` | The address of the ERC20 token contract to split tokens for. |

### splitETH

```solidity
function splitETH() external nonpayable
```

Allows any ETH stored by the contract to be split among recipients.

_Normally ETH is forwarded as it comes in, but a balance in this contract is possible if it was sent before the contract was created or if self destruct was used._

## Events

### ERC20Transferred

```solidity
event ERC20Transferred(address indexed erc20Contract, address indexed account, uint256 amount)
```

Emitted when an ERC20 token is transferred to a recipient through this split contract.

#### Parameters

| Name                    | Type      | Description                                        |
| ----------------------- | --------- | -------------------------------------------------- |
| erc20Contract `indexed` | `address` | The address of the ERC20 token contract.           |
| account `indexed`       | `address` | The account which received payment.                |
| amount                  | `uint256` | The amount of ERC20 tokens sent to this recipient. |

### ETHTransferred

```solidity
event ETHTransferred(address indexed account, uint256 amount)
```

Emitted when ETH is transferred to a recipient through this split contract.

#### Parameters

| Name              | Type      | Description                                       |
| ----------------- | --------- | ------------------------------------------------- |
| account `indexed` | `address` | The account which received payment.               |
| amount            | `uint256` | The amount of ETH payment sent to this recipient. |

### Initialized

```solidity
event Initialized(uint8 version)
```

#### Parameters

| Name    | Type    |
| ------- | ------- |
| version | `uint8` |

### PercentSplitCreated

```solidity
event PercentSplitCreated(address indexed contractAddress)
```

Emitted when a new percent split contract is created from this factory.

#### Parameters

| Name                      | Type      | Description                                    |
| ------------------------- | --------- | ---------------------------------------------- |
| contractAddress `indexed` | `address` | The address of the new percent split contract. |

### PercentSplitShare

```solidity
event PercentSplitShare(address indexed recipient, uint256 percentInBasisPoints)
```

Emitted for each share of the split being defined.

#### Parameters

| Name                 | Type      | Description                                                            |
| -------------------- | --------- | ---------------------------------------------------------------------- |
| recipient `indexed`  | `address` | The address of the recipient when payment to the split is received.    |
| percentInBasisPoints | `uint256` | The percent of the payment received by the recipient, in basis points. |
