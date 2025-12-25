#!/bin/bash

# Check if contracts are really deployed

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

RPC_URL="https://mainnet.base.org"

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Checking Deployment Status${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Load addresses
DEPLOYMENT_FILE="deployments/base-mainnet-real.json"

if [ ! -f "$DEPLOYMENT_FILE" ]; then
    echo -e "${RED}Deployment file not found!${NC}"
    exit 1
fi

AGENT_REGISTRY=$(cat $DEPLOYMENT_FILE | jq -r '.contracts.AgentRegistry')
TREASURY_MANAGER=$(cat $DEPLOYMENT_FILE | jq -r '.contracts.TreasuryManager')

echo -e "${YELLOW}Checking if contracts exist on-chain...${NC}\n"

# Check AgentRegistry
echo -n "AgentRegistry ($AGENT_REGISTRY): "
CODE=$(cast code $AGENT_REGISTRY --rpc-url $RPC_URL 2>/dev/null || echo "0x")

if [ "$CODE" == "0x" ]; then
    echo -e "${RED}NOT DEPLOYED ✗${NC}"
    DEPLOYED=false
else
    echo -e "${GREEN}DEPLOYED ✓${NC} ($(echo $CODE | wc -c) bytes)"
    DEPLOYED=true
fi

# Check TreasuryManager
echo -n "TreasuryManager ($TREASURY_MANAGER): "
CODE=$(cast code $TREASURY_MANAGER --rpc-url $RPC_URL 2>/dev/null || echo "0x")

if [ "$CODE" == "0x" ]; then
    echo -e "${RED}NOT DEPLOYED ✗${NC}"
else
    echo -e "${GREEN}DEPLOYED ✓${NC} ($(echo $CODE | wc -c) bytes)"
fi

echo ""

if [ "$DEPLOYED" = false ]; then
    echo -e "${RED}========================================${NC}"
    echo -e "${RED}⚠️  CONTRACTS NOT DEPLOYED!${NC}"
    echo -e "${RED}========================================${NC}\n"
    echo -e "${YELLOW}The previous deployment was a SIMULATION.${NC}"
    echo -e "${YELLOW}To deploy for real, run:${NC}\n"
    echo -e "  ${GREEN}./scripts/deploy-real.sh${NC}\n"
else
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}✓ Contracts are LIVE on Base!${NC}"
    echo -e "${GREEN}========================================${NC}\n"
fi
