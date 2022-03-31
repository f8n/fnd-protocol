export type Maybe<T> = T | null;
export type InputMaybe<T> = Maybe<T>;
export type Exact<T extends { [key: string]: unknown }> = { [K in keyof T]: T[K] };
export type MakeOptional<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]?: Maybe<T[SubKey]> };
export type MakeMaybe<T, K extends keyof T> = Omit<T, K> & { [SubKey in K]: Maybe<T[SubKey]> };
/** All built-in and custom scalars, mapped to their actual values */
export type Scalars = {
  ID: string;
  String: string;
  Boolean: boolean;
  Int: number;
  Float: number;
  BigDecimal: any;
  BigInt: any;
  Bytes: any;
};

export type Account = {
  __typename?: 'Account';
  /** Link to creator details if this account is or ever was one */
  creator?: Maybe<Creator>;
  /** All Feth entries related to this account. */
  feth: Array<Feth>;
  /** The account's address */
  id: Scalars['ID'];
  /** The total ETH earned by this account, excluding any NFTs minted by this creator */
  netRevenueInETH: Scalars['BigDecimal'];
  /** The total ETH earned by this account but still pending finalization, excluding any NFTs minted by this creator */
  netRevenuePendingInETH: Scalars['BigDecimal'];
  /** Approvals granted by this account, note this does not include nft.approvedSpender */
  nftAccountApprovals: Array<NftAccountApproval>;
  /** All bids accepted by this account */
  nftBidsAccepted: Array<NftMarketBid>;
  /** All bids placed by this account */
  nftBidsPlaced: Array<NftMarketBid>;
  /** NFT actions initiated by this account */
  nftHistory: Array<NftHistory>;
  /** All auctions created by this account */
  nftMarketAuctions: Array<NftMarketAuction>;
  /** All offers made by this account */
  nftOffersMade: Array<NftMarketOffer>;
  /** NFT transfers to this account from another */
  nftTransfersIn: Array<NftTransfer>;
  /** NFT transfers from this account to another */
  nftTransfersOut: Array<NftTransfer>;
  /** All NFTs currently owned by this account */
  nfts: Array<Nft>;
  /** All NFTs currently owner or listed by this account */
  nftsOwnedOrListed: Array<Nft>;
};

export type CollectionContract = {
  __typename?: 'CollectionContract';
  /** The creator account which created this collection */
  creator: Creator;
  /** The date/time the collection was created in seconds since Unix epoch */
  dateCreated: Scalars['BigInt'];
  /** The date/time the collection was self destructed in seconds since Unix epoch if applicable, this resets if the collection is re-created */
  dateSelfDestructed?: Maybe<Scalars['BigInt']>;
  /** contractAddress */
  id: Scalars['ID'];
  /** A reference to the NftContract instance */
  nftContract: NftContract;
  /** factoryAddress-templateVersion */
  version: Scalars['String'];
};

export type Creator = {
  __typename?: 'Creator';
  /** The creator's account information */
  account: Account;
  /** The account's address */
  id: Scalars['ID'];
  /** The total ETH earned by this creator */
  netRevenueInETH: Scalars['BigDecimal'];
  /** The total ETH earned by this creator but still pending finalization */
  netRevenuePendingInETH: Scalars['BigDecimal'];
  /** The total ETH for sales of NFTs this creator minted */
  netSalesInETH: Scalars['BigDecimal'];
  /** The total ETH for sales of NFTs this creator minted but still pending finalization */
  netSalesPendingInETH: Scalars['BigDecimal'];
  /** All NFTs minted by this creator */
  nfts: Array<Nft>;
};

export type Feth = {
  __typename?: 'Feth';
  balanceInETH: Scalars['BigDecimal'];
  dateLastUpdated: Scalars['BigInt'];
  escrow: Array<FethEscrow>;
  /** userAddress */
  id: Scalars['ID'];
  user: Account;
};

