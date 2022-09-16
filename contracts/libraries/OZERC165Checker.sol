// SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

/**
 * From https://github.com/OpenZeppelin/openzeppelin-contracts
 * Copying the method below which is currently unreleased.
 */

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";

/**
 * @title Library to query ERC165 support.
 * @dev Library used to query support of an interface declared via {IERC165}.
 *
 * Note that these functions return the actual result of the query: they do not
 * `revert` if an interface is not supported. It is up to the caller to decide
 * what to do in these cases.
 */
library OZERC165Checker {
  /**
   * @notice Query if a contract implements an interface, does not check ERC165 support
   * @param account The address of the contract to query for support of an interface
   * @param interfaceId The interface identifier, as specified in ERC-165
   * @return true if the contract at account indicates support of the interface with
   * identifier interfaceId, false otherwise
   * @dev Assumes that account contains a contract that supports ERC165, otherwise
   * the behavior of this method is undefined. This precondition can be checked
   * with {supportsERC165}.
   * Interface identification is specified in ERC-165.
   */
  function supportsERC165InterfaceUnchecked(address account, bytes4 interfaceId) internal view returns (bool) {
    bytes memory encodedParams = abi.encodeWithSelector(IERC165.supportsInterface.selector, interfaceId);
    (bool success, bytes memory result) = account.staticcall{ gas: 30_000 }(encodedParams);
    if (result.length < 32) return false;
    return success && abi.decode(result, (uint256)) > 0;
  }
}
