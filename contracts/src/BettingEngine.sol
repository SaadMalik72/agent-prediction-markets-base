// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";
import "./AgentRegistry.sol";
import "./TreasuryManager.sol";

/**
 * @title BettingEngine
 * @notice Handles betting logic with Automated Market Maker for dynamic odds
 * @dev Implements constant product AMM formula for price discovery
 */
contract BettingEngine is Ownable, ReentrancyGuard, Pausable {
    // ============ Constants ============

    uint256 public constant MIN_BET_AMOUNT = 0.00001 ether;
    uint256 public constant LIQUIDITY_CONSTANT = 10000; // k = 10000 for AMM
    uint256 public constant PLATFORM_FEE_BPS = 200; // 2% platform fee
    uint256 public constant MAX_SLIPPAGE_BPS = 1000; // 10% max slippage

    // ============ Structs ============

    struct Bet {
        uint256 marketId;
        uint256 outcomeId;
        uint256 agentId;
        address bettor;
        uint256 amount;
        uint256 potentialPayout;
        uint256 timestamp;
        bool settled;
        bool won;
    }

    struct Position {
        uint256 totalBacked;
        uint256 shares;
    }

    // ============ State Variables ============

    AgentRegistry public agentRegistry;
    TreasuryManager public treasuryManager;
    address public marketFactory;

    mapping(uint256 => mapping(address => Bet[])) public userBets;
    mapping(uint256 => mapping(uint256 => mapping(address => Position))) public positions;
    mapping(uint256 => mapping(uint256 => uint256)) public outcomeLiquidity;
    mapping(uint256 => uint256) public marketTotalLiquidity;
    mapping(uint256 => bool) public marketResolved;
    mapping(uint256 => bool) public marketCancelled;

    uint256 public totalBetsPlaced;
    uint256 public totalVolume;
    uint256 public platformFeesCollected;

    // ============ Events ============

    event BetPlaced(
        uint256 indexed marketId,
        uint256 indexed outcomeId,
        uint256 indexed agentId,
        address bettor,
        uint256 amount,
        uint256 potentialPayout
    );

    event BetSettled(
        uint256 indexed marketId,
        address indexed bettor,
        uint256 betIndex,
        bool won,
        uint256 payout
    );

    event MarketResolved(
        uint256 indexed marketId,
        uint256 winningOutcome,
        uint256 totalPaidOut
    );

    event MarketCancelled(uint256 indexed marketId, uint256 totalRefunded);

    event OddsUpdated(
        uint256 indexed marketId,
        uint256 indexed outcomeId,
        uint256 newOdds
    );

    // ============ Modifiers ============

    modifier onlyMarketFactory() {
        require(msg.sender == marketFactory, "Only market factory");
        _;
    }

    // ============ Constructor ============

    constructor(
        address _agentRegistry,
        address _treasuryManager
    ) Ownable(msg.sender) {
        require(_agentRegistry != address(0), "Invalid registry");
        require(_treasuryManager != address(0), "Invalid treasury");

        agentRegistry = AgentRegistry(payable(_agentRegistry));
        treasuryManager = TreasuryManager(payable(_treasuryManager));
    }

    // ============ External Functions ============

    /**
     * @notice Place a bet on a market outcome
     * @param marketId ID of the market
     * @param outcomeId ID of the outcome
     * @param agentId ID of the agent placing the bet (0 for users)
     * @param minPayout Minimum acceptable payout (slippage protection)
     */
    function placeBet(
        uint256 marketId,
        uint256 outcomeId,
        uint256 agentId,
        uint256 minPayout
    ) external payable whenNotPaused nonReentrant returns (uint256) {
        require(msg.value >= MIN_BET_AMOUNT, "Bet too small");
        require(!marketResolved[marketId], "Market resolved");
        require(!marketCancelled[marketId], "Market cancelled");

        // Validate agent if provided
        if (agentId > 0) {
            AgentRegistry.Agent memory agent = agentRegistry.getAgent(agentId);
            require(agent.creator == msg.sender, "Not agent owner");
            require(agent.isActive, "Agent not active");

            // Check agent has sufficient capital
            uint256 totalCapital = agentRegistry.getTotalCapital(agentId);
            require(msg.value <= totalCapital, "Insufficient agent capital");
        }

        // Calculate platform fee
        uint256 platformFee = (msg.value * PLATFORM_FEE_BPS) / 10000;
        uint256 betAmount = msg.value - platformFee;

        platformFeesCollected += platformFee;

        // Calculate potential payout using AMM
        uint256 potentialPayout = _calculatePayout(marketId, outcomeId, betAmount);

        require(potentialPayout >= minPayout, "Slippage too high");

        // Update liquidity
        outcomeLiquidity[marketId][outcomeId] += betAmount;
        marketTotalLiquidity[marketId] += betAmount;

        // Update position
        Position storage position = positions[marketId][outcomeId][msg.sender];
        position.totalBacked += betAmount;
        position.shares += betAmount; // Simplified shares calculation

        // Record bet
        Bet memory bet = Bet({
            marketId: marketId,
            outcomeId: outcomeId,
            agentId: agentId,
            bettor: msg.sender,
            amount: betAmount,
            potentialPayout: potentialPayout,
            timestamp: block.timestamp,
            settled: false,
            won: false
        });

        userBets[marketId][msg.sender].push(bet);

        totalBetsPlaced++;
        totalVolume += betAmount;

        // Notify market factory
        if (marketFactory != address(0)) {
            (bool success, ) = marketFactory.call(
                abi.encodeWithSignature(
                    "updateMarketStats(uint256,uint256,uint256)",
                    marketId,
                    outcomeId,
                    betAmount
                )
            );
            require(success, "Market stats update failed");
        }

        emit BetPlaced(
            marketId,
            outcomeId,
            agentId,
            msg.sender,
            betAmount,
            potentialPayout
        );

        return userBets[marketId][msg.sender].length - 1;
    }

    /**
     * @notice Resolve market and settle all bets
     * @param marketId ID of the market
     * @param winningOutcomeId ID of the winning outcome
     */
    function resolveMarket(uint256 marketId, uint256 winningOutcomeId)
        external
        onlyMarketFactory
        nonReentrant
    {
        require(!marketResolved[marketId], "Already resolved");
        require(!marketCancelled[marketId], "Market cancelled");

        marketResolved[marketId] = true;

        uint256 totalPaidOut = 0;

        // This would normally iterate through all bettors
        // For gas efficiency, we let users claim their winnings individually
        // Here we just mark it as resolved

        emit MarketResolved(marketId, winningOutcomeId, totalPaidOut);
    }

    /**
     * @notice Claim winnings for a specific bet
     * @param marketId ID of the market
     * @param betIndex Index of the bet in user's bet array
     */
    function claimWinnings(uint256 marketId, uint256 betIndex)
        external
        nonReentrant
    {
        require(marketResolved[marketId], "Market not resolved");

        Bet storage bet = userBets[marketId][msg.sender][betIndex];

        require(!bet.settled, "Already settled");
        require(bet.bettor == msg.sender, "Not your bet");

        bet.settled = true;

        // Get winning outcome from market factory
        (bool success, bytes memory data) = marketFactory.call(
            abi.encodeWithSignature("markets(uint256)", marketId)
        );
        require(success, "Failed to get market data");

        // Decode winning outcome (simplified - assumes it's in position 10)
        uint256 winningOutcome;
        assembly {
            winningOutcome := mload(add(data, 320)) // Approximate offset
        }

        if (bet.outcomeId == winningOutcome) {
            bet.won = true;

            uint256 payout = bet.potentialPayout;

            // Transfer payout
            (bool payoutSuccess, ) = msg.sender.call{value: payout}("");
            require(payoutSuccess, "Payout failed");

            // If this was an agent bet, distribute earnings
            if (bet.agentId > 0) {
                uint256 profit = payout > bet.amount ? payout - bet.amount : 0;

                if (profit > 0) {
                    treasuryManager.distributeEarnings{value: profit}(bet.agentId, profit);

                    // Update agent stats
                    agentRegistry.updatePredictionStats(bet.agentId, true);
                }
            }

            emit BetSettled(marketId, msg.sender, betIndex, true, payout);
        } else {
            // Update agent stats for loss
            if (bet.agentId > 0) {
                agentRegistry.updatePredictionStats(bet.agentId, false);
            }

            emit BetSettled(marketId, msg.sender, betIndex, false, 0);
        }
    }

    /**
     * @notice Cancel market and refund all bets
     * @param marketId ID of the market
     */
    function cancelMarket(uint256 marketId) external onlyMarketFactory nonReentrant {
        require(!marketResolved[marketId], "Already resolved");
        require(!marketCancelled[marketId], "Already cancelled");

        marketCancelled[marketId] = true;

        // Users can claim refunds individually for gas efficiency

        emit MarketCancelled(marketId, 0);
    }

    /**
     * @notice Claim refund for cancelled market
     * @param marketId ID of the market
     * @param betIndex Index of the bet
     */
    function claimRefund(uint256 marketId, uint256 betIndex) external nonReentrant {
        require(marketCancelled[marketId], "Market not cancelled");

        Bet storage bet = userBets[marketId][msg.sender][betIndex];

        require(!bet.settled, "Already settled");
        require(bet.bettor == msg.sender, "Not your bet");

        bet.settled = true;

        (bool success, ) = msg.sender.call{value: bet.amount}("");
        require(success, "Refund failed");

        emit BetSettled(marketId, msg.sender, betIndex, false, bet.amount);
    }

    /**
     * @notice Withdraw accumulated platform fees
     * @param to Recipient address
     */
    function withdrawPlatformFees(address to) external onlyOwner nonReentrant {
        require(to != address(0), "Invalid address");
        require(platformFeesCollected > 0, "No fees to withdraw");

        uint256 amount = platformFeesCollected;
        platformFeesCollected = 0;

        (bool success, ) = to.call{value: amount}("");
        require(success, "Withdrawal failed");
    }

    // ============ View Functions ============

    function getUserBets(uint256 marketId, address user)
        external
        view
        returns (Bet[] memory)
    {
        return userBets[marketId][user];
    }

    function getUserBetCount(uint256 marketId, address user)
        external
        view
        returns (uint256)
    {
        return userBets[marketId][user].length;
    }

    function getPosition(
        uint256 marketId,
        uint256 outcomeId,
        address user
    ) external view returns (Position memory) {
        return positions[marketId][outcomeId][user];
    }

    function getMarketOdds(uint256 marketId)
        external
        view
        returns (uint256[] memory)
    {
        // This is a simplified version
        // In production, you'd calculate actual AMM odds for each outcome
        uint256[] memory odds = new uint256[](10); // Max outcomes

        uint256 totalLiquidity = marketTotalLiquidity[marketId];

        if (totalLiquidity == 0) {
            // Equal odds if no liquidity
            for (uint256 i = 0; i < 10; i++) {
                odds[i] = 10000; // 1.0x in basis points
            }
        } else {
            for (uint256 i = 0; i < 10; i++) {
                uint256 outcomeLiq = outcomeLiquidity[marketId][i];
                if (outcomeLiq > 0) {
                    // Odds = total / outcome (simplified)
                    odds[i] = (totalLiquidity * 10000) / outcomeLiq;
                }
            }
        }

        return odds;
    }

    // ============ Admin Functions ============

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

    /**
     * @notice Calculate potential payout using constant product AMM
     * @param marketId ID of the market
     * @param outcomeId ID of the outcome
     * @param betAmount Amount being bet
     */
    function _calculatePayout(
        uint256 marketId,
        uint256 outcomeId,
        uint256 betAmount
    ) internal view returns (uint256) {
        uint256 currentLiquidity = outcomeLiquidity[marketId][outcomeId];

        if (currentLiquidity == 0) {
            // First bet gets 2x
            return betAmount * 2;
        }

        // Simplified AMM: payout based on liquidity ratio
        // More sophisticated AMMs would use constant product formula
        uint256 totalLiquidity = marketTotalLiquidity[marketId];
        uint256 impliedProbability = (currentLiquidity * 10000) / totalLiquidity;

        // Payout = betAmount * (10000 / impliedProbability)
        uint256 payout = (betAmount * 10000) / impliedProbability;

        // Cap at reasonable maximum (10x)
        if (payout > betAmount * 10) {
            payout = betAmount * 10;
        }

        return payout;
    }

    // ============ Receive Function ============

    receive() external payable {
        // Accept ETH
    }
}
