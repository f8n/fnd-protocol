# FNDNFT721

> Foundation NFTs implemented using the ERC-721 standard.

## Methods

### adminAccountMigration

```solidity
function adminAccountMigration(uint256[] createdTokenIds, uint256[] ownedTokenIds, address originalAddress, address payable newAddress, bytes signature) external nonpayable
```

Allows an NFT owner or creator and Foundation to work together in order to update the creator to a new account and/or transfer NFTs to that account.

_This will gracefully skip any NFTs that have been burned or transferred._

#### Parameters

| Name            | Type            | Description                                                                                                                   |
| --------------- | --------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| createdTokenIds | uint256[]       | The tokenIds of the NFTs which were created by the original address.                                                          |
| ownedTokenIds   | uint256[]       | The tokenIds of the NFTs owned by the original address to be migrated to the new account.                                     |
| originalAddress | address         | The original account address to be migrated.                                                                                  |
| newAddress      | address payable | The new address for the account.                                                                                              |
| signature       | bytes           | Message `I authorize Foundation to migrate my account to ${newAccount.address.toLowerCase()}` signed by the original account. |

### adminAccountMigrationForPaymentAddresses

```solidity
function adminAccountMigrationForPaymentAddresses(uint256[] paymentAddressTokenIds, address paymentAddressFactory, bytes paymentAddressCallData, uint256 addressLocationInCallData, address originalAddress, address payable newAddress, bytes signature) external nonpayable
```

Allows a split recipient and Foundation to work together in order to update the payment address to a new account.

#### Parameters

| Name                      | Type            | Description                                                                                                                   |
| ------------------------- | --------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| paymentAddressTokenIds    | uint256[]       | The token IDs for the NFTs to have their payment address migrated.                                                            |
| paymentAddressFactory     | address         | The contract which was used to generate the payment address being migrated.                                                   |
| paymentAddressCallData    | bytes           | The original call data used to generate the payment address being migrated.                                                   |
| addressLocationInCallData | uint256         | The position where the account to migrate begins in the call data.                                                            |
| originalAddress           | address         | The original account address to be migrated.                                                                                  |
| newAddress                | address payable | The new address for the account.                                                                                              |
| signature                 | bytes           | Message `I authorize Foundation to migrate my account to ${newAccount.address.toLowerCase()}` signed by the original account. |

### adminUpdateConfig

```solidity
function adminUpdateConfig(address _nftMarket, string baseURI, address proxyCallContract) external nonpayable
```

Allows a Foundation admin to update NFT config variables.

_This must be called right after the initial call to `initialize`._

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| \_nftMarket       | address | undefined   |
| baseURI           | string  | undefined   |
| proxyCallContract | address | undefined   |

### approve

```solidity
function approve(address to, uint256 tokenId) external nonpayable
```

_See {IERC721-approve}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |

### balanceOf

```solidity
function balanceOf(address owner) external view returns (uint256)
```

_See {IERC721-balanceOf}._

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| owner | address | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### baseURI

```solidity
function baseURI() external view returns (string)
```

_Returns the base URI set via {\_setBaseURI}. This will be automatically added as a prefix in {tokenURI} to each token&#39;s URI, or to the token ID if no specific URI is set for that token ID._

#### Returns

| Name | Type   | Description |
| ---- | ------ | ----------- |
| \_0  | string | undefined   |

### burn

```solidity
function burn(uint256 tokenId) external nonpayable
```

Allows the creator to burn if they currently own the NFT.

#### Parameters

| Name    | Type    | Description                          |
| ------- | ------- | ------------------------------------ |
| tokenId | uint256 | The tokenId of the NFT to be burned. |

### getApproved

```solidity
function getApproved(uint256 tokenId) external view returns (address)
```

_See {IERC721-getApproved}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | address | undefined   |

### getFeeBps

```solidity
function getFeeBps(uint256) external pure returns (uint256[])
```

Returns an array of fees in basis points. The expected recipients is communicated with `getFeeRecipients`.

_The tokenId param is ignored since all NFTs return the same value._

#### Parameters

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

