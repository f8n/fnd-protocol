---
title: NFTCollectionFactory
description: A factory to create NFT collections.
---


Call this factory to create NFT collections.

*This creates and initializes an ERC-1167 minimal proxy pointing to an NFT collection contract implementation.*

## Methods

### adminUpdateNFTCollectionImplementation

```solidity
function adminUpdateNFTCollectionImplementation(address _implementation) external nonpayable
```

Allows Foundation to change the NFTCollection implementation used for future collections. This call will auto-increment the version. Existing collections are not impacted.



**Parameters**

| Name | Type | Description |
|---|---|---|
| _implementation | `address` | The new NFTCollection collection implementation address. |

### adminUpdateNFTDropCollectionImplementation

```solidity
function adminUpdateNFTDropCollectionImplementation(address _implementation) external nonpayable
```

Allows Foundation to change the NFTDropCollection implementation used for future collections. This call will auto-increment the version. Existing collections are not impacted.



**Parameters**

| Name | Type | Description |
|---|---|---|
| _implementation | `address` | The new NFTDropCollection collection implementation address. |

### createNFTCollection

```solidity
function createNFTCollection(string name, string symbol, uint96 nonce) external nonpayable returns (address collection)
```

Create a new collection contract.

*The nonce must be unique for the msg.sender + implementation version, otherwise this call will revert.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| name | `string` | The collection&#39;s `name`. |
| symbol | `string` | The collection&#39;s `symbol`. |
| nonce | `uint96` | An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address. |

**Returns**

| Name | Type | Description |
|---|---|---|
| collection | `address` | The address of the newly created collection contract. |

### createNFTDropCollection

```solidity
function createNFTDropCollection(string name, string symbol, string baseURI, bool isRevealed, uint32 maxTokenId, address approvedMinter, uint96 nonce) external nonpayable returns (address collection)
```

Create a new drop collection contract.

*The nonce must be unique for the msg.sender + implementation version, otherwise this call will revert.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| name | `string` | The collection&#39;s `name`. |
| symbol | `string` | The collection&#39;s `symbol`. |
| baseURI | `string` | The base URI for the collection. |
| isRevealed | `bool` | Whether the collection is revealed or not. |
| maxTokenId | `uint32` | The max token id for this collection. |
| approvedMinter | `address` | An optional address to grant the MINTER_ROLE. |
| nonce | `uint96` | An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address. |

**Returns**

| Name | Type | Description |
|---|---|---|
| collection | `address` | The address of the newly created collection contract. |

### createNFTDropCollectionWithPaymentAddress

```solidity
function createNFTDropCollectionWithPaymentAddress(string name, string symbol, string baseURI, bool isRevealed, uint32 maxTokenId, address approvedMinter, uint96 nonce, address payable paymentAddress) external nonpayable returns (address collection)
```

Create a new drop collection contract with a custom payment address.

*All params other than `paymentAddress` are the same as in `createNFTDropCollection`. The nonce must be unique for the msg.sender + implementation version, otherwise this call will revert.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| name | `string` | The collection&#39;s `name`. |
| symbol | `string` | The collection&#39;s `symbol`. |
| baseURI | `string` | The base URI for the collection. |
| isRevealed | `bool` | Whether the collection is revealed or not. |
| maxTokenId | `uint32` | The max token id for this collection. |
| approvedMinter | `address` | An optional address to grant the MINTER_ROLE. |
| nonce | `uint96` | An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address. |
| paymentAddress | `address payable` | The address that will receive royalties and mint payments. |

**Returns**

| Name | Type | Description |
|---|---|---|
| collection | `address` | The address of the newly created collection contract. |

### createNFTDropCollectionWithPaymentFactory

