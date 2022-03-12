const hre = require("hardhat");

async function main() {
  const StakeToken = await hre.ethers.getContractFactory("StakeToken");
  const stakeToken = await StakeToken.deploy();
  await stakeToken.deployed();

  const CollectiveNFT = await hre.ethers.getContractFactory("CollectiveNFT");
  const collectiveNFT = await CollectiveNFT.deploy(stakeToken.address);
  await collectiveNFT.deployed();

  console.log("stakeToken deployed to:", stakeToken.address);
  console.log("collectiveNFT deployed to:", collectiveNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
