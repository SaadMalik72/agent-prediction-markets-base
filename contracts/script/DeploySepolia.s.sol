// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "../src/AgentRegistry.sol";
import "../src/TreasuryManager.sol";
import "../src/MarketFactory.sol";
import "../src/BettingEngine.sol";
import "../src/OracleResolver.sol";

/**
 * @title DeploySepoliaScript
 * @notice Deployment script for Agent Prediction Markets on Base Sepolia testnet
 * @dev Run with: forge script contracts/script/DeploySepolia.s.sol --rpc-url base_sepolia --broadcast --verify
 */
contract DeploySepoliaScript is Script {
    uint256 constant INITIAL_PROTOCOL_LIQUIDITY = 0.001 ether;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying to Base Sepolia testnet...");
        console.log("Deployer:", deployer);
        console.log("Balance:", deployer.balance);

        require(deployer.balance >= INITIAL_PROTOCOL_LIQUIDITY, "Insufficient balance");

        vm.startBroadcast(deployerPrivateKey);

        // Deploy all contracts
        AgentRegistry agentRegistry = new AgentRegistry();
        console.log("AgentRegistry:", address(agentRegistry));

        TreasuryManager treasuryManager = new TreasuryManager{value: INITIAL_PROTOCOL_LIQUIDITY}(
            address(agentRegistry)
        );
        console.log("TreasuryManager:", address(treasuryManager));

        BettingEngine bettingEngine = new BettingEngine(
            address(agentRegistry),
            address(treasuryManager)
        );
        console.log("BettingEngine:", address(bettingEngine));

        OracleResolver oracleResolver = new OracleResolver();
        console.log("OracleResolver:", address(oracleResolver));

        MarketFactory marketFactory = new MarketFactory(
            address(agentRegistry),
            address(bettingEngine),
            address(oracleResolver)
        );
        console.log("MarketFactory:", address(marketFactory));

        // Setup references
        agentRegistry.setTreasuryManager(address(treasuryManager));
        agentRegistry.setMarketFactory(address(marketFactory));
        bettingEngine.setMarketFactory(address(marketFactory));
        oracleResolver.setMarketFactory(address(marketFactory));

        console.log("\n=== Base Sepolia Deployment Complete ===");

        vm.stopBroadcast();
    }
}
