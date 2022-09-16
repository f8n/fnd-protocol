---
title: NFTCollection
description: A collection of NFTs by a single creator.
---


All NFTs from this contract are minted by the same creator. A 10% royalty to the creator is included which may be split with collaborators on a per-NFT basis.



## Methods

### approve

```solidity
function approve(address to, uint256 tokenId) external nonpayable
```



*See {IERC721-approve}.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| to | `address` |  |
| tokenId | `uint256` |  |

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256)
```



*See {IERC721-balanceOf}.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| owner | `address` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `uint256` |  |

### baseURI

```solidity
function baseURI() external view returns (string uri)
```

The base URI used for all NFTs in this collection.

*The `tokenCID` is appended to this to obtain an NFT&#39;s `tokenURI`.      e.g. The URI for a token with the `tokenCID`: &quot;foo&quot; and `baseURI`: &quot;ipfs://&quot; is &quot;ipfs://foo&quot;.*


**Returns**

| Name | Type | Description |
|---|---|---|
| uri | `string` | The base URI used by this collection. |

### burn

```solidity
function burn(uint256 tokenId) external nonpayable
```

Allows the creator to burn a specific token if they currently own the NFT.

*The function here asserts `onlyOwner` while the super confirms ownership.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The ID of the NFT to burn. |

### contractFactory

```solidity
function contractFactory() external view returns (address)
```

The address of the factory which was used to create this contract.




**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `address` |  |

### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address)
```



*See {IERC721-getApproved}.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `address` |  |

### getFeeBps

```solidity
function getFeeBps(uint256) external pure returns (uint256[] royaltiesInBasisPoints)
```

Get the creator royalty amounts to be sent to each recipient, in basis points.

*The tokenId param is ignored since all NFTs return the same value.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| _0 | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| royaltiesInBasisPoints | `uint256[]` | The array of fees to be sent to each recipient, in basis points. |

### getFeeRecipients

```solidity
function getFeeRecipients(uint256 tokenId) external view returns (address payable[] recipients)
```

Get the recipient addresses to which creator royalties should be sent.

*The expected royalty amounts are communicated with `getFeeBps`.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The ID of the NFT to get royalties for. |

**Returns**

| Name | Type | Description |
|---|---|---|
| recipients | `address payable[]` | An array of addresses to which royalties should be sent. |

### getHasMintedCID

```solidity
function getHasMintedCID(string tokenCID) external view returns (bool hasBeenMinted)
```

Checks if the creator has already minted a given NFT using this collection contract.



**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenCID | `string` | The CID to check for. |

**Returns**

| Name | Type | Description |
|---|---|---|
| hasBeenMinted | `bool` | True if the creator has already minted an NFT with this CID. |

### getRoyalties

```solidity
function getRoyalties(uint256 tokenId) external view returns (address payable[] recipients, uint256[] royaltiesInBasisPoints)
```

Get the creator royalties to be sent.

*The data is the same as when calling `getFeeRecipients` and `getFeeBps` separately.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The ID of the NFT to get royalties for. |

**Returns**

| Name | Type | Description |
|---|---|---|
| recipients | `address payable[]` | An array of addresses to which royalties should be sent. |
| royaltiesInBasisPoints | `uint256[]` | The array of fees to be sent to each recipient, in basis points. |

### getTokenCreatorPaymentAddress

```solidity
function getTokenCreatorPaymentAddress(uint256 tokenId) external view returns (address payable creatorPaymentAddress)
```

The address to pay the creator proceeds/royalties for the collection.



**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The ID of the NFT to get the creator payment address for. |

**Returns**

| Name | Type | Description |
|---|---|---|
| creatorPaymentAddress | `address payable` | The address to which royalties should be paid. |

### initialize

```solidity
function initialize(address payable _creator, string _name, string _symbol) external nonpayable
```

Called by the contract factory on creation.



**Parameters**

