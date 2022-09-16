// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../../interfaces/internal/IFethMarket.sol";

error FETHNode_FETH_Address_Is_Not_A_Contract();
error FETHNode_Only_FETH_Can_Transfer_ETH();

/**
 * @title A mixin for interacting with the FETH contract.
 * @author batu-inal & HardlyDifficult
 */
abstract contract FETHNode {
  using AddressUpgradeable for address;
  using AddressUpgradeable for address payable;

  /// @notice The FETH ERC-20 token for managing escrow and lockup.
  IFethMarket internal immutable feth;

  constructor(address _feth) {
    if (!_feth.isContract()) {
      revert FETHNode_FETH_Address_Is_Not_A_Contract();
    }

    feth = IFethMarket(_feth);
  }

  /**
   * @notice Only used by FETH. Any direct transfer from users will revert.
   */
  receive() external payable {
    if (msg.sender != address(feth)) {
      revert FETHNode_Only_FETH_Can_Transfer_ETH();
    }
  }

  /**
   * @notice Withdraw the msg.sender's available FETH balance if they requested more than the msg.value provided.
   * @dev This may revert if the msg.sender is non-receivable.
   * This helper should not be used anywhere that may lead to locked assets.
   * @param totalAmount The total amount of ETH required (including the msg.value).
   * @param shouldRefundSurplus If true, refund msg.value - totalAmount to the msg.sender.
   */
  function _tryUseFETHBalance(uint256 totalAmount, bool shouldRefundSurplus) internal {
    if (totalAmount > msg.value) {
      // Withdraw additional ETH required from the user's available FETH balance.
      unchecked {
        // The if above ensures delta will not underflow.
        // Withdraw ETH from the user's account in the FETH token contract,
        // making the funds available in this contract as ETH.
        feth.marketWithdrawFrom(msg.sender, totalAmount - msg.value);
      }
    } else if (shouldRefundSurplus && totalAmount < msg.value) {
      // Return any surplus ETH to the user.
      unchecked {
        // The if above ensures this will not underflow
        payable(msg.sender).sendValue(msg.value - totalAmount);
      }
    }
  }

  /**
   * @notice Gets the FETH contract used to escrow offer funds.
   * @return fethAddress The FETH contract address.
   */
  function getFethAddress() external view returns (address fethAddress) {
    fethAddress = address(feth);
  }
}