#### Returns

| Name | Type      | Description                                                                        |
| ---- | --------- | ---------------------------------------------------------------------------------- |
| \_0  | uint256[] | feesInBasisPoints The array of fees to be sent to each recipient, in basis points. |

### getFeeRecipients

```solidity
function getFeeRecipients(uint256 tokenId) external view returns (address payable[])
```

Returns an array of recipient addresses to which fees should be sent. The expected fee amount is communicated with `getFeeBps`.

#### Parameters

| Name    | Type    | Description                                               |
| ------- | ------- | --------------------------------------------------------- |
| tokenId | uint256 | The tokenId of the NFT to get the royalty recipients for. |

#### Returns

| Name | Type              | Description                                                         |
| ---- | ----------------- | ------------------------------------------------------------------- |
| \_0  | address payable[] | recipients An array of addresses to which royalties should be sent. |

### getFoundationTreasury

```solidity
function getFoundationTreasury() external view returns (address payable treasuryAddress)
```

Gets the Foundation treasury contract.

_This call is used in the royalty registry contract._

#### Returns

| Name            | Type            | Description                                      |
| --------------- | --------------- | ------------------------------------------------ |
| treasuryAddress | address payable | The address of the Foundation treasury contract. |

### getHasCreatorMintedIPFSHash

```solidity
function getHasCreatorMintedIPFSHash(address creator, string tokenIPFSPath) external view returns (bool hasMinted)
```

Checks if the creator has already minted a given NFT.

#### Parameters

| Name          | Type    | Description                                                           |
| ------------- | ------- | --------------------------------------------------------------------- |
| creator       | address | The creator which may have minted this NFT already.                   |
| tokenIPFSPath | string  | The IPFS path to the metadata JSON file, without the base URI prefix. |

#### Returns

| Name      | Type | Description                                      |
| --------- | ---- | ------------------------------------------------ |
| hasMinted | bool | True if the creator has already minted this NFT. |

### getNFTMarket

```solidity
function getNFTMarket() external view returns (address market)
```

Returns the address of the Foundation market contract.

#### Returns

| Name   | Type    | Description                             |
| ------ | ------- | --------------------------------------- |
| market | address | The Foundation market contract address. |

### getNextTokenId

```solidity
function getNextTokenId() external view returns (uint256 tokenId)
```

Gets the tokenId of the next NFT minted.

#### Returns

| Name    | Type    | Description                               |
| ------- | ------- | ----------------------------------------- |
| tokenId | uint256 | The ID that the next NFT minted will use. |

### getRoyalties

```solidity
function getRoyalties(uint256 tokenId) external view returns (address payable[] recipients, uint256[] feesInBasisPoints)
```

Get fee recipients and fees in a single call.

_The data is the same as when calling getFeeRecipients and getFeeBps separately._

#### Parameters

| Name    | Type    | Description                                      |
| ------- | ------- | ------------------------------------------------ |
| tokenId | uint256 | The tokenId of the NFT to get the royalties for. |

#### Returns

| Name              | Type              | Description                                              |
| ----------------- | ----------------- | -------------------------------------------------------- |
| recipients        | address payable[] | An array of addresses to which royalties should be sent. |
| feesInBasisPoints | uint256[]         | The array of fees to be sent to each recipient address.  |

### getTokenCreatorPaymentAddress

```solidity
function getTokenCreatorPaymentAddress(uint256 tokenId) external view returns (address payable tokenCreatorPaymentAddress)
```

Returns the payment address for a given tokenId.

_If an alternate address was not defined, the creator is returned instead._

#### Parameters

| Name    | Type    | Description                                            |
| ------- | ------- | ------------------------------------------------------ |
| tokenId | uint256 | The tokenId of the NFT to get the payment address for. |

#### Returns

| Name                       | Type            | Description                                                 |
| -------------------------- | --------------- | ----------------------------------------------------------- |
| tokenCreatorPaymentAddress | address payable | The address to which royalties should be sent for this NFT. |

### getTokenIPFSPath

