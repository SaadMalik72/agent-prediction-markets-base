// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Test.sol";
import "../src/AgentRegistry.sol";
import "../src/TreasuryManager.sol";
import "../src/MarketFactory.sol";
import "../src/BettingEngine.sol";
import "../src/OracleResolver.sol";

/**
 * @title AgentPredictionMarketsTest
 * @notice Comprehensive tests for the Agent Prediction Markets system
 */
contract AgentPredictionMarketsTest is Test {
    AgentRegistry public agentRegistry;
    TreasuryManager public treasuryManager;
    MarketFactory public marketFactory;
    BettingEngine public bettingEngine;
    OracleResolver public oracleResolver;

    address public deployer;
    address public alice;
    address public bob;
    address public charlie;

    uint256 constant INITIAL_LIQUIDITY = 0.001 ether;
    uint256 constant MIN_AGENT_STAKE = 0.0001 ether;
    uint256 constant MIN_SPONSORSHIP = 0.00005 ether;
    uint256 constant MIN_BET = 0.00001 ether;

    event AgentRegistered(uint256 indexed agentId, address indexed creator, string name, uint256 stakedAmount);
    event AgentSponsored(uint256 indexed agentId, address indexed sponsor, uint256 amount, uint256 totalSponsored);
    event MarketCreated(uint256 indexed marketId, uint256 indexed agentId, address indexed creator, string question, uint256 endTime);

    function setUp() public {
        deployer = address(this);
        alice = makeAddr("alice");
        bob = makeAddr("bob");
        charlie = makeAddr("charlie");

        // Fund test accounts
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
        vm.deal(charlie, 10 ether);

        // Deploy contracts
        agentRegistry = new AgentRegistry();
        treasuryManager = new TreasuryManager{value: INITIAL_LIQUIDITY}(address(agentRegistry));
        bettingEngine = new BettingEngine(address(agentRegistry), address(treasuryManager));
        oracleResolver = new OracleResolver();
        marketFactory = new MarketFactory(
            address(agentRegistry),
            address(bettingEngine),
            address(oracleResolver)
        );

        // Set cross-contract references
        agentRegistry.setTreasuryManager(address(treasuryManager));
        agentRegistry.setMarketFactory(address(marketFactory));
        bettingEngine.setMarketFactory(address(marketFactory));
        oracleResolver.setMarketFactory(address(marketFactory));
    }

    // ============ AgentRegistry Tests ============

    function testRegisterAgent() public {
        vm.startPrank(alice);

        vm.expectEmit(true, true, false, true);
        emit AgentRegistered(0, alice, "AliceBot", MIN_AGENT_STAKE);

        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        assertEq(agentId, 0);

        AgentRegistry.Agent memory agent = agentRegistry.getAgent(agentId);
        assertEq(agent.creator, alice);
        assertEq(agent.name, "AliceBot");
        assertEq(agent.stakedAmount, MIN_AGENT_STAKE);
        assertEq(agent.isActive, true);

        vm.stopPrank();
    }

    function testRegisterAgentInsufficientStake() public {
        vm.startPrank(alice);

        vm.expectRevert("Insufficient stake");
        agentRegistry.registerAgent{value: MIN_AGENT_STAKE - 1}(
            "AliceBot",
            "ipfs://metadata"
        );

        vm.stopPrank();
    }

    function testSponsorAgent() public {
        // Alice registers agent
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        // Bob sponsors agent
        vm.startPrank(bob);

        vm.expectEmit(true, true, false, true);
        emit AgentSponsored(agentId, bob, MIN_SPONSORSHIP, MIN_SPONSORSHIP);

        agentRegistry.sponsorAgent{value: MIN_SPONSORSHIP}(agentId);

        AgentRegistry.Agent memory agent = agentRegistry.getAgent(agentId);
        assertEq(agent.sponsoredAmount, MIN_SPONSORSHIP);

        vm.stopPrank();
    }

    function testSponsorshipTooLow() public {
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        vm.startPrank(bob);
        vm.expectRevert("Sponsorship too low");
        agentRegistry.sponsorAgent{value: MIN_SPONSORSHIP - 1}(agentId);
        vm.stopPrank();
    }

    function testWithdrawalFlow() public {
        vm.startPrank(alice);

        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE * 2}(
            "AliceBot",
            "ipfs://metadata"
        );

        // Request withdrawal
        agentRegistry.requestWithdrawal(agentId, MIN_AGENT_STAKE);

        // Try to process before cooldown
        vm.expectRevert("Cooldown not finished");

        uint256 requestId = uint256(keccak256(abi.encodePacked(agentId, alice, block.timestamp)));
        agentRegistry.processWithdrawal(agentId, requestId);

        // Fast forward past cooldown
        vm.warp(block.timestamp + 7 days + 1);

        // Process withdrawal
        uint256 balanceBefore = alice.balance;
        agentRegistry.processWithdrawal(agentId, requestId);
        uint256 balanceAfter = alice.balance;

        assertEq(balanceAfter - balanceBefore, MIN_AGENT_STAKE);

        vm.stopPrank();
    }

    function testAddStake() public {
        vm.startPrank(alice);

        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        agentRegistry.addStake{value: MIN_AGENT_STAKE}(agentId);

        AgentRegistry.Agent memory agent = agentRegistry.getAgent(agentId);
        assertEq(agent.stakedAmount, MIN_AGENT_STAKE * 2);

        vm.stopPrank();
    }

    // ============ TreasuryManager Tests ============

    function testInitialLiquidity() public {
        (uint256 treasury, , ) = treasuryManager.getProtocolStats();
        assertEq(treasury, INITIAL_LIQUIDITY);
    }

    function testDistributeEarnings() public {
        // Register agent
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        // Sponsor agent
        vm.prank(bob);
        agentRegistry.sponsorAgent{value: MIN_SPONSORSHIP}(agentId);

        // Distribute earnings
        uint256 earnings = 0.001 ether;
        uint256 aliceBalanceBefore = alice.balance;
        uint256 bobBalanceBefore = bob.balance;

        treasuryManager.distributeEarnings{value: earnings}(agentId, earnings);

        uint256 aliceBalanceAfter = alice.balance;
        uint256 bobBalanceAfter = bob.balance;

        // Creator should get 30%
        assertEq(aliceBalanceAfter - aliceBalanceBefore, (earnings * 30) / 100);

        // Sponsor should get 60%
        assertEq(bobBalanceAfter - bobBalanceBefore, (earnings * 60) / 100);
    }

    function testGrantSubsidy() public {
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        uint256 subsidyAmount = 0.0001 ether;
        uint256 aliceBalanceBefore = alice.balance;

        treasuryManager.grantSubsidy(agentId, subsidyAmount, "Promising agent");

        uint256 aliceBalanceAfter = alice.balance;
        assertEq(aliceBalanceAfter - aliceBalanceBefore, subsidyAmount);

        assertEq(treasuryManager.getAgentSubsidies(agentId), subsidyAmount);
    }

    // ============ MarketFactory Tests ============

    function testCreateMarket() public {
        // Register agent
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        // Create market
        vm.startPrank(alice);

        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        uint256 marketId = marketFactory.createMarket(
            agentId,
            "Will ETH reach $5000 by end of year?",
            "Prediction about ETH price",
            MarketFactory.MarketCategory.Crypto,
            7 days,
            outcomes,
            false
        );

        assertEq(marketId, 1);

        MarketFactory.Market memory market = marketFactory.getMarket(marketId);
        assertEq(market.creator, alice);
        assertEq(market.creatorAgentId, agentId);
        assertEq(market.question, "Will ETH reach $5000 by end of year?");
        assertTrue(uint8(market.status) == uint8(MarketFactory.MarketStatus.Active));

        vm.stopPrank();
    }

    function testCreateMarketInvalidDuration() public {
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        vm.startPrank(alice);

        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        vm.expectRevert("Duration too short");
        marketFactory.createMarket(
            agentId,
            "Test question",
            "Test description",
            MarketFactory.MarketCategory.Crypto,
            30 minutes,
            outcomes,
            false
        );

        vm.stopPrank();
    }

    function testCloseMarket() public {
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        vm.startPrank(alice);

        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        uint256 marketId = marketFactory.createMarket(
            agentId,
            "Test question",
            "Test description",
            MarketFactory.MarketCategory.Crypto,
            1 hours,
            outcomes,
            false
        );

        // Fast forward past end time
        vm.warp(block.timestamp + 1 hours + 1);

        marketFactory.closeMarket(marketId);

        MarketFactory.Market memory market = marketFactory.getMarket(marketId);
        assertTrue(uint8(market.status) == uint8(MarketFactory.MarketStatus.Closed));

        vm.stopPrank();
    }

    // ============ BettingEngine Tests ============

    function testPlaceBet() public {
        // Setup market
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        vm.startPrank(alice);
        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        uint256 marketId = marketFactory.createMarket(
            agentId,
            "Test question",
            "Test description",
            MarketFactory.MarketCategory.Crypto,
            7 days,
            outcomes,
            false
        );
        vm.stopPrank();

        // Place bet
        vm.startPrank(bob);
        uint256 betAmount = 0.0001 ether;

        uint256 betIndex = bettingEngine.placeBet{value: betAmount}(
            marketId,
            0, // outcome 0 (Yes)
            0, // no agent
            0  // no min payout
        );

        assertEq(betIndex, 0);

        BettingEngine.Bet[] memory bets = bettingEngine.getUserBets(marketId, bob);
        assertEq(bets.length, 1);
        assertEq(bets[0].amount, betAmount - (betAmount * 200) / 10000); // minus platform fee

        vm.stopPrank();
    }

    function testBetTooSmall() public {
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        vm.startPrank(alice);
        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        uint256 marketId = marketFactory.createMarket(
            agentId,
            "Test question",
            "Test description",
            MarketFactory.MarketCategory.Crypto,
            7 days,
            outcomes,
            false
        );
        vm.stopPrank();

        vm.startPrank(bob);
        vm.expectRevert("Bet too small");
        bettingEngine.placeBet{value: MIN_BET - 1}(marketId, 0, 0, 0);
        vm.stopPrank();
    }

    // ============ OracleResolver Tests ============

    function testProposeResolution() public {
        // Setup market
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        vm.startPrank(alice);
        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        uint256 marketId = marketFactory.createMarket(
            agentId,
            "Test question",
            "Test description",
            MarketFactory.MarketCategory.Crypto,
            1 hours,
            outcomes,
            false
        );
        vm.stopPrank();

        // Close market
        vm.warp(block.timestamp + 1 hours + 1);
        vm.prank(alice);
        marketFactory.closeMarket(marketId);

        // Propose resolution as owner (trusted oracle)
        oracleResolver.proposeResolution(marketId, 0);

        OracleResolver.Resolution memory resolution = oracleResolver.getResolution(marketId);
        assertEq(resolution.proposedOutcome, 0);
        assertTrue(uint8(resolution.status) == uint8(OracleResolver.ResolutionStatus.Proposed));
    }

    function testVoteOnResolution() public {
        // Setup and propose resolution
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        vm.startPrank(alice);
        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        uint256 marketId = marketFactory.createMarket(
            agentId,
            "Test question",
            "Test description",
            MarketFactory.MarketCategory.Crypto,
            1 hours,
            outcomes,
            false
        );
        vm.stopPrank();

        vm.warp(block.timestamp + 1 hours + 1);
        vm.prank(alice);
        marketFactory.closeMarket(marketId);

        oracleResolver.proposeResolution(marketId, 0);

        // Vote
        vm.prank(bob);
        oracleResolver.vote(marketId, true);

        (uint256 forVotes, uint256 againstVotes) = oracleResolver.getVoteCount(marketId);
        assertGt(forVotes, 0);
    }

    // ============ Integration Tests ============

    function testFullMarketLifecycle() public {
        // 1. Alice registers an agent
        vm.prank(alice);
        uint256 agentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://metadata"
        );

        // 2. Bob sponsors the agent
        vm.prank(bob);
        agentRegistry.sponsorAgent{value: MIN_SPONSORSHIP}(agentId);

        // 3. Alice creates a market
        vm.startPrank(alice);
        string[] memory outcomes = new string[](2);
        outcomes[0] = "Yes";
        outcomes[1] = "No";

        uint256 marketId = marketFactory.createMarket(
            agentId,
            "Will ETH reach $5000?",
            "Test market",
            MarketFactory.MarketCategory.Crypto,
            1 hours,
            outcomes,
            false
        );
        vm.stopPrank();

        // 4. Charlie places a bet
        vm.prank(charlie);
        bettingEngine.placeBet{value: 0.001 ether}(marketId, 0, 0, 0);

        // 5. Market ends
        vm.warp(block.timestamp + 1 hours + 1);

        // 6. Close market
        vm.prank(alice);
        marketFactory.closeMarket(marketId);

        // 7. Propose resolution
        oracleResolver.proposeResolution(marketId, 0);

        // 8. Vote on resolution
        vm.prank(bob);
        oracleResolver.vote(marketId, true);

        vm.prank(charlie);
        oracleResolver.vote(marketId, true);

        // 9. Finalize resolution
        vm.warp(block.timestamp + 1 days);
        oracleResolver.finalizeResolution(marketId);

        // Verify market is resolved
        MarketFactory.Market memory market = marketFactory.getMarket(marketId);
        assertTrue(uint8(market.status) == uint8(MarketFactory.MarketStatus.Resolved));
    }

    function testMultipleAgentsAndSponsors() public {
        // Alice and Bob register agents
        vm.prank(alice);
        uint256 aliceAgentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "AliceBot",
            "ipfs://alice"
        );

        vm.prank(bob);
        uint256 bobAgentId = agentRegistry.registerAgent{value: MIN_AGENT_STAKE}(
            "BobBot",
            "ipfs://bob"
        );

        // Charlie sponsors both
        vm.startPrank(charlie);
        agentRegistry.sponsorAgent{value: MIN_SPONSORSHIP}(aliceAgentId);
        agentRegistry.sponsorAgent{value: MIN_SPONSORSHIP}(bobAgentId);
        vm.stopPrank();

        // Verify sponsorships
        AgentRegistry.Agent memory aliceAgent = agentRegistry.getAgent(aliceAgentId);
        AgentRegistry.Agent memory bobAgent = agentRegistry.getAgent(bobAgentId);

        assertEq(aliceAgent.sponsoredAmount, MIN_SPONSORSHIP);
        assertEq(bobAgent.sponsoredAmount, MIN_SPONSORSHIP);
    }

    receive() external payable {}
}
