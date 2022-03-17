/*
  ･
   *　★
      ･ ｡
        　･　ﾟ☆ ｡
  　　　 *　★ ﾟ･｡ *  ｡
          　　* ☆ ｡･ﾟ*.｡
      　　　ﾟ *.｡☆｡★　･
​
                      `                     .-:::::-.`              `-::---...```
                     `-:`               .:+ssssoooo++//:.`       .-/+shhhhhhhhhhhhhyyyssooo:
                    .--::.            .+ossso+/////++/:://-`   .////+shhhhhhhhhhhhhhhhhhhhhy
                  `-----::.         `/+////+++///+++/:--:/+/-  -////+shhhhhhhhhhhhhhhhhhhhhy
                 `------:::-`      `//-.``.-/+ooosso+:-.-/oso- -////+shhhhhhhhhhhhhhhhhhhhhy
                .--------:::-`     :+:.`  .-/osyyyyyyso++syhyo.-////+shhhhhhhhhhhhhhhhhhhhhy
              `-----------:::-.    +o+:-.-:/oyhhhhhhdhhhhhdddy:-////+shhhhhhhhhhhhhhhhhhhhhy
             .------------::::--  `oys+/::/+shhhhhhhdddddddddy/-////+shhhhhhhhhhhhhhhhhhhhhy
            .--------------:::::-` +ys+////+yhhhhhhhddddddddhy:-////+yhhhhhhhhhhhhhhhhhhhhhy
          `----------------::::::-`.ss+/:::+oyhhhhhhhhhhhhhhho`-////+shhhhhhhhhhhhhhhhhhhhhy
         .------------------:::::::.-so//::/+osyyyhhhhhhhhhys` -////+shhhhhhhhhhhhhhhhhhhhhy
       `.-------------------::/:::::..+o+////+oosssyyyyyyys+`  .////+shhhhhhhhhhhhhhhhhhhhhy
       .--------------------::/:::.`   -+o++++++oooosssss/.     `-//+shhhhhhhhhhhhhhhhhhhhyo
     .-------   ``````.......--`        `-/+ooooosso+/-`          `./++++///:::--...``hhhhyo
                                              `````
   *　
      ･ ｡
　　　　･　　ﾟ☆ ｡
  　　　 *　★ ﾟ･｡ *  ｡
          　　* ☆ ｡･ﾟ*.｡
      　　　ﾟ *.｡☆｡★　･
    *　　ﾟ｡·*･｡ ﾟ*
  　　　☆ﾟ･｡°*. ﾟ
　 ･ ﾟ*｡･ﾟ★｡
　　･ *ﾟ｡　　 *
　･ﾟ*｡★･
 ☆∴｡　*
･ ｡
*/

// SPDX-License-Identifier: MIT OR Apache-2.0

pragma solidity ^0.8.0;

import "./interfaces/IERC20Approve.sol";
import "./interfaces/IERC20IncreaseAllowance.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/utils/AddressUpgradeable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/proxy/Clones.sol";
import "./libraries/BytesLibrary.sol";

/**
 * @title Auto-forward ETH to a pre-determined list of addresses.
 * @notice Deploys contracts which auto-forwards any ETH sent to it to a list of recipients
 * considering their percent share of the payment received.
 * ERC-20 tokens are also supported and may be split on demand by calling `splitERC20Tokens`.
 * If another asset type is sent to this contract address such as an NFT, arbitrary calls may be made by one
 * of the split recipients in order to recover them.
 * @dev Uses create2 counterfactual addresses so that the destination is known from the terms of the split.
 */
