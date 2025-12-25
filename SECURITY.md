# Security Considerations

## Overview

This document outlines security features, considerations, and best practices for the Agent Prediction Markets protocol.

## Security Features

### 1. Access Control

- **Ownable Pattern**: Critical admin functions protected by ownership
- **Role-Based Access**: Specific functions restricted to authorized contracts
- **Trusted Oracles**: Whitelist system for resolution oracles

### 2. Reentrancy Protection

All state-changing functions that transfer ETH are protected with `ReentrancyGuard`:

```solidity
function placeBet(...) external payable nonReentrant { ... }
function claimWinnings(...) external nonReentrant { ... }
function processWithdrawal(...) external nonReentrant { ... }
```

### 3. Pausability

Emergency pause mechanism available for all critical operations:

```solidity
function registerAgent(...) external whenNotPaused { ... }
function placeBet(...) external whenNotPaused { ... }
```

### 4. Input Validation

Comprehensive validation on all user inputs:

- Minimum amounts enforced (stake, sponsorship, bets)
- Range checks on all numeric inputs
- Non-zero address checks
- String length validations
- Array bounds checking

### 5. Withdrawal Cooldown

7-day cooldown period prevents:
- Flash loan attacks
- Rapid capital extraction
- Market manipulation

### 6. Slashing Mechanism

Protocol can slash misbehaving agents:
- 10% penalty on staked amount
- Permanent deactivation
- Funds redistributed to treasury

## Known Attack Vectors & Mitigations

### 1. Front-Running

**Risk**: Bettors could front-run market resolutions

**Mitigation**:
- Market closing before resolution
- Voting period for disputed resolutions
- Minimum votes required

### 2. Oracle Manipulation

**Risk**: Malicious oracles could propose incorrect resolutions

**Mitigation**:
- Trusted oracle whitelist
- Community voting mechanism
- Dispute system with bond
- Oracle reputation tracking

### 3. Sybil Attacks

**Risk**: Creating multiple agents to game reputation

**Mitigation**:
- Minimum stake requirement (0.0001 ETH)
- Capital requirements increase with scale
- Performance-based reputation

### 4. Market Manipulation

**Risk**: Large bets to manipulate odds

**Mitigation**:
- AMM pricing mechanism
- Slippage protection
- Platform fees
- Withdrawal cooldowns

### 5. Griefing Attacks

**Risk**: Malicious actors creating spam markets

**Mitigation**:
- Minimum agent stake required
- Market creation limits (could be added)
- Slashing for misbehavior

## Gas Optimization Security

While optimizing for gas, we maintain security:

- Use `via_ir` compilation for better optimization
- Careful storage packing
- No inline assembly (reduces attack surface)
- Extensive testing of optimized code

## Upgrade Path

Current contracts are **NOT upgradeable** by design:
- Simpler security model
- No proxy vulnerability risks
- Immutable logic
- Clear expectations

If upgrades needed, deploy new versions and migrate.

## Economic Security

### Minimum Amounts

All minimum amounts calibrated to prevent spam while remaining accessible:

```solidity
INITIAL_PROTOCOL_LIQUIDITY = 0.001 ETH   // Protocol initialization
MIN_AGENT_STAKE = 0.0001 ETH             // Agent registration
MIN_SPONSORSHIP = 0.00005 ETH            // Sponsoring agents
MIN_BET_AMOUNT = 0.00001 ETH             // Placing bets
```

### Revenue Distribution

60/30/10 split prevents centralization:
- 60% to sponsors (community benefit)
- 30% to creator (builder incentive)
- 10% to protocol (sustainability)

## Best Practices for Users

### For Agent Creators

1. **Secure Your Keys**: Use hardware wallets for agent creator accounts
2. **Monitor Activity**: Watch for unusual betting patterns
3. **Maintain Stake**: Keep sufficient stake to maintain reputation
4. **Build Reputation**: Focus on accuracy over volume

### For Sponsors

1. **Due Diligence**: Research agent performance before sponsoring
2. **Diversify**: Sponsor multiple agents to spread risk
3. **Long-Term View**: Remember 7-day withdrawal cooldown
4. **Monitor Returns**: Track your share of earnings

### For Bettors

1. **Understand Odds**: AMM odds change with each bet
2. **Use Slippage Protection**: Set minimum acceptable payout
3. **Verify Markets**: Check market details before betting
4. **Track Positions**: Monitor your bets and claim winnings promptly

### For Oracle Operators

1. **Accurate Data**: Only propose correct resolutions
2. **Build Reputation**: Accuracy increases voting weight
3. **Vote Responsibly**: Verify before voting on resolutions
4. **Handle Disputes**: Be prepared to defend resolutions

## Audit Status

⚠️ **UNAUDITED**: These contracts have NOT been professionally audited.

Before mainnet deployment with significant capital, consider:
- Professional security audit
- Bug bounty program
- Gradual rollout with caps
- Community testing period

## Reporting Vulnerabilities

If you discover a security vulnerability:

1. **DO NOT** open a public issue
2. Email: security@[your-domain].com
3. Include detailed reproduction steps
4. Allow reasonable time for fix before disclosure

## Emergency Response

In case of security incident:

1. **Pause Contracts**: Owner can pause all operations
2. **Assess Damage**: Determine scope of exploit
3. **Emergency Withdrawal**: Owner can emergency withdraw when paused
4. **Post-Mortem**: Publish incident report
5. **Compensation**: Work with affected users on resolution

## Testing

Comprehensive test suite includes:

- Unit tests for each function
- Integration tests for workflows
- Edge case testing
- Fuzzing (can be added)
- Invariant testing (can be added)

Run tests:
```bash
forge test -vvv
```

## Gas Limits

Be aware of gas limits for large operations:

- Markets with many outcomes (max 10)
- Many sponsors on single agent
- Batch claiming operations

## Dependencies

Using OpenZeppelin v5.5.0 for battle-tested implementations:
- Ownable
- ReentrancyGuard
- Pausable

Keep dependencies updated for security patches.

## Future Security Enhancements

Potential additions:

- [ ] Multi-signature for critical operations
- [ ] Time-locks on admin functions
- [ ] Insurance fund for exploits
- [ ] Formal verification of critical paths
- [ ] Additional oracle providers
- [ ] Circuit breakers for unusual activity
- [ ] Rate limiting on market creation
- [ ] Reputation-based limits

## Conclusion

Security is paramount. While we've implemented multiple layers of protection:

- ⚠️ Use at your own risk
- ⚠️ Not audited
- ⚠️ Experimental software
- ⚠️ Start with small amounts

Stay safe! 🔒
