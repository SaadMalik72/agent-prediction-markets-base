// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./AgentRegistry.sol";
import "./BettingEngine.sol";
import "./OracleResolver.sol";

/**
 * @title MarketFactory
 * @notice Creates and manages prediction markets for AI agents
 * @dev Handles market lifecycle, resolution, and interaction with other contracts
 */
contract MarketFactory is Ownable, ReentrancyGuard, Pausable {
    // ============ Enums ============

    enum MarketStatus {
        Active,
        Closed,
        Resolved,
        Disputed,
        Cancelled
    }

    enum MarketCategory {
        Crypto,
        Sports,
        Politics,
        Weather,
        Technology,
        Other
    }

    // ============ Structs ============

    struct Market {
        uint256 id;
        address creator;
        uint256 creatorAgentId;
        string question;
        string description;
        MarketCategory category;
        uint256 createdAt;
        uint256 endTime;
        uint256 resolutionTime;
        MarketStatus status;
        uint256 totalVolume;
        uint256 totalBets;
        uint256[] outcomeIds;
        uint256 winningOutcome;
        bool allowAgentsOnly;
    }

    struct Outcome {
        uint256 id;
        string name;
        uint256 totalStaked;
        uint256 backers;
    }

    // ============ State Variables ============

    AgentRegistry public agentRegistry;
    BettingEngine public bettingEngine;
    OracleResolver public oracleResolver;

    mapping(uint256 => Market) public markets;
    mapping(uint256 => mapping(uint256 => Outcome)) public marketOutcomes;
    mapping(uint256 => uint256[]) public agentMarkets;
    mapping(address => uint256[]) public userMarkets;

    uint256 public nextMarketId;
    uint256 public totalMarkets;
    uint256 public activeMarkets;
    uint256 public totalVolume;

    uint256 public constant MIN_MARKET_DURATION = 1 hours;
    uint256 public constant MAX_MARKET_DURATION = 365 days;
    uint256 public constant MIN_OUTCOMES = 2;
    uint256 public constant MAX_OUTCOMES = 10;

    // ============ Events ============

    event MarketCreated(
        uint256 indexed marketId,
        uint256 indexed agentId,
        address indexed creator,
        string question,
        uint256 endTime
    );

    event MarketClosed(uint256 indexed marketId, uint256 closedAt);

    event MarketResolved(
        uint256 indexed marketId,
        uint256 winningOutcome,
        uint256 resolvedAt
    );

    event MarketDisputed(
        uint256 indexed marketId,
        address indexed disputer,
        string reason
    );

    event MarketCancelled(uint256 indexed marketId, string reason);

    event OutcomeAdded(
        uint256 indexed marketId,
        uint256 indexed outcomeId,
        string name
    );

    // ============ Constructor ============

    constructor(
        address _agentRegistry,
        address _bettingEngine,
        address _oracleResolver
    ) Ownable(msg.sender) {
        require(_agentRegistry != address(0), "Invalid registry");
        require(_bettingEngine != address(0), "Invalid betting engine");
        require(_oracleResolver != address(0), "Invalid oracle");

        agentRegistry = AgentRegistry(payable(_agentRegistry));
        bettingEngine = BettingEngine(payable(_bettingEngine));
        oracleResolver = OracleResolver(payable(_oracleResolver));

        nextMarketId = 1;
    }

    // ============ External Functions ============

    /**
     * @notice Create a new prediction market
     * @param agentId ID of the agent creating the market
     * @param question Market question
     * @param description Detailed description
     * @param category Market category
     * @param duration Duration in seconds
     * @param outcomeNames Array of outcome names
     * @param allowAgentsOnly If true, only agents can bet
     */
    function createMarket(
        uint256 agentId,
        string calldata question,
        string calldata description,
        MarketCategory category,
        uint256 duration,
        string[] calldata outcomeNames,
        bool allowAgentsOnly
    ) external whenNotPaused nonReentrant returns (uint256) {
        // Validate agent ownership
        AgentRegistry.Agent memory agent = agentRegistry.getAgent(agentId);
        require(agent.creator == msg.sender || msg.sender == owner(), "Not agent owner");
        require(agent.isActive, "Agent not active");

        // Validate parameters
        require(bytes(question).length > 0, "Question required");
        require(duration >= MIN_MARKET_DURATION, "Duration too short");
        require(duration <= MAX_MARKET_DURATION, "Duration too long");
        require(outcomeNames.length >= MIN_OUTCOMES, "Not enough outcomes");
        require(outcomeNames.length <= MAX_OUTCOMES, "Too many outcomes");

        uint256 marketId = nextMarketId++;
        uint256 endTime = block.timestamp + duration;

        // Create market
        markets[marketId] = Market({
            id: marketId,
            creator: msg.sender,
            creatorAgentId: agentId,
            question: question,
            description: description,
            category: category,
            createdAt: block.timestamp,
            endTime: endTime,
            resolutionTime: 0,
            status: MarketStatus.Active,
            totalVolume: 0,
            totalBets: 0,
            outcomeIds: new uint256[](outcomeNames.length),
            winningOutcome: 0,
            allowAgentsOnly: allowAgentsOnly
        });

        // Create outcomes
        for (uint256 i = 0; i < outcomeNames.length; i++) {
            require(bytes(outcomeNames[i]).length > 0, "Empty outcome name");

            marketOutcomes[marketId][i] = Outcome({
                id: i,
                name: outcomeNames[i],
                totalStaked: 0,
                backers: 0
            });

            markets[marketId].outcomeIds[i] = i;

            emit OutcomeAdded(marketId, i, outcomeNames[i]);
        }

        agentMarkets[agentId].push(marketId);
        userMarkets[msg.sender].push(marketId);

        totalMarkets++;
        activeMarkets++;

        emit MarketCreated(marketId, agentId, msg.sender, question, endTime);

        return marketId;
    }

    /**
     * @notice Close a market (no more bets allowed)
     * @param marketId ID of the market
     */
    function closeMarket(uint256 marketId) external nonReentrant {
        Market storage market = markets[marketId];

        require(market.status == MarketStatus.Active, "Market not active");
        require(
            block.timestamp >= market.endTime || msg.sender == market.creator || msg.sender == owner(),
            "Cannot close yet"
        );

        market.status = MarketStatus.Closed;
        activeMarkets--;

        emit MarketClosed(marketId, block.timestamp);
    }

    /**
     * @notice Resolve a market with winning outcome
     * @param marketId ID of the market
     * @param winningOutcomeId ID of the winning outcome
     */
    function resolveMarket(uint256 marketId, uint256 winningOutcomeId)
        external
        nonReentrant
    {
        Market storage market = markets[marketId];

        require(market.status == MarketStatus.Closed, "Market not closed");
        require(
            msg.sender == address(oracleResolver) || msg.sender == owner(),
            "Not authorized"
        );
        require(winningOutcomeId < market.outcomeIds.length, "Invalid outcome");

        market.status = MarketStatus.Resolved;
        market.winningOutcome = winningOutcomeId;
        market.resolutionTime = block.timestamp;

        // Notify betting engine to process payouts
        bettingEngine.resolveMarket(marketId, winningOutcomeId);

        emit MarketResolved(marketId, winningOutcomeId, block.timestamp);
    }

    /**
     * @notice Dispute a market resolution
     * @param marketId ID of the market
     * @param reason Reason for dispute
     */
    function disputeMarket(uint256 marketId, string calldata reason)
        external
        nonReentrant
    {
        Market storage market = markets[marketId];

        require(market.status == MarketStatus.Resolved, "Market not resolved");
        require(
            block.timestamp <= market.resolutionTime + 24 hours,
            "Dispute period ended"
        );

        // User must have bet on this market
        require(
            bettingEngine.getUserBetCount(marketId, msg.sender) > 0,
            "No bets on market"
        );

        market.status = MarketStatus.Disputed;

        emit MarketDisputed(marketId, msg.sender, reason);
    }

    /**
     * @notice Cancel a market and refund bets
     * @param marketId ID of the market
     * @param reason Reason for cancellation
     */
    function cancelMarket(uint256 marketId, string calldata reason)
        external
        onlyOwner
        nonReentrant
    {
        Market storage market = markets[marketId];

        require(
            market.status == MarketStatus.Active || market.status == MarketStatus.Closed,
            "Cannot cancel"
        );

        market.status = MarketStatus.Cancelled;

        if (market.status == MarketStatus.Active) {
            activeMarkets--;
        }

        // Notify betting engine to process refunds
        bettingEngine.cancelMarket(marketId);

        emit MarketCancelled(marketId, reason);
    }

    /**
     * @notice Update market stats from betting engine
     * @param marketId ID of the market
     * @param outcomeId ID of the outcome
     * @param amount Amount bet
     */
    function updateMarketStats(
        uint256 marketId,
        uint256 outcomeId,
        uint256 amount
    ) external {
        require(msg.sender == address(bettingEngine), "Only betting engine");

        Market storage market = markets[marketId];
        Outcome storage outcome = marketOutcomes[marketId][outcomeId];

        market.totalVolume += amount;
        market.totalBets++;
        outcome.totalStaked += amount;
        outcome.backers++;

        totalVolume += amount;
    }

    // ============ View Functions ============

    function getMarket(uint256 marketId) external view returns (Market memory) {
        return markets[marketId];
    }

    function getOutcome(uint256 marketId, uint256 outcomeId)
        external
        view
        returns (Outcome memory)
    {
        return marketOutcomes[marketId][outcomeId];
    }

    function getMarketOutcomes(uint256 marketId)
        external
        view
        returns (Outcome[] memory)
    {
        Market storage market = markets[marketId];
        Outcome[] memory outcomes = new Outcome[](market.outcomeIds.length);

        for (uint256 i = 0; i < market.outcomeIds.length; i++) {
            outcomes[i] = marketOutcomes[marketId][i];
        }

        return outcomes;
    }

    function getAgentMarkets(uint256 agentId)
        external
        view
        returns (uint256[] memory)
    {
        return agentMarkets[agentId];
    }

    function getUserMarkets(address user) external view returns (uint256[] memory) {
        return userMarkets[user];
    }

    function getMarketOdds(uint256 marketId)
        external
        view
        returns (uint256[] memory)
    {
        return bettingEngine.getMarketOdds(marketId);
    }

    function isMarketActive(uint256 marketId) external view returns (bool) {
        Market storage market = markets[marketId];
        return market.status == MarketStatus.Active && block.timestamp < market.endTime;
    }

    // ============ Admin Functions ============

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function updateBettingEngine(address _bettingEngine) external onlyOwner {
        require(_bettingEngine != address(0), "Invalid address");
        bettingEngine = BettingEngine(payable(_bettingEngine));
    }

    function updateOracleResolver(address _oracleResolver) external onlyOwner {
        require(_oracleResolver != address(0), "Invalid address");
        oracleResolver = OracleResolver(payable(_oracleResolver));
    }
}
