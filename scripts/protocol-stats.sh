#!/bin/bash

# View Protocol Statistics

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Load deployment addresses
DEPLOYMENT_FILE="deployments/base-mainnet.json"
AGENT_REGISTRY=$(grep -o '"agentRegistry": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
TREASURY_MANAGER=$(grep -o '"treasuryManager": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
MARKET_FACTORY=$(grep -o '"marketFactory": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
BETTING_ENGINE=$(grep -o '"bettingEngine": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)

RPC_URL="https://mainnet.base.org"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Protocol Statistics${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${YELLOW}Fetching data from blockchain...${NC}\n"

# Agent Registry Stats
TOTAL_AGENTS=$(cast call $AGENT_REGISTRY "totalAgents()(uint256)" --rpc-url $RPC_URL)
TOTAL_STAKED=$(cast call $AGENT_REGISTRY "totalStaked()(uint256)" --rpc-url $RPC_URL)
TOTAL_SPONSORED=$(cast call $AGENT_REGISTRY "totalSponsored()(uint256)" --rpc-url $RPC_URL)

TOTAL_STAKED_ETH=$(cast to-unit $TOTAL_STAKED ether)
TOTAL_SPONSORED_ETH=$(cast to-unit $TOTAL_SPONSORED ether)

# Market Factory Stats
TOTAL_MARKETS=$(cast call $MARKET_FACTORY "totalMarkets()(uint256)" --rpc-url $RPC_URL)
ACTIVE_MARKETS=$(cast call $MARKET_FACTORY "activeMarkets()(uint256)" --rpc-url $RPC_URL)
TOTAL_VOLUME=$(cast call $MARKET_FACTORY "totalVolume()(uint256)" --rpc-url $RPC_URL)

TOTAL_VOLUME_ETH=$(cast to-unit $TOTAL_VOLUME ether)

# Betting Engine Stats
TOTAL_BETS=$(cast call $BETTING_ENGINE "totalBetsPlaced()(uint256)" --rpc-url $RPC_URL)
BETTING_VOLUME=$(cast call $BETTING_ENGINE "totalVolume()(uint256)" --rpc-url $RPC_URL)
PLATFORM_FEES=$(cast call $BETTING_ENGINE "platformFeesCollected()(uint256)" --rpc-url $RPC_URL)

BETTING_VOLUME_ETH=$(cast to-unit $BETTING_VOLUME ether)
PLATFORM_FEES_ETH=$(cast to-unit $PLATFORM_FEES ether)

# Treasury Stats
TREASURY_STATS=$(cast call $TREASURY_MANAGER \
    "getProtocolStats()(uint256,uint256,uint256)" \
    --rpc-url $RPC_URL)

TREASURY=$(echo $TREASURY_STATS | cut -d' ' -f1)
DISTRIBUTED=$(echo $TREASURY_STATS | cut -d' ' -f2)
SUBSIDIES=$(echo $TREASURY_STATS | cut -d' ' -f3)

TREASURY_ETH=$(cast to-unit $TREASURY ether)
DISTRIBUTED_ETH=$(cast to-unit $DISTRIBUTED ether)
SUBSIDIES_ETH=$(cast to-unit $SUBSIDIES ether)

# Display Results
echo -e "${GREEN}📊 Agent Registry${NC}"
echo -e "  Total Agents:      $TOTAL_AGENTS"
echo -e "  Total Staked:      $TOTAL_STAKED_ETH ETH"
echo -e "  Total Sponsored:   $TOTAL_SPONSORED_ETH ETH"
echo -e ""

echo -e "${GREEN}📈 Markets${NC}"
echo -e "  Total Markets:     $TOTAL_MARKETS"
echo -e "  Active Markets:    $ACTIVE_MARKETS"
echo -e "  Total Volume:      $TOTAL_VOLUME_ETH ETH"
echo -e ""

echo -e "${GREEN}🎲 Betting${NC}"
echo -e "  Total Bets:        $TOTAL_BETS"
echo -e "  Betting Volume:    $BETTING_VOLUME_ETH ETH"
echo -e "  Platform Fees:     $PLATFORM_FEES_ETH ETH"
echo -e ""

echo -e "${GREEN}💰 Treasury${NC}"
echo -e "  Protocol Balance:  $TREASURY_ETH ETH"
echo -e "  Total Distributed: $DISTRIBUTED_ETH ETH"
echo -e "  Total Subsidies:   $SUBSIDIES_ETH ETH"
echo -e ""

echo -e "${GREEN}🔗 Contract Addresses${NC}"
echo -e "  AgentRegistry:     $AGENT_REGISTRY"
echo -e "  TreasuryManager:   $TREASURY_MANAGER"
echo -e "  MarketFactory:     $MARKET_FACTORY"
echo -e "  BettingEngine:     $BETTING_ENGINE"
echo -e ""

echo -e "${GREEN}View on BaseScan:${NC}"
echo -e "  https://basescan.org/address/$TREASURY_MANAGER"
echo -e ""
