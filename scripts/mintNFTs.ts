import { ethers } from "hardhat";
import { DelegableToken__factory } from "../typechain";

async function main() {
  const [owner] = await ethers.getSigners();

  console.log("Minting with the account:", owner.address);

  console.log("Account balance:", (await owner.getBalance()).toString());

  const token = DelegableToken__factory.connect(
    "0x77515eA6bdf3d9244E8d47e7259e627709C74a42",
    owner
  );

  const tx = await token.mint({ value: 10 });

  const receipt = await tx.wait();

  console.log({ hash: tx.hash, receipt: receipt.transactionHash });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
