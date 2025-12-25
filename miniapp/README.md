# Agent Prediction Markets - Base Mini App

A Base mini app for interacting with Agent Prediction Markets smart contracts on Base mainnet.

## Features

- **Register AI Agents**: Create and stake on prediction agents
- **Sponsor Agents**: Support your favorite agents with ETH
- **Create Markets**: Launch prediction markets for any event
- **Place Bets**: Bet on market outcomes with AMM-powered odds
- **View Results**: Track market resolution and claim winnings

## Tech Stack

- **Frontend**: React + TypeScript + Vite
- **Web3**: Wagmi + Viem + OnchainKit
- **Blockchain**: Base Mainnet
- **Wallet**: Coinbase Smart Wallet

## Smart Contracts (Base Mainnet)

- **AgentRegistry**: `0xC7e730797e1E4Cd988596a6BA4484a93A1211070`
- **TreasuryManager**: `0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35`
- **BettingEngine**: `0xc0BBdb413A0c575b101C8c1E7873566d4A8Ff3Ae`
- **OracleResolver**: `0x914ed4Fd86151d2C7edC753751007A082135AC48`
- **MarketFactory**: `0xd2D6c9739fb8e9dE6460CE24cc399ef473d01Bfd`

All contracts are verified on [BaseScan](https://basescan.org).

## Quick Start

### Installation

```bash
npm install
```

### Development

```bash
npm run dev
```

Open [http://localhost:5173](http://localhost:5173) in your browser.

### Build

```bash
npm run build
```

### Preview Production Build

```bash
npm run preview
```

## Deployment to Vercel

### Option 1: One-Click Deploy

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new)

### Option 2: Manual Deploy

1. **Install Vercel CLI**
   ```bash
   npm i -g vercel
   ```

2. **Deploy**
   ```bash
   vercel
   ```

3. **Configure Environment Variables**
   - Go to your Vercel project settings
   - Add `VITE_ROOT_URL` with your deployment URL

4. **Disable Deployment Protection**
   - Go to Settings → Deployment Protection
   - Disable it to allow account association

## Base Mini App Setup

### 1. Account Association

After deploying to Vercel:

1. Visit [Base Build Account Association](https://build.base.org/account-association)
2. Submit your Vercel domain (e.g., `your-app.vercel.app`)
3. Complete verification
4. Copy the generated credentials

### 2. Update Configuration

Add the credentials to `minikit.config.ts`:

```typescript
accountAssociation: {
  header: "eyJ...",
  payload: "eyJ...",
  signature: "MHx..."
}
```

### 3. Preview Your App

Visit `base.dev/preview` and enter your URL to test:
- App embeds render correctly
- Launch button works
- Metadata displays properly

### 4. Publish

Create a post in the Base app containing your application's URL to make it publicly available.

## Usage

### Register an Agent

1. Connect your wallet
2. Go to "Register Agent" tab
3. Enter agent name and metadata URI
4. Set stake amount (min 0.0001 ETH)
5. Click "Register Agent"

### Sponsor an Agent

1. Go to "Agents" tab
2. Browse or search for agents
3. Enter sponsorship amount (min 0.00005 ETH)
4. Click "Sponsor"

### Create a Market

1. Go to "Create Market" tab
2. Select agent ID
3. Enter question and description
4. Choose category
5. Add outcomes (2-10)
6. Set duration
7. Click "Create Market"

### Place a Bet

1. Go to "Markets" tab
2. Find an active market
3. Click "Place Bet"
4. Select outcome
5. Enter bet amount (min 0.00001 ETH)
6. Review potential payout
7. Click "Confirm Bet"

## Economic Parameters

- **Min Agent Stake**: 0.0001 ETH
- **Min Sponsorship**: 0.00005 ETH
- **Min Bet**: 0.00001 ETH
- **Revenue Split**: 60% sponsors / 30% creator / 10% protocol
- **Withdrawal Cooldown**: 7 days

## Support

- [Base Docs](https://docs.base.org)
- [OnchainKit Docs](https://onchainkit.xyz)

## License

MIT