export type FethEscrow = {
  __typename?: 'FethEscrow';
  amountInETH: Scalars['BigDecimal'];
  dateExpiry: Scalars['BigInt'];
  dateRemoved?: Maybe<Scalars['BigInt']>;
  feth: Feth;
  /** userAddress-dateExpiry */
  id: Scalars['ID'];
  transactionHashCreated: Scalars['Bytes'];
  transactionHashRemoved?: Maybe<Scalars['Bytes']>;
};

export enum HistoricalEvent {
  /** The auction was invalidated due to another action such as Buy Now */
  AuctionInvalidated = 'AuctionInvalidated',
  /** A bid for the NFT has been made */
  Bid = 'Bid',
  /** The NFT was burned and now no longer available on-chain */
  Burned = 'Burned',
  /** The buy now for this NFT was accepted */
  BuyPriceAccepted = 'BuyPriceAccepted',
  /** The buy now for this NFT was canceled */
  BuyPriceCanceled = 'BuyPriceCanceled',
  /** The buy now for this NFT is no longer valid due to another action such as auction kick off */
  BuyPriceInvalidated = 'BuyPriceInvalidated',
  /** The NFT had a buy now price set */
  BuyPriceSet = 'BuyPriceSet',
  /** The creator has been migrated to a new account */
  CreatorMigrated = 'CreatorMigrated',
  /** The payment address for this NFT has migrated to a new address */
  CreatorPaymentAddressMigrated = 'CreatorPaymentAddressMigrated',
  /** The NFT has been listed for sale */
  Listed = 'Listed',
  /** The original mint event for this NFT */
  Minted = 'Minted',
  /** The offer for this NFT was accepted */
  OfferAccepted = 'OfferAccepted',
  /** The offer for this NFT was canceled */
  OfferCanceled = 'OfferCanceled',
  /** The latest offer for an NFT was increased */
  OfferChanged = 'OfferChanged',
  /** The offer for this NFT expired before it was expired, this status is not reflected until another action is performed */
  OfferExpired = 'OfferExpired',
  /** The offer for this NFT is no longer valid due to another action such as Buy Now */
  OfferInvalidated = 'OfferInvalidated',
  /** The NFT received an offer */
  OfferMade = 'OfferMade',
  /** The current owner of this NFT has migrated to a new account */
  OwnerMigrated = 'OwnerMigrated',
  /** The price for this listing has been modified */
  PriceChanged = 'PriceChanged',
  /** The NFT was sold in a private sale */
  PrivateSale = 'PrivateSale',
  /** The seller for the current auction has migrated to a new account */
  SellerMigrated = 'SellerMigrated',
  /** The sale has been settled on-chain and the NFT was transferred to the new owner */
  Settled = 'Settled',
  /** The NFT has been sold, this status is not reflected until the auction has been settled */
  Sold = 'Sold',
  /** The NFT was transferred from one address to another */
  Transferred = 'Transferred',
  /** The NFT was unlisted from the market */
  Unlisted = 'Unlisted'
}

export enum Marketplace {
  /** Foundation's market contract is the only one supported ATM but more will be added in the future */
  Foundation = 'Foundation'
}

