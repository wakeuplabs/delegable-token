import { ethers } from "hardhat";
import { DelegableTokenGeneric__factory } from "../typechain";
import { deployNFTContractGeneric } from "./utils";

async function main() {
  const [owner] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", owner.address);

  console.log("Account balance:", (await owner.getBalance()).toString());

  await deployNFTContractGeneric(
    owner,
    true,
    false,
    DelegableTokenGeneric__factory
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
