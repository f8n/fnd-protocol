// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

import "./AdminRole.sol";

/**
 * @title Defines a role for minter accounts.
 * @dev Wraps a role from OpenZeppelin's AccessControl for easy integration.
 * @author batu-inal & HardlyDifficult
 */
abstract contract MinterRole is Initializable, AccessControlUpgradeable, AdminRole {
  /**
   * @notice The `role` type used for approve minters.
   * @return `keccak256("MINTER_ROLE")`
   */
  bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

  modifier onlyMinterOrAdmin() {
    require(isMinter(msg.sender) || isAdmin(msg.sender), "MinterRole: Must have the minter or admin role");
    _;
  }

  function _initializeMinterRole(address minter) internal onlyInitializing {
    // Grant the role to a specified account
    _grantRole(MINTER_ROLE, minter);
  }

  /**
   * @notice Adds an account as an approved minter.
   * @dev Only callable by admins, as enforced by `grantRole`.
   * @param account The address to be approved.
   */
  function grantMinter(address account) external {
    grantRole(MINTER_ROLE, account);
  }

  /**
   * @notice Removes an account from the set of approved minters.
   * @dev Only callable by admins, as enforced by `revokeRole`.
   * @param account The address to be removed.
   */
  function revokeMinter(address account) external {
    revokeRole(MINTER_ROLE, account);
  }

  /**
   * @notice Checks if the account provided is an minter.
   * @param account The address to check.
   * @return approved True if the account is an minter.
   */
  function isMinter(address account) public view returns (bool approved) {
    approved = hasRole(MINTER_ROLE, account);
  }
}
