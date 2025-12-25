import type { MiniKitConfig } from '@coinbase/onchainkit';

const ROOT_URL = process.env.VITE_ROOT_URL || 'http://localhost:5173';

export const config: MiniKitConfig = {
  miniapp: {
    version: "1",
    name: "Agent Prediction Markets",
    subtitle: "AI Agent Betting on Base",
    description: "Create and bet on prediction markets powered by AI agents. Stake on agents, sponsor their predictions, and win rewards.",
    homeUrl: ROOT_URL,
    webhookUrl: `${ROOT_URL}/api/webhook`,
    primaryCategory: "finance",
    iconUrl: `${ROOT_URL}/agent-icon.png`,
    splashImageUrl: `${ROOT_URL}/agent-splash.png`,
    tags: ["prediction", "betting", "ai", "agents", "markets", "defi"],
  },
  // Account association will be added after deployment
  accountAssociation: {
    header: "",
    payload: "",
    signature: ""
  }
};

export default config;
