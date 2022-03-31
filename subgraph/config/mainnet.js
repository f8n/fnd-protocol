// eslint-disable-next-line @typescript-eslint/no-var-requires
const addresses = require("../../addresses");
const getAddressesForSubgraph = require("./shared");

module.exports = {
  network: "mainnet",
  startBlock: {
    treasury: 11648572,
    nftMarket: 11648710,
    nft721: 11648721,
    percentSplitV1: 12562117,
    percentSplitV2: 13623251,
    percentSplit: 14391349,
    collectionFactory: 13531391,
    feth: 14335127,
  },
  ...getAddressesForSubgraph(addresses.prod[1]),
};