```solidity
function getTokenIPFSPath(uint256 tokenId) external view returns (string path)
```

Returns the IPFS path to the metadata JSON file for a given NFT.

#### Parameters

| Name    | Type    | Description                      |
| ------- | ------- | -------------------------------- |
| tokenId | uint256 | The NFT to get the CID path for. |

#### Returns

| Name | Type   | Description                                                           |
| ---- | ------ | --------------------------------------------------------------------- |
| path | string | The IPFS path to the metadata JSON file, without the base URI prefix. |

### initialize

```solidity
function initialize() external nonpayable
```

Called once to configure the contract after the initial deployment.

_This farms the initialize call out to inherited contracts as needed._

### isApprovedForAll

```solidity
function isApprovedForAll(address owner, address operator) external view returns (bool)
```

_See {IERC721-isApprovedForAll}._

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| owner    | address | undefined   |
| operator | address | undefined   |

#### Returns

| Name | Type | Description |
| ---- | ---- | ----------- |
| \_0  | bool | undefined   |

### mint

```solidity
function mint(string tokenIPFSPath) external nonpayable returns (uint256 tokenId)
```

Allows a creator to mint an NFT.

#### Parameters

| Name          | Type   | Description                                                      |
| ------------- | ------ | ---------------------------------------------------------------- |
| tokenIPFSPath | string | The IPFS path for the NFT to mint, without the leading base URI. |

#### Returns

| Name    | Type    | Description                          |
| ------- | ------- | ------------------------------------ |
| tokenId | uint256 | The tokenId of the newly minted NFT. |

### mintAndApproveMarket

```solidity
function mintAndApproveMarket(string tokenIPFSPath) external nonpayable returns (uint256 tokenId)
```

Allows a creator to mint an NFT and set approval for the Foundation marketplace.

_This can be used by creators the first time they mint an NFT to save having to issue a separate approval transaction before starting an auction._

#### Parameters

| Name          | Type   | Description                                                      |
| ------------- | ------ | ---------------------------------------------------------------- |
| tokenIPFSPath | string | The IPFS path for the NFT to mint, without the leading base URI. |

#### Returns

| Name    | Type    | Description                          |
| ------- | ------- | ------------------------------------ |
| tokenId | uint256 | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentAddress

```solidity
function mintWithCreatorPaymentAddress(string tokenIPFSPath, address payable tokenCreatorPaymentAddress) external nonpayable returns (uint256 tokenId)
```

Allows a creator to mint an NFT and have creator revenue/royalties sent to an alternate address.

#### Parameters

| Name                       | Type            | Description                                                      |
| -------------------------- | --------------- | ---------------------------------------------------------------- |
| tokenIPFSPath              | string          | The IPFS path for the NFT to mint, without the leading base URI. |
| tokenCreatorPaymentAddress | address payable | The royalty recipient address to use for this NFT.               |

#### Returns

| Name    | Type    | Description                          |
| ------- | ------- | ------------------------------------ |
| tokenId | uint256 | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentAddressAndApproveMarket

```solidity
function mintWithCreatorPaymentAddressAndApproveMarket(string tokenIPFSPath, address payable tokenCreatorPaymentAddress) external nonpayable returns (uint256 tokenId)
```

Allows a creator to mint an NFT and have creator revenue/royalties sent to an alternate address. Also sets approval for the Foundation marketplace.

_This can be used by creators the first time they mint an NFT to save having to issue a separate approval transaction before starting an auction._

#### Parameters

| Name                       | Type            | Description                                                      |
| -------------------------- | --------------- | ---------------------------------------------------------------- |
| tokenIPFSPath              | string          | The IPFS path for the NFT to mint, without the leading base URI. |
| tokenCreatorPaymentAddress | address payable | The royalty recipient address to use for this NFT.               |

#### Returns

| Name    | Type    | Description                          |
| ------- | ------- | ------------------------------------ |
| tokenId | uint256 | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentFactory

```solidity
function mintWithCreatorPaymentFactory(string tokenIPFSPath, address paymentAddressFactory, bytes paymentAddressCallData) external nonpayable returns (uint256 tokenId)
```

