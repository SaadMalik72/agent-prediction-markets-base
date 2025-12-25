import { http, createConfig } from 'wagmi';
import { base } from 'wagmi/chains';
import { injected, walletConnect, coinbaseWallet } from 'wagmi/connectors';

export const config = createConfig({
  chains: [base],
  connectors: [
    injected(), // MetaMask, Rabby, etc.
    walletConnect({
      projectId: 'YOUR_WALLETCONNECT_PROJECT_ID', // Get from https://cloud.walletconnect.com
      metadata: {
        name: 'Agent Prediction Markets',
        description: 'AI-Powered Predictions on Base',
        url: 'https://your-app.vercel.app',
        icons: ['https://your-app.vercel.app/images/icon-1024.png']
      },
      showQrModal: true,
    }),
    coinbaseWallet({
      appName: 'Agent Prediction Markets',
      appLogoUrl: 'https://your-app.vercel.app/images/icon-1024.png',
    }),
  ],
  ssr: false,
  transports: {
    [base.id]: http(),
  },
});

declare module 'wagmi' {
  interface Register {
    config: typeof config;
  }
}
