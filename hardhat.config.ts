import "hardhat-exposed";
import "@nomicfoundation/hardhat-chai-matchers";
import "@typechain/hardhat";
import "solidity-coverage";
import "hardhat-deploy";
import "hardhat-deploy-ethers";
import "@openzeppelin/hardhat-upgrades";
import "@nomiclabs/hardhat-etherscan";
import "hardhat-preprocessor";
import "hardhat-tracer";
import "hardhat-storage-layout";
import "hardhat-exposed";
import "hardhat-gas-reporter";
import "@primitivefi/hardhat-dodoc";

import { HardhatUserConfig } from "hardhat/types";

const config: HardhatUserConfig = {
  solidity: {
    version: "0.8.17",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1337,
      },
    },
  },
  networks: {
    hardhat: {
      accounts: {
        count: 100,
      },
    },
  },
  typechain: {
    target: "ethers-v5",
    externalArtifacts: ["node_modules/@manifoldxyz/royalty-registry-solidity/build/contracts/*.json"],
    outDir: "src/typechain",
  },
  gasReporter: {
    excludeContracts: ["mocks/", "FoundationTreasury.sol", "ERC721.sol"],
  },
  dodoc: {
    runOnCompile: true,
    include: [
      "NFTCollection",
      "NFTDropCollection",
      "FETH",
      "FNDMiddleware",
      "NFTCollectionFactory",
      "NFTMarket",
      "NFTDropMarket",
      "FoundationTreasury",
      "PercentSplitETH",
    ],
    exclude: ["mixins", "mocks", "interfaces", "xyz/royalty-registry-solidity", "archive", "contracts-exposed"],
    templatePath: "./docs_template.sqrl",
  },
};

export default config;
