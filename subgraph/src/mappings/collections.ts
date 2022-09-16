import { Address, BigInt } from "@graphprotocol/graph-ts";

import { CollectionCreated as CollectionCreatedEvent } from "../../generated/FNDCollectionFactory/FNDCollectionFactoryContract";
import {
  NFTCollectionCreated as CollectionCreatedEventV2,
  NFTDropCollectionCreated as NFTDropCollectionCreatedEvent,
} from "../../generated/NFTCollectionFactory/NFTCollectionFactoryContract";
import { CollectionContract, NftDropCollectionContract } from "../../generated/schema";
import {
  NFTCollection as NFTCollectionTemplate,
  NFTDropCollection as NFTDropCollectionTemplate,
} from "../../generated/templates";
import { loadOrCreateAccount } from "../shared/accounts";
import { ZERO_ADDRESS_STRING } from "../shared/constants";
import { loadOrCreateCreator } from "../shared/creators";
import { loadOrCreateNFTContract } from "./nft";

export function handleCollectionCreated(event: CollectionCreatedEvent): void {
  _handleCollectionCreated(
    event.params.collection,
    event.params.creator,
    event.params.version,
    event.address,
    event.block.timestamp,
  );
}

export function handleCollectionCreatedV2(event: CollectionCreatedEventV2): void {
  _handleCollectionCreated(
    event.params.collection,
    event.params.creator,
    event.params.version,
    event.address,
    event.block.timestamp,
  );
}

function _handleCollectionCreated(
  nftCollection: Address,
  creator: Address,
  version: BigInt,
  eventAddress: Address,
  eventTS: BigInt,
): void {
  NFTCollectionTemplate.create(nftCollection);
  let nftContract = loadOrCreateNFTContract(nftCollection);
  let collectionEntity = CollectionContract.load(nftCollection.toHex());
  if (collectionEntity) {
    collectionEntity.dateSelfDestructed = null;
  } else {
    collectionEntity = new CollectionContract(nftCollection.toHex());
  }
  collectionEntity.nftContract = nftContract.id;
  collectionEntity.creator = loadOrCreateCreator(creator).id;
  collectionEntity.version = eventAddress.toHex() + "-" + version.toString();
  collectionEntity.dateCreated = eventTS;
  collectionEntity.save();
}

export function handleNFTDropCollectionCreated(event: NFTDropCollectionCreatedEvent): void {
  NFTDropCollectionTemplate.create(event.params.collection);
  let nftDropCollection = NftDropCollectionContract.load(event.params.collection.toHex());
  if (nftDropCollection) {
    nftDropCollection.dateSelfDestructed = null;
  } else {
    nftDropCollection = new NftDropCollectionContract(event.params.collection.toHex());
  }
  let nftContract = loadOrCreateNFTContract(event.params.collection, /*fromNFTDropCollection=*/ true);
  nftDropCollection.nftContract = nftContract.id;
  nftDropCollection.creator = loadOrCreateCreator(event.params.creator).id;
  nftDropCollection.dateCreated = event.block.timestamp;
  if (event.params.approvedMinter.toHex() != ZERO_ADDRESS_STRING) {
    nftDropCollection.approvedMinter = loadOrCreateAccount(event.params.approvedMinter).id;
  }
  nftDropCollection.paymentAddress = loadOrCreateAccount(event.params.paymentAddress).id;
  nftDropCollection.version = event.address.toHex() + "-" + event.params.version.toString();
  nftDropCollection.save();
}
