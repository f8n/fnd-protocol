import { Address, BigInt, ethereum, store } from "@graphprotocol/graph-ts";
import { PaymentAddressMigrated, TokenCreatorUpdated } from "../../generated/NFT721Contract/NFT721Contract";
import {
  Approval,
  ApprovalForAll,
  BaseURIUpdated,
  CollectionContract as CollectionContractABI,
  Minted,
  NFTOwnerMigrated,
  SelfDestruct,
  TokenCreatorPaymentAddressSet,
  Transfer,
} from "../../generated/templates/CollectionContract/CollectionContract";
import { CollectionContract, Nft, NftAccountApproval, NftContract, NftTransfer } from "../../generated/schema";
import { loadOrCreateAccount } from "../shared/accounts";
import { ZERO_ADDRESS_STRING, ZERO_BIG_DECIMAL } from "../shared/constants";
import { loadOrCreateCreator } from "../shared/creators";
import { recordNftEvent, removePreviousTransferEvent } from "../shared/events";
import { getLogId } from "../shared/ids";

export function loadOrCreateNFTContract(address: Address): NftContract {
  let nftContract = NftContract.load(address.toHex());
  if (!nftContract) {
    nftContract = new NftContract(address.toHex());
    let contract = CollectionContractABI.bind(address);
    let nameResults = contract.try_name();
    if (!nameResults.reverted) {
      nftContract.name = nameResults.value;
    }
    let symbolResults = contract.try_symbol();
    if (!symbolResults.reverted) {
      nftContract.symbol = symbolResults.value;
    }
    nftContract.baseURI = "ipfs://";
    nftContract.save();
  }
  return nftContract as NftContract;
}

function getNFTId(address: Address, id: BigInt): string {
  return address.toHex() + "-" + id.toString();
}

export function loadOrCreateNFT(address: Address, id: BigInt, event: ethereum.Event): Nft {
  let nftId = getNFTId(address, id);
  let nft = Nft.load(nftId);
  if (!nft) {
    nft = new Nft(nftId);
    nft.nftContract = loadOrCreateNFTContract(address).id;
    nft.tokenId = id;
    nft.dateMinted = event.block.timestamp;
    let contract = CollectionContractABI.bind(address);
    let ownerResult = contract.try_ownerOf(id);
    if (!ownerResult.reverted) {
      nft.owner = loadOrCreateAccount(ownerResult.value).id;
    } else {
      nft.owner = loadOrCreateAccount(Address.zero()).id;
    }
    nft.ownedOrListedBy = nft.owner;
    nft.netSalesInETH = ZERO_BIG_DECIMAL;
    nft.netSalesPendingInETH = ZERO_BIG_DECIMAL;
    nft.netRevenueInETH = ZERO_BIG_DECIMAL;
    nft.netRevenuePendingInETH = ZERO_BIG_DECIMAL;
    nft.isFirstSale = true;
    let pathResult = contract.try_tokenURI(id);
    if (!pathResult.reverted) {
      nft.tokenIPFSPath = pathResult.value;
    }
    let creatorResult = contract.try_tokenCreator(id);
    if (!creatorResult.reverted) {
      nft.creator = loadOrCreateCreator(creatorResult.value).id;
    }
    nft.save();
  }

  return nft as Nft;
}

export function handleApproval(event: Approval): void {
  let nft = loadOrCreateNFT(event.address, event.params.tokenId, event);
  if (event.params.approved != Address.zero()) {
    nft.approvedSpender = loadOrCreateAccount(event.params.approved).id;
  } else {
    nft.approvedSpender = null;
  }
  nft.save();
}

export function handleApprovalForAll(event: ApprovalForAll): void {
  let id = event.address.toHex() + "-" + event.params.owner.toHex() + "-" + event.params.operator.toHex();
  if (event.params.approved) {
    let nft721AccountApproval = new NftAccountApproval(id);
    let nftContract = loadOrCreateNFTContract(event.address);
    nft721AccountApproval.nftContract = nftContract.id;
    nft721AccountApproval.owner = loadOrCreateAccount(event.params.owner).id;
    nft721AccountApproval.spender = loadOrCreateAccount(event.params.operator).id;
    nft721AccountApproval.save();
  } else {
    store.remove("NftAccountApproval", id);
  }
}

export function handleBaseURIUpdated(event: BaseURIUpdated): void {
  let nftContract = loadOrCreateNFTContract(event.address);
  nftContract.baseURI = event.params.baseURI;
  nftContract.save();
}

