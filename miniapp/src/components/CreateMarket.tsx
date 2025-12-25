import { useState } from 'react';
import { useCreateMarket } from '../hooks/useMarkets';

const CATEGORIES = [
  { value: 0, label: 'Crypto' },
  { value: 1, label: 'Sports' },
  { value: 2, label: 'Politics' },
  { value: 3, label: 'Weather' },
  { value: 4, label: 'Technology' },
  { value: 5, label: 'Other' },
];

export function CreateMarket() {
  const [agentId, setAgentId] = useState('');
  const [question, setQuestion] = useState('');
  const [description, setDescription] = useState('');
  const [category, setCategory] = useState(0);
  const [outcomes, setOutcomes] = useState(['Yes', 'No']);
  const [durationDays, setDurationDays] = useState('7');

  const { createMarket, isPending, isSuccess, error } = useCreateMarket();

  const handleOutcomeChange = (index: number, value: string) => {
    const newOutcomes = [...outcomes];
    newOutcomes[index] = value;
    setOutcomes(newOutcomes);
  };

  const addOutcome = () => {
    if (outcomes.length < 10) {
      setOutcomes([...outcomes, '']);
    }
  };

  const removeOutcome = (index: number) => {
    if (outcomes.length > 2) {
      setOutcomes(outcomes.filter((_, i) => i !== index));
    }
  };

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    try {
      await createMarket(
        parseInt(agentId),
        question,
        description,
        category,
        outcomes,
        parseInt(durationDays)
      );
    } catch (err) {
      console.error('Failed to create market:', err);
    }
  };

  return (
    <div className="create-market">
      <h2>Create Prediction Market</h2>
      <form onSubmit={handleSubmit}>
        <div className="form-group">
          <label htmlFor="agentId">Agent ID</label>
          <input
            id="agentId"
            type="number"
            value={agentId}
            onChange={(e) => setAgentId(e.target.value)}
            placeholder="0"
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="question">Question</label>
          <input
            id="question"
            type="text"
            value={question}
            onChange={(e) => setQuestion(e.target.value)}
            placeholder="Will Bitcoin reach $100k by end of 2025?"
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="description">Description</label>
          <textarea
            id="description"
            value={description}
            onChange={(e) => setDescription(e.target.value)}
            placeholder="Detailed description of the market..."
            rows={4}
            required
          />
        </div>

        <div className="form-group">
          <label htmlFor="category">Category</label>
          <select
            id="category"
            value={category}
            onChange={(e) => setCategory(parseInt(e.target.value))}
          >
            {CATEGORIES.map((cat) => (
              <option key={cat.value} value={cat.value}>
                {cat.label}
              </option>
            ))}
          </select>
        </div>

        <div className="form-group">
          <label>Outcomes</label>
          {outcomes.map((outcome, index) => (
            <div key={index} className="outcome-input">
              <input
                type="text"
                value={outcome}
                onChange={(e) => handleOutcomeChange(index, e.target.value)}
                placeholder={`Outcome ${index + 1}`}
                required
              />
              {outcomes.length > 2 && (
                <button
                  type="button"
                  onClick={() => removeOutcome(index)}
                  className="btn-remove"
                >
                  ✕
                </button>
              )}
            </div>
          ))}
          {outcomes.length < 10 && (
            <button type="button" onClick={addOutcome} className="btn-add">
              + Add Outcome
            </button>
          )}
        </div>

        <div className="form-group">
          <label htmlFor="duration">Duration (days)</label>
          <input
            id="duration"
            type="number"
            min="1"
            max="365"
            value={durationDays}
            onChange={(e) => setDurationDays(e.target.value)}
            required
          />
          <small>Market will close in {durationDays} days</small>
        </div>

        <button type="submit" disabled={isPending} className="btn-primary">
          {isPending ? 'Creating...' : 'Create Market'}
        </button>
      </form>

      {isSuccess && (
        <div className="success-message">
          Market created successfully!
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
