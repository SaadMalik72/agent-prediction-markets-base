# 🚀 Deploy to Base Mainnet NOW

## ⚠️ Current Status: NOT DEPLOYED

Your contracts are **NOT** on Base mainnet yet. The previous run was just a simulation.

## ✅ Steps to Deploy FOR REAL

### 1. Check Your .env File

Make sure your `PRIVATE_KEY` has the `0x` prefix:

```bash
cat .env
```

Should look like:
```
PRIVATE_KEY=0x1234567890abcdef...
BASESCAN_API_KEY=ABC123...
```

If your PRIVATE_KEY doesn't have `0x`, add it:
```bash
# Edit .env and add 0x at the beginning of your private key
nano .env  # or vim, code, etc.
```

### 2. Check Your Balance

You need at least **0.002 ETH** on Base mainnet (0.001 for protocol + gas fees):

```bash
# Load your .env
source .env

# Check balance
cast balance $(cast wallet address --private-key $PRIVATE_KEY) \
  --rpc-url https://mainnet.base.org
```

### 3. Run the Real Deployment

```bash
./scripts/deploy-real.sh
```

This script will:
- ✅ Verify you have enough ETH
- ✅ Show you what you're deploying
- ✅ Ask for confirmation
- ✅ Deploy all 5 contracts to Base mainnet
- ✅ Create `broadcast/` directory with transaction data
- ✅ Verify contracts on BaseScan
- ✅ Update deployment addresses

### 4. Verify Deployment

After deployment completes:

```bash
./scripts/check-deployment.sh
```

You should see:
```
✓ Contracts are LIVE on Base!
```

### 5. View on BaseScan

Once deployed, check your contracts:
```bash
# Will show real BaseScan links
cat deployments/base-mainnet.json
```

## 🔧 Troubleshooting

### "Insufficient balance"

Get ETH on Base mainnet:
- Bridge from Ethereum: https://bridge.base.org
- Buy on exchange and withdraw to Base
- Use cross-chain swap

### "PRIVATE_KEY not set"

```bash
echo "PRIVATE_KEY=0x..." >> .env
```

### "RPC error"

Try with explicit RPC:
```bash
forge script contracts/script/Deploy.s.sol \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY \
  --broadcast \
  --verify \
  -vvv
```

## 📊 Expected Output

When deployment is REAL, you'll see:

```
========================================
Deploy to Base Mainnet
========================================

Deployer Address: 0x8F058fE6b568D97f85d517Ac441b52B95722fDDe
Balance: 0.007352 ETH

⚠️  WARNING: You are about to deploy to BASE MAINNET
⚠️  This will use REAL ETH (approximately 0.001 ETH + gas)

Continue? (yes/no): yes

Starting deployment...

[⠊] Compiling...
[⠒] Sending transactions...
[⠢] Waiting for confirmations...

✓ AgentRegistry deployed at: 0x...
✓ TreasuryManager deployed at: 0x...
✓ BettingEngine deployed at: 0x...
✓ OracleResolver deployed at: 0x...
✓ MarketFactory deployed at: 0x...

========================================
Deployment Complete!
========================================

✓ Transactions broadcasted successfully!
```

## 🎯 What's Different from Simulation?

| Simulation | Real Deployment |
|------------|-----------------|
| No `broadcast/` folder | Creates `broadcast/` with TX data |
| No real transactions | Real transactions on blockchain |
| Shows "Traces:" | Shows "Sending transactions..." |
| Addresses are predictions | Addresses are real contracts |
| No BaseScan entries | Visible on BaseScan |
| No ETH spent | ~0.001 ETH + gas used |

## ⏱️ Time Required

- Deployment: ~2-3 minutes
- Transaction confirmations: ~30 seconds
- BaseScan indexing: 1-2 minutes
- Contract verification: 2-5 minutes

**Total: ~5-10 minutes**

## ✅ Checklist

Before running `./scripts/deploy-real.sh`:

- [ ] `.env` has `PRIVATE_KEY` with `0x` prefix
- [ ] `.env` has `BASESCAN_API_KEY` (for verification)
- [ ] You have **at least 0.002 ETH** on Base mainnet
- [ ] You've reviewed the contracts (all look good)
- [ ] You're ready to spend real ETH
- [ ] You understand this is MAINNET (not testnet)

## 🚀 Ready? Let's Deploy!

```bash
./scripts/deploy-real.sh
```

**Good luck!** 🍀

---

## 💡 After Deployment

Once your contracts are live:

1. **Test functionality:**
   ```bash
   ./scripts/quick-start.sh
   ```

2. **View stats:**
   ```bash
   ./scripts/protocol-stats.sh
   ```

3. **Create your first agent:**
   ```bash
   ./scripts/register-agent.sh "MyFirstAgent" "ipfs://..." "0.0001"
   ```

4. **Share your contract addresses** and let the prediction markets begin! 🎉
