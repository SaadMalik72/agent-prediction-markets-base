// SPDX-License-Identifier: MIT
pragma solidity 0.8.24;

import "forge-std/Script.sol";
import "../src/AgentRegistry.sol";
import "../src/TreasuryManager.sol";
import "../src/MarketFactory.sol";
import "../src/BettingEngine.sol";
import "../src/OracleResolver.sol";

/**
 * @title DeployScript
 * @notice Deployment script for Agent Prediction Markets on Base
 * @dev Run with: forge script contracts/script/Deploy.s.sol --rpc-url base_mainnet --broadcast --verify
 */
contract DeployScript is Script {
    uint256 constant INITIAL_PROTOCOL_LIQUIDITY = 0.001 ether;

    AgentRegistry public agentRegistry;
    TreasuryManager public treasuryManager;
    MarketFactory public marketFactory;
    BettingEngine public bettingEngine;
    OracleResolver public oracleResolver;

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);

        console.log("Deploying contracts with account:", deployer);
        console.log("Account balance:", deployer.balance);

        require(deployer.balance >= INITIAL_PROTOCOL_LIQUIDITY, "Insufficient balance for deployment");

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy AgentRegistry
        console.log("\n1. Deploying AgentRegistry...");
        agentRegistry = new AgentRegistry();
        console.log("AgentRegistry deployed at:", address(agentRegistry));

        // 2. Deploy TreasuryManager with initial liquidity
        console.log("\n2. Deploying TreasuryManager with", INITIAL_PROTOCOL_LIQUIDITY, "ETH...");
        treasuryManager = new TreasuryManager{value: INITIAL_PROTOCOL_LIQUIDITY}(
            address(agentRegistry)
        );
        console.log("TreasuryManager deployed at:", address(treasuryManager));

        // 3. Deploy BettingEngine
        console.log("\n3. Deploying BettingEngine...");
        bettingEngine = new BettingEngine(
            address(agentRegistry),
            address(treasuryManager)
        );
        console.log("BettingEngine deployed at:", address(bettingEngine));

        // 4. Deploy OracleResolver
        console.log("\n4. Deploying OracleResolver...");
        oracleResolver = new OracleResolver();
        console.log("OracleResolver deployed at:", address(oracleResolver));

        // 5. Deploy MarketFactory
        console.log("\n5. Deploying MarketFactory...");
        marketFactory = new MarketFactory(
            address(agentRegistry),
            address(bettingEngine),
            address(oracleResolver)
        );
        console.log("MarketFactory deployed at:", address(marketFactory));

        // 6. Set cross-contract references
        console.log("\n6. Setting up cross-contract references...");
        agentRegistry.setTreasuryManager(address(treasuryManager));
        agentRegistry.setMarketFactory(address(marketFactory));
        bettingEngine.setMarketFactory(address(marketFactory));
        oracleResolver.setMarketFactory(address(marketFactory));

        console.log("\n=== Deployment Complete ===");
        console.log("AgentRegistry:", address(agentRegistry));
        console.log("TreasuryManager:", address(treasuryManager));
        console.log("BettingEngine:", address(bettingEngine));
        console.log("OracleResolver:", address(oracleResolver));
        console.log("MarketFactory:", address(marketFactory));

        vm.stopBroadcast();

        // Save deployment addresses to file
        _saveDeploymentInfo();
    }

    function _saveDeploymentInfo() internal {
        string memory json = string.concat(
            '{\n',
            '  "agentRegistry": "', vm.toString(address(agentRegistry)), '",\n',
            '  "treasuryManager": "', vm.toString(address(treasuryManager)), '",\n',
            '  "bettingEngine": "', vm.toString(address(bettingEngine)), '",\n',
            '  "oracleResolver": "', vm.toString(address(oracleResolver)), '",\n',
            '  "marketFactory": "', vm.toString(address(marketFactory)), '",\n',
            '  "network": "base",\n',
            '  "deployer": "', vm.toString(msg.sender), '",\n',
            '  "timestamp": "', vm.toString(block.timestamp), '"\n',
            '}'
        );

        vm.writeFile("deployments/base-mainnet.json", json);
        console.log("\nDeployment info saved to deployments/base-mainnet.json");
    }
}
