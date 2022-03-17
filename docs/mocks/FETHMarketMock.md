# FETHMarketMock









## Methods

### feth

```solidity
function feth() external view returns (contract IFethMarket)
```






#### Returns

| Name | Type | Description |
|---|---|---|
| _0 | contract IFethMarket | undefined |

### marketChangeLockup

```solidity
function marketChangeLockup(address unlockFrom, uint256 unlockExpiration, uint256 unlockAmount, address depositFor, uint256 depositAmount) external payable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| unlockFrom | address | undefined |
| unlockExpiration | uint256 | undefined |
| unlockAmount | uint256 | undefined |
| depositFor | address | undefined |
| depositAmount | uint256 | undefined |

### marketLockupFor

```solidity
function marketLockupFor(address account, uint256 amount) external payable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| amount | uint256 | undefined |

### marketUnlockFor

```solidity
function marketUnlockFor(address account, uint256 expiration, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| expiration | uint256 | undefined |
| amount | uint256 | undefined |

### marketWithdrawFrom

```solidity
function marketWithdrawFrom(address account, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| amount | uint256 | undefined |

### marketWithdrawLocked

```solidity
function marketWithdrawLocked(address account, uint256 expiration, uint256 amount) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| account | address | undefined |
| expiration | uint256 | undefined |
| amount | uint256 | undefined |

### setFeth

```solidity
function setFeth(address _feth) external nonpayable
```





#### Parameters

| Name | Type | Description |
|---|---|---|
| _feth | address | undefined |




