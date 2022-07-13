import chai from "chai";
import { constants, Signer } from "ethers";
import { ethers } from "hardhat";
import chaiAsPromised from "chai-as-promised";
import { deployNFTContract, mintNFT } from "../scripts/utils";
import { DelegableToken } from "../typechain";

chai.use(chaiAsPromised);
const expect = chai.expect;

const NFT_PRICE = 10;

const getTimestamp = async (addMinutes: number = 0) => {
  const blockNum = await ethers.provider.getBlockNumber();
  const block = await ethers.provider.getBlock(blockNum);
  const timestamp = block.timestamp;
  return timestamp + addMinutes * 60;
};

describe("DelegableToken", function () {
  let owner: Signer, nftBuyer: Signer, user1: Signer, user2: Signer;

  let nftContractAsBuyer: DelegableToken;
  let nftContractAsOwner: DelegableToken;
  this.beforeEach(async () => {
    [owner, nftBuyer, user1, user2] = await ethers.getSigners();

    nftContractAsOwner = await deployNFTContract(owner);

    nftContractAsBuyer = nftContractAsOwner.connect(nftBuyer);
  });

  it("Should change the user of an nft", async function () {
    const tokenID = await mintNFT(nftContractAsBuyer, NFT_PRICE);

    const nftOwnerAddr = await nftBuyer.getAddress();
    const user1Addr = await user1.getAddress();

    const lendForTenMinutes = await getTimestamp(10);

    const tx = await nftContractAsBuyer.setUser(
      tokenID,
      user1Addr,
      lendForTenMinutes
    );
    await tx.wait();

    const resultUser = await nftContractAsBuyer.userOf(tokenID);
    const resultOwner = await nftContractAsBuyer.ownerOf(tokenID);

    expect(resultUser).equal(user1Addr);
    expect(resultOwner).equal(nftOwnerAddr);
  });

  it("Should allow change the user of an nft without wait the minimum time", async function () {
    const tokenID = await mintNFT(nftContractAsBuyer, NFT_PRICE);

    const nftOwnerAddr = await nftBuyer.getAddress();
    const user1Addr = await user1.getAddress();
    const user2Addr = await user2.getAddress();

    const lendForTenMinutes = await getTimestamp(10);

    const tx = await nftContractAsBuyer.setUser(
      tokenID,
      user1Addr,
      lendForTenMinutes
    );
    await tx.wait();

    const firstUser = await nftContractAsBuyer.userOf(tokenID);
    expect(firstUser, "user").equal(user1Addr);

    const tx2 = await nftContractAsBuyer.setUser(
      tokenID,
      user2Addr,
      lendForTenMinutes
    );
    await tx2.wait();

    const resultUser = await nftContractAsBuyer.userOf(tokenID);
    const resultOwner = await nftContractAsBuyer.ownerOf(tokenID);

    expect(resultUser, "user").equal(user2Addr);
    expect(resultUser, "user").not.equal(firstUser);
    expect(resultOwner, "owner").equal(nftOwnerAddr);
  });

  it("Should allow transfer a NFT with a user", async function () {
    const tokenID = await mintNFT(nftContractAsBuyer, NFT_PRICE);

    const nftOwnerAddr = await nftBuyer.getAddress();
    const user1Addr = await user1.getAddress();
    const user2Addr = await user2.getAddress();

    const lendForTenMinutes = await getTimestamp(10);

    const tx = await nftContractAsBuyer.setUser(
      tokenID,
      user1Addr,
      lendForTenMinutes
    );
    await tx.wait();

    const tx2 = await nftContractAsBuyer.transferFrom(
      nftOwnerAddr,
      user2Addr,
      tokenID
    );
    await tx2.wait();

    const resultUser = await nftContractAsBuyer.userOf(tokenID);
    const resultOwner = await nftContractAsBuyer.ownerOf(tokenID);

    expect(resultUser, "user").equal(constants.AddressZero);
    expect(resultOwner, "owner").equal(user2Addr);
  });

  it("Should get the price and the max supply for the given NFT contract", async function () {
    const price = await nftContractAsBuyer._price();
    const maxSupply = await nftContractAsBuyer._maxSupply();

    expect(price, "price").equal(10);
    expect(maxSupply, "max supply").equal(100);
  });

  it("Should be able to change the max supply for the given NFT contract", async function () {
    const initialMaxSupply = await nftContractAsOwner._maxSupply();

    await nftContractAsOwner.changeMaxSupply(200);

    const resultMaxSupply = await nftContractAsOwner._maxSupply();

    expect(initialMaxSupply, "initial max supply").equal(100);
    expect(resultMaxSupply, "result max supply").equal(200);
  });

  it("Should be able to change the price for the given NFT contract", async function () {
    const initialPrice = await nftContractAsOwner._price();

    await nftContractAsOwner.changePrice(20);

    const resultPrice = await nftContractAsOwner._price();

    expect(initialPrice, "initial price").equal(10);
    expect(resultPrice, "result price").equal(20);
  });

  it("Only owner can change the price and the max supply for the given NFT contract", async function () {
    const price1 = await nftContractAsBuyer._price();
    const maxSupply1 = await nftContractAsBuyer._maxSupply();

    await expect(
      nftContractAsBuyer.changeMaxSupply(300)
    ).to.eventually.rejectedWith("Ownable: caller is not the owner");

    await expect(
      nftContractAsBuyer.changePrice(300)
    ).to.eventually.rejectedWith("Ownable: caller is not the owner");

    const price2 = await nftContractAsBuyer._price();
    const maxSupply2 = await nftContractAsBuyer._maxSupply();

    expect(price1, "price").equal(10);
    expect(maxSupply1, "max supply").equal(100);
    expect(price2, "price").equal(10);
    expect(maxSupply2, "max supply").equal(100);
  });

  it("Get tokenURI by tokenId", async function () {
    const tokenID = await mintNFT(nftContractAsBuyer, NFT_PRICE);
    const tokenUri = await nftContractAsBuyer.tokenURI(tokenID);

    expect(tokenUri, "tokenUri").equal("ipfs://test/1");
  });

  it("Get current supply", async function () {
    const supply1 = await nftContractAsBuyer.currentSupply();
    await mintNFT(nftContractAsBuyer, NFT_PRICE);
    const supply2 = await nftContractAsBuyer.currentSupply();
    expect(supply2, "Current Supply Increment").equal(+supply1 + 1);
  });
});

