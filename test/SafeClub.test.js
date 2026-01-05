const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("SafeClub", function () {
  let SafeClub, safeClub;
  let owner, member1, member2, outsider;

  beforeEach(async function () {
    [owner, member1, member2, outsider] = await ethers.getSigners();

    SafeClub = await ethers.getContractFactory("SafeClub");
    safeClub = await SafeClub.deploy();
    await safeClub.waitForDeployment();

    // Add members
    await safeClub.addMember(member1.address);
    await safeClub.addMember(member2.address);

    // Fund treasury
    await owner.sendTransaction({
      to: await safeClub.getAddress(),
      value: ethers.parseEther("5"),
    });
  });

  it("Owner should be a member", async function () {
    expect(await safeClub.isMember(owner.address)).to.equal(true);
  });

  it("Should create a proposal", async function () {
    await safeClub
      .connect(member1)
      .createProposal(
        ethers.parseEther("1"),
        member2.address,
        "Buy equipment",
        3600
      );

    const proposal = await safeClub.proposals(0);
    expect(proposal.amount).to.equal(ethers.parseEther("1"));
  });

  it("Should allow members to vote", async function () {
    await safeClub
      .connect(member1)
      .createProposal(
        ethers.parseEther("1"),
        member2.address,
        "Event funding",
        3600
      );

    await safeClub.connect(member1).voteOnProposal(0, true);
    await safeClub.connect(member2).voteOnProposal(0, true);

    const proposal = await safeClub.proposals(0);
    expect(proposal.votesFor).to.equal(2);
  });

  it("Should NOT allow double voting", async function () {
    await safeClub
      .connect(member1)
      .createProposal(
        ethers.parseEther("1"),
        member2.address,
        "Test double vote",
        3600
      );

    await safeClub.connect(member1).voteOnProposal(0, true);

    await expect(
      safeClub.connect(member1).voteOnProposal(0, true)
    ).to.be.revertedWith("Already voted");
  });

  it("Should execute accepted proposal", async function () {
    await safeClub
      .connect(member1)
      .createProposal(
        ethers.parseEther("1"),
        member2.address,
        "Execution test",
        60
      );

    await safeClub.connect(member1).voteOnProposal(0, true);
    await safeClub.connect(member2).voteOnProposal(0, true);

    // Wait for deadline
    await ethers.provider.send("evm_increaseTime", [65]);
    await ethers.provider.send("evm_mine");

    await expect(() => safeClub.executeProposal(0)).to.changeEtherBalances(
      [safeClub, member2],
      [ethers.parseEther("-1"), ethers.parseEther("1")]
    );
  });
});
