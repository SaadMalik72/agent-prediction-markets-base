#!/bin/bash

# Quick Start - Create a complete example workflow
# Registers an agent, creates a market, and places a bet

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Agent Prediction Markets - Quick Start${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Load deployment addresses
DEPLOYMENT_FILE="deployments/base-mainnet.json"
AGENT_REGISTRY=$(grep -o '"agentRegistry": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
MARKET_FACTORY=$(grep -o '"marketFactory": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
BETTING_ENGINE=$(grep -o '"bettingEngine": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)

RPC_URL="https://mainnet.base.org"

# Load environment
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

DEPLOYER=$(cast wallet address --private-key $PRIVATE_KEY)

echo -e "${GREEN}Your address: $DEPLOYER${NC}"
echo -e "${GREEN}Contracts loaded from: $DEPLOYMENT_FILE${NC}\n"

# Step 1: Register Agent
echo -e "${YELLOW}Step 1/4: Registering AI Agent...${NC}"
TX1=$(cast send $AGENT_REGISTRY \
    "registerAgent(string,string)" \
    "QuickStartBot" \
    "ipfs://QmQuickStart123" \
    --value 0.0001ether \
    --private-key $PRIVATE_KEY \
    --rpc-url $RPC_URL \
    2>/dev/null)

TOTAL_AGENTS=$(cast call $AGENT_REGISTRY "totalAgents()(uint256)" --rpc-url $RPC_URL)
AGENT_ID=$((TOTAL_AGENTS - 1))

echo -e "${GREEN}✓ Agent registered! ID: $AGENT_ID${NC}"
echo -e "  Transaction: $TX1\n"

sleep 2

# Step 2: Add Sponsorship
echo -e "${YELLOW}Step 2/4: Sponsoring Agent...${NC}"
TX2=$(cast send $AGENT_REGISTRY \
    "sponsorAgent(uint256)" \
    $AGENT_ID \
    --value 0.0001ether \
    --private-key $PRIVATE_KEY \
    --rpc-url $RPC_URL \
    2>/dev/null)

echo -e "${GREEN}✓ Agent sponsored with 0.0001 ETH!${NC}"
echo -e "  Transaction: $TX2\n"

sleep 2

# Step 3: Create Market
echo -e "${YELLOW}Step 3/4: Creating Prediction Market...${NC}"
QUESTION="Will ETH reach \\$5000 by end of 2025?"
OUTCOME1="Yes"
OUTCOME2="No"

TX3=$(cast send $MARKET_FACTORY \
    "createMarket(uint256,string,string,uint8,uint256,string[],bool)" \
    $AGENT_ID \
    "$QUESTION" \
    "Ethereum price prediction market" \
    0 \
    $((30 * 86400)) \
    "[\"$OUTCOME1\",\"$OUTCOME2\"]" \
    false \
    --private-key $PRIVATE_KEY \
    --rpc-url $RPC_URL \
    2>/dev/null)

TOTAL_MARKETS=$(cast call $MARKET_FACTORY "totalMarkets()(uint256)" --rpc-url $RPC_URL)
MARKET_ID=$TOTAL_MARKETS

echo -e "${GREEN}✓ Market created! ID: $MARKET_ID${NC}"
echo -e "  Question: $QUESTION"
echo -e "  Transaction: $TX3\n"

sleep 2

# Step 4: Place Bet
echo -e "${YELLOW}Step 4/4: Placing Bet...${NC}"
TX4=$(cast send $BETTING_ENGINE \
    "placeBet(uint256,uint256,uint256,uint256)" \
    $MARKET_ID \
    0 \
    $AGENT_ID \
    0 \
    --value 0.0001ether \
    --private-key $PRIVATE_KEY \
    --rpc-url $RPC_URL \
    2>/dev/null)

echo -e "${GREEN}✓ Bet placed on outcome 'Yes'!${NC}"
echo -e "  Amount: 0.0001 ETH"
echo -e "  Transaction: $TX4\n"

# Summary
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Quick Start Complete!${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${GREEN}Summary:${NC}"
echo -e "  Agent ID:  $AGENT_ID (QuickStartBot)"
echo -e "  Market ID: $MARKET_ID"
echo -e "  Bet:       0.0001 ETH on 'Yes'"
echo -e ""
echo -e "${GREEN}View on BaseScan:${NC}"
echo -e "  Agent:  https://basescan.org/address/$AGENT_REGISTRY"
echo -e "  Market: https://basescan.org/address/$MARKET_FACTORY"
echo -e ""
echo -e "${GREEN}Next steps:${NC}"
echo -e "  - Run './scripts/view-agent.sh $AGENT_ID' to see agent details"
echo -e "  - Run './scripts/view-market.sh $MARKET_ID' to see market details"
echo -e "  - Run './scripts/demo.sh' for interactive demo"
echo -e ""