```solidity
function createNFTDropCollectionWithPaymentFactory(string name, string symbol, string baseURI, bool isRevealed, uint32 maxTokenId, address approvedMinter, uint96 nonce, CallWithoutValue paymentAddressFactoryCall) external nonpayable returns (address collection)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| name | `string` |  |
| symbol | `string` |  |
| baseURI | `string` |  |
| isRevealed | `bool` |  |
| maxTokenId | `uint32` |  |
| approvedMinter | `address` |  |
| nonce | `uint96` |  |
| paymentAddressFactoryCall | `CallWithoutValue` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| collection | `address` |  |

### implementationNFTCollection

```solidity
function implementationNFTCollection() external view returns (address)
```

The address of the implementation all new NFTCollections will leverage.

*When this is changed, `versionNFTCollection` is incremented.*


**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `address` | The implementation address for NFTCollection. |

### implementationNFTDropCollection

```solidity
function implementationNFTDropCollection() external view returns (address)
```

The address of the implementation all new NFTDropCollections will leverage.

*When this is changed, `versionNFTDropCollection` is incremented.*


**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `address` | The implementation address for NFTDropCollection. |

### initialize

```solidity
function initialize(uint32 _versionNFTCollection) external nonpayable
```

Initializer called after contract creation.

*This is used so that this factory will resume versions from where our original factory had left off.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| _versionNFTCollection | `uint32` | The current implementation version for NFTCollections. |

### predictNFTCollectionAddress

```solidity
function predictNFTCollectionAddress(address creator, uint96 nonce) external view returns (address collection)
```

Returns the address of a collection given the current implementation version, creator, and nonce. This will return the same address whether the collection has already been created or not.



**Parameters**

| Name | Type | Description |
|---|---|---|
| creator | `address` | The creator of the collection. |
| nonce | `uint96` | An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address. |

**Returns**

| Name | Type | Description |
|---|---|---|
| collection | `address` | The address of the collection contract that would be created by this nonce. |

### predictNFTDropCollectionAddress

```solidity
function predictNFTDropCollectionAddress(address creator, uint96 nonce) external view returns (address collection)
```

Returns the address of an NFTDropCollection collection given the current implementation version, creator, and nonce. This will return the same address whether the collection has already been created or not.



**Parameters**

| Name | Type | Description |
|---|---|---|
| creator | `address` | The creator of the collection. |
| nonce | `uint96` | An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address. |

**Returns**

| Name | Type | Description |
|---|---|---|
| collection | `address` | The address of the collection contract that would be created by this nonce. |

### rolesManager

```solidity
function rolesManager() external view returns (contract IRoles)
```

The contract address which manages common roles.

*Defines a centralized admin role definition for permissioned functions below.*


**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `contract IRoles` | The contract address with role definitions. |

### versionNFTCollection

```solidity
function versionNFTCollection() external view returns (uint32)
```

The implementation version of new NFTCollections.

*This is auto-incremented each time `implementationNFTCollection` is changed.*


**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `uint32` | The current NFTCollection implementation version. |

### versionNFTDropCollection

```solidity
function versionNFTDropCollection() external view returns (uint32)
```

The implementation version of new NFTDropCollections.

*This is auto-incremented each time `implementationNFTDropCollection` is changed.*


**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `uint32` | The current NFTDropCollection implementation version. |



## Events

### ImplementationNFTCollectionUpdated

```solidity
event ImplementationNFTCollectionUpdated(address indexed implementation, uint256 indexed version)
```

Emitted when the implementation of NFTCollection used by new collections is updated.



**Parameters**

| Name | Type | Description |
|---|---|---|
| implementation `indexed` | `address` | The new implementation contract address. |
| version `indexed` | `uint256` | The version of the new implementation, auto-incremented. |

### ImplementationNFTDropCollectionUpdated

```solidity
event ImplementationNFTDropCollectionUpdated(address indexed implementationNFTDropCollection, uint256 indexed version)
```

Emitted when the implementation of NFTDropCollection used by new collections is updated.



**Parameters**

| Name | Type | Description |
|---|---|---|
| implementationNFTDropCollection `indexed` | `address` | The new implementation contract address. |
| version `indexed` | `uint256` | The version of the new implementation, auto-incremented. |

### Initialized

```solidity
event Initialized(uint8 version)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| version  | `uint8` |  |

### NFTCollectionCreated

```solidity
event NFTCollectionCreated(address indexed collection, address indexed creator, uint256 indexed version, string name, string symbol, uint256 nonce)
```

Emitted when a new NFTCollection is created from this factory.



**Parameters**

| Name | Type | Description |
|---|---|---|
| collection `indexed` | `address` | The address of the new NFT collection contract. |
| creator `indexed` | `address` | The address of the creator which owns the new collection. |
| version `indexed` | `uint256` | The implementation version used by the new collection. |
| name  | `string` | The name of the collection contract created. |
| symbol  | `string` | The symbol of the collection contract created. |
| nonce  | `uint256` | The nonce used by the creator when creating the collection, used to define the address of the collection. |

### NFTDropCollectionCreated

```solidity
event NFTDropCollectionCreated(address indexed collection, address indexed creator, address indexed approvedMinter, string name, string symbol, string baseURI, bool isRevealed, uint256 maxTokenId, address paymentAddress, uint256 version, uint256 nonce)
```

Emitted when a new NFTDropCollection is created from this factory.



**Parameters**

| Name | Type | Description |
|---|---|---|
| collection `indexed` | `address` | The address of the new NFT drop collection contract. |
| creator `indexed` | `address` | The address of the creator which owns the new collection. |
| approvedMinter `indexed` | `address` | An optional address to grant the MINTER_ROLE. |
| name  | `string` | The collection&#39;s `name`. |
| symbol  | `string` | The collection&#39;s `symbol`. |
| baseURI  | `string` | The base URI for the collection. |
| isRevealed  | `bool` | Whether the collection is revealed or not. |
| maxTokenId  | `uint256` | The max `tokenID` for this collection. |
| paymentAddress  | `address` | The address that will receive royalties and mint payments. |
| version  | `uint256` | The implementation version used by the new NFTDropCollection collection. |
| nonce  | `uint256` | The nonce used by the creator to create this collection. |



