# FNDCollectionFactory



> A factory to create NFT collections.

Call this factory to create an NFT collection contract managed by a single creator.

*This creates and initializes an ERC-1165 minimal proxy pointing to the NFT collection contract template.*

## Methods

### adminUpdateImplementation

```solidity
function adminUpdateImplementation(address _implementation) external nonpayable
```

Allows Foundation to change the collection implementation used for future collections. This call will auto-increment the version. Existing collections are not impacted.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _implementation | `address` | The new collection implementation address. |

### adminUpdateProxyCallContract

```solidity
function adminUpdateProxyCallContract(address _proxyCallContract) external nonpayable
```

Allows Foundation to change the proxy call contract address.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _proxyCallContract | `address` | The new proxy call contract address. |

### adminUpdateRolesContract

```solidity
function adminUpdateRolesContract(address _rolesContract) external nonpayable
```

Allows Foundation to change the admin role contract address.



#### Parameters

| Name | Type | Description |
|---|---|---|
| _rolesContract | `address` | The new admin role contract address. |

### createCollection

```solidity
function createCollection(string name, string symbol, uint256 nonce) external nonpayable returns (address collectionAddress)
```

Create a new collection contract.

*The nonce is required and must be unique for the msg.sender + implementation version, otherwise this call will revert.*

#### Parameters

| Name | Type | Description |
|---|---|---|
| name | `string` | The name for the new collection being created. |
| symbol | `string` | The symbol for the new collection being created. |
| nonce | `uint256` | An arbitrary value used to allow a creator to mint multiple collections. |

#### Returns

| Name | Type | Description |
|---|---|---|
| collectionAddress | `address` | The address of the new collection contract. |

### implementation

```solidity
function implementation() external view returns (address)
```

The address of the template all new collections will leverage.




#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | `address` |  |

### predictCollectionAddress

```solidity
function predictCollectionAddress(address creator, uint256 nonce) external view returns (address collectionAddress)
```

Returns the address of a collection given the current implementation version, creator, and nonce. This will return the same address whether the collection has already been created or not.



#### Parameters

| Name | Type | Description |
|---|---|---|
| creator | `address` | The creator of the collection. |
| nonce | `uint256` | An arbitrary value used to allow a creator to mint multiple collections. |

#### Returns

| Name | Type | Description |
|---|---|---|
| collectionAddress | `address` | The address of the collection contract that would be created by this nonce. |

### proxyCallContract

```solidity
function proxyCallContract() external view returns (contract IProxyCall)
```

The address of the proxy call contract implementation.

*Used by the collections to safely call another contract with arbitrary call data.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | `contract IProxyCall` |  |

### rolesContract

```solidity
function rolesContract() external view returns (contract IRoles)
```

The contract address which manages common roles.

*Used by the collections for a shared operator definition.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | `contract IRoles` |  |

### version

```solidity
function version() external view returns (uint256)
```

The implementation version new collections will use.

*This is auto-incremented each time the implementation is changed.*


#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | `uint256` |  |



## Events

### CollectionCreated

```solidity
event CollectionCreated(address indexed collectionContract, address indexed creator, uint256 indexed version, string name, string symbol, uint256 nonce)
```

Emitted when a new collection is created from this factory.



#### Parameters

| Name | Type | Description |
|---|---|---|
| collectionContract `indexed` | `address` | The address of the new NFT collection contract. |
| creator `indexed` | `address` | The address of the creator which owns the new collection. |
| version `indexed` | `uint256` | The implementation version used by the new collection. |
| name  | `string` | The name of the collection contract created. |
| symbol  | `string` | The symbol of the collection contract created. |
| nonce  | `uint256` | The nonce used by the creator when creating the collection, used to define the address of the collection. |

### ImplementationUpdated

```solidity
event ImplementationUpdated(address indexed implementation, uint256 indexed version)
```

Emitted when the implementation contract used by new collections is updated.



#### Parameters

| Name | Type | Description |
|---|---|---|
| implementation `indexed` | `address` | The new implementation contract address. |
| version `indexed` | `uint256` | The version of the new implementation, auto-incremented. |

### ProxyCallContractUpdated

```solidity
event ProxyCallContractUpdated(address indexed proxyCallContract)
```

Emitted when the proxy call contract used by collections is updated.



#### Parameters

| Name | Type | Description |
|---|---|---|
| proxyCallContract `indexed` | `address` | The new proxy call contract address. |

### RolesContractUpdated

```solidity
event RolesContractUpdated(address indexed rolesContract)
```

Emitted when the contract defining roles is updated.



#### Parameters

| Name | Type | Description |
|---|---|---|
| rolesContract `indexed` | `address` | The new roles contract address. |



