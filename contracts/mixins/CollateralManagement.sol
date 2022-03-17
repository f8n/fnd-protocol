// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";

import "../mixins/roles/AdminRole.sol";

error CollateralManagement_Cannot_Withdraw_To_Address_Zero();
error CollateralManagement_Cannot_Withdraw_To_Self();

/**
 * @title Enables deposits and withdrawals.
 */
abstract contract CollateralManagement is AdminRole {
  using AddressUpgradeable for address payable;

  /**
   * @notice Emitted when funds are withdrawn from this contract.
   * @param to The address which received the ETH withdrawn.
   * @param amount The amount of ETH which was withdrawn.
   */
  event FundsWithdrawn(address indexed to, uint256 amount);

  /**
   * @notice Accept native currency payments (i.e. fees)
   */
  // solhint-disable-next-line no-empty-blocks
  receive() external payable {}

  /**
   * @notice Allows an admin to withdraw funds.
   * @param to        Address to receive the withdrawn funds
   * @param amount    Amount to withdrawal or 0 to withdraw all available funds
   */
  function withdrawFunds(address payable to, uint256 amount) external onlyAdmin {
    if (amount == 0) {
      amount = address(this).balance;
    }
    if (to == address(0)) {
      revert CollateralManagement_Cannot_Withdraw_To_Address_Zero();
    } else if (to == address(this)) {
      revert CollateralManagement_Cannot_Withdraw_To_Self();
    }
    to.sendValue(amount);

    emit FundsWithdrawn(to, amount);
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[1000] private __gap;
}
