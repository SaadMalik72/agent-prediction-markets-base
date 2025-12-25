// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./AgentRegistry.sol";

/**
 * @title TreasuryManager
 * @notice Manages protocol treasury, revenue distribution, and agent subsidies
 * @dev Handles 60/30/10 split: sponsors/creator/protocol
 */
contract TreasuryManager is Ownable, ReentrancyGuard, Pausable {
    // ============ Constants ============

    uint256 public constant INITIAL_PROTOCOL_LIQUIDITY = 0.001 ether;
    uint256 public constant SPONSOR_SHARE = 60; // 60%
    uint256 public constant CREATOR_SHARE = 30; // 30%
    uint256 public constant PROTOCOL_FEE = 10; // 10%
    uint256 public constant MIN_SUBSIDY_AMOUNT = 0.00001 ether;
    uint256 public constant MAX_SUBSIDY_PER_AGENT = 0.0002 ether;

    // ============ State Variables ============

    AgentRegistry public agentRegistry;

    uint256 public protocolTreasury;
    uint256 public totalDistributed;
    uint256 public totalSubsidiesGiven;

    mapping(uint256 => uint256) public agentEarnings;
    mapping(uint256 => uint256) public agentSubsidies;
    mapping(uint256 => mapping(address => uint256)) public sponsorEarnings;

    // ============ Events ============

    event ProtocolInitialized(uint256 initialLiquidity);

    event EarningsDistributed(
        uint256 indexed agentId,
        uint256 totalAmount,
        uint256 sponsorShare,
        uint256 creatorShare,
        uint256 protocolShare
    );

    event SponsorPayout(
        uint256 indexed agentId,
        address indexed sponsor,
        uint256 amount
    );

    event CreatorPayout(
        uint256 indexed agentId,
        address indexed creator,
        uint256 amount
    );

    event SubsidyGranted(
        uint256 indexed agentId,
        uint256 amount,
        string reason
    );

    event ProtocolWithdrawal(address indexed to, uint256 amount);

    // ============ Constructor ============

    /**
     * @notice Initialize protocol with required liquidity
     * @param _agentRegistry Address of AgentRegistry contract
     */
    constructor(address _agentRegistry) payable Ownable(msg.sender) {
        require(msg.value == INITIAL_PROTOCOL_LIQUIDITY, "Must send exact initial liquidity");
        require(_agentRegistry != address(0), "Invalid registry address");

        agentRegistry = AgentRegistry(payable(_agentRegistry));
        protocolTreasury = msg.value;

        emit ProtocolInitialized(msg.value);
    }

    // ============ External Functions ============

    /**
     * @notice Distribute earnings from a market to agent stakeholders
     * @param agentId ID of the agent that earned
     * @param amount Total amount to distribute
     */
    function distributeEarnings(uint256 agentId, uint256 amount)
        external
        payable
        nonReentrant
        whenNotPaused
    {
        require(msg.value == amount, "Amount mismatch");
        require(amount > 0, "Amount must be positive");

        // Calculate shares
        uint256 sponsorShare = (amount * SPONSOR_SHARE) / 100;
        uint256 creatorShare = (amount * CREATOR_SHARE) / 100;
        uint256 protocolShare = amount - sponsorShare - creatorShare;

        // Update protocol treasury
        protocolTreasury += protocolShare;

        // Get agent info
        AgentRegistry.Agent memory agent = agentRegistry.getAgent(agentId);

        // Distribute to creator
        agentEarnings[agentId] += creatorShare;
        (bool creatorSuccess, ) = agent.creator.call{value: creatorShare}("");
        require(creatorSuccess, "Creator payout failed");

        emit CreatorPayout(agentId, agent.creator, creatorShare);

        // Distribute to sponsors proportionally
        _distributeSponsorShare(agentId, sponsorShare);

        // Update stats
        totalDistributed += amount;
        agentRegistry.recordEarnings(agentId, amount);

        emit EarningsDistributed(
            agentId,
            amount,
            sponsorShare,
            creatorShare,
            protocolShare
        );
    }

    /**
     * @notice Grant subsidy to a promising agent
     * @param agentId ID of the agent
     * @param amount Subsidy amount
     * @param reason Reason for subsidy
     */
    function grantSubsidy(
        uint256 agentId,
        uint256 amount,
        string calldata reason
    ) external onlyOwner nonReentrant {
        require(amount >= MIN_SUBSIDY_AMOUNT, "Subsidy too small");
        require(
            agentSubsidies[agentId] + amount <= MAX_SUBSIDY_PER_AGENT,
            "Exceeds max subsidy per agent"
        );
        require(protocolTreasury >= amount, "Insufficient treasury");

        AgentRegistry.Agent memory agent = agentRegistry.getAgent(agentId);
        require(agent.isActive, "Agent not active");

        protocolTreasury -= amount;
        agentSubsidies[agentId] += amount;
        totalSubsidiesGiven += amount;

        (bool success, ) = agent.creator.call{value: amount}("");
        require(success, "Subsidy transfer failed");

        emit SubsidyGranted(agentId, amount, reason);
    }

    /**
     * @notice Withdraw protocol fees (owner only)
     * @param to Recipient address
     * @param amount Amount to withdraw
     */
    function withdrawProtocolFees(address to, uint256 amount)
        external
        onlyOwner
        nonReentrant
    {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be positive");
        require(protocolTreasury >= amount, "Insufficient treasury");

        protocolTreasury -= amount;

        (bool success, ) = to.call{value: amount}("");
        require(success, "Withdrawal failed");

        emit ProtocolWithdrawal(to, amount);
    }

    /**
     * @notice Emergency withdrawal (owner only, when paused)
     * @param to Recipient address
     */
    function emergencyWithdraw(address to) external onlyOwner whenPaused nonReentrant {
        require(to != address(0), "Invalid address");

        uint256 balance = address(this).balance;
        require(balance > 0, "No balance");

        (bool success, ) = to.call{value: balance}("");
        require(success, "Emergency withdrawal failed");

        emit ProtocolWithdrawal(to, balance);
    }

    // ============ View Functions ============

    function getAgentEarnings(uint256 agentId) external view returns (uint256) {
        return agentEarnings[agentId];
    }

    function getSponsorEarnings(uint256 agentId, address sponsor)
        external
        view
        returns (uint256)
    {
        return sponsorEarnings[agentId][sponsor];
    }

    function getAgentSubsidies(uint256 agentId) external view returns (uint256) {
        return agentSubsidies[agentId];
    }

    function getProtocolStats()
        external
        view
        returns (
            uint256 treasury,
            uint256 distributed,
            uint256 subsidies
        )
    {
        return (protocolTreasury, totalDistributed, totalSubsidiesGiven);
    }

    // ============ Admin Functions ============

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function updateAgentRegistry(address _agentRegistry) external onlyOwner {
        require(_agentRegistry != address(0), "Invalid address");
        agentRegistry = AgentRegistry(payable(_agentRegistry));
    }

    // ============ Internal Functions ============

    /**
     * @notice Distribute sponsor share proportionally among all sponsors
     * @param agentId ID of the agent
     * @param totalSponsorShare Total amount to distribute to sponsors
     */
    function _distributeSponsorShare(uint256 agentId, uint256 totalSponsorShare) internal {
        address[] memory sponsors = agentRegistry.getAgentSponsors(agentId);

        if (sponsors.length == 0) {
            // No sponsors, add to protocol treasury
            protocolTreasury += totalSponsorShare;
            return;
        }

        // Get total sponsored amount
        uint256 totalSponsored = agentRegistry.getAgent(agentId).sponsoredAmount;

        if (totalSponsored == 0) {
            protocolTreasury += totalSponsorShare;
            return;
        }

        // Distribute proportionally
        uint256 distributedSoFar = 0;

        for (uint256 i = 0; i < sponsors.length; i++) {
            address sponsor = sponsors[i];
            AgentRegistry.Sponsorship memory sponsorship = agentRegistry.getSponsorship(
                agentId,
                sponsor
            );

            uint256 sponsorAmount;

            if (i == sponsors.length - 1) {
                // Last sponsor gets remainder to avoid rounding issues
                sponsorAmount = totalSponsorShare - distributedSoFar;
            } else {
                sponsorAmount = (totalSponsorShare * sponsorship.amount) / totalSponsored;
                distributedSoFar += sponsorAmount;
            }

            if (sponsorAmount > 0) {
                sponsorEarnings[agentId][sponsor] += sponsorAmount;

                (bool success, ) = sponsor.call{value: sponsorAmount}("");
                require(success, "Sponsor payout failed");

                emit SponsorPayout(agentId, sponsor, sponsorAmount);
            }
        }
    }

    // ============ Receive Function ============

    receive() external payable {
        // Accept incoming ETH (e.g., from slashing)
        protocolTreasury += msg.value;
    }
}
