#!/bin/bash

# Deploy using forge create (more direct approach)

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploy to Base Mainnet (forge create)${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Load environment
if [ ! -f .env ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    exit 1
fi

source .env

# Ensure PRIVATE_KEY has 0x prefix
if [[ ! "$PRIVATE_KEY" =~ ^0x ]]; then
    PRIVATE_KEY="0x$PRIVATE_KEY"
    export PRIVATE_KEY
fi

RPC_URL="https://mainnet.base.org"
DEPLOYER=$(cast wallet address --private-key $PRIVATE_KEY)

echo -e "${GREEN}Deployer:${NC} $DEPLOYER"

# Check balance
BALANCE=$(cast balance $DEPLOYER --rpc-url $RPC_URL)
BALANCE_ETH=$(cast to-unit $BALANCE ether)
echo -e "${GREEN}Balance:${NC} $BALANCE_ETH ETH\n"

if (( $(echo "$BALANCE_ETH < 0.002" | bc -l) )); then
    echo -e "${RED}Error: Insufficient balance!${NC}"
    echo -e "Need at least 0.002 ETH, you have $BALANCE_ETH ETH"
    exit 1
fi

echo -e "${YELLOW}⚠️  WARNING: Deploying to BASE MAINNET${NC}"
echo -e "${YELLOW}⚠️  This will use REAL ETH${NC}\n"
echo -n "Continue? (yes/no): "
read CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo -e "\n${YELLOW}Cancelled.${NC}"
    exit 0
fi

echo -e "\n${GREEN}Starting deployment...${NC}\n"

# 1. Deploy AgentRegistry
echo -e "${YELLOW}1/5: Deploying AgentRegistry...${NC}"
AGENT_REGISTRY=$(forge create \
    contracts/src/AgentRegistry.sol:AgentRegistry \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --json | jq -r '.deployedTo')

if [ -z "$AGENT_REGISTRY" ] || [ "$AGENT_REGISTRY" == "null" ]; then
    echo -e "${RED}Failed to deploy AgentRegistry${NC}"
    exit 1
fi
echo -e "${GREEN}✓ AgentRegistry: $AGENT_REGISTRY${NC}\n"
sleep 2

# 2. Deploy TreasuryManager
echo -e "${YELLOW}2/5: Deploying TreasuryManager (with 0.001 ETH)...${NC}"
TREASURY_MANAGER=$(forge create \
    contracts/src/TreasuryManager.sol:TreasuryManager \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --constructor-args $AGENT_REGISTRY \
    --value 0.001ether \
    --json | jq -r '.deployedTo')

if [ -z "$TREASURY_MANAGER" ] || [ "$TREASURY_MANAGER" == "null" ]; then
    echo -e "${RED}Failed to deploy TreasuryManager${NC}"
    exit 1
fi
echo -e "${GREEN}✓ TreasuryManager: $TREASURY_MANAGER${NC}\n"
sleep 2

# 3. Deploy BettingEngine
echo -e "${YELLOW}3/5: Deploying BettingEngine...${NC}"
BETTING_ENGINE=$(forge create \
    contracts/src/BettingEngine.sol:BettingEngine \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --constructor-args $AGENT_REGISTRY $TREASURY_MANAGER \
    --json | jq -r '.deployedTo')

if [ -z "$BETTING_ENGINE" ] || [ "$BETTING_ENGINE" == "null" ]; then
    echo -e "${RED}Failed to deploy BettingEngine${NC}"
    exit 1
fi
echo -e "${GREEN}✓ BettingEngine: $BETTING_ENGINE${NC}\n"
sleep 2

# 4. Deploy OracleResolver
echo -e "${YELLOW}4/5: Deploying OracleResolver...${NC}"
ORACLE_RESOLVER=$(forge create \
    contracts/src/OracleResolver.sol:OracleResolver \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --json | jq -r '.deployedTo')

if [ -z "$ORACLE_RESOLVER" ] || [ "$ORACLE_RESOLVER" == "null" ]; then
    echo -e "${RED}Failed to deploy OracleResolver${NC}"
    exit 1
fi
echo -e "${GREEN}✓ OracleResolver: $ORACLE_RESOLVER${NC}\n"
sleep 2

# 5. Deploy MarketFactory
echo -e "${YELLOW}5/5: Deploying MarketFactory...${NC}"
MARKET_FACTORY=$(forge create \
    contracts/src/MarketFactory.sol:MarketFactory \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --constructor-args $AGENT_REGISTRY $BETTING_ENGINE $ORACLE_RESOLVER \
    --json | jq -r '.deployedTo')

if [ -z "$MARKET_FACTORY" ] || [ "$MARKET_FACTORY" == "null" ]; then
    echo -e "${RED}Failed to deploy MarketFactory${NC}"
    exit 1
fi
echo -e "${GREEN}✓ MarketFactory: $MARKET_FACTORY${NC}\n"

# Configure cross-contract references
echo -e "${YELLOW}Configuring contract references...${NC}"

cast send $AGENT_REGISTRY \
    "setTreasuryManager(address)" \
    $TREASURY_MANAGER \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    > /dev/null

cast send $AGENT_REGISTRY \
    "setMarketFactory(address)" \
    $MARKET_FACTORY \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    > /dev/null

cast send $BETTING_ENGINE \
    "setMarketFactory(address)" \
    $MARKET_FACTORY \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    > /dev/null

cast send $ORACLE_RESOLVER \
    "setMarketFactory(address)" \
    $MARKET_FACTORY \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    > /dev/null

echo -e "${GREEN}✓ Configuration complete${NC}\n"

# Save deployment addresses
cat > deployments/base-mainnet-real.json << EOF
{
  "network": "base-mainnet",
  "chainId": 8453,
  "deployer": "$DEPLOYER",
  "timestamp": "$(date +%s)",
  "deploymentDate": "$(date +%Y-%m-%d)",
  "contracts": {
    "AgentRegistry": "$AGENT_REGISTRY",
    "TreasuryManager": "$TREASURY_MANAGER",
    "BettingEngine": "$BETTING_ENGINE",
    "OracleResolver": "$ORACLE_RESOLVER",
    "MarketFactory": "$MARKET_FACTORY"
  },
  "verified": false
}
EOF

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}✓ DEPLOYMENT SUCCESSFUL!${NC}"
echo -e "${GREEN}========================================${NC}\n"

echo -e "${BLUE}Contract Addresses:${NC}"
echo -e "  AgentRegistry:   $AGENT_REGISTRY"
echo -e "  TreasuryManager: $TREASURY_MANAGER"
echo -e "  BettingEngine:   $BETTING_ENGINE"
echo -e "  OracleResolver:  $ORACLE_RESOLVER"
echo -e "  MarketFactory:   $MARKET_FACTORY"
echo -e ""

echo -e "${BLUE}View on BaseScan:${NC}"
echo -e "  https://basescan.org/address/$AGENT_REGISTRY"
echo -e "  https://basescan.org/address/$TREASURY_MANAGER"
echo -e "  https://basescan.org/address/$BETTING_ENGINE"
echo -e "  https://basescan.org/address/$ORACLE_RESOLVER"
echo -e "  https://basescan.org/address/$MARKET_FACTORY"
echo -e ""

echo -e "${GREEN}Deployment info saved to: deployments/base-mainnet-real.json${NC}\n"

echo -e "${YELLOW}Waiting 30 seconds for blockchain confirmation...${NC}"
sleep 30

# Verify deployment
echo -e "\n${YELLOW}Verifying contracts are on-chain...${NC}\n"

CODE=$(cast code $AGENT_REGISTRY --rpc-url $RPC_URL)
if [ "$CODE" != "0x" ]; then
    echo -e "${GREEN}✓ AgentRegistry confirmed on-chain!${NC}"
else
    echo -e "${RED}✗ AgentRegistry not found on-chain${NC}"
fi

CODE=$(cast code $TREASURY_MANAGER --rpc-url $RPC_URL)
if [ "$CODE" != "0x" ]; then
    echo -e "${GREEN}✓ TreasuryManager confirmed on-chain!${NC}"

    # Check balance
    BALANCE=$(cast balance $TREASURY_MANAGER --rpc-url $RPC_URL)
    BALANCE_ETH=$(cast to-unit $BALANCE ether)
    echo -e "${GREEN}  Treasury balance: $BALANCE_ETH ETH${NC}"
else
    echo -e "${RED}✗ TreasuryManager not found on-chain${NC}"
fi

echo -e "\n${GREEN}🎉 All done! Your contracts are LIVE on Base mainnet!${NC}\n"
