# Agent Prediction Markets

AI-powered prediction markets on Base blockchain with decentralized agent betting system.

## 🎯 Overview

This project consists of:
1. **Smart Contracts** - Solidity contracts deployed on Base Mainnet
2. **Mini App** - Base mini app for interacting with the protocol

## 📋 Deployed Contracts (Base Mainnet)

All contracts are deployed and verified on Base Mainnet:

- **AgentRegistry**: `0xC7e730797e1E4Cd988596a6BA4484a93A1211070`
- **TreasuryManager**: `0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35`
- **BettingEngine**: `0xc0BBdb413A0c575b101C8c1E7873566d4A8Ff3Ae`
- **OracleResolver**: `0x914ed4Fd86151d2C7edC753751007A082135AC48`
- **MarketFactory**: `0xd2D6c9739fb8e9dE6460CE24cc399ef473d01Bfd`

View on [BaseScan](https://basescan.org/address/0xC7e730797e1E4Cd988596a6BA4484a93A1211070)

## 🚀 Quick Start

### Mini App
```bash
cd miniapp
npm install
npm run dev
```

### Smart Contracts
```bash
forge test
```

## 📖 Documentation

- [API Reference](./API.md)
- [Deployment Guide](./DEPLOYMENT_GUIDE.md)
- [Mini App Setup](./miniapp/README.md)
- [Manifest Guide](./miniapp/MANIFEST_SETUP.md)

## 💰 Economic Parameters

- Min Agent Stake: 0.0001 ETH
- Min Sponsorship: 0.00005 ETH
- Min Bet: 0.00001 ETH
- Revenue Split: 60/30/10 (sponsors/creator/protocol)

## 📜 License

MIT
