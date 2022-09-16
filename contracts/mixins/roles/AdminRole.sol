// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";

/**
 * @title Defines a role for admin accounts.
 * @dev Wraps the default admin role from OpenZeppelin's AccessControl for easy integration.
 * @author batu-inal & HardlyDifficult
 */
abstract contract AdminRole is Initializable, AccessControlUpgradeable {
  modifier onlyAdmin() {
    require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "AdminRole: caller does not have the Admin role");
    _;
  }

  function _initializeAdminRole(address admin) internal onlyInitializing {
    // Grant the role to a specified account
    _grantRole(DEFAULT_ADMIN_ROLE, admin);
  }

  /**
   * @notice Adds an account as an approved admin.
   * @dev Only callable by existing admins, as enforced by `grantRole`.
   * @param account The address to be approved.
   */
  function grantAdmin(address account) external {
    grantRole(DEFAULT_ADMIN_ROLE, account);
  }

  /**
   * @notice Removes an account from the set of approved admins.
   * @dev Only callable by existing admins, as enforced by `revokeRole`.
   * @param account The address to be removed.
   */
  function revokeAdmin(address account) external {
    revokeRole(DEFAULT_ADMIN_ROLE, account);
  }

  /**
   * @notice Checks if the account provided is an admin.
   * @param account The address to check.
   * @return approved True if the account is an admin.
   * @dev This call is used by the royalty registry contract.
   */
  function isAdmin(address account) public view returns (bool approved) {
    approved = hasRole(DEFAULT_ADMIN_ROLE, account);
  }

  /**
   * @notice This empty reserved space is put in place to allow future versions to add new
   * variables without shifting down storage in the inheritance chain.
   * See https://docs.openzeppelin.com/contracts/4.x/upgradeable#storage_gaps
   */
  uint256[1_000] private __gap;
}
