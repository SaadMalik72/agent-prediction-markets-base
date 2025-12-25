#!/bin/bash
# Simple deployment script - REAL DEPLOYMENT

source .env

echo "⚠️  WARNING: Deploying to BASE MAINNET with REAL ETH"
echo -n "Continue? (yes/no): "
read CONFIRM

if [ "$CONFIRM" != "yes" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Deploying AgentRegistry..."
forge create contracts/src/AgentRegistry.sol:AgentRegistry \
  --rpc-url https://mainnet.base.org \
  --private-key $PRIVATE_KEY \
  --broadcast
