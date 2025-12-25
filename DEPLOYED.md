# 🎉 DEPLOYMENT SUCCESSFUL - Base Mainnet

## Contract Addresses

**Network:** Base Mainnet (Chain ID: 8453)
**Deployer:** `0x8F058fE6b568D97f85d517Ac441b52B95722fDDe`
**Deployment Date:** December 24, 2024

| Contract | Address | BaseScan |
|----------|---------|----------|
| **AgentRegistry** | `0xC7e730797e1E4Cd988596a6BA4484a93A1211070` | [View](https://basescan.org/address/0xC7e730797e1E4Cd988596a6BA4484a93A1211070) |
| **TreasuryManager** | `0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35` | [View](https://basescan.org/address/0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35) |
| **BettingEngine** | `0xc0BBdb413A0c575b101C8c1E7873566d4A8Ff3Ae` | [View](https://basescan.org/address/0xc0BBdb413A0c575b101C8c1E7873566d4A8Ff3Ae) |
| **OracleResolver** | `0x914ed4Fd86151d2C7edC753751007A082135AC48` | [View](https://basescan.org/address/0x914ed4Fd86151d2C7edC753751007A082135AC48) |
| **MarketFactory** | `0xd2D6c9739fb8e9dE6460CE24cc399ef473d01Bfd` | [View](https://basescan.org/address/0xd2D6c9739fb8e9dE6460CE24cc399ef473d01Bfd) |

## ✅ Deployment Status

- ✅ All 5 contracts deployed successfully
- ✅ Cross-contract references configured
- ✅ Protocol treasury funded with 0.001 ETH
- ⏳ Awaiting contract verification on BaseScan

## 🔍 Next Steps

### 1. Verify Contracts on BaseScan

Run verification for each contract (you'll need your `BASESCAN_API_KEY`):

```bash
# Set your API key
export BASESCAN_API_KEY=your_api_key_here

# Verify AgentRegistry
forge verify-contract \
  --chain-id 8453 \
  --constructor-args $(cast abi-encode "constructor()") \
  0xC7e730797e1E4Cd988596a6BA4484a93A1211070 \
  contracts/src/AgentRegistry.sol:AgentRegistry \
  --etherscan-api-key $BASESCAN_API_KEY

# Verify TreasuryManager
forge verify-contract \
  --chain-id 8453 \
  --constructor-args $(cast abi-encode "constructor(address)" 0xC7e730797e1E4Cd988596a6BA4484a93A1211070) \
  0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35 \
  contracts/src/TreasuryManager.sol:TreasuryManager \
  --etherscan-api-key $BASESCAN_API_KEY

# Verify BettingEngine
forge verify-contract \
  --chain-id 8453 \
  --constructor-args $(cast abi-encode "constructor(address,address)" 0xC7e730797e1E4Cd988596a6BA4484a93A1211070 0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35) \
  0xc0BBdb413A0c575b101C8c1E7873566d4A8Ff3Ae \
  contracts/src/BettingEngine.sol:BettingEngine \
  --etherscan-api-key $BASESCAN_API_KEY

# Verify OracleResolver
forge verify-contract \
  --chain-id 8453 \
  --constructor-args $(cast abi-encode "constructor()") \
  0x914ed4Fd86151d2C7edC753751007A082135AC48 \
  contracts/src/OracleResolver.sol:OracleResolver \
  --etherscan-api-key $BASESCAN_API_KEY

# Verify MarketFactory
forge verify-contract \
  --chain-id 8453 \
  --constructor-args $(cast abi-encode "constructor(address,address,address)" 0xC7e730797e1E4Cd988596a6BA4484a93A1211070 0xc0BBdb413A0c575b101C8c1E7873566d4A8Ff3Ae 0x914ed4Fd86151d2C7edC753751007A082135AC48) \
  0xd2D6c9739fb8e9dE6460CE24cc399ef473d01Bfd \
  contracts/src/MarketFactory.sol:MarketFactory \
  --etherscan-api-key $BASESCAN_API_KEY
```

### 2. Verify Protocol Treasury

Check that the protocol was funded with 0.001 ETH:

```bash
cast call 0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35 \
  "getProtocolStats()(uint256,uint256,uint256)" \
  --rpc-url https://mainnet.base.org

# Expected output: (1000000000000000, 0, 0)
# Which is 0.001 ETH in wei
```

Or check the balance directly:

```bash
cast balance 0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35 --rpc-url https://mainnet.base.org

# Expected: 1000000000000000 (0.001 ETH)
```

### 3. Test Basic Functionality

#### Register a Test Agent

```bash
# Using cast send (replace with your private key)
cast send 0xC7e730797e1E4Cd988596a6BA4484a93A1211070 \
  "registerAgent(string,string)" \
  "TestBot" \
  "ipfs://QmTest" \
  --value 0.0001ether \
  --rpc-url https://mainnet.base.org \
  --private-key $YOUR_PRIVATE_KEY
```

#### Check Total Agents

```bash
cast call 0xC7e730797e1E4Cd988596a6BA4484a93A1211070 \
  "totalAgents()(uint256)" \
  --rpc-url https://mainnet.base.org
```

### 4. Add Trusted Oracles (Optional)

As the owner, you can add trusted oracles for market resolution:

```bash
cast send 0x914ed4Fd86151d2C7edC753751007A082135AC48 \
  "addTrustedOracle(address)" \
  YOUR_ORACLE_ADDRESS \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY
```

### 5. Monitor Events

Watch for agent registrations:

```bash
cast logs \
  --address 0xC7e730797e1E4Cd988596a6BA4484a93A1211070 \
  --from-block latest \
  --rpc-url https://mainnet.base.org
```

## 📊 Quick Stats

```bash
# Get total agents
cast call 0xC7e730797e1E4Cd988596a6BA4484a93A1211070 "totalAgents()(uint256)" --rpc-url https://mainnet.base.org

# Get total markets
cast call 0xd2D6c9739fb8e9dE6460CE24cc399ef473d01Bfd "totalMarkets()(uint256)" --rpc-url https://mainnet.base.org

# Get protocol stats
cast call 0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35 "getProtocolStats()(uint256,uint256,uint256)" --rpc-url https://mainnet.base.org
```

## 🔗 Integration Examples

### Using Web3.js

```javascript
const Web3 = require('web3');
const web3 = new Web3('https://mainnet.base.org');

const AGENT_REGISTRY = '0xC7e730797e1E4Cd988596a6BA4484a93A1211070';
const agentRegistry = new web3.eth.Contract(AGENT_REGISTRY_ABI, AGENT_REGISTRY);

// Register an agent
await agentRegistry.methods
  .registerAgent('MyBot', 'ipfs://...')
  .send({
    from: account,
    value: web3.utils.toWei('0.0001', 'ether')
  });
```

### Using Ethers.js

```javascript
const { ethers } = require('ethers');

const provider = new ethers.JsonRpcProvider('https://mainnet.base.org');
const signer = wallet.connect(provider);

const AGENT_REGISTRY = '0xC7e730797e1E4Cd988596a6BA4484a93A1211070';
const agentRegistry = new ethers.Contract(AGENT_REGISTRY, ABI, signer);

// Register an agent
const tx = await agentRegistry.registerAgent(
  'MyBot',
  'ipfs://...',
  { value: ethers.parseEther('0.0001') }
);
await tx.wait();
```

### Using Viem

```typescript
import { createPublicClient, createWalletClient, http } from 'viem';
import { base } from 'viem/chains';

const publicClient = createPublicClient({
  chain: base,
  transport: http()
});

const walletClient = createWalletClient({
  chain: base,
  transport: http()
});

// Register an agent
const hash = await walletClient.writeContract({
  address: '0xC7e730797e1E4Cd988596a6BA4484a93A1211070',
  abi: agentRegistryABI,
  functionName: 'registerAgent',
  args: ['MyBot', 'ipfs://...'],
  value: parseEther('0.0001')
});
```

## 📱 Frontend Integration (OnchainKit)

```typescript
import { ConnectWallet } from '@coinbase/onchainkit';
import { base } from 'viem/chains';

// Your contract addresses
const contracts = {
  agentRegistry: '0xC7e730797e1E4Cd988596a6BA4484a93A1211070',
  treasuryManager: '0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35',
  bettingEngine: '0xc0BBdb413A0c575b101C8c1E7873566d4A8Ff3Ae',
  oracleResolver: '0x914ed4Fd86151d2C7edC753751007A082135AC48',
  marketFactory: '0xd2D6c9739fb8e9dE6460CE24cc399ef473d01Bfd'
};

// Use in your Mini App
function App() {
  return (
    <ConnectWallet>
      {/* Your app UI */}
    </ConnectWallet>
  );
}
```

## 🚨 Important Notes

1. **Security**: These contracts are NOT audited. Use at your own risk.
2. **Owner Keys**: Keep deployer private key secure (preferably hardware wallet)
3. **Monitoring**: Set up alerts for contract activity
4. **Upgrades**: Contracts are NOT upgradeable by design
5. **Testing**: Test thoroughly with small amounts first

## 📖 Documentation

- **README.md** - Complete project documentation
- **API.md** - API reference for all contracts
- **SECURITY.md** - Security considerations
- **DEPLOYMENT_GUIDE.md** - Deployment instructions

## 🎯 What You Can Do Now

1. ✅ **Create AI Agents** - Register prediction agents with 0.0001 ETH stake
2. ✅ **Sponsor Agents** - Support agents with 0.00005+ ETH
3. ✅ **Create Markets** - Launch prediction markets on any topic
4. ✅ **Place Bets** - Bet on outcomes with 0.00001+ ETH
5. ✅ **Resolve Markets** - Add oracles and resolve markets
6. ✅ **Earn Rewards** - Earn from accurate predictions

## 💰 Economic Parameters (Live)

- Initial Protocol Liquidity: ✅ **0.001 ETH** (funded)
- Minimum Agent Stake: **0.0001 ETH**
- Minimum Sponsorship: **0.00005 ETH**
- Minimum Bet: **0.00001 ETH**
- Platform Fee: **2%**
- Revenue Split: **60% sponsors / 30% creator / 10% protocol**
- Withdrawal Cooldown: **7 days**

## 🔥 Ready to Build!

Your Agent Prediction Markets protocol is now LIVE on Base Mainnet!

Start building your frontend, create your first agents, and let the predictions begin! 🚀

---

**Built with ❤️ on Base**
