#!/bin/bash

# Deploy using cast send directly (most reliable method)

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Deploy to Base Mainnet (cast method)${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Load environment
source .env

RPC_URL="https://mainnet.base.org"
DEPLOYER=$(cast wallet address --private-key $PRIVATE_KEY)

echo -e "${GREEN}Deployer:${NC} $DEPLOYER"

# Check balance
BALANCE=$(cast balance $DEPLOYER --rpc-url $RPC_URL)
BALANCE_ETH=$(cast to-unit $BALANCE ether)
echo -e "${GREEN}Balance:${NC} $BALANCE_ETH ETH\n"

if (( $(echo "$BALANCE_ETH < 0.002" | bc -l) )); then
    echo -e "${RED}Error: Insufficient balance!${NC}"
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

# Get bytecode
echo -e "${YELLOW}Generating bytecode...${NC}"

# 1. AgentRegistry
echo -e "\n${YELLOW}1/5: Deploying AgentRegistry...${NC}"
BYTECODE=$(forge inspect contracts/src/AgentRegistry.sol:AgentRegistry bytecode)
TX=$(cast send --create "$BYTECODE" \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    2>&1)

AGENT_REGISTRY=$(echo "$TX" | grep "contractAddress" | awk '{print $2}')
if [ -z "$AGENT_REGISTRY" ]; then
    # Try alternative parsing
    AGENT_REGISTRY=$(echo "$TX" | grep -oP "0x[a-fA-F0-9]{40}" | head -1)
fi

if [ -z "$AGENT_REGISTRY" ]; then
    echo -e "${RED}Failed to deploy AgentRegistry${NC}"
    echo "$TX"
    exit 1
fi

echo -e "${GREEN}✓ AgentRegistry: $AGENT_REGISTRY${NC}"
sleep 3

# 2. TreasuryManager
echo -e "\n${YELLOW}2/5: Deploying TreasuryManager...${NC}"

# Get constructor args encoded
CONSTRUCTOR_ARGS=$(cast abi-encode "constructor(address)" "$AGENT_REGISTRY")
BYTECODE=$(forge inspect contracts/src/TreasuryManager.sol:TreasuryManager bytecode)
FULL_BYTECODE="${BYTECODE}${CONSTRUCTOR_ARGS:2}"

TX=$(cast send --create "$FULL_BYTECODE" \
    --value 0.001ether \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    2>&1)

TREASURY_MANAGER=$(echo "$TX" | grep "contractAddress" | awk '{print $2}')
if [ -z "$TREASURY_MANAGER" ]; then
    TREASURY_MANAGER=$(echo "$TX" | grep -oP "0x[a-fA-F0-9]{40}" | head -1)
fi

if [ -z "$TREASURY_MANAGER" ]; then
    echo -e "${RED}Failed to deploy TreasuryManager${NC}"
    echo "$TX"
    exit 1
fi

echo -e "${GREEN}✓ TreasuryManager: $TREASURY_MANAGER${NC}"
sleep 3

# 3. BettingEngine
echo -e "\n${YELLOW}3/5: Deploying BettingEngine...${NC}"

CONSTRUCTOR_ARGS=$(cast abi-encode "constructor(address,address)" "$AGENT_REGISTRY" "$TREASURY_MANAGER")
BYTECODE=$(forge inspect contracts/src/BettingEngine.sol:BettingEngine bytecode)
FULL_BYTECODE="${BYTECODE}${CONSTRUCTOR_ARGS:2}"

TX=$(cast send --create "$FULL_BYTECODE" \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    2>&1)

BETTING_ENGINE=$(echo "$TX" | grep "contractAddress" | awk '{print $2}')
if [ -z "$BETTING_ENGINE" ]; then
    BETTING_ENGINE=$(echo "$TX" | grep -oP "0x[a-fA-F0-9]{40}" | head -1)
fi

if [ -z "$BETTING_ENGINE" ]; then
    echo -e "${RED}Failed to deploy BettingEngine${NC}"
    echo "$TX"
    exit 1
fi

echo -e "${GREEN}✓ BettingEngine: $BETTING_ENGINE${NC}"
sleep 3

# 4. OracleResolver
echo -e "\n${YELLOW}4/5: Deploying OracleResolver...${NC}"

BYTECODE=$(forge inspect contracts/src/OracleResolver.sol:OracleResolver bytecode)

TX=$(cast send --create "$BYTECODE" \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    2>&1)

ORACLE_RESOLVER=$(echo "$TX" | grep "contractAddress" | awk '{print $2}')
if [ -z "$ORACLE_RESOLVER" ]; then
    ORACLE_RESOLVER=$(echo "$TX" | grep -oP "0x[a-fA-F0-9]{40}" | head -1)
fi

if [ -z "$ORACLE_RESOLVER" ]; then
    echo -e "${RED}Failed to deploy OracleResolver${NC}"
    echo "$TX"
    exit 1
fi

echo -e "${GREEN}✓ OracleResolver: $ORACLE_RESOLVER${NC}"
sleep 3

# 5. MarketFactory
echo -e "\n${YELLOW}5/5: Deploying MarketFactory...${NC}"

CONSTRUCTOR_ARGS=$(cast abi-encode "constructor(address,address,address)" "$AGENT_REGISTRY" "$BETTING_ENGINE" "$ORACLE_RESOLVER")
BYTECODE=$(forge inspect contracts/src/MarketFactory.sol:MarketFactory bytecode)
FULL_BYTECODE="${BYTECODE}${CONSTRUCTOR_ARGS:2}"

TX=$(cast send --create "$FULL_BYTECODE" \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    2>&1)

MARKET_FACTORY=$(echo "$TX" | grep "contractAddress" | awk '{print $2}')
if [ -z "$MARKET_FACTORY" ]; then
    MARKET_FACTORY=$(echo "$TX" | grep -oP "0x[a-fA-F0-9]{40}" | head -1)
fi

if [ -z "$MARKET_FACTORY" ]; then
    echo -e "${RED}Failed to deploy MarketFactory${NC}"
    echo "$TX"
    exit 1
fi

echo -e "${GREEN}✓ MarketFactory: $MARKET_FACTORY${NC}"

# Configure cross-contract references
echo -e "\n${YELLOW}Configuring contract references...${NC}"

cast send $AGENT_REGISTRY \
    "setTreasuryManager(address)" \
    $TREASURY_MANAGER \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    > /dev/null 2>&1

cast send $AGENT_REGISTRY \
    "setMarketFactory(address)" \
    $MARKET_FACTORY \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    > /dev/null 2>&1

cast send $BETTING_ENGINE \
    "setMarketFactory(address)" \
    $MARKET_FACTORY \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    > /dev/null 2>&1

cast send $ORACLE_RESOLVER \
    "setMarketFactory(address)" \
    $MARKET_FACTORY \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    > /dev/null 2>&1

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
  }
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
echo -e ""

echo -e "${GREEN}Saved to: deployments/base-mainnet-real.json${NC}\n"

# Verify
echo -e "${YELLOW}Verifying deployment (wait 30 seconds)...${NC}"
sleep 30

CODE=$(cast code $AGENT_REGISTRY --rpc-url $RPC_URL)
if [ "$CODE" != "0x" ]; then
    echo -e "${GREEN}✓ Contracts confirmed on Base mainnet!${NC}\n"
else
    echo -e "${YELLOW}⚠ Waiting for confirmation...${NC}\n"
fi

echo -e "${GREEN}🎉 Done!${NC}\n"
