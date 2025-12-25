# Agent Prediction Markets - Makefile

.PHONY: help install build test test-gas clean deploy-sepolia deploy-mainnet verify

help: ## Show this help message
	@echo 'Usage: make [target]'
	@echo ''
	@echo 'Available targets:'
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'

install: ## Install dependencies
	@echo "Installing Foundry dependencies..."
	forge install

build: ## Compile contracts
	@echo "Compiling contracts..."
	forge build

test: ## Run all tests
	@echo "Running tests..."
	forge test -vvv

test-gas: ## Run tests with gas reporting
	@echo "Running tests with gas report..."
	forge test --gas-report

test-coverage: ## Generate test coverage report
	@echo "Generating coverage report..."
	forge coverage

clean: ## Clean build artifacts
	@echo "Cleaning artifacts..."
	forge clean
	rm -rf cache out broadcast

deploy-sepolia: ## Deploy to Base Sepolia testnet
	@echo "Deploying to Base Sepolia..."
	@if [ -z "$$PRIVATE_KEY" ]; then \
		echo "Error: PRIVATE_KEY not set"; \
		exit 1; \
	fi
	forge script contracts/script/DeploySepolia.s.sol \
		--rpc-url base_sepolia \
		--broadcast \
		--verify \
		--etherscan-api-key $$BASESCAN_API_KEY

deploy-mainnet: ## Deploy to Base Mainnet
	@echo "WARNING: Deploying to MAINNET"
	@echo "Press Ctrl+C to cancel, or wait 5 seconds to continue..."
	@sleep 5
	@if [ -z "$$PRIVATE_KEY" ]; then \
		echo "Error: PRIVATE_KEY not set"; \
		exit 1; \
	fi
	forge script contracts/script/Deploy.s.sol \
		--rpc-url base_mainnet \
		--broadcast \
		--verify \
		--etherscan-api-key $$BASESCAN_API_KEY

verify: ## Verify contracts on BaseScan
	@echo "Verify contracts manually using:"
	@echo "forge verify-contract --chain-id 8453 <CONTRACT_ADDRESS> <CONTRACT_NAME>"

snapshot: ## Create gas snapshot
	@echo "Creating gas snapshot..."
	forge snapshot

format: ## Format Solidity code
	@echo "Formatting code..."
	forge fmt

lint: ## Lint Solidity code
	@echo "Linting code..."
	forge fmt --check

check: build test lint ## Build, test and lint

size: ## Check contract sizes
	@echo "Checking contract sizes..."
	forge build --sizes

update: ## Update dependencies
	@echo "Updating dependencies..."
	forge update

local-node: ## Start local Anvil node
	@echo "Starting local Anvil node..."
	anvil

anvil-deploy: ## Deploy to local Anvil node
	@echo "Deploying to local Anvil..."
	forge script contracts/script/Deploy.s.sol \
		--rpc-url http://localhost:8545 \
		--broadcast \
		--private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80

.DEFAULT_GOAL := help
