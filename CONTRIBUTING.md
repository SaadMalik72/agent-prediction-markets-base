# Contributing to Agent Prediction Markets on Base

Thank you for your interest in contributing to the Agent Prediction Markets project! This document provides guidelines and instructions for contributing to this AI-powered prediction markets platform on Base blockchain.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [How to Contribute](#how-to-contribute)
- [Coding Standards](#coding-standards)
- [Testing](#testing)
- [Security](#security)
- [Areas for Contribution](#areas-for-contribution)

## Code of Conduct

This project and everyone participating in it is governed by our commitment to:

- **Respectful Communication**: Be kind, constructive, and professional
- **Inclusive Environment**: Welcome contributors from all backgrounds
- **Collaborative Spirit**: Help others learn and grow
- **Quality Focus**: Strive for excellence in all contributions

## Getting Started

### Prerequisites

Before contributing, ensure you have:

- **Git**: For version control
- **Foundry**: For Ethereum development (see [Development Setup](#development-setup))
- **Node.js**: v18+ for frontend/Mini App development
- **Base Sepolia ETH**: For testing (get from [Base Sepolia Faucet](https://www.coinbase.com/faucets/base-sepolia-faucet))

### Project Structure

```
agent-prediction-markets-base/
├── contracts/          # Solidity smart contracts
├── deployments/        # Deployment configurations
├── miniapp/           # Mini App frontend
├── scripts/           # Utility scripts
├── API.md             # API documentation
├── DEPLOYMENT_GUIDE.md # Deployment instructions
└── USAGE_SCRIPTS.md   # Usage examples
```

## Development Setup

### 1. Clone the Repository

```bash
git clone https://github.com/SaadMalik72/agent-prediction-markets-base.git
cd agent-prediction-markets-base
```

### 2. Install Foundry

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 3. Install Dependencies

```bash
forge install
```

### 4. Set Up Environment

```bash
cp .env.example .env
# Edit .env with your configuration
```

Required environment variables:
- `PRIVATE_KEY`: Your testnet private key
- `BASE_SEPOLIA_RPC_URL`: Base Sepolia RPC endpoint
- `BASE_MAINNET_RPC_URL`: Base Mainnet RPC endpoint
- `ETHERSCAN_API_KEY`: For contract verification

### 5. Build and Test

```bash
# Compile contracts
forge build

# Run tests
forge test

# Run tests with verbosity
forge test -vvv
```

## How to Contribute

### Reporting Issues

If you find a bug or have a suggestion:

1. **Check existing issues** to avoid duplicates
2. **Create a new issue** with:
   - Clear title and description
   - Steps to reproduce (for bugs)
   - Expected vs actual behavior
   - System information (OS, Node version, etc.)
   - Screenshots if applicable

### Submitting Pull Requests

1. **Fork the repository** and create your branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes** following our coding standards

3. **Test your changes**:
   ```bash
   forge test
   npm test  # for Mini App changes
   ```

4. **Commit with clear messages**:
   ```bash
   git commit -m "feat: add agent betting strategy module"
   ```

5. **Push to your fork**:
   ```bash
   git push origin feature/your-feature-name
   ```

6. **Open a Pull Request** with:
   - Clear description of changes
   - Link to related issue(s)
   - Screenshots/demo for UI changes
   - Test results

### Commit Message Convention

We follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation changes
- `style:` Code style changes (formatting, semicolons, etc.)
- `refactor:` Code refactoring
- `test:` Adding or updating tests
- `chore:` Build process or auxiliary tool changes

Example:
```
feat: implement sentiment analysis for market resolution

- Add SentimentAnalyzer contract
- Integrate with Chainlink oracle
- Add unit tests for sentiment scoring
```

## Coding Standards

### Solidity

- Follow [Solidity Style Guide](https://docs.soliditylang.org/en/latest/style-guide.html)
- Use `solhint` for linting
- Maximum line length: 120 characters
- Use explicit visibility modifiers
- Add NatSpec documentation for all public functions

Example:
```solidity
/**
 * @notice Places a bet on a prediction market
 * @param _marketId The ID of the market to bet on
 * @param _outcome The predicted outcome (true/false)
 * @param _amount The amount to bet in wei
 */
function placeBet(
    uint256 _marketId,
    bool _outcome,
    uint256 _amount
) external payable nonReentrant {
    // Implementation
}
```

### JavaScript/TypeScript (Mini App)

- Use ESLint and Prettier
- Follow existing code patterns
- Add JSDoc comments for functions
- Use TypeScript for new files

## Testing

### Smart Contract Tests

```bash
# Run all tests
forge test

# Run specific test
forge test --match-test testPlaceBet

# Run with gas report
forge test --gas-report

# Run with coverage
forge coverage
```

### Test Requirements

- All new features must include tests
- Maintain >80% code coverage
- Test edge cases and failure modes
- Use fuzzing where appropriate

### Mini App Tests

```bash
cd miniapp
npm test
npm run test:coverage
```

## Security

### Reporting Security Issues

**DO NOT** create public issues for security vulnerabilities.

Instead:
1. Email security concerns to: [maintainer email]
2. Include detailed description and reproduction steps
3. Allow 48 hours for initial response
4. Coordinate disclosure timeline

### Security Best Practices

- Use OpenZeppelin contracts where possible
- Follow [Consensys Smart Contract Best Practices](https://consensys.github.io/smart-contract-best-practices/)
- Run Slither analysis: `slither .`
- Run Mythril analysis: `mythril analyze contracts/Contract.sol`
- Never commit private keys or sensitive data

## Areas for Contribution

### High Priority

1. **Agent Strategy Improvements**
   - Enhanced betting algorithms
   - Multi-agent coordination
   - Risk management strategies

2. **Oracle Integration**
   - Additional data sources
   - Cross-chain oracle solutions
   - Decentralized resolution mechanisms

3. **Smart Contract Optimization**
   - Gas optimization
   - Batch operations
   - Layer 2 scaling improvements

### Medium Priority

4. **Mini App Enhancements**
   - UI/UX improvements
   - Mobile responsiveness
   - Accessibility features

5. **Documentation**
   - API documentation
   - Tutorial content
   - Code examples

6. **Testing Infrastructure**
   - Integration tests
   - Performance benchmarks
   - Chaos testing

### Good First Issues

- Fix typos in documentation
- Add inline code comments
- Improve error messages
- Update dependencies
- Add logging to scripts

## Questions?

- Join our [Discord community](https://discord.gg/predictionmarkets)
- Check the [API documentation](API.md)
- Review [deployment guide](DEPLOYMENT_GUIDE.md)
- Read [usage examples](USAGE_SCRIPTS.md)

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

Thank you for helping build the future of AI-powered prediction markets on Base! 🚀