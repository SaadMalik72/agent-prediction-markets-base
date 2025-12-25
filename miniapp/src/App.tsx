import { useState } from 'react';
import { WagmiProvider } from 'wagmi';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { config } from './wagmi.config';
import { ConnectWallet } from '@coinbase/onchainkit/wallet';
import { RegisterAgent } from './components/RegisterAgent';
import { AgentList } from './components/AgentList';
import { CreateMarket } from './components/CreateMarket';
import { MarketList } from './components/MarketList';
import './App.css';

const queryClient = new QueryClient();

type Tab = 'markets' | 'agents' | 'create-market' | 'register-agent';

function AppContent() {
  const [activeTab, setActiveTab] = useState<Tab>('markets');

  return (
    <div className="app">
      <header className="app-header">
        <div className="header-content">
          <div className="logo">
            <h1>🤖 Agent Prediction Markets</h1>
            <p>AI-Powered Predictions on Base</p>
          </div>
          <ConnectWallet />
        </div>
      </header>

      <nav className="app-nav">
        <button
          className={activeTab === 'markets' ? 'active' : ''}
          onClick={() => setActiveTab('markets')}
        >
          📊 Markets
        </button>
        <button
          className={activeTab === 'agents' ? 'active' : ''}
          onClick={() => setActiveTab('agents')}
        >
          🤖 Agents
        </button>
        <button
          className={activeTab === 'create-market' ? 'active' : ''}
          onClick={() => setActiveTab('create-market')}
        >
          ➕ Create Market
        </button>
        <button
          className={activeTab === 'register-agent' ? 'active' : ''}
          onClick={() => setActiveTab('register-agent')}
        >
          🆕 Register Agent
        </button>
      </nav>

      <main className="app-main">
        <div className="container">
          {activeTab === 'markets' && <MarketList />}
          {activeTab === 'agents' && <AgentList />}
          {activeTab === 'create-market' && <CreateMarket />}
          {activeTab === 'register-agent' && <RegisterAgent />}
        </div>
      </main>

      <footer className="app-footer">
        <p>Powered by Base • OnchainKit</p>
        <div className="contract-links">
          <a
            href="https://basescan.org/address/0xC7e730797e1E4Cd988596a6BA4484a93A1211070"
            target="_blank"
            rel="noopener noreferrer"
          >
            View Contracts
          </a>
        </div>
      </footer>
    </div>
  );
}

function App() {
  return (
    <WagmiProvider config={config}>
      <QueryClientProvider client={queryClient}>
        <AppContent />
      </QueryClientProvider>
    </WagmiProvider>
  );
}

export default App;
