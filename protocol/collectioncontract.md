# CollectionContract

> A collection of NFTs by a single creator.

All NFTs from this contract are minted by the same creator. A 10% royalty to the creator is included which may be split with collaborators on a per-NFT basis.

## Methods

### adminAccountMigration

```solidity
function adminAccountMigration(uint256[] ownedTokenIds, address originalAddress, address payable newAddress, bytes signature) external nonpayable
```

Allows an NFT owner or creator and Foundation to work together in order to update the creator to a new account and/or transfer NFTs to that account.

_This will gracefully skip any NFTs that have been burned or transferred._

#### Parameters

| Name            | Type              | Description                                                                                                                   |
| --------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| ownedTokenIds   | `uint256[]`       | The tokenIds of the NFTs owned by the original address to be migrated to the new account.                                     |
| originalAddress | `address`         | The original account address to be migrated.                                                                                  |
| newAddress      | `address payable` | The new address for the account.                                                                                              |
| signature       | `bytes`           | Message `I authorize Foundation to migrate my account to ${newAccount.address.toLowerCase()}` signed by the original account. |

### adminAccountMigrationForPaymentAddresses

```solidity
function adminAccountMigrationForPaymentAddresses(uint256[] paymentAddressTokenIds, address paymentAddressFactory, bytes paymentAddressCallData, uint256 addressLocationInCallData, address originalAddress, address payable newAddress, bytes signature) external nonpayable
```

Allows a split recipient and Foundation to work together in order to update the payment address to a new account.

#### Parameters

| Name                      | Type              | Description                                                                                                                   |
| ------------------------- | ----------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| paymentAddressTokenIds    | `uint256[]`       | The token IDs for the NFTs to have their payment address migrated.                                                            |
| paymentAddressFactory     | `address`         | The contract which was used to generate the payment address being migrated.                                                   |
| paymentAddressCallData    | `bytes`           | The original call data used to generate the payment address being migrated.                                                   |
| addressLocationInCallData | `uint256`         | The position where the account to migrate begins in the call data.                                                            |
| originalAddress           | `address`         | The original account address to be migrated.                                                                                  |
| newAddress                | `address payable` | The new address for the account.                                                                                              |
| signature                 | `bytes`           | Message `I authorize Foundation to migrate my account to ${newAccount.address.toLowerCase()}` signed by the original account. |

### approve

```solidity
function approve(address to, uint256 tokenId) external nonpayable
```

_See {IERC721-approve}._

#### Parameters

| Name    | Type      |
| ------- | --------- |
| to      | `address` |
| tokenId | `uint256` |

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256)
```

_See {IERC721-balanceOf}._

#### Parameters

| Name  | Type      |
| ----- | --------- |
| owner | `address` |

#### Returns

| Name | Type      |
| ---- | --------- |
| \_0  | `uint256` |

### baseURI

```solidity
function baseURI() external view returns (string uri)
```

Get the base URI used for all NFTs in this collection.

#### Returns

| Name | Type     | Description   |
| ---- | -------- | ------------- |
| uri  | `string` | The base URI. |

### burn

```solidity
function burn(uint256 tokenId) external nonpayable
```

Allows the creator to burn if they currently own the NFT.

#### Parameters

| Name    | Type      | Description                     |
| ------- | --------- | ------------------------------- |
| tokenId | `uint256` | The tokenId of the NFT to burn. |

### collectionFactory

```solidity
function collectionFactory() external view returns (contract ICollectionFactory)
```

The factory which was used to create this collection.

_This is used to read common config._

#### Returns

| Name | Type                          |
| ---- | ----------------------------- |
| \_0  | `contract ICollectionFactory` |

### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address)
```

_See {IERC721-getApproved}._

#### Parameters

| Name    | Type      |
| ------- | --------- |
| tokenId | `uint256` |

#### Returns

| Name | Type      |
| ---- | --------- |
| \_0  | `address` |

### getFeeBps