export type Nft = {
  __typename?: 'Nft';
  /** An account authorized to transfer this NFT, if one was approved */
  approvedSpender?: Maybe<Account>;
  /** All auctions which were created for this NFT */
  auctions: Array<NftMarketAuction>;
  /** All bids ever placed for this NFT */
  bids: Array<NftMarketBid>;
  /** The creator of this NFT */
  creator?: Maybe<Creator>;
  /** The date/time when this NFT was minted in seconds since Unix epoch */
  dateMinted: Scalars['BigInt'];
  /** tokenContractAddress-tokenId */
  id: Scalars['ID'];
  /** True if the NFT has not yet been sold in the Foundation market */
  isFirstSale: Scalars['Boolean'];
  /** The most recent sale price in the Foundation marketplace, if there has been one */
  lastSalePriceInETH?: Maybe<Scalars['BigDecimal']>;
  /** The last auction for this NFT which was finalized, if there was one */
  latestFinalizedAuction?: Maybe<NftMarketAuction>;
  /** The transfer details where this NFT was minted */
  mintedTransfer?: Maybe<NftTransfer>;
  /** The current or last auction for this NFT which has not been canceled, if any */
  mostRecentActiveAuction?: Maybe<NftMarketAuction>;
  /** The current or last previous auction for this NFT */
  mostRecentAuction?: Maybe<NftMarketAuction>;
  /** The most recent buy now for this NFT, which may or may not still be valid */
  mostRecentBuyNow?: Maybe<NftMarketBuyNow>;
  /** The most recent offer made for this NFT, which may or may not still be valid */
  mostRecentOffer?: Maybe<NftMarketOffer>;
  /** The total ETH earned by the creator from this NFT */
  netRevenueInETH: Scalars['BigDecimal'];
  /** The total ETH earned by this creator from this NFT but still pending finalization */
  netRevenuePendingInETH: Scalars['BigDecimal'];
  /** The total ETH for sales of this NFT */
  netSalesInETH: Scalars['BigDecimal'];
  /** The total ETH for sales of this NFT but still pending finalization */
  netSalesPendingInETH: Scalars['BigDecimal'];
  /** All buy nows made for this NFT */
  nftBuyNows: Array<NftMarketBuyNow>;
  /** The token's contract */
  nftContract: NftContract;
  /** The event history for this NFT */
  nftHistory: Array<NftHistory>;
  /** All offers made for this NFT */
  nftOffers: Array<NftMarketOffer>;
  /** The current owner or the owner who listed the NFT */
  ownedOrListedBy: Account;
  /** The current owner of this NFT */
  owner: Account;
  /** A reference to the split details defined by the tokenCreatorPaymentAddress, if that address is a PercentSplit */
  percentSplit?: Maybe<PercentSplit>;
  /** An optional address to receive revenue and creator royalty payments generated by this NFT */
  tokenCreatorPaymentAddress?: Maybe<Scalars['Bytes']>;
  /** The content path for the metadata of this NFT on IPFS */
  tokenIPFSPath?: Maybe<Scalars['String']>;
  /** The tokenId for this specific NFT */
  tokenId: Scalars['BigInt'];
  /** All transfers that have occurred for this NFT */
  transfers?: Maybe<Array<NftTransfer>>;
};

export type NftAccountApproval = {
  __typename?: 'NftAccountApproval';
  /** tokenAddress-owner-spender */
  id: Scalars['ID'];
  /** The token's contract */
  nftContract: NftContract;
  /** The account which granted this approval */
  owner: Account;
  /** The account which is authorized to transfer NFTs held by the owner */
  spender: Account;
};

export type NftContract = {
  __typename?: 'NftContract';
  /** Append baseURI+tokenIPFSPath to get the tokenURI */
  baseURI?: Maybe<Scalars['String']>;
  /** The contract's address */
  id: Scalars['ID'];
  /** The token name */
  name?: Maybe<Scalars['String']>;
  /** All NFTs minted by this contract */
  nfts: Array<Nft>;
  /** The token symbol */
  symbol?: Maybe<Scalars['String']>;
};

