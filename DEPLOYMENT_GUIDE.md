# Deployment Guide - Agent Prediction Markets

Complete guide for deploying to Base Sepolia (testnet) and Base Mainnet.

## Prerequisites

1. **Foundry Installed**
```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

2. **ETH for Gas Fees**
- Base Sepolia: Get testnet ETH from [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-ethereum-goerli-faucet)
- Base Mainnet: Need real ETH (minimum 0.001 ETH + gas fees ~0.01 ETH)

3. **BaseScan API Key**
- Get from [BaseScan](https://basescan.org/apis)
- Needed for contract verification

## Environment Setup

### 1. Create .env file

```bash
cp .env.example .env
```

### 2. Edit .env with your values

```env
PRIVATE_KEY=your_private_key_here
BASESCAN_API_KEY=your_basescan_api_key_here
```

⚠️ **NEVER commit your .env file!** It's in .gitignore for safety.

### 3. Load environment variables

```bash
source .env
```

## Pre-Deployment Checklist

- [ ] Foundry installed and updated
- [ ] .env file configured with private key and API key
- [ ] Sufficient ETH in deployer wallet (0.001 + gas fees)
- [ ] Contracts compiled successfully (`forge build`)
- [ ] All tests passing (`forge test`)
- [ ] BaseScan API key valid

## Deployment to Base Sepolia (Testnet)

### Step 1: Get Testnet ETH

Visit: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet

You need at least 0.01 ETH for deployment + gas.

### Step 2: Verify Configuration

```bash
# Check your balance
cast balance $YOUR_ADDRESS --rpc-url base_sepolia

# Should show > 0.01 ETH
```

### Step 3: Deploy

```bash
forge script contracts/script/DeploySepolia.s.sol \
  --rpc-url base_sepolia \
  --broadcast \
  --verify \
  --etherscan-api-key $BASESCAN_API_KEY \
  -vvvv
```

### Step 4: Save Deployment Addresses

The script will output contract addresses. Save them:

```
AgentRegistry: 0x...
TreasuryManager: 0x...
BettingEngine: 0x...
OracleResolver: 0x...
MarketFactory: 0x...
```

### Step 5: Verify Deployment

Check contracts on BaseScan Sepolia:
- https://sepolia.basescan.org/address/YOUR_CONTRACT_ADDRESS

## Deployment to Base Mainnet

⚠️ **WARNING**: Mainnet deployment uses real ETH. Double-check everything!

### Step 1: Final Safety Checks

```bash
# Run all tests
forge test -vvv

# Check contract sizes
forge build --sizes

# Verify you have enough ETH
cast balance $YOUR_ADDRESS --rpc-url base_mainnet

# Should show > 0.011 ETH (0.001 for protocol + ~0.01 for gas)
```

### Step 2: Review Economic Parameters

Open `contracts/src/TreasuryManager.sol` and verify:

```solidity
INITIAL_PROTOCOL_LIQUIDITY = 0.001 ether  ✓
MIN_AGENT_STAKE = 0.0001 ether            ✓
MIN_SPONSORSHIP = 0.00005 ether           ✓
```

### Step 3: Deploy to Mainnet

```bash
# This will deploy with a 5-second safety delay
make deploy-mainnet
```

Or manually:

```bash
forge script contracts/script/Deploy.s.sol \
  --rpc-url base_mainnet \
  --broadcast \
  --verify \
  --etherscan-api-key $BASESCAN_API_KEY \
  -vvvv
```

### Step 4: Verify Contracts

Check on BaseScan:
- https://basescan.org/address/YOUR_CONTRACT_ADDRESS

### Step 5: Initial Configuration

After deployment, you may want to:

1. **Add Trusted Oracles**
```bash
cast send $ORACLE_RESOLVER_ADDRESS \
  "addTrustedOracle(address)" \
  $ORACLE_ADDRESS \
  --rpc-url base_mainnet \
  --private-key $PRIVATE_KEY
```

2. **Verify Protocol Treasury**
```bash
cast call $TREASURY_MANAGER_ADDRESS \
  "getProtocolStats()(uint256,uint256,uint256)" \
  --rpc-url base_mainnet

# Should return (1000000000000000, 0, 0)
# Which is 0.001 ETH in wei
```

## Post-Deployment Tasks

### 1. Save Deployment Info

Create `deployments/base-mainnet.json`:

```json
{
  "network": "base-mainnet",
  "chainId": 8453,
  "deployer": "0x...",
  "timestamp": "2025-01-01T00:00:00Z",
  "contracts": {
    "AgentRegistry": "0x...",
    "TreasuryManager": "0x...",
    "BettingEngine": "0x...",
    "OracleResolver": "0x...",
    "MarketFactory": "0x..."
  }
}
```

### 2. Verify All Contracts

Each contract should be verified on BaseScan. If auto-verification failed:

```bash
forge verify-contract \
  --chain-id 8453 \
  --constructor-args $(cast abi-encode "constructor()") \
  $CONTRACT_ADDRESS \
  contracts/src/ContractName.sol:ContractName \
  --etherscan-api-key $BASESCAN_API_KEY