Allows a creator to mint an NFT and have creator revenue/royalties sent to an alternate address which is defined by a contract call, typically a proxy contract address representing the payment terms.

#### Parameters

| Name                   | Type    | Description                                                             |
| ---------------------- | ------- | ----------------------------------------------------------------------- |
| tokenIPFSPath          | string  | The IPFS path for the NFT to mint, without the leading base URI.        |
| paymentAddressFactory  | address | The contract to call which will return the address to use for payments. |
| paymentAddressCallData | bytes   | The call details to sent to the factory provided.                       |

#### Returns

| Name    | Type    | Description                          |
| ------- | ------- | ------------------------------------ |
| tokenId | uint256 | The tokenId of the newly minted NFT. |

### mintWithCreatorPaymentFactoryAndApproveMarket

```solidity
function mintWithCreatorPaymentFactoryAndApproveMarket(string tokenIPFSPath, address paymentAddressFactory, bytes paymentAddressCallData) external nonpayable returns (uint256 tokenId)
```

Allows a creator to mint an NFT and have creator revenue/royalties sent to an alternate address which is defined by a contract call, typically a proxy contract address representing the payment terms. Also sets approval for the Foundation marketplace.

_This can be used by creators the first time they mint an NFT to save having to issue a separate approval transaction before starting an auction._

#### Parameters

| Name                   | Type    | Description                                                             |
| ---------------------- | ------- | ----------------------------------------------------------------------- |
| tokenIPFSPath          | string  | The IPFS path for the NFT to mint, without the leading base URI.        |
| paymentAddressFactory  | address | The contract to call which will return the address to use for payments. |
| paymentAddressCallData | bytes   | The call details to sent to the factory provided.                       |

#### Returns

| Name    | Type    | Description                          |
| ------- | ------- | ------------------------------------ |
| tokenId | uint256 | The tokenId of the newly minted NFT. |

### name

```solidity
function name() external pure returns (string)
```

_See {IERC721Metadata-name}._

#### Returns

| Name | Type   | Description |
| ---- | ------ | ----------- |
| \_0  | string | undefined   |

### ownerOf

```solidity
function ownerOf(uint256 tokenId) external view returns (address)
```

_See {IERC721-ownerOf}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | address | undefined   |

### proxyCallAddress

```solidity
function proxyCallAddress() external view returns (address contractAddress)
```

Returns the address of the current proxy call contract.

#### Returns

| Name            | Type    | Description                                     |
| --------------- | ------- | ----------------------------------------------- |
| contractAddress | address | The address of the current proxy call contract. |

### royaltyInfo

```solidity
function royaltyInfo(uint256 tokenId, uint256 salePrice) external view returns (address receiver, uint256 royaltyAmount)
```

Returns the receiver and the amount to be sent for a secondary sale.

#### Parameters

| Name      | Type    | Description                                                         |
| --------- | ------- | ------------------------------------------------------------------- |
| tokenId   | uint256 | The tokenId of the NFT to get the royalty recipient and amount for. |
| salePrice | uint256 | The total price of the sale.                                        |

#### Returns

