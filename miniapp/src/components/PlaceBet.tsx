import { useState } from 'react';
import { usePlaceBet, useGetOdds } from '../hooks/useMarkets';
import { formatEther } from 'viem';

interface PlaceBetProps {
  marketId: number;
  outcomeCount: number;
}

export function PlaceBet({ marketId, outcomeCount }: PlaceBetProps) {
  const [selectedOutcome, setSelectedOutcome] = useState(0);
  const [betAmount, setBetAmount] = useState('0.00001');

  const { placeBet, isPending, isSuccess, error } = usePlaceBet();
  const { odds } = useGetOdds(marketId, selectedOutcome, betAmount);

  const handlePlaceBet = async () => {
    try {
      await placeBet(marketId, selectedOutcome, betAmount);
    } catch (err) {
      console.error('Failed to place bet:', err);
    }
  };

  const potentialPayout = odds ? formatEther(odds) : '0';

  return (
    <div className="place-bet">
      <h4>Place Your Bet</h4>

      <div className="form-group">
        <label>Select Outcome</label>
        <select
          value={selectedOutcome}
          onChange={(e) => setSelectedOutcome(parseInt(e.target.value))}
        >
          {Array.from({ length: outcomeCount }, (_, i) => (
            <option key={i} value={i}>
              Outcome #{i}
            </option>
          ))}
        </select>
      </div>

      <div className="form-group">
        <label>Bet Amount (ETH)</label>
        <input
          type="number"
          step="0.00001"
          min="0.00001"
          value={betAmount}
          onChange={(e) => setBetAmount(e.target.value)}
          placeholder="0.00001"
        />
        <small>Minimum: 0.00001 ETH</small>
      </div>

      {odds && (
        <div className="odds-display">
          <div className="potential-payout">
            <span className="label">Potential Payout:</span>
            <span className="value">{potentialPayout} ETH</span>
          </div>
        </div>
      )}

      <button
        onClick={handlePlaceBet}
        disabled={isPending || parseFloat(betAmount) < 0.00001}
        className="btn-primary"
      >
        {isPending ? 'Placing Bet...' : 'Confirm Bet'}
      </button>

      {isSuccess && (
        <div className="success-message">
          Bet placed successfully! Good luck!
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