```solidity
function getFeeBps(uint256) external pure returns (uint256[] feesInBasisPoints)
```

Returns an array of royalties to be sent for secondary sales in basis points. The expected recipients is communicated with `getFeeRecipients`.

_The tokenId param is ignored since all NFTs return the same value._

#### Parameters

| Name | Type      |
| ---- | --------- |
| \_0  | `uint256` |

#### Returns

| Name              | Type        | Description                                                      |
| ----------------- | ----------- | ---------------------------------------------------------------- |
| feesInBasisPoints | `uint256[]` | The array of fees to be sent to each recipient, in basis points. |

### getFeeRecipients

```solidity
function getFeeRecipients(uint256 tokenId) external view returns (address payable[] recipients)
```

Returns an array of recipient addresses to which royalties for secondary sales should be sent. The expected royalty amount is communicated with `getFeeBps`.

#### Parameters

| Name    | Type      | Description                                               |
| ------- | --------- | --------------------------------------------------------- |
| tokenId | `uint256` | The tokenId of the NFT to get the royalty recipients for. |

#### Returns

| Name       | Type                | Description                                              |
| ---------- | ------------------- | -------------------------------------------------------- |
| recipients | `address payable[]` | An array of addresses to which royalties should be sent. |

### getHasMintedCID

```solidity
function getHasMintedCID(string tokenCID) external view returns (bool hasBeenMinted)
```

Checks if the creator has already minted a given NFT using this collection contract.

#### Parameters

| Name     | Type     | Description           |
| -------- | -------- | --------------------- |
| tokenCID | `string` | The CID to check for. |

#### Returns

| Name          | Type   | Description                                                  |
| ------------- | ------ | ------------------------------------------------------------ |
| hasBeenMinted | `bool` | True if the creator has already minted an NFT with this CID. |

### getRoyalties

```solidity
function getRoyalties(uint256 tokenId) external view returns (address payable[] recipients, uint256[] feesInBasisPoints)
```

Returns an array of royalties to be sent for secondary sales.

_The data is the same as when calling getFeeRecipients and getFeeBps separately._

#### Parameters

| Name    | Type      | Description                                      |
| ------- | --------- | ------------------------------------------------ |
| tokenId | `uint256` | The tokenId of the NFT to get the royalties for. |

#### Returns

| Name              | Type                | Description                                              |
| ----------------- | ------------------- | -------------------------------------------------------- |
| recipients        | `address payable[]` | An array of addresses to which royalties should be sent. |
| feesInBasisPoints | `uint256[]`         | The array of fees to be sent to each recipient address.  |

### getTokenCreatorPaymentAddress

```solidity
function getTokenCreatorPaymentAddress(uint256 tokenId) external view returns (address payable tokenCreatorPaymentAddress)
```

Returns the desired payment address to be used for any transfers to the creator.

_The payment address may be assigned for each individual NFT, if not defined the collection owner is returned._

#### Parameters

| Name    | Type      | Description                                      |
| ------- | --------- | ------------------------------------------------ |
| tokenId | `uint256` | The tokenId of the NFT to get the royalties for. |

#### Returns

| Name                       | Type              | Description                                                    |
| -------------------------- | ----------------- | -------------------------------------------------------------- |
| tokenCreatorPaymentAddress | `address payable` | The address to use for royalty payments for sales of this NFT. |

### initialize

```solidity
function initialize(address payable _creator, string _name, string _symbol) external nonpayable
```

Called by the factory on creation.

#### Parameters

