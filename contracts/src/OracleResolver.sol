// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/**
 * @title OracleResolver
 * @notice Resolves prediction markets using oracle data and community voting
 * @dev Supports both trusted oracles and decentralized resolution
 */
contract OracleResolver is Ownable, ReentrancyGuard {
    // ============ Enums ============

    enum ResolutionStatus {
        Pending,
        Proposed,
        Disputed,
        Finalized
    }

    // ============ Structs ============

    struct Resolution {
        uint256 marketId;
        uint256 proposedOutcome;
        address proposer;
        uint256 proposedAt;
        uint256 votesFor;
        uint256 votesAgainst;
        ResolutionStatus status;
        bool finalized;
    }

    struct Vote {
        address voter;
        bool support;
        uint256 weight;
        uint256 timestamp;
    }

    // ============ State Variables ============

    address public marketFactory;

    mapping(uint256 => Resolution) public resolutions;
    mapping(uint256 => mapping(address => Vote)) public votes;
    mapping(uint256 => address[]) public voters;
    mapping(address => bool) public trustedOracles;
    mapping(address => uint256) public oracleReputation;

    uint256 public constant VOTING_PERIOD = 24 hours;
    uint256 public constant MIN_VOTES_REQUIRED = 3;
    uint256 public constant DISPUTE_BOND = 0.0001 ether;

    uint256 public totalResolutions;
    uint256 public successfulResolutions;

    // ============ Events ============

    event ResolutionProposed(
        uint256 indexed marketId,
        uint256 proposedOutcome,
        address indexed proposer
    );

    event VoteCast(
        uint256 indexed marketId,
        address indexed voter,
        bool support,
        uint256 weight
    );

    event ResolutionFinalized(
        uint256 indexed marketId,
        uint256 outcome,
        uint256 totalVotes
    );

    event ResolutionDisputed(
        uint256 indexed marketId,
        address indexed disputer
    );

    event OracleAdded(address indexed oracle);
    event OracleRemoved(address indexed oracle);

    // ============ Modifiers ============

    modifier onlyTrustedOracle() {
        require(trustedOracles[msg.sender] || msg.sender == owner(), "Not trusted oracle");
        _;
    }

    modifier onlyMarketFactory() {
        require(msg.sender == marketFactory, "Only market factory");
        _;
    }

    // ============ Constructor ============

    constructor() Ownable(msg.sender) {
        // Owner is trusted oracle by default
        trustedOracles[msg.sender] = true;
        oracleReputation[msg.sender] = 100;
    }

    // ============ External Functions ============

    /**
     * @notice Propose a resolution for a market
     * @param marketId ID of the market
     * @param outcomeId Proposed winning outcome
     */
    function proposeResolution(uint256 marketId, uint256 outcomeId)
        external
        onlyTrustedOracle
        nonReentrant
    {
        require(resolutions[marketId].status == ResolutionStatus.Pending, "Already proposed");

        resolutions[marketId] = Resolution({
            marketId: marketId,
            proposedOutcome: outcomeId,
            proposer: msg.sender,
            proposedAt: block.timestamp,
            votesFor: 0,
            votesAgainst: 0,
            status: ResolutionStatus.Proposed,
            finalized: false
        });

        totalResolutions++;

        emit ResolutionProposed(marketId, outcomeId, msg.sender);

        // If proposer is high reputation oracle, auto-vote
        if (oracleReputation[msg.sender] >= 90) {
            _castVote(marketId, msg.sender, true, oracleReputation[msg.sender]);
        }
    }

    /**
     * @notice Vote on a proposed resolution
     * @param marketId ID of the market
     * @param support Whether to support the proposal
     */
    function vote(uint256 marketId, bool support) external nonReentrant {
        Resolution storage resolution = resolutions[marketId];

        require(resolution.status == ResolutionStatus.Proposed, "Not in voting");
        require(
            block.timestamp <= resolution.proposedAt + VOTING_PERIOD,
            "Voting period ended"
        );
        require(votes[marketId][msg.sender].voter == address(0), "Already voted");

        // Calculate vote weight (could be based on stake, reputation, etc.)
        uint256 weight = trustedOracles[msg.sender] ? oracleReputation[msg.sender] : 1;

        _castVote(marketId, msg.sender, support, weight);
    }

    /**
     * @notice Finalize a resolution after voting period
     * @param marketId ID of the market
     */
    function finalizeResolution(uint256 marketId) external nonReentrant {
        Resolution storage resolution = resolutions[marketId];

        require(resolution.status == ResolutionStatus.Proposed, "Not proposed");
        require(
            block.timestamp > resolution.proposedAt + VOTING_PERIOD ||
            voters[marketId].length >= MIN_VOTES_REQUIRED,
            "Voting not complete"
        );
        require(!resolution.finalized, "Already finalized");

        uint256 totalVotes = resolution.votesFor + resolution.votesAgainst;
        require(totalVotes >= MIN_VOTES_REQUIRED, "Not enough votes");

        // Check if proposal passed (simple majority)
        bool passed = resolution.votesFor > resolution.votesAgainst;

        if (passed) {
            resolution.status = ResolutionStatus.Finalized;
            resolution.finalized = true;

            // Notify market factory to resolve the market
            if (marketFactory != address(0)) {
                (bool success, ) = marketFactory.call(
                    abi.encodeWithSignature(
                        "resolveMarket(uint256,uint256)",
                        marketId,
                        resolution.proposedOutcome
                    )
                );
                require(success, "Market resolution failed");
            }

            successfulResolutions++;

            // Increase proposer reputation
            if (oracleReputation[resolution.proposer] < 100) {
                oracleReputation[resolution.proposer] += 1;
            }

            emit ResolutionFinalized(marketId, resolution.proposedOutcome, totalVotes);
        } else {
            // Proposal rejected, reset to pending
            resolution.status = ResolutionStatus.Pending;

            // Decrease proposer reputation
            if (oracleReputation[resolution.proposer] > 10) {
                oracleReputation[resolution.proposer] -= 5;
            }
        }
    }

    /**
     * @notice Dispute a proposed resolution
     * @param marketId ID of the market
     */
    function disputeResolution(uint256 marketId) external payable nonReentrant {
        require(msg.value >= DISPUTE_BOND, "Insufficient dispute bond");

        Resolution storage resolution = resolutions[marketId];

        require(
            resolution.status == ResolutionStatus.Proposed ||
            resolution.status == ResolutionStatus.Finalized,
            "Cannot dispute"
        );

        resolution.status = ResolutionStatus.Disputed;

        emit ResolutionDisputed(marketId, msg.sender);
    }

    /**
     * @notice Admin override for disputed resolutions
     * @param marketId ID of the market
     * @param outcomeId Correct outcome
     */
    function adminResolve(uint256 marketId, uint256 outcomeId)
        external
        onlyOwner
        nonReentrant
    {
        Resolution storage resolution = resolutions[marketId];

        resolution.proposedOutcome = outcomeId;
        resolution.status = ResolutionStatus.Finalized;
        resolution.finalized = true;

        // Notify market factory
        if (marketFactory != address(0)) {
            (bool success, ) = marketFactory.call(
                abi.encodeWithSignature(
                    "resolveMarket(uint256,uint256)",
                    marketId,
                    outcomeId
                )
            );
            require(success, "Market resolution failed");
        }

        emit ResolutionFinalized(marketId, outcomeId, 0);
    }

    // ============ View Functions ============

    function getResolution(uint256 marketId) external view returns (Resolution memory) {
        return resolutions[marketId];
    }

    function getVote(uint256 marketId, address voter) external view returns (Vote memory) {
        return votes[marketId][voter];
    }

    function getVoters(uint256 marketId) external view returns (address[] memory) {
        return voters[marketId];
    }

    function getVoteCount(uint256 marketId) external view returns (uint256 forVotes, uint256 againstVotes) {
        Resolution storage resolution = resolutions[marketId];
        return (resolution.votesFor, resolution.votesAgainst);
    }

    function canFinalize(uint256 marketId) external view returns (bool) {
        Resolution storage resolution = resolutions[marketId];

        if (resolution.status != ResolutionStatus.Proposed) return false;
        if (resolution.finalized) return false;

        uint256 totalVotes = resolution.votesFor + resolution.votesAgainst;

        return (
            block.timestamp > resolution.proposedAt + VOTING_PERIOD &&
            totalVotes >= MIN_VOTES_REQUIRED
        );
    }

    // ============ Admin Functions ============

    function addTrustedOracle(address oracle) external onlyOwner {
        require(oracle != address(0), "Invalid address");
        require(!trustedOracles[oracle], "Already trusted");

        trustedOracles[oracle] = true;
        oracleReputation[oracle] = 50; // Start with medium reputation

        emit OracleAdded(oracle);
    }

    function removeTrustedOracle(address oracle) external onlyOwner {
        require(trustedOracles[oracle], "Not trusted oracle");

        trustedOracles[oracle] = false;

        emit OracleRemoved(oracle);
    }

    function setMarketFactory(address _marketFactory) external onlyOwner {
        require(_marketFactory != address(0), "Invalid address");
        marketFactory = _marketFactory;
    }

    function setOracleReputation(address oracle, uint256 reputation) external onlyOwner {
        require(trustedOracles[oracle], "Not trusted oracle");
        require(reputation <= 100, "Reputation too high");

        oracleReputation[oracle] = reputation;
    }

    // ============ Internal Functions ============

    function _castVote(
        uint256 marketId,
        address voter,
        bool support,
        uint256 weight
    ) internal {
        votes[marketId][voter] = Vote({
            voter: voter,
            support: support,
            weight: weight,
            timestamp: block.timestamp
        });

        voters[marketId].push(voter);

        Resolution storage resolution = resolutions[marketId];

        if (support) {
            resolution.votesFor += weight;
        } else {
            resolution.votesAgainst += weight;
        }

        emit VoteCast(marketId, voter, support, weight);
    }

    // ============ Receive Function ============

    receive() external payable {
        // Accept dispute bonds
    }
}