| Name | Type | Description |
|---|---|---|
| _creator | `address payable` | The creator of this collection. |
| _name | `string` | The collection&#39;s `name`. |
| _symbol | `string` | The collection&#39;s `symbol`. |

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```



*See {IERC721-isApprovedForAll}.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| owner | `address` |  |
| operator | `address` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `bool` |  |

### latestTokenId

```solidity
function latestTokenId() external view returns (uint32)
```

The tokenId of the most recently created NFT.




**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `uint32` |  |

### maxTokenId

```solidity
function maxTokenId() external view returns (uint32)
```

The max tokenId which can be minted.




**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `uint32` |  |

### mint

```solidity
function mint(string tokenCID) external nonpayable returns (uint256 tokenId)
```

Mint an NFT defined by its metadata path.

*This is only callable by the collection creator/owner.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenCID | `string` | The CID for the metadata json of the NFT to mint. |

**Returns**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### mintAndApprove

```solidity
function mintAndApprove(string tokenCID, address operator) external nonpayable returns (uint256 tokenId)
```

Mint an NFT defined by its metadata path and approves the provided operator address.

*This is only callable by the collection creator/owner. It can be used the first time they mint to save having to issue a separate approval transaction before listing the NFT for sale.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenCID | `string` | The CID for the metadata json of the NFT to mint. |
| operator | `address` | The address to set as an approved operator for the creator&#39;s account. |

**Returns**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentAddress

```solidity
function mintWithCreatorPaymentAddress(string tokenCID, address payable tokenCreatorPaymentAddress) external nonpayable returns (uint256 tokenId)
```

Mint an NFT defined by its metadata path and have creator revenue/royalties sent to an alternate address.

*This is only callable by the collection creator/owner.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenCID | `string` | The CID for the metadata json of the NFT to mint. |
| tokenCreatorPaymentAddress | `address payable` | The royalty recipient address to use for this NFT. |

**Returns**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentAddressAndApprove

```solidity
function mintWithCreatorPaymentAddressAndApprove(string tokenCID, address payable tokenCreatorPaymentAddress, address operator) external nonpayable returns (uint256 tokenId)
```

Mint an NFT defined by its metadata path and approves the provided operator address.

*This is only callable by the collection creator/owner. It can be used the first time they mint to save having to issue a separate approval transaction before listing the NFT for sale.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenCID | `string` | The CID for the metadata json of the NFT to mint. |
| tokenCreatorPaymentAddress | `address payable` | The royalty recipient address to use for this NFT. |
| operator | `address` | The address to set as an approved operator for the creator&#39;s account. |

**Returns**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentFactory

```solidity
function mintWithCreatorPaymentFactory(string tokenCID, address paymentAddressFactory, bytes paymentAddressCall) external nonpayable returns (uint256 tokenId)
```

Mint an NFT defined by its metadata path and have creator revenue/royalties sent to an alternate address which is defined by a contract call, typically a proxy contract address representing the payment terms.

*This is only callable by the collection creator/owner.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenCID | `string` | The CID for the metadata json of the NFT to mint. |
| paymentAddressFactory | `address` | The contract to call which will return the address to use for payments. |
| paymentAddressCall | `bytes` | The call details to send to the factory provided. |

**Returns**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentFactoryAndApprove

```solidity
function mintWithCreatorPaymentFactoryAndApprove(string tokenCID, address paymentAddressFactory, bytes paymentAddressCall, address operator) external nonpayable returns (uint256 tokenId)
```

Mint an NFT defined by its metadata path and have creator revenue/royalties sent to an alternate address which is defined by a contract call, typically a proxy contract address representing the payment terms.

*This is only callable by the collection creator/owner. It can be used the first time they mint to save having to issue a separate approval transaction before listing the NFT for sale.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenCID | `string` | The CID for the metadata json of the NFT to mint. |
| paymentAddressFactory | `address` | The contract to call which will return the address to use for payments. |
| paymentAddressCall | `bytes` | The call details to send to the factory provided. |
| operator | `address` | The address to set as an approved operator for the creator&#39;s account. |

**Returns**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### name

```solidity
function name() external view returns (string)
```



*See {IERC721Metadata-name}.*


**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `string` |  |

### owner

```solidity
function owner() external view returns (address payable)
```

The creator/owner of this NFT collection.




**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `address payable` |  |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
```



*See {IERC721-ownerOf}.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `address` |  |

### royaltyInfo

```solidity
function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount)
```

Get the creator royalties to be sent.



**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` | The ID of the NFT to get royalties for. |
| salePrice | `uint256` | The total price of the sale. |

**Returns**

| Name | Type | Description |
|---|---|---|
| receiver | `address` | The address to which royalties should be sent. |
| royaltyAmount | `uint256` | The total amount that should be sent to the `receiver`. |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external nonpayable
```



*See {IERC721-safeTransferFrom}.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| from | `address` |  |
| to | `address` |  |
| tokenId | `uint256` |  |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes data) external nonpayable
```



*See {IERC721-safeTransferFrom}.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| from | `address` |  |
| to | `address` |  |
| tokenId | `uint256` |  |
| data | `bytes` |  |

### selfDestruct

```solidity
function selfDestruct() external nonpayable
```

Allows the collection creator to destroy this contract only if no NFTs have been minted yet or the minted NFTs have been burned.

*Once destructed, a new collection could be deployed to this address (although that&#39;s discouraged).*


### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```



