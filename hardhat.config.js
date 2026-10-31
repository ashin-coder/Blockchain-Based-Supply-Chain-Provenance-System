require("@nomicfoundation/hardhat-ethers");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.24",
    settings: { optimizer: { enabled: true, runs: 200 } },
  },
  networks: {
    // Local Hardhat node: start it with `npx hardhat node`
    localhost: { url: "http://127.0.0.1:8545" },
    // Public testnet deployment will be added later (e.g. Sepolia or Polygon Amoy).
  },
};
