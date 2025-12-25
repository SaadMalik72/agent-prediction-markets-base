#!/bin/bash

# Agent Prediction Markets - Demo Script
# Interactive demo of protocol functionality

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Load deployment addresses
DEPLOYMENT_FILE="deployments/base-mainnet.json"

if [ ! -f "$DEPLOYMENT_FILE" ]; then
    echo -e "${RED}Error: Deployment file not found!${NC}"
    echo "Please deploy contracts first or check the path."
    exit 1
fi

# Parse addresses from JSON (using grep/sed for simplicity)
AGENT_REGISTRY=$(grep -o '"agentRegistry": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
TREASURY_MANAGER=$(grep -o '"treasuryManager": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
BETTING_ENGINE=$(grep -o '"bettingEngine": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
ORACLE_RESOLVER=$(grep -o '"oracleResolver": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)
MARKET_FACTORY=$(grep -o '"marketFactory": "[^"]*"' $DEPLOYMENT_FILE | cut -d'"' -f4)

# Network
RPC_URL="https://mainnet.base.org"

# Load environment
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

# Check private key
if [ -z "$PRIVATE_KEY" ]; then
    echo -e "${RED}Error: PRIVATE_KEY not set in .env${NC}"
    exit 1
fi

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Check balance
check_balance() {
    BALANCE=$(cast balance $1 --rpc-url $RPC_URL)
    BALANCE_ETH=$(cast to-unit $BALANCE ether)
    echo "$BALANCE_ETH ETH"
}

# Get deployer address
DEPLOYER=$(cast wallet address --private-key $PRIVATE_KEY)

# Main menu
show_menu() {
    clear
    print_header "Agent Prediction Markets - Demo"

    echo -e "${BLUE}Contract Addresses:${NC}"
    echo "  AgentRegistry:   $AGENT_REGISTRY"
    echo "  TreasuryManager: $TREASURY_MANAGER"
    echo "  BettingEngine:   $BETTING_ENGINE"
    echo "  OracleResolver:  $ORACLE_RESOLVER"
    echo "  MarketFactory:   $MARKET_FACTORY"
    echo ""
    echo -e "${BLUE}Your Address:${NC} $DEPLOYER"
    echo -e "${BLUE}Balance:${NC} $(check_balance $DEPLOYER)"
    echo ""
    echo "========================================"
    echo "1) Register an Agent"
    echo "2) Sponsor an Agent"
    echo "3) View Agent Info"
    echo "4) Create a Market"
    echo "5) Place a Bet"
    echo "6) View Market Info"
    echo "7) View Protocol Stats"
    echo "8) Check Total Agents"
    echo "9) Check Total Markets"
    echo "0) Exit"
    echo "========================================"
    echo -n "Choose an option: "
}

# Function: Register Agent
register_agent() {
    print_header "Register an Agent"

    echo -n "Enter agent name: "
    read AGENT_NAME

    echo -n "Enter metadata URI (e.g., ipfs://...): "
    read METADATA_URI

    echo -n "Enter stake amount in ETH (min 0.0001): "
    read STAKE_AMOUNT

    print_info "Registering agent '$AGENT_NAME' with $STAKE_AMOUNT ETH stake..."

    TX=$(cast send $AGENT_REGISTRY \
        "registerAgent(string,string)" \
        "$AGENT_NAME" \
        "$METADATA_URI" \
        --value "${STAKE_AMOUNT}ether" \
        --private-key $PRIVATE_KEY \
        --rpc-url $RPC_URL)

    print_success "Agent registered!"
    echo "Transaction: $TX"

    # Get agent ID from logs
    TOTAL_AGENTS=$(cast call $AGENT_REGISTRY "totalAgents()(uint256)" --rpc-url $RPC_URL)
    AGENT_ID=$((TOTAL_AGENTS - 1))
    print_success "Your Agent ID: $AGENT_ID"

    echo -n "Press Enter to continue..."
    read
}

# Function: Sponsor Agent
sponsor_agent() {
    print_header "Sponsor an Agent"

    echo -n "Enter Agent ID to sponsor: "
    read AGENT_ID

    echo -n "Enter sponsorship amount in ETH (min 0.00005): "
    read SPONSOR_AMOUNT

    print_info "Sponsoring agent #$AGENT_ID with $SPONSOR_AMOUNT ETH..."

    TX=$(cast send $AGENT_REGISTRY \
        "sponsorAgent(uint256)" \
        $AGENT_ID \
        --value "${SPONSOR_AMOUNT}ether" \
        --private-key $PRIVATE_KEY \
        --rpc-url $RPC_URL)

    print_success "Agent sponsored!"
    echo "Transaction: $TX"

    echo -n "Press Enter to continue..."
    read
}

# Function: View Agent Info
view_agent() {
    print_header "View Agent Information"

    echo -n "Enter Agent ID: "
    read AGENT_ID

    print_info "Fetching agent #$AGENT_ID information..."

    # Call getAgent function
    RESULT=$(cast call $AGENT_REGISTRY \
        "getAgent(uint256)(address,string,string,uint256,uint256,uint256,uint256,uint256,uint256,uint256,uint256,bool,bool)" \
        $AGENT_ID \
        --rpc-url $RPC_URL)

    echo -e "\n${GREEN}Agent #$AGENT_ID Details:${NC}"
    echo "$RESULT"

    # Get performance
    PERFORMANCE=$(cast call $AGENT_REGISTRY \
        "getAgentPerformance(uint256)(uint256,uint256,uint256)" \
        $AGENT_ID \
        --rpc-url $RPC_URL)

    echo -e "\n${GREEN}Performance:${NC}"
    echo "$PERFORMANCE"

    echo -n "\nPress Enter to continue..."
    read
}

# Function: Create Market
create_market() {
    print_header "Create a Prediction Market"

    echo -n "Enter your Agent ID: "
    read AGENT_ID

    echo -n "Enter market question: "
    read QUESTION

    echo -n "Enter market description: "
    read DESCRIPTION

    echo "Categories: 0=Crypto, 1=Sports, 2=Politics, 3=Weather, 4=Technology, 5=Other"
    echo -n "Enter category (0-5): "
    read CATEGORY

    echo -n "Enter duration in days: "
    read DAYS
    DURATION=$((DAYS * 86400))

    echo -n "Enter outcome 1 name: "
    read OUTCOME1

    echo -n "Enter outcome 2 name: "
    read OUTCOME2

    echo -n "Allow only agents to bet? (true/false): "
    read AGENTS_ONLY

    print_info "Creating market..."

    # This is complex, we'll use cast with ABI encoding
    TX=$(cast send $MARKET_FACTORY \
        "createMarket(uint256,string,string,uint8,uint256,string[],bool)" \
        $AGENT_ID \
        "$QUESTION" \
        "$DESCRIPTION" \
        $CATEGORY \
        $DURATION \
        "[\"$OUTCOME1\",\"$OUTCOME2\"]" \
        $AGENTS_ONLY \
        --private-key $PRIVATE_KEY \
        --rpc-url $RPC_URL)

    print_success "Market created!"
    echo "Transaction: $TX"

    echo -n "Press Enter to continue..."
    read
}

# Function: Place Bet
place_bet() {
    print_header "Place a Bet"

    echo -n "Enter Market ID: "
    read MARKET_ID

    echo -n "Enter Outcome ID (0, 1, etc.): "
    read OUTCOME_ID

    echo -n "Enter your Agent ID (or 0 for personal bet): "
    read AGENT_ID

    echo -n "Enter bet amount in ETH (min 0.00001): "
    read BET_AMOUNT

    print_info "Placing bet..."

    TX=$(cast send $BETTING_ENGINE \
        "placeBet(uint256,uint256,uint256,uint256)" \
        $MARKET_ID \
        $OUTCOME_ID \
        $AGENT_ID \
        0 \
        --value "${BET_AMOUNT}ether" \
        --private-key $PRIVATE_KEY \
        --rpc-url $RPC_URL)

    print_success "Bet placed!"
    echo "Transaction: $TX"

    echo -n "Press Enter to continue..."
    read
}

# Function: View Market Info
view_market() {
    print_header "View Market Information"

    echo -n "Enter Market ID: "
    read MARKET_ID

    print_info "Fetching market #$MARKET_ID information..."

    RESULT=$(cast call $MARKET_FACTORY \
        "getMarket(uint256)" \
        $MARKET_ID \
        --rpc-url $RPC_URL)

    echo -e "\n${GREEN}Market #$MARKET_ID Details:${NC}"
    echo "$RESULT"

    echo -n "\nPress Enter to continue..."
    read
}

# Function: Protocol Stats
protocol_stats() {
    print_header "Protocol Statistics"

    STATS=$(cast call $TREASURY_MANAGER \
        "getProtocolStats()(uint256,uint256,uint256)" \
        --rpc-url $RPC_URL)

    echo -e "${GREEN}Treasury Stats:${NC}"
    echo "$STATS"

    TOTAL_AGENTS=$(cast call $AGENT_REGISTRY "totalAgents()(uint256)" --rpc-url $RPC_URL)
    TOTAL_MARKETS=$(cast call $MARKET_FACTORY "totalMarkets()(uint256)" --rpc-url $RPC_URL)
    TOTAL_VOLUME=$(cast call $MARKET_FACTORY "totalVolume()(uint256)" --rpc-url $RPC_URL)

    echo -e "\n${GREEN}Platform Stats:${NC}"
    echo "Total Agents:  $TOTAL_AGENTS"
    echo "Total Markets: $TOTAL_MARKETS"
    echo "Total Volume:  $(cast to-unit $TOTAL_VOLUME ether) ETH"

    echo -n "\nPress Enter to continue..."
    read
}

# Function: Total Agents
total_agents() {
    print_header "Total Agents"

    TOTAL=$(cast call $AGENT_REGISTRY "totalAgents()(uint256)" --rpc-url $RPC_URL)

    print_success "Total Agents Registered: $TOTAL"

    echo -n "\nPress Enter to continue..."
    read
}

# Function: Total Markets
total_markets() {
    print_header "Total Markets"

    TOTAL=$(cast call $MARKET_FACTORY "totalMarkets()(uint256)" --rpc-url $RPC_URL)

    print_success "Total Markets Created: $TOTAL"

    echo -n "\nPress Enter to continue..."
    read
}

# Main loop
while true; do
    show_menu
    read OPTION

    case $OPTION in
        1) register_agent ;;
        2) sponsor_agent ;;
        3) view_agent ;;
        4) create_market ;;
        5) place_bet ;;
        6) view_market ;;
        7) protocol_stats ;;
        8) total_agents ;;
        9) total_markets ;;
        0)
            print_success "Goodbye!"
            exit 0
            ;;
        *)
            print_error "Invalid option!"
            sleep 1
            ;;
    esac
done
