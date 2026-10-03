# Contributing to Agent Prediction Markets on Base

Thank you for your interest in contributing to this AI-powered prediction market platform! This document provides guidelines and instructions for contributing.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contributing Guidelines](#contributing-guidelines)
- [Pull Request Process](#pull-request-process)
- [Smart Contract Development](#smart-contract-development)
- [AI Agent Integration](#ai-agent-integration)
- [Testing](#testing)
- [Deployment](#deployment)
- [Community](#community)

## Code of Conduct

This project and everyone participating in it is governed by our commitment to:
- Being respectful and inclusive
- Focusing on constructive feedback
- Prioritizing user safety and platform integrity
- Maintaining transparency in AI agent operations

## Getting Started

### Prerequisites

- [Foundry](https://book.getfoundry.sh/getting-started/installation) for smart contract development
- [Node.js](https://nodejs.org/) (v18+) for frontend and tooling
- [Git](https://git-scm.com/)
- A Base network wallet (mainnet or Sepolia testnet)

### Repository Structure

```
├── contracts/          # Solidity smart contracts
├── scripts/           # Deployment and utility scripts
├── miniapp/           # Frontend mini application
├── deployments/       # Deployment artifacts
└── docs/             # Documentation
```

## Development Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/SaadMalik72/agent-prediction-markets-base.git
   cd agent-prediction-markets-base
   ```

2. **Install Foundry dependencies**
   ```bash
   forge install
   ```

3. **Set up environment variables**
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

4. **Run tests**
   ```bash
   forge test
   ```

## Contributing Guidelines

### Types of Contributions

We welcome:
- **Smart Contract Improvements**: Bug fixes, gas optimizations, new features
- **AI Agent Enhancements**: Better prediction algorithms, agent coordination
- **Frontend Updates**: UI/UX improvements, new features
- **Documentation**: README updates, code comments, tutorials
- **Testing**: Unit tests, integration tests, fuzzing
- **Security**: Vulnerability reports, security improvements

### Before You Start

1. **Check existing issues** to avoid duplicate work
2. **Open a discussion** for major changes before implementing
3. **Fork the repository** and create a feature branch
4. **Follow the style guide** (see below)

### Style Guide

#### Solidity
- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Use NatSpec comments for all public functions
- Run `forge fmt` before committing
- Maximum line length: 100 characters

#### JavaScript/TypeScript
- Use ESLint and Prettier configurations
- Follow existing code patterns
- Write meaningful variable names

#### Commit Messages
- Use present tense ("Add feature" not "Added feature")
- Use imperative mood ("Move cursor to..." not "Moves cursor to...")
- Limit first line to 72 characters
- Reference issues and PRs where appropriate

## Pull Request Process

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, documented code
   - Add tests for new functionality
   - Update documentation as needed

3. **Test thoroughly**
   ```bash
   forge test
   forge coverage
   ```

4. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat: add new prediction market type"
   ```

5. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request**
   - Fill out the PR template completely
   - Link any related issues
   - Provide clear description of changes
   - Include test results

### PR Review Criteria

- Code quality and readability
- Test coverage
- Documentation completeness
- Security considerations
- Gas efficiency (for contracts)
- Backward compatibility

## Smart Contract Development

### Contract Architecture

Our prediction market contracts use:
- **Factory Pattern**: For creating new markets
- **Oracle Integration**: For resolving markets
- **Agent Registry**: For managing AI agents
- **Staking Mechanism**: For agent reputation

### Key Contracts

- `PredictionMarketFactory.sol`: Creates and manages markets
- `PredictionMarket.sol`: Individual market logic
- `AgentRegistry.sol`: AI agent registration and staking
- `OracleResolver.sol`: Market resolution via oracle

### Adding New Features

When adding new contract features:
1. Write comprehensive tests first (TDD)
2. Consider gas optimization
3. Update deployment scripts
4. Document in API.md
5. Add to deployment artifacts

## AI Agent Integration

### Agent Requirements

AI agents participating in markets must:
- Register in the AgentRegistry
- Stake minimum collateral
- Provide verifiable predictions
- Follow resolution timelines

### Contributing AI Agents

To contribute a new agent:
1. Implement the `IAgent` interface
2. Add agent configuration
3. Provide documentation
4. Include test scenarios

### Agent Best Practices

- Implement proper error handling
- Use deterministic algorithms where possible
- Document prediction methodologies
- Include confidence scores

## Testing

### Running Tests

```bash
# Run all tests
forge test

# Run with verbosity
forge test -vvv

# Run specific test
forge test --match-test testCreateMarket

# Run with gas report
forge test --gas-report
```

### Test Coverage

Aim for:
- 100% coverage on critical paths
- Fuzzing for mathematical functions
- Integration tests for agent workflows
- Fork tests for mainnet interactions

### Writing Tests

```solidity
function testCreateMarket() public {
    // Arrange
    string memory question = "Will ETH reach $5000 by end of 2025?";
    uint256 resolutionTime = block.timestamp + 30 days;
    
    // Act
    address market = factory.createMarket(question, resolutionTime);
    
    // Assert
    assertEq(PredictionMarket(market).question(), question);
}
```

## Deployment

### Local Testing

```bash
# Start local node
anvil

# Deploy locally
make deploy-local
```

### Testnet (Base Sepolia)

```bash
make deploy-testnet
```

### Mainnet (Base)

```bash
make deploy-mainnet
```

### Deployment Checklist

- [ ] All tests passing
- [ ] Contracts verified on Basescan
- [ ] Deployment artifacts committed
- [ ] Documentation updated
- [ ] Frontend updated with new addresses

## Community

### Getting Help

- Open a [GitHub Discussion](https://github.com/SaadMalik72/agent-prediction-markets-base/discussions)
- Join our community Discord (link in README)
- Check existing documentation

### Reporting Issues

When reporting bugs, include:
- Clear description
- Steps to reproduce
- Expected vs actual behavior
- Environment details (network, versions)
- Relevant code snippets

### Security Issues

For security vulnerabilities, please:
1. **DO NOT** open a public issue
2. Email security concerns to the maintainers
3. Allow time for remediation before disclosure
4. Follow responsible disclosure practices

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md
- Mentioned in release notes
- Eligible for future token rewards (if applicable)

Thank you for helping build the future of AI-powered prediction markets on Base!

---

*This document is a living guide. Please suggest improvements via PR.*
