/* eslint-disable camelcase */
import { Signer } from "ethers";
import { DelegableToken, DelegableToken__factory } from "../typechain";

export const deployNFTContract = async (
  owner: Signer,
  showLog: boolean = false,
  allowChangeUserBeforeUserExpired: boolean = true
) => {
  const nftContractFactory = new DelegableToken__factory(owner);
  const nftContract = await nftContractFactory.deploy(
    "DelegableToken",
    "DT721",
    "ipfs://test/",
    10,
    100,
    true,
    allowChangeUserBeforeUserExpired
  );
  await nftContract.deployed();

  if (showLog) console.log("NFTContract deployed to:", nftContract.address);

  return nftContract;
};

export const mintNFT = async (nftContract: DelegableToken, price: number) => {
  const mintTx = await nftContract.mint({ value: price });

  const nftIDReceipt = await mintTx.wait();

  const [nftID] = nftIDReceipt.events![0].args!;

  return nftID;
};
