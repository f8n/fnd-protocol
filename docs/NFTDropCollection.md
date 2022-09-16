---
title: NFTDropCollection
description: A contract to batch mint a collection of NFTs.
---


A 10% royalty to the creator is included which may be split with collaborators.

*A collection can have up to 4,294,967,295 (2^32-1) tokens*

## Methods

### DEFAULT_ADMIN_ROLE

```solidity
function DEFAULT_ADMIN_ROLE() external view returns (bytes32)
```






**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `bytes32` |  |

### MINTER_ROLE

```solidity
function MINTER_ROLE() external view returns (bytes32)
```

The `role` type used for approve minters.




**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `bytes32` |  |

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
function baseURI() external view returns (string)
```

The base URI used for all NFTs in this collection.

*The `&lt;tokenId&gt;.json` is appended to this to obtain an NFT&#39;s `tokenURI`.      e.g. The URI for `tokenId`: &quot;1&quot; with `baseURI`: &quot;ipfs://foo/&quot; is &quot;ipfs://foo/1.json&quot;.*


**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `string` | The base URI used by this collection. |

### burn

```solidity
function burn(uint256 tokenId) external nonpayable
```

Allows the collection admin to burn a specific token if they currently own the NFT.

*The function here asserts `onlyAdmin` while the super confirms ownership.*

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

### getRoleAdmin

```solidity
function getRoleAdmin(bytes32 role) external view returns (bytes32)
```



*Returns the admin role that controls `role`. See {grantRole} and {revokeRole}. To change a role&#39;s admin, use {_setRoleAdmin}.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| role | `bytes32` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `bytes32` |  |

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
function getTokenCreatorPaymentAddress(uint256) external view returns (address payable creatorPaymentAddress)
```

The address to pay the creator proceeds/royalties for the collection.



**Parameters**

| Name | Type | Description |
|---|---|---|
| _0 | `uint256` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| creatorPaymentAddress | `address payable` | The address to which royalties should be paid. |

### grantAdmin

```solidity
function grantAdmin(address account) external nonpayable
```

Adds an account as an approved admin.

*Only callable by existing admins, as enforced by `grantRole`.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| account | `address` | The address to be approved. |

### grantMinter

```solidity
function grantMinter(address account) external nonpayable
```

Adds an account as an approved minter.

*Only callable by admins, as enforced by `grantRole`.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| account | `address` | The address to be approved. |

### grantRole

```solidity
function grantRole(bytes32 role, address account) external nonpayable
```



*Grants `role` to `account`. If `account` had not been already granted `role`, emits a {RoleGranted} event. Requirements: - the caller must have ``role``&#39;s admin role. May emit a {RoleGranted} event.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| role | `bytes32` |  |
| account | `address` |  |

### hasRole

```solidity
function hasRole(bytes32 role, address account) external view returns (bool)
```



*Returns `true` if `account` has been granted `role`.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| role | `bytes32` |  |
| account | `address` |  |

**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `bool` |  |

### initialize

```solidity
function initialize(address payable _creator, string _name, string _symbol, string baseURI_, bool _isRevealed, uint32 _maxTokenId, address _approvedMinter, address payable _paymentAddress) external nonpayable
```

Called by the contract factory on creation.



**Parameters**

| Name | Type | Description |
|---|---|---|
| _creator | `address payable` | The creator of this collection. This account is the default admin for this collection. |
| _name | `string` | The collection&#39;s `name`. |
| _symbol | `string` | The collection&#39;s `symbol`. |
| baseURI_ | `string` | The base URI for the collection. |
| _isRevealed | `bool` | Whether the collection is revealed or not. |
| _maxTokenId | `uint32` | The max token id for this collection. |
| _approvedMinter | `address` | An optional address to grant the MINTER_ROLE. Set to address(0) if only admins should be granted permission to mint. |
| _paymentAddress | `address payable` | The address that will receive royalties and mint payments. |

### isAdmin

```solidity
function isAdmin(address account) external view returns (bool approved)
```

Checks if the account provided is an admin.

*This call is used by the royalty registry contract.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| account | `address` | The address to check. |

**Returns**

| Name | Type | Description |
|---|---|---|
| approved | `bool` | True if the account is an admin. |

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

### isMinter

```solidity
function isMinter(address account) external view returns (bool approved)
```

Checks if the account provided is an minter.



**Parameters**

| Name | Type | Description |
|---|---|---|
| account | `address` | The address to check. |

**Returns**

| Name | Type | Description |
|---|---|---|
| approved | `bool` | True if the account is an minter. |

### isRevealed

```solidity
function isRevealed() external view returns (bool)
```

Whether the collection is revealed or not.




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

### mintCountTo

```solidity
function mintCountTo(uint16 count, address to) external nonpayable returns (uint256 firstTokenId)
```

