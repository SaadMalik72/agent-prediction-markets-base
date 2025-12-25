#!/bin/bash

# Register a new agent quickly

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Parse arguments
AGENT_NAME=${1:-"MyAgent"}
METADATA_URI=${2:-"ipfs://QmDefaultMetadata"}
STAKE_AMOUNT=${3:-"0.0001"}

# Load deployment addresses
DEPLOYMENT_FILE="deployments/base-mainnet.json"
AGENT_REGISTRY=$(grep -o '"agentRegistry": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
RPC_URL="https://mainnet.base.org"

# Load environment
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}Error: PRIVATE_KEY not set in .env${NC}"
    exit 1
fi

DEPLOYER=$(cast wallet address --private-key $PRIVATE_KEY)

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Register New Agent${NC}"
echo -e "${BLUE}========================================${NC}\n"

echo -e "${GREEN}Agent Details:${NC}"
echo -e "  Name:      $AGENT_NAME"
echo -e "  Metadata:  $METADATA_URI"
echo -e "  Stake:     $STAKE_AMOUNT ETH"
echo -e "  Creator:   $DEPLOYER"
echo -e ""

echo -e "${YELLOW}Registering agent...${NC}\n"

TX=$(cast send $AGENT_REGISTRY \
    "registerAgent(string,string)" \
    "$AGENT_NAME" \
    "$METADATA_URI" \
    --value "${STAKE_AMOUNT}ether" \
    --private-key $PRIVATE_KEY \
    --rpc-url $RPC_URL)

TOTAL_AGENTS=$(cast call $AGENT_REGISTRY "totalAgents()(uint256)" --rpc-url $RPC_URL)
AGENT_ID=$((TOTAL_AGENTS - 1))

echo -e "${GREEN}✓ Agent registered successfully!${NC}\n"
echo -e "  Agent ID:    $AGENT_ID"
echo -e "  Transaction: $TX"
echo -e ""
echo -e "${GREEN}View on BaseScan:${NC}"
echo -e "  https://basescan.org/tx/$TX"
echo -e ""
echo -e "${GREEN}Next steps:${NC}"
echo -e "  - View details: ./scripts/view-agent.sh $AGENT_ID"
echo -e "  - Sponsor it:   cast send $AGENT_REGISTRY 'sponsorAgent(uint256)' $AGENT_ID --value 0.00005ether"
echo -e ""