contract PercentSplitETH is Initializable {
  using AddressUpgradeable for address payable;
  using AddressUpgradeable for address;
  using BytesLibrary for bytes;
  using SafeMath for uint256;

  /// @notice A representation of shares using 16-bits for efficient storage.
  /// @dev This is only used internally.
  struct ShareCompressed {
    address payable recipient;
    uint16 percentInBasisPoints;
  }

  /// @notice A representation of shares using 256-bits to ease integration.
  struct Share {
    address payable recipient;
    uint256 percentInBasisPoints;
  }

  ShareCompressed[] private _shares;

  uint256 private constant BASIS_POINTS = 10000;

  /**
   * @notice Emitted when an ERC20 token is transferred to a recipient through this split contract.
   * @param erc20Contract The address of the ERC20 token contract.
   * @param account The account which received payment.
   * @param amount The amount of ERC20 tokens sent to this recipient.
   */
  event ERC20Transferred(address indexed erc20Contract, address indexed account, uint256 amount);
  /**
   * @notice Emitted when ETH is transferred to a recipient through this split contract.
   * @param account The account which received payment.
   * @param amount The amount of ETH payment sent to this recipient.
   */
  event ETHTransferred(address indexed account, uint256 amount);
  /**
   * @notice Emitted when a new percent split contract is created from this factory.
   * @param contractAddress The address of the new percent split contract.
   */
  event PercentSplitCreated(address indexed contractAddress);
  /**
   * @notice Emitted for each share of the split being defined.
   * @param recipient The address of the recipient when payment to the split is received.
   * @param percentInBasisPoints The percent of the payment received by the recipient, in basis points.
   */
  event PercentSplitShare(address indexed recipient, uint256 percentInBasisPoints);

  /**
   * @dev Requires that the msg.sender is one of the recipients in this split.
   */
  modifier onlyRecipient() {
    for (uint256 i = 0; i < _shares.length; ++i) {
      if (_shares[i].recipient == msg.sender) {
        _;
        return;
      }
    }
    revert("Split: Can only be called by one of the recipients");
  }

  /**
   * @notice Called once to configure the contract after the initial deployment.
   * @dev This will be called by `createSplit` after deploying the proxy so it should never be called directly.
   * @param shares The list of recipients and their share of the payment for the template to use.
   */
  function initialize(Share[] memory shares) external initializer {
    require(shares.length >= 2, "Split: Too few recipients");
    require(shares.length <= 5, "Split: Too many recipients");
    uint256 total;
    unchecked {
      // The array length cannot overflow 256 bits.
      for (uint256 i = 0; i < shares.length; ++i) {
        require(shares[i].percentInBasisPoints < BASIS_POINTS, "Split: Share must be less than 100%");
        // Require above ensures total will not overflow.
        total += shares[i].percentInBasisPoints;
        _shares.push(
          ShareCompressed({
            recipient: shares[i].recipient,
            percentInBasisPoints: uint16(shares[i].percentInBasisPoints)
          })
        );
        emit PercentSplitShare(shares[i].recipient, shares[i].percentInBasisPoints);
      }
    }
    require(total == BASIS_POINTS, "Split: Total amount must equal 100%");
  }

  /**
   * @notice Forwards any ETH received to the recipients in this split.
   * @dev Each recipient increases the gas required to split
   * and contract recipients may significantly increase the gas required.
   */
  receive() external payable {
    _splitETH(msg.value);
  }

  /**
   * @notice Creates a new minimal proxy contract and initializes it with the given split terms.
   * If the contract had already been created, its address is returned.
   * This must be called on the original implementation and not a proxy created previously.
   * @param shares The list of recipients and their share of the payment for this split.
   * @return splitInstance The contract address for the split contract created.
   */
  function createSplit(Share[] memory shares) external returns (PercentSplitETH splitInstance) {
    bytes32 salt = keccak256(abi.encode(shares));
    address clone = Clones.predictDeterministicAddress(address(this), salt);
    splitInstance = PercentSplitETH(payable(clone));
    if (!clone.isContract()) {
      emit PercentSplitCreated(clone);
      Clones.cloneDeterministic(address(this), salt);
      splitInstance.initialize(shares);
    }
  }

  /**
   * @notice Allows the split recipients to make an arbitrary contract call.
   * @dev This is provided to allow recovering from unexpected scenarios,
   * such as receiving an NFT at this address.
   *
   * It will first attempt a fair split of ERC20 tokens before proceeding.
   *
   * This contract is built to split ETH payments. The ability to attempt to make other calls is here
   * just in case other assets were also sent so that they don't get locked forever in the contract.
   * @param target The address of the contract to call.
   * @param callData The data to send to the `target` contract.
   */
  function proxyCall(address payable target, bytes memory callData) external onlyRecipient {
    require(
      !callData.startsWith(type(IERC20Approve).interfaceId) &&
        !callData.startsWith(type(IERC20IncreaseAllowance).interfaceId),
      "Split: ERC20 tokens must be split"
    );
    _splitERC20Tokens(IERC20(target));
    target.functionCall(callData);
  }

  /**
   * @notice Allows any ETH stored by the contract to be split among recipients.
   * @dev Normally ETH is forwarded as it comes in, but a balance in this contract
   * is possible if it was sent before the contract was created or if self destruct was used.
   */
  function splitETH() external {
    _splitETH(address(this).balance);
  }

  /**
   * @notice Anyone can call this function to split all available tokens at the provided address between the recipients.
   * @dev This contract is built to split ETH payments. The ability to attempt to split ERC20 tokens is here
   * just in case tokens were also sent so that they don't get locked forever in the contract.
   * @param erc20Contract The address of the ERC20 token contract to split tokens for.
   */
  function splitERC20Tokens(IERC20 erc20Contract) external {
    require(_splitERC20Tokens(erc20Contract), "Split: ERC20 split failed");
  }

  function _splitERC20Tokens(IERC20 erc20Contract) private returns (bool) {
    try erc20Contract.balanceOf(address(this)) returns (uint256 balance) {
      if (balance == 0) {
        return false;
      }
      uint256 amountToSend;
      uint256 totalSent;
      unchecked {
        for (uint256 i = _shares.length - 1; i != 0; i--) {
          ShareCompressed memory share = _shares[i];
          bool success;
          (success, amountToSend) = balance.tryMul(share.percentInBasisPoints);
          if (!success) {
            return false;
          }
          amountToSend /= BASIS_POINTS;
          totalSent += amountToSend;
          try erc20Contract.transfer(share.recipient, amountToSend) {
            emit ERC20Transferred(address(erc20Contract), share.recipient, amountToSend);
          } catch {
            return false;
          }
        }
        // Favor the 1st recipient if there are any rounding issues
        amountToSend = balance - totalSent;
      }
      try erc20Contract.transfer(_shares[0].recipient, amountToSend) {
        emit ERC20Transferred(address(erc20Contract), _shares[0].recipient, amountToSend);
      } catch {
        return false;
      }
      return true;
    } catch {
      return false;
    }
  }

  function _splitETH(uint256 value) private {
    if (value != 0) {
      uint256 totalSent;
      uint256 amountToSend;
      unchecked {
        for (uint256 i = _shares.length - 1; i != 0; i--) {
          ShareCompressed memory share = _shares[i];
          amountToSend = (value * share.percentInBasisPoints) / BASIS_POINTS;
          totalSent += amountToSend;
          share.recipient.sendValue(amountToSend);
          emit ETHTransferred(share.recipient, amountToSend);
        }
        // Favor the 1st recipient if there are any rounding issues
        amountToSend = value - totalSent;
      }
      _shares[0].recipient.sendValue(amountToSend);
      emit ETHTransferred(_shares[0].recipient, amountToSend);
    }
  }

  /**
   * @notice Returns a recipient's percent share in basis points.
   * @param index The index of the recipient to get the share of.
   * @return percentInBasisPoints The percent of the payment received by the recipient, in basis points.
   */
  function getPercentInBasisPointsByIndex(uint256 index) external view returns (uint256 percentInBasisPoints) {
    percentInBasisPoints = _shares[index].percentInBasisPoints;
  }

  /**
   * @notice Returns the address for the proxy contract which would represent the given split terms.
   * @dev The contract may or may not already be deployed at the address returned.
   * Ensure that it is deployed before sending funds to this address.
   * @param shares The list of recipients and their share of the payment for this split.
   * @return splitInstance The contract address for the split contract created.
   */
  function getPredictedSplitAddress(Share[] memory shares) external view returns (address splitInstance) {
    bytes32 salt = keccak256(abi.encode(shares));
    splitInstance = Clones.predictDeterministicAddress(address(this), salt);
  }

  /**
   * @notice Returns how many recipients are part of this split.
   * @return length The number of recipients in this split.
   */
  function getShareLength() external view returns (uint256 length) {
    length = _shares.length;
  }

  /**
   * @notice Returns a recipient in this split.
   * @param index The index of the recipient to get.
   * @return recipient The recipient at the given index.
   */
  function getShareRecipientByIndex(uint256 index) external view returns (address payable recipient) {
    recipient = _shares[index].recipient;
  }

  /**
   * @notice Returns a tuple with the terms of this split.
   * @return shares The list of recipients and their share of the payment for this split.
   */
  function getShares() external view returns (Share[] memory shares) {
    shares = new Share[](_shares.length);
    for (uint256 i = 0; i < shares.length; ++i) {
      shares[i] = Share({ recipient: _shares[i].recipient, percentInBasisPoints: _shares[i].percentInBasisPoints });
    }
  }
}
