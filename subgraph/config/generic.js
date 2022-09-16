// Helper for C-style Struct for readable code organization.
// For more see: https://stackoverflow.com/a/46741349
const Struct =
  (...keys) =>
  (...v) =>
    keys.reduce((o, k, i) => {
      o[k] = v[i];
      return o;
    }, {});

const SubgraphNetworkConfig = Struct("networkName", "chainId", "env", "startBlock");

networkNameToSubgraphConfig = {
  optimismKovan: SubgraphNetworkConfig("optimism-kovan", 69, "staging", 238000),
};

// Convert "dash-structure" to "camelCaseStructure".
function fromDashToCamelCase(str) {
  return str.replace(/-([a-z])/g, function (g) {
    return g[1].toUpperCase();
  });
}

const NETWORK_NAME = fromDashToCamelCase(process.env.NETWORK_NAME);

const addresses = require(`../../src/addresses/${networkNameToSubgraphConfig[NETWORK_NAME].env}/${networkNameToSubgraphConfig[NETWORK_NAME].chainId}.json`);
const getAddressesForSubgraph = require("./shared");

// Subgraph Config.
module.exports = {
  network: networkNameToSubgraphConfig[NETWORK_NAME].networkName,
  startBlock: {
    treasury: networkNameToSubgraphConfig[NETWORK_NAME].startBlock,
    nftDropMarket: networkNameToSubgraphConfig[NETWORK_NAME].startBlock,
    nftMarket: networkNameToSubgraphConfig[NETWORK_NAME].startBlock,
    nft721: networkNameToSubgraphConfig[NETWORK_NAME].startBlock,
    percentSplitV1: networkNameToSubgraphConfig[NETWORK_NAME].startBlock,
    percentSplitV2: networkNameToSubgraphConfig[NETWORK_NAME].startBlock,
    percentSplit: networkNameToSubgraphConfig[NETWORK_NAME].startBlock,
    nftCollectionFactoryV1: networkNameToSubgraphConfig[NETWORK_NAME].startBlock,
    feth: networkNameToSubgraphConfig[NETWORK_NAME].startBlock,
    nftCollectionFactoryV2: networkNameToSubgraphConfig[NETWORK_NAME].startBlock,
  },
  ...getAddressesForSubgraph(addresses),
};
