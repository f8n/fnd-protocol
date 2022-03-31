// eslint-disable-next-line @typescript-eslint/no-var-requires
const addresses = require("../../addresses");
const getAddressesForSubgraph = require("./shared");

module.exports = {
  network: "goerli",
  startBlock: {
    treasury: 4093137,
    nftMarket: 4093141,
    nft721: 4093147,
    percentSplitV1: 4901372,
    percentSplitV2: 5826847,
    percentSplit: 6421609,
    collectionFactory: 5746425,
    feth: 6385436,
  },
  ...getAddressesForSubgraph(addresses.staging[5]),
};
