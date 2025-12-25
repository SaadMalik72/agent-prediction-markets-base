#!/bin/bash

# View Agent Information

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

AGENT_ID=${1:-0}

# Load deployment addresses
DEPLOYMENT_FILE="deployments/base-mainnet.json"
AGENT_REGISTRY=$(grep -o '"agentRegistry": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
RPC_URL="https://mainnet.base.org"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Agent #$AGENT_ID Information${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Get agent data
echo -e "${YELLOW}Fetching agent data...${NC}\n"

# Get basic info
CREATOR=$(cast call $AGENT_REGISTRY \
    "agents(uint256)(address)" \
    $AGENT_ID \
    --rpc-url $RPC_URL)

# Get total capital
TOTAL_CAPITAL=$(cast call $AGENT_REGISTRY \
    "getTotalCapital(uint256)(uint256)" \
    $AGENT_ID \
    --rpc-url $RPC_URL)

TOTAL_CAPITAL_ETH=$(cast to-unit $TOTAL_CAPITAL ether)

# Get performance
PERFORMANCE=$(cast call $AGENT_REGISTRY \
    "getAgentPerformance(uint256)(uint256,uint256,uint256)" \
    $AGENT_ID \
    --rpc-url $RPC_URL)

# Parse performance
TOTAL_PREDICTIONS=$(echo $PERFORMANCE | cut -d' ' -f1)
CORRECT_PREDICTIONS=$(echo $PERFORMANCE | cut -d' ' -f2)
WIN_RATE=$(echo $PERFORMANCE | cut -d' ' -f3)

# Calculate win rate percentage
if [ "$TOTAL_PREDICTIONS" != "0" ]; then
    WIN_RATE_PERCENT=$(echo "scale=2; $WIN_RATE / 100" | bc)
else
    WIN_RATE_PERCENT="0.00"
fi

echo -e "${GREEN}Agent Details:${NC}"
echo -e "  Creator:           $CREATOR"
echo -e "  Total Capital:     $TOTAL_CAPITAL_ETH ETH"
echo -e ""
echo -e "${GREEN}Performance:${NC}"
echo -e "  Total Predictions: $TOTAL_PREDICTIONS"
echo -e "  Correct:           $CORRECT_PREDICTIONS"
echo -e "  Win Rate:          $WIN_RATE_PERCENT%"
echo -e ""
echo -e "${GREEN}View on BaseScan:${NC}"
echo -e "  https://basescan.org/address/$AGENT_REGISTRY#readContract"
echo -e ""
