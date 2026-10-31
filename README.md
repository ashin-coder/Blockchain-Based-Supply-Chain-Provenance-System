# Blockchain-Based Supply Chain Provenance System

**CSE 540 · Group 9**

All contract interfaces and function signatures are defined. So far only participant onboarding, product registration and product lookup are implemented. The remaining functions are documented placeholders that will be built in later milestones.

## Description

When a product moves from a producer to a store shelf, it passes through several companies, and each keeps its own records. That makes it hard to prove where a product came from, spot counterfeits, or trace a bad batch quickly.

This project records a product's journey on the Ethereum blockchain. Each stakeholder records their own step, every step is signed and timestamped, and nobody can change the history afterwards. Consumers can check a product's history and status for free.

**Stakeholders and what they can do**

| Role | Can do |
|---|---|
| Admin | Onboard participants and give them a role |
| Producer | Register new products / batches |
| Distributor | Receive products and ship them on |
| Retailer | Receive products and record the final sale |
| Regulator | Certify products and issue recalls |
| Consumer | Read and verify (no account needed) |

**Product life cycle**

```
Created ──ship──▶ InTransit ──receive──▶ Received ──ship──▶ InTransit ...
                                             │
                                             └──deliver (retailer)──▶ Delivered

Any stage ──recall (regulator)──▶ Recalled
```

## Repository structure

```
contracts/
  interfaces/ISupplyChain.sol   Interface: data types, events and function signatures
  SupplyChain.sol               Draft contract: registration implemented, other functions stubbed
scripts/
  deploy.js                     Deploys the contract and registers demo participants
hardhat.config.js               Hardhat configuration (Solidity 0.8.24)
package.json                    Dependencies and npm scripts
```

## Dependencies

- [Node.js](https://nodejs.org/) 18 or newer
- [Hardhat](https://hardhat.org/) — local blockchain, compiling and deployment
- [OpenZeppelin Contracts](https://www.openzeppelin.com/contracts) — role-based access control
- [Ethers.js](https://docs.ethers.org/v6/) v6 — talking to the contract from scripts

All of these are installed by `npm install`.

## Setup

```bash
git clone <this-repo-url>
cd <repo-folder>
npm install
npx hardhat compile
```

## How to deploy and use (local)

1. Start a local blockchain (leave it running):

   ```bash
   npx hardhat node
   ```

2. In a second terminal, deploy the contract:

   ```bash
   npx hardhat run scripts/deploy.js --network localhost
   ```

   This prints the contract address and registers one demo producer, distributor, retailer and regulator using Hardhat's test accounts.

3. Interact with it using the Hardhat console:

   ```bash
   npx hardhat console --network localhost
   ```

   ```js
   const [admin, producer, distributor, retailer, regulator] = await ethers.getSigners();
   const sc = await ethers.getContractAt("SupplyChain", "<deployed-address>");

   await sc.connect(producer).registerProduct("Organic Coffee", "BATCH-001", "Colombia", ethers.ZeroHash);
   await sc.getProduct(1);
   await sc.getHistory(1);
   ```


## Contract overview

| Function | Who can call | What it does | Status |
|---|---|---|---|
| `registerParticipant(account, role, name)` | Admin | Onboards a stakeholder with one role | Implemented |
| `registerProduct(name, batchId, origin, metadataHash)` | Producer | Creates a product with a unique ID | Implemented |
| `getProduct(productId)` / `getHistory(productId)` | Anyone | Reads the product record and its journey | Implemented |
| `shipProduct(productId, to, location)` | Current owner | Starts a hand-over to a registered distributor or retailer | Planned |
| `receiveProduct(productId, location)` | Named recipient | Confirms arrival and becomes the new owner | Planned |
| `deliverProduct(productId, location)` | Retailer (owner) | Records the final sale to a consumer | Planned |
| `certifyProduct(productId, certificateHash)` | Regulator | Marks the product as certified | Planned |
| `recallProduct(productId, reason)` | Regulator | Recalls the product (final state) | Planned |
| `verifyProduct(productId)` | Anyone | Returns `true` if the product is certified and not recalled | Planned |

Planned functions already have their final signatures and comments describing their intended behaviour, for now they revert with `NotImplemented()`.

Each action will emit an event (`ProductRegistered`, `ShipmentStarted`, `OwnershipTransferred`, `ProductDelivered`, `ProductCertified`, `ProductRecalled`) to form a public audit trail.

## Planned next steps

- Implement custody transfer, delivery, certification, recall and verification
- Duplicate batch-ID protection
- Unit tests for every function and failure case
- Storage stage and IoT sensor readings (simulated oracle) with automatic alerts
- Off-chain documents in IPFS, linked by hash
- Web interface for each stakeholder and a consumer verification page
- Deployment to a public test network

## Team

| Name | Role |
|---|---|
| Vibhu Bhardwaj | Research & Smart Contract Development |
| Ashin Kunjumon | Research & Smart Contract Development |
| Riana Chatterjee | Frontend & User Interface |
| Vineeth Subramaniam Jayasankar | Frontend & User Interface |
| Shreyas Sreekumar | System Integration & Testing |