export type NftHistory = {
  __typename?: 'NftHistory';
  /** The account associated with this event, if unknown the txOrigin is used. Usually the same as txOrigin but may differ when multisig or other contracts are used */
  actorAccount: Account;
  /** The value amount associated with this event, in ETH. Null if unknown or n/a */
  amountInETH?: Maybe<Scalars['BigDecimal']>;
  /** The ERC-20 value associated with this event. Null if unknown or ETH was used */
  amountInTokens?: Maybe<Scalars['BigInt']>;
  /** The related auction for this change, if applicable */
  auction?: Maybe<NftMarketAuction>;
  /** The related buy now for this change, if applicable */
  buyNow?: Maybe<NftMarketBuyNow>;
  /** The contract which processed this event, may be a marketplace or the NFT itself */
  contractAddress: Scalars['Bytes'];
  /** The date/time of this event in seconds since Unix epoch */
  date: Scalars['BigInt'];
  /** The type of action that this row represents */
  event: HistoricalEvent;
  /** tx-logId-eventType */
  id: Scalars['ID'];
  /** Which market which facilitated this transaction, null when the action was specific to the NFT itself */
  marketplace?: Maybe<Marketplace>;
  /** The NFT being sold in this auction */
  nft: Nft;
  /** The destination of the NFT for events where the NFT was transferred, null if n/a */
  nftRecipient?: Maybe<Account>;
  /** The related offer for this change, if applicable */
  offer?: Maybe<NftMarketOffer>;
  /** The related private sale for this change, if applicable */
  privateSale?: Maybe<PrivateSale>;
  /** The ERC-20 token address associated with this event. Null if unknown or ETH was used */
  tokenAddress?: Maybe<Scalars['Bytes']>;
  /** The transaction hash where this event occurred */
  transactionHash: Scalars['Bytes'];
  /** The msg.sender for the transaction associated with this event */
  txOrigin: Account;
};

export type NftMarketAuction = {
  __typename?: 'NftMarketAuction';
  /** The id for this auction */
  auctionId: Scalars['BigInt'];
  /** The volume of ETH bid */
  bidVolumeInETH: Scalars['BigDecimal'];
  /** All bids placed in this auction */
  bids: Array<NftMarketBid>;
  /** The reason this auction was canceled, if known */
  canceledReason?: Maybe<Scalars['String']>;
  /** How much the creator earned from this auction, set once there a bid is placed */
  creatorRevenueInETH?: Maybe<Scalars['BigDecimal']>;
  /** The date/time the auction was canceled in seconds since Unix epoch, if applicable */
  dateCanceled?: Maybe<Scalars['BigInt']>;
  /** The date/time the auction was initially created in seconds since Unix epoch */
  dateCreated: Scalars['BigInt'];
  /** The date/time the auction will be closed, only known once the reserve price has been met in seconds since Unix epoch */
  dateEnding?: Maybe<Scalars['BigInt']>;
  /** The date/time the auction was finalized in seconds since Unix epoch, if applicable */
  dateFinalized?: Maybe<Scalars['BigInt']>;
  /** The date/time the auction was invalidated in seconds since Unix epoch, if applicable */
  dateInvalidated?: Maybe<Scalars['BigInt']>;
  /** The date/time the auction countdown began, only known once reserve price has been met in seconds since Unix epoch */
  dateStarted?: Maybe<Scalars['BigInt']>;
  /** How long the auction runs for once the reserve price has been met in seconds */
  duration: Scalars['BigInt'];
  /** How long to extend the dateEnding if a bid is placed near the end of the countdown in seconds */
  extensionDuration: Scalars['BigInt'];
  /** How much Foundation earned from this auction, set once there a bid is placed */
  foundationRevenueInETH?: Maybe<Scalars['BigDecimal']>;
  /** The current highest bid, if one has been placed */
  highestBid?: Maybe<NftMarketBid>;
  /** marketContractAddress-auctionId */
  id: Scalars['ID'];
  /** The first bid which met the reserve price */
  initialBid?: Maybe<NftMarketBid>;
  /** True if this is the first sale on Foundation and being sold by the creator */
  isPrimarySale: Scalars['Boolean'];
  /** The NFT being sold in this auction */
  nft: Nft;
  /** The NFT contract for this NFT */
  nftContract: NftContract;
  /** The contract managing this auction */
  nftMarketContract: NftMarketContract;
  /** How many bids have been placed for any auction on Foundation */
  numberOfBids: Scalars['BigInt'];
  /** How much the owner (if not the creator) earned from this auction, set once there a bid is placed */
  ownerRevenueInETH?: Maybe<Scalars['BigDecimal']>;
  /** The initial reserve price which needs to be met in order to begin the auction countdown */
  reservePriceInETH: Scalars['BigDecimal'];
  /** The NFT owner currently offering the NFT for sale */
  seller: Account;
  /** The current status of this auction */
  status: NftMarketAuctionStatus;
  /** The tx hash where this auction was canceled, if applicable */
  transactionHashCanceled?: Maybe<Scalars['Bytes']>;
  /** The tx hash where this auction was initially created */
  transactionHashCreated: Scalars['Bytes'];
  /** The tx hash where this auction was invalidated, if applicable */
  transactionHashInvalidated?: Maybe<Scalars['Bytes']>;
};

