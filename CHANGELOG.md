# Changelog

## Unreleased

- TBD

## 2.2.1

### Market

- [Try try catch](https://github.com/f8n/fnd-contracts/pull/1838) so that contracts with a fallback function or unsupported return types do not cause the NFT to get stuck in escrow.

## 2.2.0

### Market

- [Bid Referrals](https://github.com/f8n/fnd-contracts/pull/1782): adds `placeBidV2` with referral incentives.
- [Offer Referrals](https://github.com/f8n/fnd-contracts/pull/1790): adds `makeOfferV2` with referral incentives.
- Auction gas savings: don't store duration/extension. https://github.com/f8n/fnd-contracts/pull/1793

## 2.1.1

### Middleware

- Catch reverts in `getFees` and return `keccak256("Failed to getFees")`.

## 2.1.0

### General

- Upgrade to [solc 0.8.13](https://github.com/ethereum/solidity/releases/tag/v0.8.13)

### Market

- [Buy referrals](https://github.com/f8n/fnd-contracts/pull/1726): adds `buyV2` with referral incentives.
- Royalties: ignore `royaltyInfo` from the NFT contract when the amount is 0 (does not impact the royalty override)
- On placeBidOf, leverage FETH from an outstanding offer.
- Remove withdraw from escrow (leaning on fallback to FETH instead).
- Revert when setting the same buy or reserve price.
- Don't check royalty APIs for non-address(0) recipient (still checks length > 0).
- Use OZ ECDSA for private sale signature verification.
- Gas optimizations & style improvements.

### Middleware

- Switch `probeNFT` to return bytes32 instead of throwing errors.

## 2.0.3

### Middleware

- `probeNFT` https://github.com/f8n/fnd-contracts/pull/1645

## 2.0.1

### Percent Split Factory

- Block proxy to `increaseAllowance`
- Optimize storage to save gas
