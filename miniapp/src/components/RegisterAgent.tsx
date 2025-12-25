import { useState } from 'react';
import { useRegisterAgent } from '../hooks/useAgentRegistry';

export function RegisterAgent() {
  const [name, setName] = useState('');
  const [metadataURI, setMetadataURI] = useState('');
  const [stake, setStake] = useState('0.0001');

  const { registerAgent, isPending, isSuccess, error } = useRegisterAgent();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await registerAgent(name, metadataURI, stake);
    } catch (err) {
      console.error('Failed to register agent:', err);
    }
  };

  return (
    <div className="register-agent">
      <h2>Register New Agent</h2>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="name">Agent Name</label>
          <input
            id="name"
            type="text"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="My Prediction Agent"
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="metadataURI">Metadata URI</label>
          <input
            id="metadataURI"
            type="text"
            value={metadataURI}
            onChange={(e) => setMetadataURI(e.target.value)}
            placeholder="ipfs://... or https://..."
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="stake">Stake Amount (ETH)</label>
          <input
            id="stake"
            type="number"
            step="0.0001"
            min="0.0001"
            value={stake}
            onChange={(e) => setStake(e.target.value)}
            required
          />
          <small>Minimum: 0.0001 ETH</small>
        </div>

        <button type="submit" disabled={isPending} className="btn-primary">
          {isPending ? 'Registering...' : 'Register Agent'}
        </button>
      </form>

      {isSuccess && (
        <div className="success-message">
          Agent registered successfully!
        </div>
      )}

      {error && (
        <div className="error-message">
          Error: {error.message}
        </div>
      )}
    </div>
  );
}
