// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

error BytesLibrary_Expected_Address_Not_Found();
error BytesLibrary_Start_Location_Too_Large();

/**
 * @title A library for manipulation of byte arrays.
 * @author batu-inal & HardlyDifficult
 */
library BytesLibrary {
  /// @notice An address is 20 bytes long
  uint256 private constant ADDRESS_BYTES_LENGTH = 20;

  /// @notice A signature is 4 bytes long
  uint256 private constant SIGNATURE_BYTES_LENGTH = 4;

  /**
   * @dev Replace the address at the given location in a byte array if the contents at that location
   * match the expected address.
   */
  function replaceAtIf(
    bytes memory data,
    uint256 startLocation,
    address expectedAddress,
    address newAddress
  ) internal pure {
    unchecked {
      if (startLocation > type(uint256).max - ADDRESS_BYTES_LENGTH) {
        revert BytesLibrary_Start_Location_Too_Large();
      }
      bytes memory expectedData = abi.encodePacked(expectedAddress);
      bytes memory newData = abi.encodePacked(newAddress);
      uint256 dataLocation;
      for (uint256 i = 0; i < ADDRESS_BYTES_LENGTH; ++i) {
        dataLocation = startLocation + i;
        if (data[dataLocation] != expectedData[i]) {
          revert BytesLibrary_Expected_Address_Not_Found();
        }
        data[dataLocation] = newData[i];
      }
    }
  }

  /**
   * @dev Checks if the call data starts with the given function signature.
   */
  function startsWith(bytes memory callData, bytes4 functionSig) internal pure returns (bool) {
    // A signature is 4 bytes long
    if (callData.length < SIGNATURE_BYTES_LENGTH) {
      return false;
    }
    return bytes4(callData) == functionSig;
  }
}
