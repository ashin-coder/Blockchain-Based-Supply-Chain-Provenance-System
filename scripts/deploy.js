/**
 * Deploys the draft SupplyChain contract and registers a few demo participants.
 *
 *   npx hardhat node                                         (terminal 1)
 *   npx hardhat run scripts/deploy.js --network localhost    (terminal 2)
 */
const { ethers } = require("hardhat");

async function main() {
  const [admin, producer, distributor, retailer, regulator] = await ethers.getSigners();

  // 1. Deploy (the deployer becomes the admin)
  const SupplyChain = await ethers.getContractFactory("SupplyChain");
  const sc = await SupplyChain.deploy();
  await sc.waitForDeployment();
  console.log("SupplyChain deployed to:", await sc.getAddress());

  // 2. Onboard one participant per role using the local test accounts
  const participants = [
    [producer, await sc.PRODUCER_ROLE(), "Demo Producer"],
    [distributor, await sc.DISTRIBUTOR_ROLE(), "Demo Distributor"],
    [retailer, await sc.RETAILER_ROLE(), "Demo Retailer"],
    [regulator, await sc.REGULATOR_ROLE(), "Demo Regulator"],
  ];
  for (const [signer, role, name] of participants) {
    await (await sc.registerParticipant(signer.address, role, name)).wait();
    console.log(`  ${name.padEnd(17)} ${signer.address}`);
  }
}

main().catch((err) => {
  console.error(err);
  process.exitCode = 1;
});