| Name      | Type              | Description                              |
| --------- | ----------------- | ---------------------------------------- |
| \_creator | `address payable` | The creator of this collection contract. |
| \_name    | `string`          | The name of this collection.             |
| \_symbol  | `string`          | The symbol for this collection.          |

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```

_See {IERC721-isApprovedForAll}._

#### Parameters

| Name     | Type      |
| -------- | --------- |
| owner    | `address` |
| operator | `address` |

#### Returns

| Name | Type   |
| ---- | ------ |
| \_0  | `bool` |

### latestTokenId

```solidity
function latestTokenId() external view returns (uint256)
```

The tokenId of the most recently created NFT.

_Minting starts at tokenId 1. Each mint will use this value + 1._

#### Returns

| Name | Type      |
| ---- | --------- |
| \_0  | `uint256` |

### maxTokenId

```solidity
function maxTokenId() external view returns (uint256)
```

The max tokenId which can be minted, or 0 if there's no limit.

_This value may be set at any time, but once set it cannot be increased._

#### Returns

| Name | Type      |
| ---- | --------- |
| \_0  | `uint256` |

### mint

```solidity
function mint(string tokenCID) external nonpayable returns (uint256 tokenId)
```

Allows the owner to mint an NFT defined by its metadata path.

#### Parameters

| Name     | Type     | Description                 |
| -------- | -------- | --------------------------- |
| tokenCID | `string` | The CID of the NFT to mint. |

#### Returns

| Name    | Type      | Description                          |
| ------- | --------- | ------------------------------------ |
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### mintAndApprove

```solidity
function mintAndApprove(string tokenCID, address operator) external nonpayable returns (uint256 tokenId)
```

Allows the owner to mint and sets approval for all for the provided operator.

_This can be used by creators the first time they mint an NFT to save having to issue a separate approval transaction before starting an auction._

#### Parameters

| Name     | Type      | Description                                                      |
| -------- | --------- | ---------------------------------------------------------------- |
| tokenCID | `string`  | The CID of the NFT to mint.                                      |
| operator | `address` | The address to set as the operator for this collection contract. |

#### Returns

| Name    | Type      | Description                          |
| ------- | --------- | ------------------------------------ |
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentAddress

```solidity
function mintWithCreatorPaymentAddress(string tokenCID, address payable tokenCreatorPaymentAddress) external nonpayable returns (uint256 tokenId)
```

Allows the owner to mint an NFT and have creator revenue/royalties sent to an alternate address.

#### Parameters

| Name                       | Type              | Description                                        |
| -------------------------- | ----------------- | -------------------------------------------------- |
| tokenCID                   | `string`          | The CID of the NFT to mint.                        |
| tokenCreatorPaymentAddress | `address payable` | The royalty recipient address to use for this NFT. |

#### Returns

| Name    | Type      | Description                          |
| ------- | --------- | ------------------------------------ |
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentAddressAndApprove

```solidity
function mintWithCreatorPaymentAddressAndApprove(string tokenCID, address payable tokenCreatorPaymentAddress, address operator) external nonpayable returns (uint256 tokenId)
```

Allows the owner to mint an NFT and have creator revenue/royalties sent to an alternate address. Also sets approval for all for the provided operator.

_This can be used by creators the first time they mint an NFT to save having to issue a separate approval transaction before starting an auction._

#### Parameters

| Name                       | Type              | Description                                                      |
| -------------------------- | ----------------- | ---------------------------------------------------------------- |
| tokenCID                   | `string`          | The CID of the NFT to mint.                                      |
| tokenCreatorPaymentAddress | `address payable` | The royalty recipient address to use for this NFT.               |
| operator                   | `address`         | The address to set as the operator for this collection contract. |

#### Returns

| Name    | Type      | Description                          |
| ------- | --------- | ------------------------------------ |
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentFactory

```solidity
function mintWithCreatorPaymentFactory(string tokenCID, address paymentAddressFactory, bytes paymentAddressCallData) external nonpayable returns (uint256 tokenId)
```

Allows the owner to mint an NFT and have creator revenue/royalties sent to an alternate address which is defined by a contract call, typically a proxy contract address representing the payment terms.

#### Parameters

| Name                   | Type      | Description                                                             |
| ---------------------- | --------- | ----------------------------------------------------------------------- |
| tokenCID               | `string`  | The CID of the NFT to mint.                                             |
| paymentAddressFactory  | `address` | The contract to call which will return the address to use for payments. |
| paymentAddressCallData | `bytes`   | The call details to sent to the factory provided.                       |

#### Returns

| Name    | Type      | Description                          |
| ------- | --------- | ------------------------------------ |
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentFactoryAndApprove

```solidity
function mintWithCreatorPaymentFactoryAndApprove(string tokenCID, address paymentAddressFactory, bytes paymentAddressCallData, address operator) external nonpayable returns (uint256 tokenId)
```

Allows the owner to mint an NFT and have creator revenue/royalties sent to an alternate address which is defined by a contract call, typically a proxy contract address representing the payment terms. Also sets approval for all for the provided operator.

_This can be used by creators the first time they mint an NFT to save having to issue a separate approval transaction before starting an auction._

#### Parameters

| Name                   | Type      | Description                                                             |
| ---------------------- | --------- | ----------------------------------------------------------------------- |
| tokenCID               | `string`  | The CID of the NFT to mint.                                             |
| paymentAddressFactory  | `address` | The contract to call which will return the address to use for payments. |
| paymentAddressCallData | `bytes`   | The call details to sent to the factory provided.                       |
| operator               | `address` | The address to set as the operator for this collection contract.        |

#### Returns

| Name    | Type      | Description                          |
| ------- | --------- | ------------------------------------ |
| tokenId | `uint256` | The tokenId of the newly minted NFT. |

### name

```solidity
function name() external view returns (string)
```

_See {IERC721Metadata-name}._

#### Returns

| Name | Type     |
| ---- | -------- |
| \_0  | `string` |

### owner

```solidity
function owner() external view returns (address payable)
```

The owner/creator of this NFT collection.

#### Returns

| Name | Type              |
| ---- | ----------------- |
| \_0  | `address payable` |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
```