```

### 3. Test Basic Functions

```bash
# Test agent registration (from another account)
cast send $AGENT_REGISTRY_ADDRESS \
  "registerAgent(string,string)" \
  "TestBot" \
  "ipfs://test" \
  --value 0.0001ether \
  --rpc-url base_mainnet \
  --private-key $TEST_PRIVATE_KEY
```

### 4. Monitor Events

```bash
# Watch for AgentRegistered events
cast logs \
  --address $AGENT_REGISTRY_ADDRESS \
  --from-block latest \
  --rpc-url base_mainnet
```

## Deployment Costs

Expected gas costs on Base:

| Operation | Estimated Gas | Cost @ 0.5 gwei |
|-----------|---------------|-----------------|
| AgentRegistry | ~2,000,000 | ~0.001 ETH |
| TreasuryManager | ~1,500,000 | ~0.00075 ETH |
| BettingEngine | ~2,500,000 | ~0.00125 ETH |
| OracleResolver | ~1,800,000 | ~0.0009 ETH |
| MarketFactory | ~2,200,000 | ~0.0011 ETH |
| **Total** | **~10,000,000** | **~0.005 ETH** |

Plus **0.001 ETH** for protocol liquidity = **~0.006 ETH total**

*Actual costs may vary based on network congestion*

## Troubleshooting

### "Insufficient balance" Error

```bash
# Check your balance
cast balance $YOUR_ADDRESS --rpc-url base_mainnet

# You need at least 0.011 ETH
```

### "Nonce too low" Error

```bash
# Check current nonce
cast nonce $YOUR_ADDRESS --rpc-url base_mainnet

# Use --nonce flag if needed
```

### Verification Failed

```bash
# Wait a few minutes, then retry
forge verify-contract \
  $CONTRACT_ADDRESS \
  contracts/src/ContractName.sol:ContractName \
  --etherscan-api-key $BASESCAN_API_KEY \
  --chain-id 8453
```

### "Contract already deployed"

If deployment fails partway, you may need to:
1. Use a new deployer address, OR
2. Manually deploy remaining contracts, OR
3. Adjust nonce in deployment script

## Contract Addresses (After Deployment)

Update this section after deployment:

### Base Mainnet
```
AgentRegistry:     0x...
TreasuryManager:   0x...
BettingEngine:     0x...
OracleResolver:    0x...
MarketFactory:     0x...
```

### Base Sepolia
```
AgentRegistry:     0x...
TreasuryManager:   0x...
BettingEngine:     0x...
OracleResolver:    0x...
MarketFactory:     0x...
```

## Security Considerations

### Before Mainnet Launch

- [ ] Complete security audit
- [ ] Set up monitoring (Tenderly, Defender)
- [ ] Prepare incident response plan
- [ ] Set up multi-sig for owner functions
- [ ] Configure time-locks for critical operations
- [ ] Test with small amounts first
- [ ] Have emergency pause plan ready

### After Launch

- [ ] Monitor contract activity
- [ ] Watch for unusual transactions
- [ ] Keep owner keys secure (hardware wallet)
- [ ] Regular security reviews
- [ ] Community bug bounty program

## Integration Guide

After deployment, integrate with frontend:

```typescript
import { createPublicClient, createWalletClient, http } from 'viem';
import { base } from 'viem/chains';

const publicClient = createPublicClient({
  chain: base,
  transport: http()
});

const agentRegistry = {
  address: '0x...', // Your deployed address
  abi: agentRegistryABI
};

// Register an agent
const { hash } = await walletClient.writeContract({
  ...agentRegistry,
  functionName: 'registerAgent',
  args: ['BotName', 'ipfs://...'],
  value: parseEther('0.0001')
});
```

## Useful Commands

```bash
# Check contract balance
cast balance $CONTRACT_ADDRESS --rpc-url base_mainnet

# Call view function
cast call $CONTRACT_ADDRESS "functionName()(returnType)" --rpc-url base_mainnet

# Send transaction
cast send $CONTRACT_ADDRESS "functionName(type)" argument --private-key $PRIVATE_KEY --rpc-url base_mainnet

# Get transaction receipt
cast receipt $TX_HASH --rpc-url base_mainnet

# Decode transaction input
cast 4byte-decode $INPUT_DATA
```

## Support

- Issues: GitHub Issues
- Documentation: README.md
- API Reference: API.md
- Security: SECURITY.md

---

**Good luck with your deployment! 🚀**
