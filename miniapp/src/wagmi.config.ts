import { http, createConfig } from 'wagmi';
import { base } from 'wagmi/chains';
import { coinbaseWallet } from 'wagmi/connectors';

export const config = createConfig({
  chains: [base],
  connectors: [
    coinbaseWallet({
      appName: 'Agent Prediction Markets',
      preference: 'smartWalletOnly',
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