_See {IERC721-ownerOf}._

#### Parameters

| Name    | Type      |
| ------- | --------- |
| tokenId | `uint256` |

#### Returns

| Name | Type      |
| ---- | --------- |
| \_0  | `address` |

### royaltyInfo

```solidity
function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount)
```

Returns the receiver and the amount to be sent for a secondary sale.

#### Parameters

| Name      | Type      | Description                                                         |
| --------- | --------- | ------------------------------------------------------------------- |
| tokenId   | `uint256` | The tokenId of the NFT to get the royalty recipient and amount for. |
| salePrice | `uint256` | The total price of the sale.                                        |

#### Returns

| Name          | Type      | Description                                             |
| ------------- | --------- | ------------------------------------------------------- |
| receiver      | `address` | The royalty recipient address for this sale.            |
| royaltyAmount | `uint256` | The total amount that should be sent to the `receiver`. |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external nonpayable
```

_See {IERC721-safeTransferFrom}._

#### Parameters

| Name    | Type      |
| ------- | --------- |
| from    | `address` |
| to      | `address` |
| tokenId | `uint256` |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes _data) external nonpayable
```

_See {IERC721-safeTransferFrom}._

#### Parameters

| Name    | Type      |
| ------- | --------- |
| from    | `address` |
| to      | `address` |
| tokenId | `uint256` |
| \_data  | `bytes`   |

### selfDestruct

```solidity
function selfDestruct() external nonpayable
```

Allows the collection owner to destroy this contract only if no NFTs have been minted yet.

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```

_See {IERC721-setApprovalForAll}._

#### Parameters

| Name     | Type      |
| -------- | --------- |
| operator | `address` |
| approved | `bool`    |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool interfaceSupported)
```

_Checks the supported royalty interfaces._

#### Parameters

| Name        | Type     |
| ----------- | -------- |
| interfaceId | `bytes4` |

#### Returns

| Name               | Type   |
| ------------------ | ------ |
| interfaceSupported | `bool` |

### symbol

```solidity
function symbol() external view returns (string)
```

_See {IERC721Metadata-symbol}._

#### Returns

| Name | Type     |
| ---- | -------- |
| \_0  | `string` |

### tokenCreator

```solidity
function tokenCreator(uint256) external view returns (address payable creator)
```