Mint `count` number of NFTs for the `to` address.

*This is only callable by an address with either the MINTER_ROLE or the DEFAULT_ADMIN_ROLE.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| count | `uint16` | The number of NFTs to mint. |
| to | `address` | The address to mint the NFTs for. |

**Returns**

| Name | Type | Description |
|---|---|---|
| firstTokenId | `uint256` | The tokenId for the first NFT minted. The other minted tokens are assigned sequentially, so `firstTokenId` - `firstTokenId + count - 1` were minted. |

### name

```solidity
function name() external view returns (string)
```



*See {IERC721Metadata-name}.*


**Returns**

| Name | Type | Description |
|---|---|---|
| _0 | `string` |  |

### numberOfTokensAvailableToMint

```solidity
function numberOfTokensAvailableToMint() external view returns (uint256 count)
```

Get the number of tokens which can still be minted.




**Returns**

| Name | Type | Description |
|---|---|---|
| count | `uint256` | The max number of additional NFTs that can be minted by this collection. |

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

### renounceRole

```solidity
function renounceRole(bytes32 role, address account) external nonpayable
```



*Revokes `role` from the calling account. Roles are often managed via {grantRole} and {revokeRole}: this function&#39;s purpose is to provide a mechanism for accounts to lose their privileges if they are compromised (such as when a trusted device is misplaced). If the calling account had been revoked `role`, emits a {RoleRevoked} event. Requirements: - the caller must be `account`. May emit a {RoleRevoked} event.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| role | `bytes32` |  |
| account | `address` |  |

### reveal

```solidity
function reveal(string baseURI_) external nonpayable
```

Allows a collection admin to reveal the collection&#39;s final content.

*Once revealed, the collection&#39;s content is immutable. Use `updatePreRevealContent` to update content while unrevealed.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| baseURI_ | `string` | The base URI of the final content for this collection. |

### revokeAdmin

```solidity
function revokeAdmin(address account) external nonpayable
```

Removes an account from the set of approved admins.

*Only callable by existing admins, as enforced by `revokeRole`.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| account | `address` | The address to be removed. |

### revokeMinter

```solidity
function revokeMinter(address account) external nonpayable
```

Removes an account from the set of approved minters.

*Only callable by admins, as enforced by `revokeRole`.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| account | `address` | The address to be removed. |

### revokeRole

```solidity
function revokeRole(bytes32 role, address account) external nonpayable
```



*Revokes `role` from `account`. If `account` had been granted `role`, emits a {RoleRevoked} event. Requirements: - the caller must have ``role``&#39;s admin role. May emit a {RoleRevoked} event.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| role | `bytes32` |  |
| account | `address` |  |

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

Allows a collection admin to destroy this contract only if no NFTs have been minted yet or the minted NFTs have been burned.

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

### updateMaxTokenId

```solidity
function updateMaxTokenId(uint32 _maxTokenId) external nonpayable
```

Allows the owner to set a max tokenID. This provides a guarantee to collectors about the limit of this collection contract.

*Once this value has been set, it may be decreased but can never be increased. This max may be more than the final `totalSupply` if 1 or more tokens were burned.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| _maxTokenId | `uint32` | The max tokenId to set, all NFTs must have a tokenId less than or equal to this value. |

### updatePreRevealContent

```solidity
function updatePreRevealContent(string baseURI_) external nonpayable
```

Allows a collection admin to update the pre-reveal content.

*Use `reveal` to reveal the final content for this collection.*

**Parameters**

| Name | Type | Description |
|---|---|---|
| baseURI_ | `string` | The base URI of the pre-reveal content. |



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

### RoleAdminChanged

```solidity
event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| role `indexed` | `bytes32` |  |
| previousAdminRole `indexed` | `bytes32` |  |
| newAdminRole `indexed` | `bytes32` |  |

### RoleGranted

```solidity
event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| role `indexed` | `bytes32` |  |
| account `indexed` | `address` |  |
| sender `indexed` | `address` |  |

### RoleRevoked

```solidity
event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender)
```





**Parameters**

| Name | Type | Description |
|---|---|---|
| role `indexed` | `bytes32` |  |
| account `indexed` | `address` |  |
| sender `indexed` | `address` |  |

### SelfDestruct

```solidity
event SelfDestruct(address indexed admin)
```

Emitted when this collection is self destructed by the creator/owner/admin.



**Parameters**

| Name | Type | Description |
|---|---|---|
| admin `indexed` | `address` |  |

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

### URIUpdated

```solidity
event URIUpdated(string baseURI, bool isRevealed)
```

Emitted when the collection is revealed.



**Parameters**

| Name | Type | Description |
|---|---|---|
| baseURI  | `string` | The base URI for the collection. |
| isRevealed  | `bool` | Whether the collection is revealed. |



