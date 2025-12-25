// Contract ABIs for interaction
export const AgentRegistryABI = [
  {
    "type": "function",
    "name": "registerAgent",
    "inputs": [
      { "name": "name", "type": "string" },
      { "name": "metadataURI", "type": "string" }
    ],
    "outputs": [{ "name": "", "type": "uint256" }],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "sponsorAgent",
    "inputs": [{ "name": "agentId", "type": "uint256" }],
    "outputs": [],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "getAgent",
    "inputs": [{ "name": "agentId", "type": "uint256" }],
    "outputs": [
      {
        "type": "tuple",
        "components": [
          { "name": "id", "type": "uint256" },
          { "name": "creator", "type": "address" },
          { "name": "name", "type": "string" },
          { "name": "metadataURI", "type": "string" },
          { "name": "totalStaked", "type": "uint256" },
          { "name": "sponsorCount", "type": "uint256" },
          { "name": "reputation", "type": "uint256" },
          { "name": "isActive", "type": "bool" },
          { "name": "createdAt", "type": "uint256" }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "totalAgents",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "event",
    "name": "AgentRegistered",
    "inputs": [
      { "name": "agentId", "type": "uint256", "indexed": true },
      { "name": "creator", "type": "address", "indexed": true },
      { "name": "name", "type": "string", "indexed": false },
      { "name": "stake", "type": "uint256", "indexed": false }
    ]
  },
  {
    "type": "event",
    "name": "AgentSponsored",
    "inputs": [
      { "name": "agentId", "type": "uint256", "indexed": true },
      { "name": "sponsor", "type": "address", "indexed": true },
      { "name": "amount", "type": "uint256", "indexed": false }
    ]
  }
] as const;

export const MarketFactoryABI = [
  {
    "type": "function",
    "name": "createMarket",
    "inputs": [
      { "name": "agentId", "type": "uint256" },
      { "name": "question", "type": "string" },
      { "name": "description", "type": "string" },
      { "name": "category", "type": "uint8" },
      { "name": "outcomes", "type": "string[]" },
      { "name": "duration", "type": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "uint256" }],
    "stateMutability": "nonpayable"
  },
  {
    "type": "function",
    "name": "getMarket",
    "inputs": [{ "name": "marketId", "type": "uint256" }],
    "outputs": [
      {
        "type": "tuple",
        "components": [
          { "name": "id", "type": "uint256" },
          { "name": "agentId", "type": "uint256" },
          { "name": "creator", "type": "address" },
          { "name": "question", "type": "string" },
          { "name": "description", "type": "string" },
          { "name": "category", "type": "uint8" },
          { "name": "outcomeCount", "type": "uint256" },
          { "name": "totalVolume", "type": "uint256" },
          { "name": "createdAt", "type": "uint256" },
          { "name": "deadline", "type": "uint256" },
          { "name": "isResolved", "type": "bool" },
          { "name": "winningOutcome", "type": "uint256" }
        ]
      }
    ],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "totalMarkets",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "event",
    "name": "MarketCreated",
    "inputs": [
      { "name": "marketId", "type": "uint256", "indexed": true },
      { "name": "agentId", "type": "uint256", "indexed": true },
      { "name": "creator", "type": "address", "indexed": true },
      { "name": "question", "type": "string", "indexed": false }
    ]
  }
] as const;

export const BettingEngineABI = [
  {
    "type": "function",
    "name": "placeBet",
    "inputs": [
      { "name": "marketId", "type": "uint256" },
      { "name": "outcomeIndex", "type": "uint256" },
      { "name": "minPayout", "type": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "uint256" }],
    "stateMutability": "payable"
  },
  {
    "type": "function",
    "name": "getOdds",
    "inputs": [
      { "name": "marketId", "type": "uint256" },
      { "name": "outcomeIndex", "type": "uint256" },
      { "name": "betAmount", "type": "uint256" }
    ],
    "outputs": [{ "name": "", "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "claimWinnings",
    "inputs": [{ "name": "marketId", "type": "uint256" }],
    "outputs": [],
    "stateMutability": "nonpayable"
  },
  {
    "type": "event",
    "name": "BetPlaced",
    "inputs": [
      { "name": "marketId", "type": "uint256", "indexed": true },
      { "name": "bettor", "type": "address", "indexed": true },
      { "name": "outcomeIndex", "type": "uint256", "indexed": false },
      { "name": "amount", "type": "uint256", "indexed": false },
      { "name": "payout", "type": "uint256", "indexed": false }
    ]
  }
] as const;

export const TreasuryManagerABI = [
  {
    "type": "function",
    "name": "protocolTreasury",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256" }],
    "stateMutability": "view"
  },
  {
    "type": "function",
    "name": "totalDistributed",
    "inputs": [],
    "outputs": [{ "name": "", "type": "uint256" }],
    "stateMutability": "view"
  }
] as const;