| Name          | Type    | Description                                             |
| ------------- | ------- | ------------------------------------------------------- |
| receiver      | address | The royalty recipient address for this sale.            |
| royaltyAmount | uint256 | The total amount that should be sent to the `receiver`. |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId) external nonpayable
```

_See {IERC721-safeTransferFrom}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| from    | address | undefined   |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |

### safeTransferFrom

```solidity
function safeTransferFrom(address from, address to, uint256 tokenId, bytes _data) external nonpayable
```

_See {IERC721-safeTransferFrom}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| from    | address | undefined   |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |
| \_data  | bytes   | undefined   |

### setApprovalForAll

```solidity
function setApprovalForAll(address operator, bool approved) external nonpayable
```

_See {IERC721-setApprovalForAll}._

#### Parameters

| Name     | Type    | Description |
| -------- | ------- | ----------- |
| operator | address | undefined   |
| approved | bool    | undefined   |

### supportsInterface

```solidity
function supportsInterface(bytes4 interfaceId) external view returns (bool)
```

#### Parameters

| Name        | Type   | Description |
| ----------- | ------ | ----------- |
| interfaceId | bytes4 | undefined   |

#### Returns

| Name | Type | Description |
| ---- | ---- | ----------- |
| \_0  | bool | undefined   |

### symbol

```solidity
function symbol() external pure returns (string)
```

_See {IERC721Metadata-symbol}._

#### Returns

| Name | Type   | Description |
| ---- | ------ | ----------- |
| \_0  | string | undefined   |

### tokenByIndex

```solidity
function tokenByIndex(uint256 index) external view returns (uint256)
```

_See {IERC721Enumerable-tokenByIndex}._

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| index | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### tokenCreator

```solidity
function tokenCreator(uint256 tokenId) external view returns (address payable creator)
```

Returns the creator&#39;s address for a given tokenId.

#### Parameters

| Name    | Type    | Description                                    |
| ------- | ------- | ---------------------------------------------- |
| tokenId | uint256 | The tokenId of the NFT to get the creator for. |

#### Returns

| Name    | Type            | Description                                      |
| ------- | --------------- | ------------------------------------------------ |
| creator | address payable | The creator&#39;s address for the given tokenId. |

### tokenOfOwnerByIndex

```solidity
function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256)
```

_See {IERC721Enumerable-tokenOfOwnerByIndex}._

#### Parameters

| Name  | Type    | Description |
| ----- | ------- | ----------- |
| owner | address | undefined   |
| index | uint256 | undefined   |

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### tokenURI

```solidity
function tokenURI(uint256 tokenId) external view returns (string)
```

_See {IERC721Metadata-tokenURI}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| tokenId | uint256 | undefined   |

#### Returns

| Name | Type   | Description |
| ---- | ------ | ----------- |
| \_0  | string | undefined   |

### totalSupply

```solidity
function totalSupply() external view returns (uint256)
```

_See {IERC721Enumerable-totalSupply}._

#### Returns

| Name | Type    | Description |
| ---- | ------- | ----------- |
| \_0  | uint256 | undefined   |

### transferFrom

```solidity
function transferFrom(address from, address to, uint256 tokenId) external nonpayable
```

_See {IERC721-transferFrom}._

#### Parameters

| Name    | Type    | Description |
| ------- | ------- | ----------- |
| from    | address | undefined   |
| to      | address | undefined   |
| tokenId | uint256 | undefined   |

## Events

### Approval

```solidity
event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId)
```

#### Parameters

| Name               | Type    | Description |
| ------------------ | ------- | ----------- |
| owner `indexed`    | address | undefined   |
| approved `indexed` | address | undefined   |
| tokenId `indexed`  | uint256 | undefined   |

### ApprovalForAll

```solidity
event ApprovalForAll(address indexed owner, address indexed operator, bool approved)
```

#### Parameters

| Name               | Type    | Description |
| ------------------ | ------- | ----------- |
| owner `indexed`    | address | undefined   |
| operator `indexed` | address | undefined   |
| approved           | bool    | undefined   |

### BaseURIUpdated

```solidity
event BaseURIUpdated(string baseURI)
```

Emitted when the base URI used by NFTs created by this contract is updated.

#### Parameters

| Name    | Type   | Description |
| ------- | ------ | ----------- |
| baseURI | string | undefined   |

### Initialized

```solidity
event Initialized(uint8 version)
```

#### Parameters

| Name    | Type  | Description |
| ------- | ----- | ----------- |
| version | uint8 | undefined   |

### Minted

```solidity
event Minted(address indexed creator, uint256 indexed tokenId, string indexed indexedTokenIPFSPath, string tokenIPFSPath)
```

Emitted when a new NFT is minted.

#### Parameters

| Name                           | Type    | Description |
| ------------------------------ | ------- | ----------- |
| creator `indexed`              | address | undefined   |
| tokenId `indexed`              | uint256 | undefined   |
| indexedTokenIPFSPath `indexed` | string  | undefined   |
| tokenIPFSPath                  | string  | undefined   |

### NFTCreatorMigrated

```solidity
event NFTCreatorMigrated(uint256 indexed tokenId, address indexed originalAddress, address indexed newAddress)
```

Emitted when the creator for an NFT is changed through account migration.

#### Parameters

| Name                      | Type    | Description |
| ------------------------- | ------- | ----------- |
| tokenId `indexed`         | uint256 | undefined   |
| originalAddress `indexed` | address | undefined   |
| newAddress `indexed`      | address | undefined   |

### NFTMarketUpdated

```solidity
event NFTMarketUpdated(address indexed nftMarket)
```

Emitted when the market contract address used for approvals is updated.

#### Parameters

| Name                | Type    | Description |
| ------------------- | ------- | ----------- |
| nftMarket `indexed` | address | undefined   |

### NFTOwnerMigrated

```solidity
event NFTOwnerMigrated(uint256 indexed tokenId, address indexed originalAddress, address indexed newAddress)
```

Emitted when the owner of an NFT is changed through account migration.

#### Parameters

| Name                      | Type    | Description |
| ------------------------- | ------- | ----------- |
| tokenId `indexed`         | uint256 | undefined   |
| originalAddress `indexed` | address | undefined   |
| newAddress `indexed`      | address | undefined   |

### PaymentAddressMigrated

```solidity
event PaymentAddressMigrated(uint256 indexed tokenId, address indexed originalAddress, address indexed newAddress, address originalPaymentAddress, address newPaymentAddress)
```

Emitted when the payment address for an NFT is changed through account migration.

#### Parameters

| Name                      | Type    | Description |
| ------------------------- | ------- | ----------- |
| tokenId `indexed`         | uint256 | undefined   |
| originalAddress `indexed` | address | undefined   |
| newAddress `indexed`      | address | undefined   |
| originalPaymentAddress    | address | undefined   |
| newPaymentAddress         | address | undefined   |

### ProxyCallContractUpdated

```solidity
event ProxyCallContractUpdated(address indexed proxyCallContract)
```

Emitted when the proxy call contract is updated.

#### Parameters

| Name                        | Type    | Description |
| --------------------------- | ------- | ----------- |
| proxyCallContract `indexed` | address | undefined   |

### TokenCreatorPaymentAddressSet

```solidity
event TokenCreatorPaymentAddressSet(address indexed fromPaymentAddress, address indexed toPaymentAddress, uint256 indexed tokenId)
```

Emitted when the creator payment address for an NFT is set.

#### Parameters

| Name                         | Type    | Description |
| ---------------------------- | ------- | ----------- |
| fromPaymentAddress `indexed` | address | undefined   |
| toPaymentAddress `indexed`   | address | undefined   |
| tokenId `indexed`            | uint256 | undefined   |

### TokenCreatorUpdated

```solidity
event TokenCreatorUpdated(address indexed fromCreator, address indexed toCreator, uint256 indexed tokenId)
```

Emitted when the creator for an NFT is set.

#### Parameters

| Name                  | Type    | Description |
| --------------------- | ------- | ----------- |
| fromCreator `indexed` | address | undefined   |
| toCreator `indexed`   | address | undefined   |
| tokenId `indexed`     | uint256 | undefined   |

### Transfer

```solidity
event Transfer(address indexed from, address indexed to, uint256 indexed tokenId)
```

#### Parameters

| Name              | Type    | Description |
| ----------------- | ------- | ----------- |
| from `indexed`    | address | undefined   |
| to `indexed`      | address | undefined   |
| tokenId `indexed` | uint256 | undefined   |

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

### FoundationTreasuryNode_Address_Is_Not_A_Contract

```solidity
error FoundationTreasuryNode_Address_Is_Not_A_Contract()
```

### FoundationTreasuryNode_Caller_Not_Admin

```solidity
error FoundationTreasuryNode_Caller_Not_Admin()
```

### FoundationTreasuryNode_Caller_Not_Operator

```solidity
error FoundationTreasuryNode_Caller_Not_Operator()
```