export enum NftMarketAuctionStatus {
  /** This auction was canceled before the reserve price was hit */
  Canceled = 'Canceled',
  /** This auction was finalized and the NFT has been transferred to the winner */
  Finalized = 'Finalized',
  /** This auction was invalidated due to another action such as Buy Now */
  Invalidated = 'Invalidated',
  /** This auction has not been canceled or finalized yet, it may be active or pending finalization */
  Open = 'Open'
}

export type NftMarketBid = {
  __typename?: 'NftMarketBid';
  /** The size of the bid placed, including fees */
  amountInETH: Scalars['BigDecimal'];
  /** The bid this one outbid, if applicable */
  bidThisOutbid?: Maybe<NftMarketBid>;
  /** The account which placed the bid */
  bidder: Account;
  /** The date/item when this bid became no longer Active in seconds since Unix epoch, if applicable */
  dateLeftActiveStatus?: Maybe<Scalars['BigInt']>;
  /** The date/time the bid was placed in seconds since Unix epoch */
  datePlaced: Scalars['BigInt'];
  /** True if this bid caused the end time of an auction to be extended */
  extendedAuction: Scalars['Boolean'];
  /** marketContractAddress-auctionId-txHash-logId */
  id: Scalars['ID'];
  /** The NFT being sold in this auction */
  nft: Nft;
  /** The auction this bid was for */
  nftMarketAuction: NftMarketAuction;
  /** The bid which outbid this one, if applicable */
  outbidByBid?: Maybe<NftMarketBid>;
  /** The account which offered this NFT for sale */
  seller: Account;
  /** The current status of this bid */
  status: NftMarketBidStatus;
  /** The tx hash that moved this bid out of Active status, if applicable */
  transactionHashLeftActiveStatus?: Maybe<Scalars['Bytes']>;
  /** The tx hash that placed the bid */
  transactionHashPlaced: Scalars['Bytes'];
};

export enum NftMarketBidStatus {
  /** This bid won the auction and was finalized, completing the NFT transfer */
  FinalizedWinner = 'FinalizedWinner',
  /** This bid is currently the highest, either on-track to win or has won and is pending finalization */
  Highest = 'Highest',
  /** This bid was outbid by another user */
  Outbid = 'Outbid'
}

export type NftMarketBuyNow = {
  __typename?: 'NftMarketBuyNow';
  /** The value being bought at for this NFT */
  amountInETH: Scalars['BigDecimal'];
  /** The account purchasing the NFT using this buy now, if applicable */
  buyer?: Maybe<Account>;
  /** How much the creator earned from this buy now, set once accepted */
  creatorRevenueInETH?: Maybe<Scalars['BigDecimal']>;
  /** The date/time the buy now was accepted in seconds since Unix epoch, if applicable */
  dateAccepted?: Maybe<Scalars['BigInt']>;
  /** The date/time the buy now was canceled in seconds since Unix epoch, if applicable */
  dateCanceled?: Maybe<Scalars['BigInt']>;
  /** The date/time the buy now was initially created in seconds since Unix epoch */
  dateCreated: Scalars['BigInt'];
  /** The date/time the buy now was invalidate in seconds since Unix epoch, if applicable */
  dateInvalidated?: Maybe<Scalars['BigInt']>;
  /** How much Foundation earned from this buy now, set once accepted */
  foundationRevenueInETH?: Maybe<Scalars['BigDecimal']>;
  /** tx-logId */
  id: Scalars['ID'];
  /** True if this is the first sale on Foundation and being sold by the creator, not known until the offer is accepted */
  isPrimarySale?: Maybe<Scalars['Boolean']>;
  /** The NFT this buy now is for */
  nft: Nft;
  /** The NFT contract for this NFT */
  nftContract: NftContract;
  /** The contract managing this buy now */
  nftMarketContract: NftMarketContract;
  /** How much the owner (if not the creator) earned from this buy now, set once accepted */
  ownerRevenueInETH?: Maybe<Scalars['BigDecimal']>;
  /** The seller which owns the NFT. */
  seller: Account;
  /** The current status of this buy now */
  status: NftMarketBuyNowStatus;
  /** The tx hash where this buy now was accepted, if applicable */
  transactionHashAccepted?: Maybe<Scalars['Bytes']>;
  /** The tx hash where this buy now was canceled, if applicable */
  transactionHashCanceled?: Maybe<Scalars['Bytes']>;
  /** The tx hash where this buy now was initially created */
  transactionHashCreated: Scalars['Bytes'];
  /** The tx hash where this offer was outbid, if applicable */
  transactionHashInvalidated?: Maybe<Scalars['Bytes']>;
};