export function handleTokenCreatorUpdated(event: TokenCreatorUpdated): void {
  let nft = loadOrCreateNFT(event.address, event.params.tokenId, event);
  nft.creator = loadOrCreateCreator(event.params.toCreator).id;
  nft.save();

  if (event.params.fromCreator.toHex() != ZERO_ADDRESS_STRING) {
    recordNftEvent(
      event,
      nft as Nft,
      "CreatorMigrated",
      loadOrCreateAccount(event.params.fromCreator),
      null,
      null,
      null,
      loadOrCreateAccount(event.params.toCreator),
    );
  }
}

export function handleMinted(event: Minted): void {
  let nft = loadOrCreateNFT(event.address, event.params.tokenId, event);
  updateTokenIPFSPath(nft as Nft, event.params.tokenCID.toString(), event.block.timestamp);

  nft.creator = loadOrCreateCreator(event.params.creator).id;
  nft.save();
  let creatorAccount = loadOrCreateAccount(event.params.creator);
  recordNftEvent(event, nft as Nft, "Minted", creatorAccount, null, null, null, creatorAccount);
}

export function handleTransfer(event: Transfer): void {
  let nftContract = loadOrCreateNFTContract(event.address);
  let nftId = getNFTId(event.address, event.params.tokenId);
  let nft: Nft | null;
  if (event.params.from.toHex() == ZERO_ADDRESS_STRING) {
    // Mint
    nft = new Nft(nftId);
    nft.nftContract = nftContract.id;
    nft.tokenId = event.params.tokenId;
    nft.dateMinted = event.block.timestamp;
    nft.owner = loadOrCreateAccount(event.params.to).id;
    nft.ownedOrListedBy = nft.owner;
    nft.netSalesInETH = ZERO_BIG_DECIMAL;
    nft.netSalesPendingInETH = ZERO_BIG_DECIMAL;
    nft.netRevenueInETH = ZERO_BIG_DECIMAL;
    nft.netRevenuePendingInETH = ZERO_BIG_DECIMAL;
    nft.isFirstSale = true;
    nft.save();
  } else {
    // Transfer or Burn
    nft = loadOrCreateNFT(event.address, event.params.tokenId, event);
    nft.owner = loadOrCreateAccount(event.params.to).id;
    nft.ownedOrListedBy = nft.owner;

    if (event.params.to.toHex() == ZERO_ADDRESS_STRING) {
      // Burn
      recordNftEvent(event, nft as Nft, "Burned", loadOrCreateAccount(event.params.from));
    } else {
      // Transfer
      recordNftEvent(
        event,
        nft as Nft,
        "Transferred",
        loadOrCreateAccount(event.params.from),
        null,
        null,
        null,
        loadOrCreateAccount(event.params.to),
      );
    }
  }

  let transfer = new NftTransfer(getLogId(event));
  transfer.nft = nftId;
  transfer.from = loadOrCreateAccount(event.params.from).id;
  transfer.to = loadOrCreateAccount(event.params.to).id;
  transfer.dateTransferred = event.block.timestamp;
  transfer.transactionHash = event.transaction.hash;
  transfer.save();

  if (event.params.from.toHex() == ZERO_ADDRESS_STRING) {
    nft.mintedTransfer = transfer.id;
  }
  nft.save();
}

function updateTokenIPFSPath(nft: Nft, tokenIPFSPath: string, _: BigInt): void {
  nft.tokenIPFSPath = tokenIPFSPath;
  nft.save();
}

export function handleTokenCreatorPaymentAddressSet(event: TokenCreatorPaymentAddressSet): void {
  let nft = loadOrCreateNFT(event.address, event.params.tokenId, event);
  nft.tokenCreatorPaymentAddress = event.params.toPaymentAddress;
  // This field resets to null if a PercentSplit does not exist at this address
  nft.percentSplit = event.params.toPaymentAddress.toHex();
  nft.save();
}

export function handlePaymentAddressMigrated(event: PaymentAddressMigrated): void {
  let nft = loadOrCreateNFT(event.address, event.params.tokenId, event);
  let originalAccount = loadOrCreateAccount(event.params.originalAddress);
  let newAccount = loadOrCreateAccount(event.params.newAddress);

  recordNftEvent(event, nft as Nft, "CreatorPaymentAddressMigrated", originalAccount, null, null, null, newAccount);
}

export function handleNFTOwnerMigrated(event: NFTOwnerMigrated): void {
  let nft = loadOrCreateNFT(event.address, event.params.tokenId, event);
  recordNftEvent(
    event,
    nft as Nft,
    "OwnerMigrated",
    loadOrCreateAccount(event.params.originalAddress),
    null,
    null,
    null,
    loadOrCreateAccount(event.params.newAddress),
  );
  removePreviousTransferEvent(event);
}

export function handleSelfDestruct(event: SelfDestruct): void {
  let collection = CollectionContract.load(event.address.toHex());
  if (collection) {
    collection.dateSelfDestructed = event.block.timestamp;
    collection.save();
  }
}