*See {IERC721-setApprovalForAll}.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| operator | `address` |  |
| approved | `bool` |  |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool interfaceSupported)
```



*Returns true if this contract implements the interface defined by `interfaceId`. See the corresponding https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section] to learn more about how these ids are created. This function call must use less than 30 000 gas.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| interfaceId | `bytes4` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| interfaceSupported | `bool` |  |

### symbol

```solidity
function symbol() external view returns (string)
```



*See {IERC721Metadata-symbol}.*


**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `string` |  |

### tokenCreator

```solidity
function tokenCreator(uint256) external view returns (address payable creator)
```

Returns the creator of this NFT collection.

*The tokenId param is ignored since all NFTs return the same value.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| _0 | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| creator | `address payable` | The creator of this collection. |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string uri)
```



*Returns the Uniform Resource Identifier (URI) for `tokenId` token.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| tokenId | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| uri | `string` |  |

### totalSupply

```solidity
function totalSupply() external view returns (uint256 supply)
```

Returns the total amount of tokens stored by the contract.

*From the ERC-721 enumerable standard.*


**Returns**

| Name | Type | Description |
|---|---|---|
| supply | `uint256` | The total number of NFTs tracked by this contract. |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) external nonpayable
```



*See {IERC721-transferFrom}.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| from | `address` |  |
| to | `address` |  |
| tokenId | `uint256` |  |

### updateBaseURI

```solidity
function updateBaseURI(string baseURIOverride) external nonpayable
```

Allows the owner to assign a baseURI to use for the tokenURI instead of the default `ipfs://`.



**Parameters**

| Name | Type | Description |
|---|---|---|
| baseURIOverride | `string` | The new base URI to use for all NFTs in this collection. |

### updateMaxTokenId

```solidity
function updateMaxTokenId(uint32 _maxTokenId) external nonpayable
```

Allows the owner to set a max tokenID. This provides a guarantee to collectors about the limit of this collection contract, if applicable.

*Once this value has been set, it may be decreased but can never be increased. This max may be more than the final `totalSupply` if 1 or more tokens were burned.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| _maxTokenId | `uint32` | The max tokenId to set, all NFTs must have a tokenId less than or equal to this value. |



## Events

### Approval

```solidity
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| owner `indexed` | `address` |  |
| approved `indexed` | `address` |  |
| tokenId `indexed` | `uint256` |  |

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed owner, address indexed operator, bool approved)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| owner `indexed` | `address` |  |
| operator `indexed` | `address` |  |
| approved  | `bool` |  |

### BaseURIUpdated

```solidity
event BaseURIUpdated(string baseURI)
```

Emitted when the owner changes the base URI to be used for NFTs in this collection.



**Parameters**

| Name | Type | Description |
|---|---|---|
| baseURI  | `string` | The new base URI to use. |

### Initialized

```solidity
event Initialized(uint8 version)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| version  | `uint8` |  |

### MaxTokenIdUpdated

```solidity
event MaxTokenIdUpdated(uint256 indexed maxTokenId)
```

Emitted when the max tokenId supported by this collection is updated.



**Parameters**

| Name | Type | Description |
|---|---|---|
| maxTokenId `indexed` | `uint256` |  |

### Minted

```solidity
event Minted(address indexed creator, uint256 indexed tokenId, string indexed indexedTokenCID, string tokenCID)
```

Emitted when a new NFT is minted.



**Parameters**

| Name | Type | Description |
|---|---|---|
| creator `indexed` | `address` | The address of the collection owner at this time this NFT was minted. |
| tokenId `indexed` | `uint256` | The tokenId of the newly minted NFT. |
| indexedTokenCID `indexed` | `string` | The CID of the newly minted NFT, indexed to enable watching for mint events by the tokenCID. |
| tokenCID  | `string` | The actual CID of the newly minted NFT. |

### SelfDestruct

```solidity
event SelfDestruct(address indexed admin)
```

Emitted when this collection is self destructed by the creator/owner/admin.



**Parameters**

| Name | Type | Description |
|---|---|---|
| admin `indexed` | `address` |  |

### TokenCreatorPaymentAddressSet

```solidity
event TokenCreatorPaymentAddressSet(address indexed fromPaymentAddress, address indexed toPaymentAddress, uint256 indexed tokenId)
```

Emitted when the payment address for creator royalties is set.



**Parameters**

| Name | Type | Description |
|---|---|---|
| fromPaymentAddress `indexed` | `address` | The original address used for royalty payments. |
| toPaymentAddress `indexed` | `address` | The new address used for royalty payments. |
| tokenId `indexed` | `uint256` | The NFT which had the royalty payment address updated. |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| from `indexed` | `address` |  |
| to `indexed` | `address` |  |
| tokenId `indexed` | `uint256` |  |



