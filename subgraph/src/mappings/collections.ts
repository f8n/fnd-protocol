import { CollectionCreated as CollectionCreatedEvent } from "../../generated/FNDCollectionFactory/FNDCollectionFactoryContract";
import { CollectionContract as CollectionContractTemplate } from "../../generated/templates";
import { CollectionContract } from "../../generated/schema";
import { loadOrCreateNFTContract } from "./nft";
import { loadOrCreateCreator } from "../shared/creators";

export function handleCollectionCreated(event: CollectionCreatedEvent): void {
  CollectionContractTemplate.create(event.params.collectionContract);
  let nftContract = loadOrCreateNFTContract(event.params.collectionContract);
  let collectionEntity = CollectionContract.load(event.params.collectionContract.toHex());
  if (collectionEntity) {
    collectionEntity.dateSelfDestructed = null;
  } else {
    collectionEntity = new CollectionContract(event.params.collectionContract.toHex());
  }
  collectionEntity.nftContract = nftContract.id;
  collectionEntity.creator = loadOrCreateCreator(event.params.creator).id;
  collectionEntity.version = event.address.toHex() + "-" + event.params.version.toString();
  collectionEntity.dateCreated = event.block.timestamp;
  collectionEntity.save();
}
