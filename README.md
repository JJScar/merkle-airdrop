# MerkleAidrop

This is a project that was made with the intent to learn more about merkle trees, signatures and airdrops. It follows the 3 hour course that can be found in this [link](https://www.youtube.com/watch?v=jGC3pGCfYQE&ab_channel=CyfrinAudits).

- [Merkle Airdrop](#merkle-airdrop)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Pre-deploy: Generate merkle proofs](#pre-deploy-generate-merkle-proofs)
- [Deploy](#deploy)
  - [Deploy to Anvil](#deploy-to-anvil)
- [Interacting - Local anvil network](#interacting---local-anvil-network)
  - [Setup anvil and deploy contracts](#setup-anvil-and-deploy-contracts)
  - [Sign your airdrop claim](#sign-your-airdrop-claim)
  - [Claim your airdrop](#claim-your-airdrop)
  - [Check claim amount](#check-claim-amount)
- [Testing](#testing)
  - [Test Coverage](#test-coverage)
- [Estimate gas](#estimate-gas)
- [Formatting](#formatting)
- [Thank you!](#thank-you)

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

To get started, we are assuming you're working with vanilla `foundry` and not `foundry-zksync` to start. 


## Quickstart

```bash
git clone https://github.com/ciara/merkle-airdrop
cd merkle-airdrop
make # or forge install && forge build if you don't have make 
```

# Usage

## Pre-deploy: Generate merkle proofs

We are going to generate merkle proofs for an array of addresses to airdrop funds to. If you'd like to work with the default addresses and proofs already created in this repo, skip to [deploy](#deploy)

If you'd like to work with a different array of addresses (the `whitelist` list in `GenerateInput.s.sol`), you will need to follow the following:

First, the array of addresses to airdrop to needs to be updated in `GenerateInput.s.sol. To generate the input file and then the merkle root and proofs, run the following:

Using make:

```bash
make merkle
```

Or using the commands directly:

```bash
forge script script/GenerateInput.s.sol:GenerateInput && forge script script/MakeMerkle.s.sol:MakeMerkle
```

Then, retrieve the `root` (there may be more than 1, but they will all be the same) from `script/target/output.json` and paste it in the `Makefile` as `ROOT` (for zkSync deployments) and update `s_merkleRoot` in `DeployMerkleAirdrop.s.sol` for Ethereum/Anvil deployments.

# Deploy 

## Deploy to Anvil

```bash
# Optional, ensure you're on vanilla foundry
foundryup
# Run a local anvil node
make anvil
# Then, in a second terminal
make deploy
```

## Testing

```bash
foundryup
forge test
```

### Test Coverage

```bash
forge coverage
```

## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot`


# Formatting


To run code formatting:
```
forge fmt
```

# Thank you!
