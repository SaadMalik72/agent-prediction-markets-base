// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title AgentRegistry
 * @notice Manages AI agent registration, staking, sponsorships, and reputation
 * @dev Handles agent lifecycle, performance tracking, and economic incentives
 */
contract AgentRegistry is Ownable, ReentrancyGuard, Pausable {
    // ============ Constants ============

    uint256 public constant MIN_AGENT_STAKE = 0.0001 ether;
    uint256 public constant MIN_SPONSORSHIP = 0.00005 ether;
    uint256 public constant WITHDRAWAL_COOLDOWN = 7 days;
    uint256 public constant SLASH_PERCENTAGE = 10; // 10% penalty for misbehavior
    uint256 public constant MAX_REPUTATION = 10000;

    // ============ Structs ============

    struct Agent {
        address creator;
        string name;
        string metadataURI;
        uint256 stakedAmount;
        uint256 sponsoredAmount;
        uint256 totalEarnings;
        uint256 totalPredictions;
        uint256 correctPredictions;
        uint256 reputation;
        uint256 createdAt;
        uint256 lastActivityAt;
        bool isActive;
        bool isSlashed;
    }

    struct Sponsorship {
        address sponsor;
        uint256 amount;
        uint256 timestamp;
        uint256 earnedRewards;
    }

    struct WithdrawalRequest {
        uint256 amount;
        uint256 requestedAt;
        bool processed;
    }

    // ============ State Variables ============

    mapping(uint256 => Agent) public agents;
    mapping(uint256 => mapping(address => Sponsorship)) public sponsorships;
    mapping(uint256 => address[]) public agentSponsors;
    mapping(address => uint256[]) public creatorAgents;
    mapping(address => mapping(uint256 => WithdrawalRequest)) public withdrawalRequests;

    uint256 public nextAgentId;
    uint256 public totalAgents;
    uint256 public totalStaked;
    uint256 public totalSponsored;

    address public treasuryManager;
    address public marketFactory;

    // ============ Events ============

    event AgentRegistered(
        uint256 indexed agentId,
        address indexed creator,
        string name,
        uint256 stakedAmount
    );

    event AgentSponsored(
        uint256 indexed agentId,
        address indexed sponsor,
        uint256 amount,
        uint256 totalSponsored
    );

    event StakeAdded(
        uint256 indexed agentId,
        address indexed creator,
        uint256 amount
    );

    event WithdrawalRequested(
        uint256 indexed agentId,
        address indexed requester,
        uint256 amount,
        uint256 availableAt
    );

    event WithdrawalProcessed(
        uint256 indexed agentId,
        address indexed requester,
        uint256 amount
    );

    event AgentSlashed(
        uint256 indexed agentId,
        uint256 slashedAmount,
        string reason
    );

    event ReputationUpdated(
        uint256 indexed agentId,
        uint256 oldReputation,
        uint256 newReputation
    );

    event AgentDeactivated(uint256 indexed agentId);
    event AgentReactivated(uint256 indexed agentId);

    // ============ Modifiers ============

    modifier onlyAgentCreator(uint256 agentId) {
        require(agents[agentId].creator == msg.sender, "Not agent creator");
        _;
    }

    modifier onlyTreasuryOrFactory() {
        require(
            msg.sender == treasuryManager || msg.sender == marketFactory,
            "Unauthorized"
        );
        _;
    }

    modifier agentExists(uint256 agentId) {
        require(agentId < nextAgentId, "Agent does not exist");
        _;
    }

    modifier agentActive(uint256 agentId) {
        require(agents[agentId].isActive, "Agent not active");
        require(!agents[agentId].isSlashed, "Agent is slashed");
        _;
    }

    // ============ Constructor ============

    constructor() Ownable(msg.sender) {
        nextAgentId = 0;
    }

    // ============ External Functions ============

    /**
     * @notice Register a new AI agent with initial stake
     * @param name Agent name
     * @param metadataURI IPFS URI containing agent metadata
     */
    function registerAgent(
        string calldata name,
        string calldata metadataURI
    ) external payable whenNotPaused nonReentrant returns (uint256) {
        require(msg.value >= MIN_AGENT_STAKE, "Insufficient stake");
        require(bytes(name).length > 0, "Name cannot be empty");

        uint256 agentId = nextAgentId++;

        agents[agentId] = Agent({
            creator: msg.sender,
            name: name,
            metadataURI: metadataURI,
            stakedAmount: msg.value,
            sponsoredAmount: 0,
            totalEarnings: 0,
            totalPredictions: 0,
            correctPredictions: 0,
            reputation: 5000, // Start at 50% reputation
            createdAt: block.timestamp,
            lastActivityAt: block.timestamp,
            isActive: true,
            isSlashed: false
        });

        creatorAgents[msg.sender].push(agentId);
        totalAgents++;
        totalStaked += msg.value;

        emit AgentRegistered(agentId, msg.sender, name, msg.value);

        return agentId;
    }

    /**
     * @notice Sponsor an existing agent
     * @param agentId ID of the agent to sponsor
     */
    function sponsorAgent(uint256 agentId)
        external
        payable
        agentExists(agentId)
        agentActive(agentId)
        whenNotPaused
        nonReentrant
    {
        require(msg.value >= MIN_SPONSORSHIP, "Sponsorship too low");

        Agent storage agent = agents[agentId];
        Sponsorship storage sponsorship = sponsorships[agentId][msg.sender];

        if (sponsorship.amount == 0) {
            // New sponsor
            agentSponsors[agentId].push(msg.sender);
            sponsorship.sponsor = msg.sender;
            sponsorship.timestamp = block.timestamp;
        }

        sponsorship.amount += msg.value;
        agent.sponsoredAmount += msg.value;
        totalSponsored += msg.value;

        emit AgentSponsored(agentId, msg.sender, msg.value, agent.sponsoredAmount);
    }

    /**
     * @notice Add additional stake to an agent
     * @param agentId ID of the agent
     */
    function addStake(uint256 agentId)
        external
        payable
        agentExists(agentId)
        onlyAgentCreator(agentId)
        whenNotPaused
        nonReentrant
    {
        require(msg.value > 0, "Must stake something");

        agents[agentId].stakedAmount += msg.value;
        totalStaked += msg.value;

        emit StakeAdded(agentId, msg.sender, msg.value);
    }

    /**
     * @notice Request withdrawal of stake or sponsorship
     * @param agentId ID of the agent
     * @param amount Amount to withdraw
     */
    function requestWithdrawal(uint256 agentId, uint256 amount)
        external
        agentExists(agentId)
        nonReentrant
    {
        require(amount > 0, "Amount must be positive");

        Agent storage agent = agents[agentId];

        if (msg.sender == agent.creator) {
            require(amount <= agent.stakedAmount, "Insufficient stake");
            require(
                agent.stakedAmount - amount >= MIN_AGENT_STAKE || amount == agent.stakedAmount,
                "Would fall below minimum stake"
            );
        } else {
            Sponsorship storage sponsorship = sponsorships[agentId][msg.sender];
            require(sponsorship.amount >= amount, "Insufficient sponsorship");
        }

        uint256 requestId = uint256(keccak256(abi.encodePacked(agentId, msg.sender, block.timestamp)));

        withdrawalRequests[msg.sender][requestId] = WithdrawalRequest({
            amount: amount,
            requestedAt: block.timestamp,
            processed: false
        });

        emit WithdrawalRequested(
            agentId,
            msg.sender,
            amount,
            block.timestamp + WITHDRAWAL_COOLDOWN
        );
    }

    /**
     * @notice Process a withdrawal after cooldown period
     * @param agentId ID of the agent
     * @param requestId ID of the withdrawal request
     */
    function processWithdrawal(uint256 agentId, uint256 requestId)
        external
        agentExists(agentId)
        nonReentrant
    {
        WithdrawalRequest storage request = withdrawalRequests[msg.sender][requestId];

        require(!request.processed, "Already processed");
        require(
            block.timestamp >= request.requestedAt + WITHDRAWAL_COOLDOWN,
            "Cooldown not finished"
        );

        Agent storage agent = agents[agentId];
        uint256 amount = request.amount;

        request.processed = true;

        if (msg.sender == agent.creator) {
            agent.stakedAmount -= amount;
            totalStaked -= amount;

            if (agent.stakedAmount == 0) {
                agent.isActive = false;
                emit AgentDeactivated(agentId);
            }
        } else {
            Sponsorship storage sponsorship = sponsorships[agentId][msg.sender];
            sponsorship.amount -= amount;
            agent.sponsoredAmount -= amount;
            totalSponsored -= amount;
        }

        (bool success, ) = msg.sender.call{value: amount}("");
        require(success, "Transfer failed");

        emit WithdrawalProcessed(agentId, msg.sender, amount);
    }

    /**
     * @notice Update agent prediction stats (called by MarketFactory)
     * @param agentId ID of the agent
     * @param wasCorrect Whether the prediction was correct
     */
    function updatePredictionStats(uint256 agentId, bool wasCorrect)
        external
        agentExists(agentId)
        onlyTreasuryOrFactory
    {
        Agent storage agent = agents[agentId];

        agent.totalPredictions++;
        if (wasCorrect) {
            agent.correctPredictions++;
        }
        agent.lastActivityAt = block.timestamp;

        // Update reputation based on performance
        _updateReputation(agentId);
    }

    /**
     * @notice Record earnings for an agent (called by TreasuryManager)
     * @param agentId ID of the agent
     * @param amount Amount earned
     */
    function recordEarnings(uint256 agentId, uint256 amount)
        external
        agentExists(agentId)
        onlyTreasuryOrFactory
    {
        agents[agentId].totalEarnings += amount;
    }

    /**
     * @notice Slash an agent for misbehavior
     * @param agentId ID of the agent
     * @param reason Reason for slashing
     */
    function slashAgent(uint256 agentId, string calldata reason)
        external
        onlyOwner
        agentExists(agentId)
    {
        Agent storage agent = agents[agentId];
        require(!agent.isSlashed, "Already slashed");

        uint256 slashAmount = (agent.stakedAmount * SLASH_PERCENTAGE) / 100;

        agent.stakedAmount -= slashAmount;
        agent.isSlashed = true;
        agent.isActive = false;
        totalStaked -= slashAmount;

        // Send slashed funds to treasury
        if (treasuryManager != address(0)) {
            (bool success, ) = treasuryManager.call{value: slashAmount}("");
            require(success, "Slash transfer failed");
        }

        emit AgentSlashed(agentId, slashAmount, reason);
    }

    // ============ View Functions ============

    function getAgent(uint256 agentId) external view agentExists(agentId) returns (Agent memory) {
        return agents[agentId];
    }

    function getAgentSponsors(uint256 agentId) external view agentExists(agentId) returns (address[] memory) {
        return agentSponsors[agentId];
    }

    function getCreatorAgents(address creator) external view returns (uint256[] memory) {
        return creatorAgents[creator];
    }

    function getSponsorship(uint256 agentId, address sponsor)
        external
        view
        agentExists(agentId)
        returns (Sponsorship memory)
    {
        return sponsorships[agentId][sponsor];
    }

    function getAgentPerformance(uint256 agentId)
        external
        view
        agentExists(agentId)
        returns (uint256 total, uint256 correct, uint256 winRate)
    {
        Agent storage agent = agents[agentId];
        total = agent.totalPredictions;
        correct = agent.correctPredictions;
        winRate = total > 0 ? (correct * 10000) / total : 0;
    }

    function getTotalCapital(uint256 agentId)
        external
        view
        agentExists(agentId)
        returns (uint256)
    {
        return agents[agentId].stakedAmount + agents[agentId].sponsoredAmount;
    }

    // ============ Admin Functions ============

    function setTreasuryManager(address _treasuryManager) external onlyOwner {
        require(_treasuryManager != address(0), "Invalid address");
        treasuryManager = _treasuryManager;
    }

    function setMarketFactory(address _marketFactory) external onlyOwner {
        require(_marketFactory != address(0), "Invalid address");
        marketFactory = _marketFactory;
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    // ============ Internal Functions ============

    function _updateReputation(uint256 agentId) internal {
        Agent storage agent = agents[agentId];

        if (agent.totalPredictions == 0) return;

        uint256 oldReputation = agent.reputation;

        // Calculate win rate (0-10000, representing 0-100%)
        uint256 winRate = (agent.correctPredictions * 10000) / agent.totalPredictions;

        // Reputation moves towards win rate
        uint256 newReputation = (oldReputation * 9 + winRate) / 10; // Weighted average

        // Ensure reputation stays in bounds
        if (newReputation > MAX_REPUTATION) {
            newReputation = MAX_REPUTATION;
        }

        agent.reputation = newReputation;

        emit ReputationUpdated(agentId, oldReputation, newReputation);
    }
}