Returns the creator of this NFT collection.

_The tokenId param is ignored since all NFTs return the same value._

#### Parameters

| Name | Type      |
| ---- | --------- |
| \_0  | `uint256` |

#### Returns

| Name    | Type              | Description                     |
| ------- | ----------------- | ------------------------------- |
| creator | `address payable` | The creator of this collection. |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string uri)
```

A distinct URI to the asset for a given NFT.

#### Parameters

| Name    | Type      | Description                                |
| ------- | --------- | ------------------------------------------ |
| tokenId | `uint256` | The tokenId of the NFT to get the URI for. |

#### Returns

| Name | Type     | Description           |
| ---- | -------- | --------------------- |
| uri  | `string` | The URI for this NFT. |

### totalSupply

```solidity
function totalSupply() external view returns (uint256 supply)
```

Count of NFTs tracked by this contract.

_From the ERC-721 enumerable standard._

#### Returns

| Name   | Type      | Description                                              |
| ------ | --------- | -------------------------------------------------------- |
| supply | `uint256` | The total number of NFTs still tracked by this contract. |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) external nonpayable
```

_See {IERC721-transferFrom}._

#### Parameters

| Name    | Type      |
| ------- | --------- |
| from    | `address` |
| to      | `address` |
| tokenId | `uint256` |

### updateBaseURI

```solidity
function updateBaseURI(string baseURIOverride) external nonpayable
```

Allows the owner to assign a baseURI to use for the tokenURI instead of the default `ipfs://`.

#### Parameters

| Name            | Type     | Description                                              |
| --------------- | -------- | -------------------------------------------------------- |
| baseURIOverride | `string` | The new base URI to use for all NFTs in this collection. |

### updateMaxTokenId

```solidity
function updateMaxTokenId(uint256 _maxTokenId) external nonpayable
```

Allows the owner to set a max tokenID. This provides a guarantee to collectors about the limit of this collection contract, if applicable.

_Once this value has been set, it may be decreased but can never be increased._

#### Parameters

| Name         | Type      | Description                                                                            |
| ------------ | --------- | -------------------------------------------------------------------------------------- |
| \_maxTokenId | `uint256` | The max tokenId to set, all NFTs must have a tokenId less than or equal to this value. |

## Events

### Approval

```solidity
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId)
```

#### Parameters

