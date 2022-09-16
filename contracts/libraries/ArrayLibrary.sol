// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

/**
 * @title Helper functions for arrays.
 * @author batu-inal & HardlyDifficult
 */
library ArrayLibrary {
  /**
   * @notice Reduces the size of an array if it's greater than the specified max size,
   * using the first maxSize elements.
   */
  function capLength(address payable[] memory data, uint256 maxLength) internal pure {
    if (data.length > maxLength) {
      assembly {
        mstore(data, maxLength)
      }
    }
  }

  /**
   * @notice Reduces the size of an array if it's greater than the specified max size,
   * using the first maxSize elements.
   */
  function capLength(uint256[] memory data, uint256 maxLength) internal pure {
    if (data.length > maxLength) {
      assembly {
        mstore(data, maxLength)
      }
    }
  }
}
