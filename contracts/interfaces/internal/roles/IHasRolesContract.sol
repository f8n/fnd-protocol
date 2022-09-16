// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.12;

import "./IRoles.sol";

/**
 * @author batu-inal & HardlyDifficult
 */
interface IHasRolesContract {
  function rolesManager() external returns (IRoles);
}