export enum NftMarketBuyNowStatus {
  /** This buy now was accepted */
  Accepted = 'Accepted',
  /** This buy now has been canceled */
  Canceled = 'Canceled',
  /** This buy now is no longer valid due to another action such as accepted offer / kicked off auction */
  Invalidated = 'Invalidated',
  /** This buy now is applicable */
  Open = 'Open'
}

export type NftMarketContract = {
  __typename?: 'NftMarketContract';
  /** The contract's address */
  id: Scalars['ID'];
  /** How many bids have been placed for any auction on Foundation */
  numberOfBidsPlaced: Scalars['BigInt'];
};

export type NftMarketOffer = {
  __typename?: 'NftMarketOffer';
  /** The value being offered for this NFT */
  amountInETH: Scalars['BigDecimal'];
  /** The account making this offer */
  buyer: Account;
  /** The reason this offer was canceled, if known */
  canceledReason?: Maybe<Scalars['String']>;
  /** How much the creator earned from this offer, set once accepted */
  creatorRevenueInETH?: Maybe<Scalars['BigDecimal']>;
  /** The date/time the offer was accepted in seconds since Unix epoch, if applicable */
  dateAccepted?: Maybe<Scalars['BigInt']>;
  /** The date/time the offer was canceled in seconds since Unix epoch, if applicable */
  dateCanceled?: Maybe<Scalars['BigInt']>;
  /** The date/time the offer was initially created in seconds since Unix epoch */
  dateCreated: Scalars['BigInt'];
  /** The date/time the offer will expire in seconds since Unix epoch */
  dateExpires: Scalars['BigInt'];
  /** The date/time the offer was invalidate in seconds since Unix epoch, if applicable */
  dateInvalidated?: Maybe<Scalars['BigInt']>;
  /** The date/time the offer was outbid in seconds since Unix epoch, if applicable */
  dateOutbid?: Maybe<Scalars['BigInt']>;
  /** How much Foundation earned from this offer, set once accepted */
  foundationRevenueInETH?: Maybe<Scalars['BigDecimal']>;
  /** tx-logId */
  id: Scalars['ID'];
  /** True if this is the first sale on Foundation and being sold by the creator, not known until the offer is accepted */
  isPrimarySale?: Maybe<Scalars['Boolean']>;
  /** The NFT this offer is for */
  nft: Nft;
  /** The NFT contract for this NFT */
  nftContract: NftContract;
  /** The contract managing this offer */
  nftMarketContract: NftMarketContract;
  /** The offer that outbid this offer, if applicable */
  offerOutbidBy?: Maybe<NftMarketOffer>;
  /** The offer that was outbid when this offer was placed, if applicable */
  outbidOffer?: Maybe<NftMarketOffer>;
  /** How much the owner (if not the creator) earned from this offer, set once accepted */
  ownerRevenueInETH?: Maybe<Scalars['BigDecimal']>;
  /** The seller which accepted this offer, if applicable */
  seller?: Maybe<Account>;
  /** The current status of this offer */
  status: NftMarketOfferStatus;
  /** The tx hash where this offer was accepted, if applicable */
  transactionHashAccepted?: Maybe<Scalars['Bytes']>;
  /** The tx hash where this offer was canceled, if applicable */
  transactionHashCanceled?: Maybe<Scalars['Bytes']>;
  /** The tx hash where this offer was initially created */
  transactionHashCreated: Scalars['Bytes'];
  /** The tx hash where this offer was outbid, if applicable */
  transactionHashInvalidated?: Maybe<Scalars['Bytes']>;
  /** The tx hash where this offer was outbid, if applicable */
  transactionHashOutbid?: Maybe<Scalars['Bytes']>;
};

