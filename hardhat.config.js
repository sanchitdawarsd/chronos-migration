require("@nomicfoundation/hardhat-toolbox");

/** @type import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: {
    version: "0.8.0", // Use the version that matches your contract
    settings: {
      optimizer: {
        enabled: true,
        runs: 200,
      },
    },
  },
};