| Name               | Type      |
| ------------------ | --------- |
| owner `indexed`    | `address` |
| approved `indexed` | `address` |
| tokenId `indexed`  | `uint256` |

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed owner, address indexed operator, bool approved)
```

#### Parameters

| Name               | Type      |
| ------------------ | --------- |
| owner `indexed`    | `address` |
| operator `indexed` | `address` |
| approved           | `bool`    |

### BaseURIUpdated

```solidity
event BaseURIUpdated(string baseURI)
```

Emitted when the owner changes the base URI to be used for NFTs in this collection.

#### Parameters

| Name    | Type     | Description              |
| ------- | -------- | ------------------------ |
| baseURI | `string` | The new base URI to use. |

### CreatorMigrated

```solidity
event CreatorMigrated(address indexed originalAddress, address indexed newAddress)
```

Emitted when the owner of this collection is changed through account migration.

#### Parameters

| Name                      | Type      | Description                                 |
| ------------------------- | --------- | ------------------------------------------- |
| originalAddress `indexed` | `address` | The address which was previously the owner. |
| newAddress `indexed`      | `address` | The new address which is now the owner.     |

### Initialized

```solidity
event Initialized(uint8 version)
```

#### Parameters

| Name    | Type    |
| ------- | ------- |
| version | `uint8` |

### MaxTokenIdUpdated

```solidity
event MaxTokenIdUpdated(uint256 indexed maxTokenId)
```

Emitted when the max tokenId supported by this collection is defined.

#### Parameters

| Name                 | Type      | Description                                                                                            |
| -------------------- | --------- | ------------------------------------------------------------------------------------------------------ |
| maxTokenId `indexed` | `uint256` | The new max tokenId. All NFTs in this collection will have a tokenId less than or equal to this value. |

### Minted

```solidity
event Minted(address indexed creator, uint256 indexed tokenId, string indexed indexedTokenCID, string tokenCID)
```

Emitted when a new NFT is minted.

#### Parameters

| Name                      | Type      | Description                                                                                  |
| ------------------------- | --------- | -------------------------------------------------------------------------------------------- |
| creator `indexed`         | `address` | The address of the collection owner at this time this NFT was minted.                        |
| tokenId `indexed`         | `uint256` | The tokenId of the newly minted NFT.                                                         |
| indexedTokenCID `indexed` | `string`  | The CID of the newly minted NFT, indexed to enable watching for mint events by the tokenCID. |
| tokenCID                  | `string`  | The actual CID of the newly minted NFT.                                                      |

### NFTOwnerMigrated

```solidity
event NFTOwnerMigrated(uint256 indexed tokenId, address indexed originalAddress, address indexed newAddress)
```

Emitted when the owner of an NFT is changed through account migration.

#### Parameters

| Name                      | Type      | Description                                   |
| ------------------------- | --------- | --------------------------------------------- |
| tokenId `indexed`         | `uint256` | The tokenId of the NFT which was transferred. |
| originalAddress `indexed` | `address` | The address which was previously the owner.   |
| newAddress `indexed`      | `address` | The new address which is now the owner.       |

### PaymentAddressMigrated

```solidity
event PaymentAddressMigrated(uint256 indexed tokenId, address indexed originalAddress, address indexed newAddress, address originalPaymentAddress, address newPaymentAddress)
```

Emitted when the payment address for an NFT is changed through account migration.

#### Parameters

| Name                      | Type      | Description                                                          |
| ------------------------- | --------- | -------------------------------------------------------------------- |
| tokenId `indexed`         | `uint256` | The tokenId of the NFT which had the payment address changed.        |
| originalAddress `indexed` | `address` | The original recipient address for royalties that is being migrated. |
| newAddress `indexed`      | `address` | The new recipient address for royalties.                             |
| originalPaymentAddress    | `address` | The original payment address for royalty payments.                   |
| newPaymentAddress         | `address` | The new payment address used to split royalty payments.              |

### SelfDestruct

```solidity
event SelfDestruct(address indexed owner)
```

Emitted when this collection is self destructed by the owner.

#### Parameters

| Name            | Type      | Description                                                           |
| --------------- | --------- | --------------------------------------------------------------------- |
| owner `indexed` | `address` | The collection owner at the time this collection was self destructed. |

### TokenCreatorPaymentAddressSet

```solidity
event TokenCreatorPaymentAddressSet(address indexed fromPaymentAddress, address indexed toPaymentAddress, uint256 indexed tokenId)
```

Emitted when the payment address for creator royalties is set.

#### Parameters

| Name                         | Type      | Description                                            |
| ---------------------------- | --------- | ------------------------------------------------------ |
| fromPaymentAddress `indexed` | `address` | The original address used for royalty payments.        |
| toPaymentAddress `indexed`   | `address` | The new address used for royalty payments.             |
| tokenId `indexed`            | `uint256` | The NFT which had the royalty payment address updated. |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)
```

#### Parameters

| Name              | Type      |
| ----------------- | --------- |
| from `indexed`    | `address` |
| to `indexed`      | `address` |
| tokenId `indexed` | `uint256` |

## Errors

### AccountMigrationLibrary_Cannot_Migrate_Account_To_Itself

```solidity
error AccountMigrationLibrary_Cannot_Migrate_Account_To_Itself()
```

### AccountMigrationLibrary_Signature_Verification_Failed

```solidity
error AccountMigrationLibrary_Signature_Verification_Failed()
```

### BytesLibrary_Expected_Address_Not_Found

```solidity
error BytesLibrary_Expected_Address_Not_Found()
```