describe("DelegableToken allowChangeUserBeforeUserExpired=False", function () {
  let owner: Signer, nftBuyer: Signer, user1: Signer, user2: Signer;

  let nftContractAsBuyer: DelegableToken;
  let nftContractAsOwner: DelegableToken;
  this.beforeEach(async () => {
    [owner, nftBuyer, user1, user2] = await ethers.getSigners();

    nftContractAsOwner = await deployNFTContract(owner, false, false);

    nftContractAsBuyer = nftContractAsOwner.connect(nftBuyer);
  });

  it("Allows to lend the token to Owner", async function () {
    const tokenID = await mintNFT(nftContractAsBuyer, NFT_PRICE);

    const nftOwnerAddr = await nftBuyer.getAddress();
    const user1Addr = await user1.getAddress();
    const user2Addr = await user2.getAddress();

    const lendForTenMinutes = await getTimestamp(10);

    const tx = await nftContractAsBuyer.setUser(
      tokenID,
      user1Addr,
      lendForTenMinutes
    );
    await tx.wait();

    const firstUser = await nftContractAsBuyer.userOf(tokenID);
    expect(firstUser, "user").equal(user1Addr);
    try {
      await nftContractAsBuyer.setUser(tokenID, user2Addr, lendForTenMinutes);
    } catch (err: any) {
      const isTokenNotAvailableError = err.reason
        .toString()
        .includes("token not available");
      if (!isTokenNotAvailableError) {
        throw err;
      }
    }

    const resultUser = await nftContractAsBuyer.userOf(tokenID);
    const resultOwner = await nftContractAsBuyer.ownerOf(tokenID);

    expect(resultUser, "user").not.equal(user2Addr);
    expect(resultUser, "user").equal(firstUser);
    expect(resultOwner, "owner").equal(nftOwnerAddr);
  });
});
