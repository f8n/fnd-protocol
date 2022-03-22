// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

/**
 * @title A gap to represent the space previously consumed by the use of ERC165Upgradeable.
 */
abstract contract ERC165UpgradeableGap {
  /// @notice The size of the ERC165Upgradeable contract which is no longer used.
  uint256[50] private __gap;
}
