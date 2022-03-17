// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "../interfaces/IProxyCall.sol";

/**
 * @title Forwards arbitrary calls to an external contract to be processed.
 * @dev This is used so that the from address of the calling contract does not have
 * any special permissions (e.g. ERC-20 transfer).
 */
abstract contract NFT721ProxyCall {
  using AddressUpgradeable for address payable;
  using AddressUpgradeable for address;

  /// @notice The address for a contract which forwards arbitrary proxy calls.
  /// @dev This is used to improve security, so that the msg.sender is not the NFT's address.
  IProxyCall private proxyCall;

  /**
   * @notice Emitted when the proxy call contract is updated.
   * @param proxyCallContract The new proxy call contract address.
   */
  event ProxyCallContractUpdated(address indexed proxyCallContract);

  /**
   * @dev Used by other mixins to make external calls through the proxy contract.
   * This will fail if the proxyCall address is address(0).
   */
  function _proxyCallAndReturnContractAddress(address externalContract, bytes memory callData)
    internal
    returns (address payable result)
  {
    result = proxyCall.proxyCallAndReturnAddress(externalContract, callData);
    require(result.isContract(), "NFT721ProxyCall: address returned is not a contract");
  }

  /**
   * @dev Called by the adminUpdateConfig function to set the address of the proxy call contract.
   */
  function _updateProxyCall(address proxyCallContract) internal {
    require(proxyCallContract.isContract(), "NFT721ProxyCall: Proxy call address is not a contract");
    proxyCall = IProxyCall(proxyCallContract);

    emit ProxyCallContractUpdated(proxyCallContract);
  }

  /**
   * @notice Returns the address of the current proxy call contract.
   * @return contractAddress The address of the current proxy call contract.
   */
  function proxyCallAddress() external view returns (address contractAddress) {
    contractAddress = address(proxyCall);
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[99] private __gap;
}
