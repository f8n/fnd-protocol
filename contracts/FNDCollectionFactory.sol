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

pragma solidity ^0.8.0;

import "./interfaces/ICollectionContractInitializer.sol";
import "./interfaces/ICollectionFactory.sol";
import "./interfaces/IProxyCall.sol";
import "./interfaces/IRoles.sol";

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title A factory to create NFT collections.
 * @notice Call this factory to create an NFT collection contract managed by a single creator.
 * @dev This creates and initializes an ERC-1165 minimal proxy pointing to the NFT collection contract template.
 */
contract FNDCollectionFactory is ICollectionFactory {
  using AddressUpgradeable for address;
  using AddressUpgradeable for address payable;
  using Clones for address;
  using Strings for uint256;

  /**
   * @notice The contract address which manages common roles.
   * @dev Used by the collections for a shared operator definition.
   */
  IRoles public rolesContract;

  /**
   * @notice The address of the template all new collections will leverage.
   */
  address public implementation;

  /**
   * @notice The address of the proxy call contract implementation.
   * @dev Used by the collections to safely call another contract with arbitrary call data.
   */
  IProxyCall public proxyCallContract;

  /**
   * @notice The implementation version new collections will use.
   * @dev This is auto-incremented each time the implementation is changed.
   */
  uint256 public version;

  /**
   * @notice Emitted when a new collection is created from this factory.
   * @param collectionContract The address of the new NFT collection contract.
   * @param creator The address of the creator which owns the new collection.
   * @param version The implementation version used by the new collection.
   * @param name The name of the collection contract created.
   * @param symbol The symbol of the collection contract created.
   * @param nonce The nonce used by the creator when creating the collection,
   * used to define the address of the collection.
   */
  event CollectionCreated(
    address indexed collectionContract,
    address indexed creator,
    uint256 indexed version,
    string name,
    string symbol,
    uint256 nonce
  );
  /**
   * @notice Emitted when the implementation contract used by new collections is updated.
   * @param implementation The new implementation contract address.
   * @param version The version of the new implementation, auto-incremented.
   */
  event ImplementationUpdated(address indexed implementation, uint256 indexed version);
  /**
   * @notice Emitted when the proxy call contract used by collections is updated.
   * @param proxyCallContract The new proxy call contract address.
   */
  event ProxyCallContractUpdated(address indexed proxyCallContract);
  /**
   * @notice Emitted when the contract defining roles is updated.
   * @param rolesContract The new roles contract address.
   */
  event RolesContractUpdated(address indexed rolesContract);

  modifier onlyAdmin() {
    require(rolesContract.isAdmin(msg.sender), "FNDCollectionFactory: Caller does not have the Admin role");
    _;
  }

  /**
   * @notice Defines requirements for the collection factory at deployment time.
   * @param _proxyCallContract The address of the proxy call contract implementation.
   * @param _rolesContract The address of the contract defining roles for collections to use.
   */
  constructor(address _proxyCallContract, address _rolesContract) {
    _updateRolesContract(_rolesContract);
    _updateProxyCallContract(_proxyCallContract);
  }

  /**
   * @notice Allows Foundation to change the collection implementation used for future collections.
   * This call will auto-increment the version.
   * Existing collections are not impacted.
   * @param _implementation The new collection implementation address.
   */
  function adminUpdateImplementation(address _implementation) external onlyAdmin {
    _updateImplementation(_implementation);
  }

  /**
   * @notice Allows Foundation to change the proxy call contract address.
   * @param _proxyCallContract The new proxy call contract address.
   */
  function adminUpdateProxyCallContract(address _proxyCallContract) external onlyAdmin {
    _updateProxyCallContract(_proxyCallContract);
  }

  /**
   * @notice Allows Foundation to change the admin role contract address.
   * @param _rolesContract The new admin role contract address.
   */
  function adminUpdateRolesContract(address _rolesContract) external onlyAdmin {
    _updateRolesContract(_rolesContract);
  }

  /**
   * @notice Create a new collection contract.
   * @dev The nonce is required and must be unique for the msg.sender + implementation version,
   * otherwise this call will revert.
   * @param name The name for the new collection being created.
   * @param symbol The symbol for the new collection being created.
   * @param nonce An arbitrary value used to allow a creator to mint multiple collections.
   * @return collectionAddress The address of the new collection contract.
   */
  function createCollection(
    string calldata name,
    string calldata symbol,
    uint256 nonce
  ) external returns (address collectionAddress) {
    require(bytes(symbol).length != 0, "FNDCollectionFactory: Symbol is required");

    // This reverts if the NFT was previously created using this implementation version + msg.sender + nonce
    collectionAddress = implementation.cloneDeterministic(_getSalt(msg.sender, nonce));

    ICollectionContractInitializer(collectionAddress).initialize(payable(msg.sender), name, symbol);

    emit CollectionCreated(collectionAddress, msg.sender, version, name, symbol, nonce);
  }

  function _updateRolesContract(address _rolesContract) private {
    require(_rolesContract.isContract(), "FNDCollectionFactory: RolesContract is not a contract");
    rolesContract = IRoles(_rolesContract);

    emit RolesContractUpdated(_rolesContract);
  }

  /**
   * @dev Updates the implementation address, increments the version, and initializes the template.
   * Since the template is initialized when set, implementations cannot be re-used.
   * To downgrade the implementation, deploy the same bytecode again and then update to that.
   */
  function _updateImplementation(address _implementation) private {
    require(_implementation.isContract(), "FNDCollectionFactory: Implementation is not a contract");
    implementation = _implementation;
    unchecked {
      // Version cannot overflow 256 bits.
      version++;
    }

    // The implementation is initialized when assigned so that others may not claim it as their own.
    ICollectionContractInitializer(_implementation).initialize(
      payable(address(rolesContract)),
      string(abi.encodePacked("Foundation Collection Template v", version.toString())),
      string(abi.encodePacked("FCTv", version.toString()))
    );

    emit ImplementationUpdated(_implementation, version);
  }

  function _updateProxyCallContract(address _proxyCallContract) private {
    require(_proxyCallContract.isContract(), "FNDCollectionFactory: Proxy call address is not a contract");
    proxyCallContract = IProxyCall(_proxyCallContract);

    emit ProxyCallContractUpdated(_proxyCallContract);
  }

  /**
   * @notice Returns the address of a collection given the current implementation version, creator, and nonce.
   * This will return the same address whether the collection has already been created or not.
   * @param creator The creator of the collection.
   * @param nonce An arbitrary value used to allow a creator to mint multiple collections.
   * @return collectionAddress The address of the collection contract that would be created by this nonce.
   */
  function predictCollectionAddress(address creator, uint256 nonce) external view returns (address collectionAddress) {
    collectionAddress = implementation.predictDeterministicAddress(_getSalt(creator, nonce));
  }

  function _getSalt(address creator, uint256 nonce) private pure returns (bytes32) {
    return keccak256(abi.encodePacked(creator, nonce));
  }
}
