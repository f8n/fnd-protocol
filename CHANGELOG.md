# Changelog

## 2.3.0

- Add Drops
- [Remove admin cancel](https://github.com/f8n/fnd-contracts/pull/1973) functions from the market
- Remove `makeOffer` (was deprecated in favor of `makeOfferV2`).
- Introduce the `NFTDropMarket`.
- Add `getSellerOf` to the markets and `getSellerOrOwnerOf` to the middleware.
- Upgrade to [solc 0.8.16](https://github.com/ethereum/solidity/releases/tag/v0.8.16)
- SplitsV3: Gas-optimization to reduce costs of creating splits

## 2.2.5

- Upgrade to [solc 0.8.15](https://github.com/ethereum/solidity/releases/tag/v0.8.15)

## 2.2.4

- Middleware [fix div by 0](https://github.com/f8n/fnd-contracts/pull/1888) when 0 royalties are requested

## 2.2.3

- [Remove Private Sales](https://github.com/f8n/fnd-contracts/pull/1864)
- [Try/catch `tokenCreator`](https://github.com/f8n/fnd-contracts/pull/1867) so that other royalty APIs are checked for contracts with a fallback function.
- [Ignore `owner` when address(0)](https://github.com/f8n/fnd-contracts/pull/1868)

## 2.2.2

- Middleware: [Fix `probeNFT`](https://github.com/f8n/fnd-contracts/pull/1865) for fallback function in the royalty recipient.
- Upgrade to [solc 0.8.14](https://github.com/ethereum/solidity/releases/tag/v0.8.14)

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