export enum NftMarketOfferStatus {
  /** This offer was accepted */
  Accepted = 'Accepted',
  /** This offer has been canceled */
  Canceled = 'Canceled',
  /** This offer has expired, this status is not reflected until another action is performed */
  Expired = 'Expired',
  /** This offer is no longer valid due to another action such as Buy Now */
  Invalidated = 'Invalidated',
  /** This offer is applicable unless it has expired */
  Open = 'Open',
  /** This offer has been outbid by another offer, potentially from the same buyer */
  Outbid = 'Outbid'
}

export type NftTransfer = {
  __typename?: 'NftTransfer';
  /** The date/time of the transfer in seconds since Unix epoch */
  dateTransferred: Scalars['BigInt'];
  /** The source of the transfer, 0 when the token was minted */
  from: Account;
  /** tx-logId */
  id: Scalars['ID'];
  /** The NFT which was transferred */
  nft: Nft;
  /** The destination of the transfer, 0 when the token is burned */
  to: Account;
  /** The tx hash where the transfer occurred */
  transactionHash: Scalars['Bytes'];
};

export type PercentSplit = {
  __typename?: 'PercentSplit';
  /** The date/time this split was initially created in seconds since Unix epoch */
  dateCreated: Scalars['BigInt'];
  /** The address of this split contract */
  id: Scalars['ID'];
  /** All the NFTs currently leveraging this split */
  nfts: Array<Nft>;
  /** How many different shares are in this split */
  shareCount: Scalars['BigInt'];
  /** The recipients and their percent share for this split */
  shares: Array<PercentSplitShare>;
};

export type PercentSplitShare = {
  __typename?: 'PercentSplitShare';
  /** The recipient included in the split */
  account: Account;
  /** contractAddress-logId */
  id: Scalars['ID'];
  /** The index position of this share in the split, as defined in the contract */
  indexOfShare: Scalars['BigInt'];
  /** The percent share this recipient will receive */
  shareInPercent: Scalars['BigDecimal'];
  /** The split this share is for */
  split: PercentSplit;
};

export type PrivateSale = {
  __typename?: 'PrivateSale';
  /** The total sale price */
  amountInETH: Scalars['BigDecimal'];
  /** The account which bought this NFT */
  buyer: Account;
  /** How much the creator earned from this sale */
  creatorRevenueInETH: Scalars['BigDecimal'];
  /** The date/time this sale was completed in seconds since Unix epoch */
  dateSold: Scalars['BigInt'];
  /** The deadline at which this offer was set to expire, in seconds since Unix epoch */
  deadline: Scalars['BigInt'];
  /** How much Foundation earned from this sale */
  foundationRevenueInETH: Scalars['BigDecimal'];
  /** tx-logId */
  id: Scalars['ID'];
  /** True if this is the first sale on Foundation and being sold by the creator */
  isPrimarySale: Scalars['Boolean'];
  /** The NFT which was sold */
  nft: Nft;
  /** How much the owner (if not the creator) earned from this sale */
  ownerRevenueInETH: Scalars['BigDecimal'];
  /** The account which sold this NFT */
  seller: Account;
  /** The tx hash in which this was sold */
  transactionHashSold: Scalars['Bytes'];
};
