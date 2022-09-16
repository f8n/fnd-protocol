/*
  ･
   *　★
      ･ ｡
        　･　ﾟ☆ ｡
  　　　 *　★ ﾟ･｡ *  ｡
          　　* ☆ ｡･ﾟ*.｡
      　　　ﾟ *.｡☆｡★　･
​
                      `                     .-:::::-.`              `-::---...```
                     `-:`               .:+ssssoooo++//:.`       .-/+shhhhhhhhhhhhhyyyssooo:
                    .--::.            .+ossso+/////++/:://-`   .////+shhhhhhhhhhhhhhhhhhhhhy
                  `-----::.         `/+////+++///+++/:--:/+/-  -////+shhhhhhhhhhhhhhhhhhhhhy
                 `------:::-`      `//-.``.-/+ooosso+:-.-/oso- -////+shhhhhhhhhhhhhhhhhhhhhy
                .--------:::-`     :+:.`  .-/osyyyyyyso++syhyo.-////+shhhhhhhhhhhhhhhhhhhhhy
              `-----------:::-.    +o+:-.-:/oyhhhhhhdhhhhhdddy:-////+shhhhhhhhhhhhhhhhhhhhhy
             .------------::::--  `oys+/::/+shhhhhhhdddddddddy/-////+shhhhhhhhhhhhhhhhhhhhhy
            .--------------:::::-` +ys+////+yhhhhhhhddddddddhy:-////+yhhhhhhhhhhhhhhhhhhhhhy
          `----------------::::::-`.ss+/:::+oyhhhhhhhhhhhhhhho`-////+shhhhhhhhhhhhhhhhhhhhhy
         .------------------:::::::.-so//::/+osyyyhhhhhhhhhys` -////+shhhhhhhhhhhhhhhhhhhhhy
       `.-------------------::/:::::..+o+////+oosssyyyyyyys+`  .////+shhhhhhhhhhhhhhhhhhhhhy
       .--------------------::/:::.`   -+o++++++oooosssss/.     `-//+shhhhhhhhhhhhhhhhhhhhyo
     .-------   ``````.......--`        `-/+ooooosso+/-`          `./++++///:::--...``hhhhyo
                                              `````
   *　
      ･ ｡
　　　　･　　ﾟ☆ ｡
  　　　 *　★ ﾟ･｡ *  ｡
          　　* ☆ ｡･ﾟ*.｡
      　　　ﾟ *.｡☆｡★　･
    *　　ﾟ｡·*･｡ ﾟ*
  　　　☆ﾟ･｡°*. ﾟ
　 ･ ﾟ*｡･ﾟ★｡
　　･ *ﾟ｡　　 *
　･ﾟ*｡★･
 ☆∴｡　*
･ ｡
*/

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "./interfaces/internal/INFTDropCollectionInitializer.sol";
import "./interfaces/internal/INFTCollectionInitializer.sol";
import "./interfaces/internal/roles/IHasRolesContract.sol";
import "./interfaces/internal/roles/IRoles.sol";

import "./libraries/AddressLibrary.sol";
import "./mixins/shared/Gap10000.sol";

/**
 * @title A factory to create NFT collections.
 * @notice Call this factory to create NFT collections.
 * @dev This creates and initializes an ERC-1167 minimal proxy pointing to an NFT collection contract implementation.
 * @author batu-inal & HardlyDifficult
 */
