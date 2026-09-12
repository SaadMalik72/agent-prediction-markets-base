# Contributing to Agent Prediction Markets

Thank you for your interest in contributing to Agent Prediction Markets! This project enables AI-powered prediction markets on the Base blockchain with a decentralized agent betting system.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Environment](#development-environment)
- [Project Structure](#project-structure)
- [Smart Contract Architecture](#smart-contract-architecture)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Submitting Changes](#submitting-changes)
- [Security](#security)
- [Areas for Contribution](#areas-for-contribution)

## Code of Conduct

This project adheres to a standard of respectful, constructive collaboration. We expect all contributors to:

- Be respectful and inclusive in all interactions
- Focus on constructive feedback and solutions
- Respect differing viewpoints and experiences
- Prioritize the security and integrity of the protocol

## Getting Started

### Prerequisites

- **Foundry**: Ethereum development toolkit
  ```bash
  curl -L https://foundry.paradigm.xyz | bash
  foundryup
  ```
- **Node.js** (v18+): For miniapp development
- **Git**: Version control

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork:
   ```bash
   git clone https://github.com/YOUR_USERNAME/agent-prediction-markets-base.git
   cd agent-prediction-markets-base
   ```
3. Install dependencies:
   ```bash
   forge install
   ```

## Development Environment

### Environment Setup

1. Copy the example environment file:
   ```bash
   cp .env.example .env
   ```

2. Configure your environment variables:
   ```
   PRIVATE_KEY=your_private_key_here
   BASE_RPC_URL=https://mainnet.base.org
   BASE_SEPOLIA_RPC_URL=https://sepolia.base.org
   ETHERSCAN_API_KEY=your_etherscan_api_key
   ```

### Building Contracts

```bash
# Compile contracts
forge build

# Run tests
forge test

# Run tests with gas report
forge test --gas-report

# Run tests with coverage
forge coverage
```

## Project Structure

```
agent-prediction-markets-base/
├── contracts/
│   └── src/
│       ├── AgentRegistry.sol      # Agent registration & staking
│       ├── BettingEngine.sol      # AMM betting engine
│       ├── MarketFactory.sol      # Market creation & lifecycle
│       ├── OracleResolver.sol     # Market resolution system
│       └── TreasuryManager.sol    # Revenue distribution
├── scripts/
│   ├── deploy.s.sol               # Deployment scripts
│   └── interact.s.sol             # Interaction scripts
├── miniapp/                       # React miniapp frontend
│   ├── src/
│   └── public/
├── test/                          # Test files
├── deployments/                   # Deployment records
└── docs/                          # Documentation
```

## Smart Contract Architecture

### Core Components

1. **AgentRegistry** (480 lines)
   - Agent registration with staking mechanism
   - Community sponsorship system
   - On-chain reputation tracking
   - Slashing for misbehavior

2. **BettingEngine** (453 lines)
   - AMM-based betting with dynamic odds
   - Liquidity pool management
   - Automated payout distribution

3. **MarketFactory** (417 lines)
   - Market creation and lifecycle management
   - Market state transitions
   - Fee configuration

4. **OracleResolver** (369 lines)
   - Decentralized market resolution
   - Oracle integration
   - Dispute mechanism

5. **TreasuryManager** (309 lines)
   - Protocol revenue collection
   - Automated distribution (60% sponsors / 30% creator / 10% protocol)
   - 7-day withdrawal cooldown

### Economic Parameters

| Parameter | Value |
|-----------|-------|
| Initial Protocol Liquidity | 0.001 ETH |
| Minimum Agent Stake | 0.0001 ETH |
| Minimum Sponsorship | 0.00005 ETH |
| Minimum Bet | 0.00001 ETH |
| Withdrawal Cooldown | 7 days |
| Revenue Split (Sponsors/Creator/Protocol) | 60%/30%/10% |

## Coding Standards

### Solidity Style Guide

We follow the [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html) with these additions:

- **Layout**: Contract layout should follow: imports → errors → events → structs → state variables → constructor → external → public → internal → private → view/pure
- **Naming**: 
  - Contracts: `PascalCase`
  - Functions: `camelCase`
  - Constants: `UPPER_SNAKE_CASE`
  - Events: `PascalCase` prefixed with contract name
- **Documentation**: All public/external functions must have NatSpec comments
- **Gas Optimization**: Use `calldata` for external function parameters, pack structs efficiently

### Example Contract Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {ReentrancyGuard} from "@openzeppelin/contracts/security/ReentrancyGuard.sol";

/**
 * @title ExampleContract
 * @notice Brief description of the contract
 * @dev Additional implementation details
 */
contract ExampleContract is ReentrancyGuard {
    // ============ Errors ============
    error ExampleContract__InvalidParameter();
    
    // ============ Events ============
    event ExampleContract__ActionPerformed(address indexed user, uint256 amount);
    
    // ============ Structs ============
    struct ExampleStruct {
        address user;
        uint256 amount;
    }
    
    // ============ State Variables ============
    uint256 public constant MIN_AMOUNT = 0.0001 ether;
    mapping(address => uint256) public userBalances;
    
    // ============ Constructor ============
    constructor() {
        // Initialization
    }
    
    // ============ External Functions ============
    
    /**
     * @notice Brief description of what the function does
     * @param amount The amount to process
     * @return success Whether the operation succeeded
     */
    function performAction(uint256 amount) external returns (bool success) {
        // Implementation
    }
    
    // ============ Internal Functions ============
    
    function _internalHelper() internal pure returns (uint256) {
        // Implementation
    }
}
```

## Testing

### Test Requirements

- All new features must include comprehensive tests
- Aim for >80% code coverage
- Include both positive and negative test cases
- Test edge cases and boundary conditions

### Running Tests

```bash
# Run all tests
forge test

# Run specific test file
forge test --match-path test/AgentRegistry.t.sol

# Run specific test
forge test --match-test test_RegisterAgent

# Run tests with verbosity
forge test -vvv

# Run tests with gas report
forge test --gas-report

# Generate coverage report
forge coverage --report lcov
```

### Test Structure

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {AgentRegistry} from "../contracts/src/AgentRegistry.sol";

contract AgentRegistryTest is Test {
    AgentRegistry public registry;
    address public user = address(1);
    
    function setUp() public {
        registry = new AgentRegistry();
        vm.deal(user, 1 ether);
    }
    
    function test_RegisterAgent_Success() public {
        vm.prank(user);
        uint256 agentId = registry.registerAgent{value: 0.0001 ether}(
            "Test Agent",
            "ipfs://metadata"
        );
        
        assertEq(agentId, 1);
        
        AgentRegistry.Agent memory agent = registry.getAgent(agentId);
        assertEq(agent.creator, user);
        assertEq(agent.name, "Test Agent");
    }
    
    function test_RegisterAgent_InsufficientStake() public {
        vm.prank(user);
        vm.expectRevert(AgentRegistry__InsufficientStake.selector);
        registry.registerAgent{value: 0.00001 ether}("Test Agent", "ipfs://metadata");
    }
}
```

## Submitting Changes

### Pull Request Process

1. **Create a branch**: `git checkout -b feature/your-feature-name`
2. **Make your changes**: Follow coding standards and add tests
3. **Run tests**: Ensure all tests pass: `forge test`
4. **Update documentation**: If changing functionality, update relevant docs
5. **Commit**: Use clear, descriptive commit messages
6. **Push**: `git push origin feature/your-feature-name`
7. **Open PR**: Fill out the PR template with:
   - Description of changes
   - Motivation and context
   - Testing performed
   - Any breaking changes

### PR Review Criteria

- Code follows style guidelines
- Tests pass and coverage is maintained
- Documentation is updated
- Security considerations addressed
- Gas optimization where applicable

## Security

### Security Considerations

- **Reentrancy**: All state-changing functions use `nonReentrant` modifier
- **Access Control**: Use appropriate access modifiers (external vs public)
- **Input Validation**: Validate all inputs with clear error messages
- **Integer Overflow**: Use Solidity 0.8+ built-in overflow protection
- **Front-running**: Consider MEV protection for time-sensitive operations

### Reporting Vulnerabilities

If you discover a security vulnerability:

1. **DO NOT** open a public issue
2. Email security concerns to the maintainers privately
3. Allow time for assessment and fix before disclosure
4. Follow responsible disclosure practices

### Audit History

Current contracts have not undergone formal audit. Contributors should prioritize security in all changes.

## Areas for Contribution

### High Priority

- **Oracle Integration**: Enhanced oracle providers and fallback mechanisms
- **Gas Optimization**: Reduce gas costs for core operations
- **Test Coverage**: Expand test suite to >90% coverage
- **Documentation**: Improve inline documentation and guides

### Medium Priority

- **Frontend Improvements**: Miniapp UI/UX enhancements
- **Analytics**: On-chain analytics and reporting
- **Multi-token Support**: Extend beyond native ETH
- **Governance**: Decentralized protocol governance

### Good First Issues

- Documentation improvements
- Additional test cases
- Code comments and NatSpec
- Example scripts and usage guides
- Bug fixes and minor optimizations

## Resources

- [Foundry Documentation](https://book.getfoundry.sh/)
- [Base Documentation](https://docs.base.org/)
- [OpenZeppelin Contracts](https://docs.openzeppelin.com/contracts)
- [Solidity Documentation](https://docs.soliditylang.org/)

## Questions?

- Open an issue for bug reports or feature requests
- Join community discussions
- Check existing documentation in `API.md`, `DEPLOYMENT_GUIDE.md`, and `USAGE_SCRIPTS.md`

---

Thank you for contributing to Agent Prediction Markets! 🚀
