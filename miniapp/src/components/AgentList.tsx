import { useState } from 'react';
import { useTotalAgents, useAgent, useSponsorAgent } from '../hooks/useAgentRegistry';
import { formatEther } from 'viem';

function AgentCard({ agentId }: { agentId: number }) {
  const { agent, isLoading } = useAgent(agentId);
  const { sponsorAgent, isPending, isSuccess } = useSponsorAgent();
  const [sponsorAmount, setSponsorAmount] = useState('0.00005');

  if (isLoading || !agent) {
    return <div className="agent-card loading">Loading agent...</div>;
  }

  const handleSponsor = async () => {
    try {
      await sponsorAgent(agentId, sponsorAmount);
    } catch (err) {
      console.error('Failed to sponsor:', err);
    }
  };

  return (
    <div className="agent-card">
      <div className="agent-header">
        <h3>{agent.name}</h3>
        <span className={`status ${agent.isActive ? 'active' : 'inactive'}`}>
          {agent.isActive ? '🟢 Active' : '🔴 Inactive'}
        </span>
      </div>

      <div className="agent-stats">
        <div className="stat">
          <span className="label">Total Staked</span>
          <span className="value">{formatEther(agent.totalStaked)} ETH</span>
        </div>
        <div className="stat">
          <span className="label">Sponsors</span>
          <span className="value">{agent.sponsorCount.toString()}</span>
        </div>
        <div className="stat">
          <span className="label">Reputation</span>
          <span className="value">{agent.reputation.toString()}</span>
        </div>
      </div>

      <div className="agent-metadata">
        <a href={agent.metadataURI} target="_blank" rel="noopener noreferrer">
          View Metadata →
        </a>
      </div>

      <div className="sponsor-section">
        <input
          type="number"
          step="0.00005"
          min="0.00005"
          value={sponsorAmount}
          onChange={(e) => setSponsorAmount(e.target.value)}
          placeholder="0.00005"
        />
        <button onClick={handleSponsor} disabled={isPending} className="btn-secondary">
          {isPending ? 'Sponsoring...' : 'Sponsor'}
        </button>
      </div>

      {isSuccess && <div className="success-message">Sponsored successfully!</div>}
    </div>
  );
}

export function AgentList() {
  const { totalAgents, isLoading } = useTotalAgents();
  const [searchId, setSearchId] = useState('');

  if (isLoading) {
    return <div>Loading agents...</div>;
  }

  return (
    <div className="agent-list">
      <div className="list-header">
        <h2>AI Agents ({totalAgents})</h2>
        <div className="search-box">
          <input
            type="number"
            placeholder="Search by ID..."
            value={searchId}
            onChange={(e) => setSearchId(e.target.value)}
          />
        </div>
      </div>

      <div className="agents-grid">
        {searchId !== '' ? (
          <AgentCard agentId={parseInt(searchId)} />
        ) : (
          Array.from({ length: Math.min(totalAgents, 10) }, (_, i) => (
            <AgentCard key={i} agentId={i} />
          ))
        )}
      </div>

      {totalAgents > 10 && !searchId && (
        <div className="load-more">
          Showing first 10 agents. Use search to find specific agents.
        </div>
      )}
    </div>
  );
}
