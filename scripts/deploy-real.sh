#!/bin/bash

# Deploy contracts to Base Mainnet (FOR REAL)

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploy to Base Mainnet${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Load environment
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please create .env with your PRIVATE_KEY"
    exit 1
fi

source .env

# Check PRIVATE_KEY
if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}Error: PRIVATE_KEY not set in .env${NC}"
    exit 1
fi

# Ensure PRIVATE_KEY has 0x prefix
if [[ ! "$PRIVATE_KEY" =~ ^0x ]]; then
    echo -e "${YELLOW}Adding 0x prefix to PRIVATE_KEY...${NC}"
    PRIVATE_KEY="0x$PRIVATE_KEY"
    export PRIVATE_KEY
fi

# Get deployer address
DEPLOYER=$(cast wallet address --private-key $PRIVATE_KEY)

echo -e "${GREEN}Deployer Address:${NC} $DEPLOYER\n"

# Check balance
BALANCE=$(cast balance $DEPLOYER --rpc-url https://mainnet.base.org)
BALANCE_ETH=$(cast to-unit $BALANCE ether)

echo -e "${GREEN}Balance:${NC} $BALANCE_ETH ETH\n"

# Validate balance
MIN_REQUIRED="0.002"
if (( $(echo "$BALANCE_ETH < $MIN_REQUIRED" | bc -l) )); then
    echo -e "${RED}Error: Insufficient balance!${NC}"
    echo -e "You have: $BALANCE_ETH ETH"
    echo -e "Need at least: $MIN_REQUIRED ETH (0.001 for protocol + ~0.001 for gas)"
    echo -e "\nGet ETH on Base mainnet first!"
    exit 1
fi

echo -e "${YELLOW}⚠️  WARNING: You are about to deploy to BASE MAINNET${NC}"
echo -e "${YELLOW}⚠️  This will use REAL ETH (approximately 0.001 ETH + gas)${NC}\n"

echo -n "Continue? (yes/no): "
read CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "\n${YELLOW}Deployment cancelled.${NC}"
    exit 0
fi

echo -e "\n${GREEN}Starting deployment...${NC}\n"

# Determine which API key to use
if [ -z "$BASESCAN_API_KEY" ]; then
    if [ -z "$ETHERSCAN_API_KEY" ]; then
        echo -e "${YELLOW}Warning: No API key found. Skipping verification.${NC}"
        VERIFY_FLAG=""
        API_KEY=""
    else
        echo -e "${YELLOW}Using ETHERSCAN_API_KEY for verification${NC}"
        VERIFY_FLAG="--verify"
        API_KEY="--etherscan-api-key $ETHERSCAN_API_KEY"
    fi
else
    echo -e "${GREEN}Using BASESCAN_API_KEY for verification${NC}"
    VERIFY_FLAG="--verify"
    API_KEY="--etherscan-api-key $BASESCAN_API_KEY"
fi

# Run deployment with proper flags
forge script contracts/script/Deploy.s.sol \
    --rpc-url https://mainnet.base.org \
    --private-key $PRIVATE_KEY \
    --broadcast \
    $VERIFY_FLAG \
    $API_KEY \
    -vvv

echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}Deployment Complete!${NC}"
echo -e "${GREEN}========================================${NC}\n"

# Check if broadcast directory was created
if [ -d "broadcast" ]; then
    echo -e "${GREEN}✓ Transactions broadcasted successfully!${NC}"
    echo -e "\nBroadcast data saved in: broadcast/\n"

    # Wait a bit for transactions to be mined
    echo -e "${YELLOW}Waiting 30 seconds for transactions to be mined...${NC}"
    sleep 30

    # Run check script
    if [ -f "scripts/check-deployment.sh" ]; then
        chmod +x scripts/check-deployment.sh
        ./scripts/check-deployment.sh
    fi
else
    echo -e "${RED}⚠️  Warning: No broadcast directory created${NC}"
    echo -e "Deployment may have been simulated only."
fi

echo -e "\n${GREEN}Next steps:${NC}"
echo -e "  1. Check your transactions on BaseScan"
echo -e "  2. Verify contracts with: make verify"
echo -e "  3. Test with: ./scripts/quick-start.sh"
echo -e ""
