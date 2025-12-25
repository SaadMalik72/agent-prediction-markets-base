import { useState } from 'react';
import { useTotalMarkets, useMarket } from '../hooks/useMarkets';
import { PlaceBet } from './PlaceBet';
import { formatEther } from 'viem';

const CATEGORIES = ['Crypto', 'Sports', 'Politics', 'Weather', 'Technology', 'Other'];

function MarketCard({ marketId }: { marketId: number }) {
  const { market, isLoading } = useMarket(marketId);
  const [showBetting, setShowBetting] = useState(false);

  if (isLoading || !market) {
    return <div className="market-card loading">Loading market...</div>;
  }

  const deadline = new Date(Number(market.deadline) * 1000);
  const isExpired = deadline < new Date();
  const daysRemaining = Math.ceil((deadline.getTime() - Date.now()) / (1000 * 60 * 60 * 24));

  return (
    <div className="market-card">
      <div className="market-header">
        <div className="market-badge">{CATEGORIES[Number(market.category)] || 'Other'}</div>
        <div className={`market-status ${market.isResolved ? 'resolved' : isExpired ? 'expired' : 'active'}`}>
          {market.isResolved ? '✓ Resolved' : isExpired ? '⏰ Expired' : `🔥 ${daysRemaining}d left`}
        </div>
      </div>

      <h3 className="market-question">{market.question}</h3>
      <p className="market-description">{market.description}</p>

      <div className="market-stats">
        <div className="stat">
          <span className="label">Agent ID</span>
          <span className="value">#{market.agentId.toString()}</span>
        </div>
        <div className="stat">
          <span className="label">Total Volume</span>
          <span className="value">{formatEther(market.totalVolume)} ETH</span>
        </div>
        <div className="stat">
          <span className="label">Outcomes</span>
          <span className="value">{market.outcomeCount.toString()}</span>
        </div>
      </div>

      {market.isResolved && (
        <div className="winning-outcome">
          Winning Outcome: #{market.winningOutcome.toString()}
        </div>
      )}

      {!market.isResolved && !isExpired && (
        <button
          onClick={() => setShowBetting(!showBetting)}
          className="btn-primary"
        >
          {showBetting ? 'Hide Betting' : 'Place Bet'}
        </button>
      )}

      {showBetting && !market.isResolved && (
        <PlaceBet marketId={marketId} outcomeCount={Number(market.outcomeCount)} />
      )}
    </div>
  );
}

export function MarketList() {
  const { totalMarkets, isLoading } = useTotalMarkets();
  const [searchId, setSearchId] = useState('');
  const [filter, setFilter] = useState<'all' | 'active' | 'resolved'>('active');

  if (isLoading) {
    return <div>Loading markets...</div>;
  }

  return (
    <div className="market-list">
      <div className="list-header">
        <h2>Prediction Markets ({totalMarkets})</h2>
        <div className="controls">
          <div className="filter-tabs">
            <button
              className={filter === 'all' ? 'active' : ''}
              onClick={() => setFilter('all')}
            >
              All
            </button>
            <button
              className={filter === 'active' ? 'active' : ''}
              onClick={() => setFilter('active')}
            >
              Active
            </button>
            <button
              className={filter === 'resolved' ? 'active' : ''}
              onClick={() => setFilter('resolved')}
            >
              Resolved
            </button>
          </div>
          <input
            type="number"
            placeholder="Search by ID..."
            value={searchId}
            onChange={(e) => setSearchId(e.target.value)}
          />
        </div>
      </div>

      <div className="markets-grid">
        {searchId !== '' ? (
          <MarketCard marketId={parseInt(searchId)} />
        ) : (
          Array.from({ length: Math.min(totalMarkets, 10) }, (_, i) => (
            <MarketCard key={i} marketId={i} />
          ))
        )}
      </div>

      {totalMarkets > 10 && !searchId && (
        <div className="load-more">
          Showing first 10 markets. Use search to find specific markets.
        </div>
      )}
    </div>
  );
}