contract NFTCollectionFactory is IHasRolesContract, Initializable, Gap10000 {
  using AddressUpgradeable for address;
  using Clones for address;
  using Strings for uint32;

  /****** Slot 0 (after inheritance) ******/
  /**
   * @notice The address of the implementation all new NFTCollections will leverage.
   * @dev When this is changed, `versionNFTCollection` is incremented.
   * @return The implementation address for NFTCollection.
   */
  address public implementationNFTCollection;

  /**
   * @notice The implementation version of new NFTCollections.
   * @dev This is auto-incremented each time `implementationNFTCollection` is changed.
   * @return The current NFTCollection implementation version.
   */
  uint32 public versionNFTCollection;

  /****** Slot 1 ******/
  /**
   * @notice The address of the implementation all new NFTDropCollections will leverage.
   * @dev When this is changed, `versionNFTDropCollection` is incremented.
   * @return The implementation address for NFTDropCollection.
   */
  address public implementationNFTDropCollection;

  /**
   * @notice The implementation version of new NFTDropCollections.
   * @dev This is auto-incremented each time `implementationNFTDropCollection` is changed.
   * @return The current NFTDropCollection implementation version.
   */
  uint32 public versionNFTDropCollection;

  /****** End of storage ******/

  /**
   * @notice The contract address which manages common roles.
   * @dev Defines a centralized admin role definition for permissioned functions below.
   * @return The contract address with role definitions.
   */
  IRoles public immutable rolesManager;

  /**
   * @notice Emitted when the implementation of NFTCollection used by new collections is updated.
   * @param implementation The new implementation contract address.
   * @param version The version of the new implementation, auto-incremented.
   */
  event ImplementationNFTCollectionUpdated(address indexed implementation, uint256 indexed version);

  /**
   * @notice Emitted when the implementation of NFTDropCollection used by new collections is updated.
   * @param implementationNFTDropCollection The new implementation contract address.
   * @param version The version of the new implementation, auto-incremented.
   */
  event ImplementationNFTDropCollectionUpdated(
    address indexed implementationNFTDropCollection,
    uint256 indexed version
  );

  /**
   * @notice Emitted when a new NFTCollection is created from this factory.
   * @param collection The address of the new NFT collection contract.
   * @param creator The address of the creator which owns the new collection.
   * @param version The implementation version used by the new collection.
   * @param name The name of the collection contract created.
   * @param symbol The symbol of the collection contract created.
   * @param nonce The nonce used by the creator when creating the collection,
   * used to define the address of the collection.
   */
  event NFTCollectionCreated(
    address indexed collection,
    address indexed creator,
    uint256 indexed version,
    string name,
    string symbol,
    uint256 nonce
  );

  /**
   * @notice Emitted when a new NFTDropCollection is created from this factory.
   * @param collection The address of the new NFT drop collection contract.
   * @param creator The address of the creator which owns the new collection.
   * @param approvedMinter An optional address to grant the MINTER_ROLE.
   * @param name The collection's `name`.
   * @param symbol The collection's `symbol`.
   * @param baseURI The base URI for the collection.
   * @param isRevealed Whether the collection is revealed or not.
   * @param maxTokenId The max `tokenID` for this collection.
   * @param paymentAddress The address that will receive royalties and mint payments.
   * @param version The implementation version used by the new NFTDropCollection collection.
   * @param nonce The nonce used by the creator to create this collection.
   */
  event NFTDropCollectionCreated(
    address indexed collection,
    address indexed creator,
    address indexed approvedMinter,
    string name,
    string symbol,
    string baseURI,
    bool isRevealed,
    uint256 maxTokenId,
    address paymentAddress,
    uint256 version,
    uint256 nonce
  );

  modifier onlyAdmin() {
    require(rolesManager.isAdmin(msg.sender), "NFTCollectionFactory: Caller does not have the Admin role");
    _;
  }

  modifier onlyContract(address _implementation) {
    require(_implementation.isContract(), "NFTCollectionFactory: Implementation is not a contract");
    _;
  }

  /**
   * @notice Defines requirements for the collection drop factory at deployment time.
   * @param _rolesManager The address of the contract defining roles for collections to use.
   */
  constructor(address _rolesManager) initializer {
    require(_rolesManager.isContract(), "NFTCollectionFactory: RolesContract is not a contract");

    rolesManager = IRoles(_rolesManager);
  }

  /**
   * @notice Initializer called after contract creation.
   * @dev This is used so that this factory will resume versions from where our original factory had left off.
   * @param _versionNFTCollection The current implementation version for NFTCollections.
   */
  function initialize(uint32 _versionNFTCollection) external initializer {
    versionNFTCollection = _versionNFTCollection;
  }

  /**
   * @notice Allows Foundation to change the NFTCollection implementation used for future collections.
   * This call will auto-increment the version.
   * Existing collections are not impacted.
   * @param _implementation The new NFTCollection collection implementation address.
   */
  function adminUpdateNFTCollectionImplementation(address _implementation)
    external
    onlyAdmin
    onlyContract(_implementation)
  {
    implementationNFTCollection = _implementation;
    // Version will not realistically overflow 32 bits.
    ++versionNFTCollection;

    // The implementation is initialized when assigned so that others may not claim it as their own.
    INFTCollectionInitializer(_implementation).initialize(
      payable(address(rolesManager)),
      string.concat("NFT Collection Implementation v", versionNFTCollection.toString()),
      string.concat("NFTv", versionNFTCollection.toString())
    );

    emit ImplementationNFTCollectionUpdated(_implementation, versionNFTCollection);
  }

  /**
   * @notice Allows Foundation to change the NFTDropCollection implementation used for future collections.
   * This call will auto-increment the version.
   * Existing collections are not impacted.
   * @param _implementation The new NFTDropCollection collection implementation address.
   */
  function adminUpdateNFTDropCollectionImplementation(address _implementation)
    external
    onlyAdmin
    onlyContract(_implementation)
  {
    implementationNFTDropCollection = _implementation;
    // Version will not realistically overflow 32 bits.
    ++versionNFTDropCollection;

    // The implementation is initialized when assigned so that others may not claim it as their own.
    INFTDropCollectionInitializer(_implementation).initialize(
      payable(address(this)),
      string.concat("NFT Drop Collection Implementation v", versionNFTDropCollection.toString()),
      string.concat("NFTDropV", versionNFTDropCollection.toString()),
      "ipfs://QmUtCsULTpfUYWBfcUS1y25rqBZ6E5CfKzZg6j9P3gFScK/",
      true,
      1,
      address(0),
      payable(0)
    );

    emit ImplementationNFTDropCollectionUpdated(_implementation, versionNFTDropCollection);
  }

  /**
   * @notice Create a new collection contract.
   * @dev The nonce must be unique for the msg.sender + implementation version, otherwise this call will revert.
   * @param name The collection's `name`.
   * @param symbol The collection's `symbol`.
   * @param nonce An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address.
   * @return collection The address of the newly created collection contract.
   */
  function createNFTCollection(
    string calldata name,
    string calldata symbol,
    uint96 nonce
  ) external returns (address collection) {
    require(bytes(symbol).length != 0, "NFTCollectionFactory: Symbol is required");

    // This reverts if the NFT was previously created using this implementation version + msg.sender + nonce
    collection = implementationNFTCollection.cloneDeterministic(_getSalt(msg.sender, nonce));

    INFTCollectionInitializer(collection).initialize(payable(msg.sender), name, symbol);

    emit NFTCollectionCreated(collection, msg.sender, versionNFTCollection, name, symbol, nonce);
  }

  /**
   * @notice Create a new drop collection contract.
   * @dev The nonce must be unique for the msg.sender + implementation version, otherwise this call will revert.
   * @param name The collection's `name`.
   * @param symbol The collection's `symbol`.
   * @param baseURI The base URI for the collection.
   * @param isRevealed Whether the collection is revealed or not.
   * @param maxTokenId The max token id for this collection.
   * @param approvedMinter An optional address to grant the MINTER_ROLE.
   * @param nonce An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address.
   * @return collection The address of the newly created collection contract.
   */
  function createNFTDropCollection(
    string calldata name,
    string calldata symbol,
    string calldata baseURI,
    bool isRevealed,
    uint32 maxTokenId,
    address approvedMinter,
    uint96 nonce
  ) external returns (address collection) {
    collection = _createNFTDropCollection(
      name,
      symbol,
      baseURI,
      isRevealed,
      maxTokenId,
      approvedMinter,
      payable(0),
      nonce
    );
  }

  /**
   * @notice Create a new drop collection contract with a custom payment address.
   * @dev All params other than `paymentAddress` are the same as in `createNFTDropCollection`.
   * The nonce must be unique for the msg.sender + implementation version, otherwise this call will revert.
   * @param name The collection's `name`.
   * @param symbol The collection's `symbol`.
   * @param baseURI The base URI for the collection.
   * @param isRevealed Whether the collection is revealed or not.
   * @param maxTokenId The max token id for this collection.
   * @param approvedMinter An optional address to grant the MINTER_ROLE.
   * @param nonce An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address.
   * @param paymentAddress The address that will receive royalties and mint payments.
   * @return collection The address of the newly created collection contract.
   */
  function createNFTDropCollectionWithPaymentAddress(
    string calldata name,
    string calldata symbol,
    string calldata baseURI,
    bool isRevealed,
    uint32 maxTokenId,
    address approvedMinter,
    uint96 nonce,
    address payable paymentAddress
  ) external returns (address collection) {
    collection = _createNFTDropCollection(
      name,
      symbol,
      baseURI,
      isRevealed,
      maxTokenId,
      approvedMinter,
      paymentAddress != msg.sender ? paymentAddress : payable(0),
      nonce
    );
  }

  /**
   * @notice Create a new drop collection contract with a custom payment address derived from the factory.
   * @dev All params other than `paymentAddressFactoryCall` are the same as in `createNFTDropCollection`.
   * The nonce must be unique for the msg.sender + implementation version, otherwise this call will revert.
   * @param name The collection's `name`.
   * @param symbol The collection's `symbol`.
   * @param baseURI The base URI for the collection.
   * @param isRevealed Whether the collection is revealed or not.
   * @param maxTokenId The max token id for this collection.
   * @param approvedMinter An optional address to grant the MINTER_ROLE.
   * @param nonce An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address.
   * @param paymentAddressFactoryCall The contract call which will return the address to use for payments.
   * @return collection The address of the newly created collection contract.
   */
  function createNFTDropCollectionWithPaymentFactory(
    string calldata name,
    string calldata symbol,
    string calldata baseURI,
    bool isRevealed,
    uint32 maxTokenId,
    address approvedMinter,
    uint96 nonce,
    CallWithoutValue calldata paymentAddressFactoryCall
  ) external returns (address collection) {
    collection = _createNFTDropCollection(
      name,
      symbol,
      baseURI,
      isRevealed,
      maxTokenId,
      approvedMinter,
      AddressLibrary.callAndReturnContractAddress(paymentAddressFactoryCall),
      nonce
    );
  }

  function _createNFTDropCollection(
    string calldata name,
    string calldata symbol,
    string calldata baseURI,
    bool isRevealed,
    uint32 maxTokenId,
    address approvedMinter,
    address payable paymentAddress,
    uint96 nonce
  ) private returns (address collection) {
    require(bytes(symbol).length > 0, "NFTCollectionFactory: Symbol is required");
    require(maxTokenId > 0, "NFTCollectionFactory: maxTokenId is required");

    // This reverts if the NFT was previously created using this implementation version + msg.sender + nonce
    collection = implementationNFTDropCollection.cloneDeterministic(_getSalt(msg.sender, nonce));

    INFTDropCollectionInitializer(collection).initialize(
      payable(msg.sender),
      name,
      symbol,
      baseURI,
      isRevealed,
      maxTokenId,
      approvedMinter,
      paymentAddress
    );

    emit NFTDropCollectionCreated(
      collection,
      msg.sender,
      approvedMinter,
      name,
      symbol,
      baseURI,
      isRevealed,
      maxTokenId,
      paymentAddress,
      versionNFTDropCollection,
      nonce
    );
  }

  /**
   * @notice Returns the address of a collection given the current implementation version, creator, and nonce.
   * This will return the same address whether the collection has already been created or not.
   * @param creator The creator of the collection.
   * @param nonce An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address.
   * @return collection The address of the collection contract that would be created by this nonce.
   */
  function predictNFTCollectionAddress(address creator, uint96 nonce) external view returns (address collection) {
    collection = implementationNFTCollection.predictDeterministicAddress(_getSalt(creator, nonce));
  }

  /**
   * @notice Returns the address of an NFTDropCollection collection given the current
   * implementation version, creator, and nonce.
   * This will return the same address whether the collection has already been created or not.
   * @param creator The creator of the collection.
   * @param nonce An arbitrary value used to allow a creator to mint multiple collections with a counterfactual address.
   * @return collection The address of the collection contract that would be created by this nonce.
   */
  function predictNFTDropCollectionAddress(address creator, uint96 nonce) external view returns (address collection) {
    collection = implementationNFTDropCollection.predictDeterministicAddress(_getSalt(creator, nonce));
  }

  /**
   * @dev Salt is address + nonce packed.
   */
  function _getSalt(address creator, uint96 nonce) private pure returns (bytes32) {
    return bytes32((uint256(uint160(creator)) << 96) | uint256(nonce));
  }
}
