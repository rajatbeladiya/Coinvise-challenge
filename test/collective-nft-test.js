const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("CollectiveNFT", function () {
    let deployer, alice, bob, charlie, david;

    before(async function () {
        [deployer, alice, bob, charlie, david] = await ethers.getSigners();
        users = [alice, bob, charlie];

        const CollectiveNFT = await ethers.getContractFactory("CollectiveNFT", deployer);
        const StakeToken = await ethers.getContractFactory("StakeToken", deployer);

        this.stakeToken = await StakeToken.deploy();
        this.collectiveNFT = await CollectiveNFT.deploy(this.stakeToken.address);

        for (let i = 0; i < 2; i++) {
            const amount = ethers.utils.parseEther('100000');
            await this.stakeToken.mint(users[i].address, amount);
            expect(
                await this.stakeToken.balanceOf(users[i].address)
            ).to.be.eq(amount);
        }
        await this.stakeToken.mint(charlie.address, ethers.utils.parseEther('1000'))
        expect(
            await this.stakeToken.balanceOf(charlie.address)
        ).to.be.eq(ethers.utils.parseEther('1000'));

    });

    it("Should buy nft by eth", async function () {
        const amount = ethers.utils.parseEther('1');
        await this.collectiveNFT.connect(charlie).buyNFT({ value: amount });

        expect(
            await this.collectiveNFT.balanceOf(charlie.address)
        ).to.be.eq(1);
        expect(
            await ethers.provider.getBalance(this.collectiveNFT.address)
        ).to.eq(amount);

    });

    it("Should distribute reward", async function () {
        // await ethers.provider.send("evm_increaseTime", [5 * 24 * 60 * 60]); // 5 days
        await ethers.provider.send("evm_increaseTime", [2 * 60 * 60]); // 2 minutes
        await this.collectiveNFT.connect(alice).distributeRewards();
        await this.collectiveNFT.connect(bob).distributeRewards();
    });

    it("Should not distribute reward if already retrived", async function () {
        await expect(this.collectiveNFT.connect(alice).distributeRewards())
        .to.be.revertedWith('already retrived reward');
    });

    it("Should not get reward if not enough stakeholder", async function () {
        await expect(this.collectiveNFT.connect(charlie).distributeRewards())
        .to.be.revertedWith('not eligible for reward');
    });

});
