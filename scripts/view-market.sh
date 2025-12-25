#!/bin/bash

# View Market Information

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

MARKET_ID=${1:-1}

# Load deployment addresses
DEPLOYMENT_FILE="deployments/base-mainnet.json"
MARKET_FACTORY=$(grep -o '"marketFactory": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
RPC_URL="https://mainnet.base.org"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Market #$MARKET_ID Information${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${YELLOW}Fetching market data...${NC}\n"

# Check if market is active
IS_ACTIVE=$(cast call $MARKET_FACTORY \
    "isMarketActive(uint256)(bool)" \
    $MARKET_ID \
    --rpc-url $RPC_URL)

# Get market outcomes
OUTCOMES=$(cast call $MARKET_FACTORY \
    "getMarketOutcomes(uint256)" \
    $MARKET_ID \
    --rpc-url $RPC_URL)

echo -e "${GREEN}Market Status:${NC}"
if [ "$IS_ACTIVE" == "true" ]; then
    echo -e "  Status: ${GREEN}ACTIVE ✓${NC}"
else
    echo -e "  Status: ${YELLOW}CLOSED${NC}"
fi
echo -e ""

echo -e "${GREEN}Outcomes:${NC}"
echo "$OUTCOMES"
echo -e ""

echo -e "${GREEN}View on BaseScan:${NC}"
echo -e "  https://basescan.org/address/$MARKET_FACTORY#readContract"
echo -e ""
