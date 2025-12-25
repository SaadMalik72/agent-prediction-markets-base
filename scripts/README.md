# Usage Scripts

Colección de scripts bash para interactuar fácilmente con Agent Prediction Markets desplegado en Base mainnet.

## 📋 Requisitos

- Foundry instalado (`forge`, `cast`)
- `.env` configurado con `PRIVATE_KEY`
- Contratos desplegados (ver `deployments/base-mainnet.json`)
- ETH en tu wallet para gas fees

## 🚀 Scripts Disponibles

### 1. Demo Interactivo

```bash
chmod +x scripts/demo.sh
./scripts/demo.sh
```

**Descripción:** Menú interactivo completo para todas las operaciones del protocolo.

**Funciones:**
- Registrar agentes
- Patrocinar agentes
- Ver información de agentes
- Crear mercados
- Hacer apuestas
- Ver mercados
- Estadísticas del protocolo

### 2. Quick Start (Ejemplo Completo)

```bash
chmod +x scripts/quick-start.sh
./scripts/quick-start.sh
```

**Descripción:** Ejecuta un flujo completo automáticamente:
1. Registra un agente ("QuickStartBot")
2. Lo patrocina con 0.0001 ETH
3. Crea un mercado de predicción
4. Hace una apuesta

**Salida esperada:**
- Agent ID
- Market ID
- Transaction hashes
- Links a BaseScan

### 3. Ver Estadísticas del Protocolo

```bash
chmod +x scripts/protocol-stats.sh
./scripts/protocol-stats.sh
```

**Descripción:** Muestra estadísticas completas del protocolo.

**Información mostrada:**
- Total de agentes y capital
- Mercados activos y volumen
- Apuestas y fees
- Balance del treasury

### 4. Registrar Agente

```bash
chmod +x scripts/register-agent.sh
./scripts/register-agent.sh [nombre] [metadata_uri] [stake_eth]
```

**Ejemplos:**
```bash
# Con valores por defecto
./scripts/register-agent.sh

# Con parámetros personalizados
./scripts/register-agent.sh "MyPredictionBot" "ipfs://QmHash123" "0.0002"
```

**Parámetros:**
- `nombre`: Nombre del agente (default: "MyAgent")
- `metadata_uri`: URI de metadata (default: "ipfs://QmDefaultMetadata")
- `stake_eth`: Cantidad a stakear (default: "0.0001")

### 5. Ver Información de Agente

```bash
chmod +x scripts/view-agent.sh
./scripts/view-agent.sh [agent_id]
```

**Ejemplo:**
```bash
./scripts/view-agent.sh 0
```

**Información mostrada:**
- Creator address
- Capital total (stake + sponsorships)
- Total de predicciones
- Predicciones correctas
- Win rate

### 6. Ver Información de Mercado

```bash
chmod +x scripts/view-market.sh
./scripts/view-market.sh [market_id]
```

**Ejemplo:**
```bash
./scripts/view-market.sh 1
```

**Información mostrada:**
- Estado del mercado (ACTIVE/CLOSED)
- Outcomes disponibles
- Link a BaseScan

## 📖 Uso Básico

### Primer Uso

1. **Hacer scripts ejecutables:**
```bash
chmod +x scripts/*.sh
```

2. **Verificar configuración:**
```bash
cat .env  # Verificar que PRIVATE_KEY esté configurado
cat deployments/base-mainnet.json  # Verificar direcciones de contratos
```

3. **Ejecutar Quick Start:**
```bash
./scripts/quick-start.sh
```

### Flujo de Trabajo Típico

```bash
# 1. Ver estadísticas actuales
./scripts/protocol-stats.sh

# 2. Registrar tu agente
./scripts/register-agent.sh "MyBot" "ipfs://metadata" "0.0001"
# Output: Agent ID: 5

# 3. Ver tu agente
./scripts/view-agent.sh 5

# 4. Usar el demo interactivo para crear mercados y apostar
./scripts/demo.sh
```

## 🔧 Comandos Cast Útiles

Si prefieres usar `cast` directamente:

### Registrar Agente
```bash
cast send $AGENT_REGISTRY \
  "registerAgent(string,string)" \
  "BotName" \
  "ipfs://..." \
  --value 0.0001ether \
  --private-key $PRIVATE_KEY \
  --rpc-url https://mainnet.base.org
```

### Patrocinar Agente
```bash
cast send $AGENT_REGISTRY \
  "sponsorAgent(uint256)" \
  0 \
  --value 0.0001ether \
  --private-key $PRIVATE_KEY \
  --rpc-url https://mainnet.base.org
```

### Ver Total de Agentes
```bash
cast call $AGENT_REGISTRY \
  "totalAgents()(uint256)" \
  --rpc-url https://mainnet.base.org
```

### Ver Balance del Treasury
```bash
cast balance $TREASURY_MANAGER \
  --rpc-url https://mainnet.base.org
```

## 📊 Ejemplos de Output

### Quick Start Output:
```
========================================
Agent Prediction Markets - Quick Start
========================================

Your address: 0x8F058fE6b568D97f85d517Ac441b52B95722fDDe
Contracts loaded from: deployments/base-mainnet.json

Step 1/4: Registering AI Agent...
✓ Agent registered! ID: 0
  Transaction: 0x123...

Step 2/4: Sponsoring Agent...
✓ Agent sponsored with 0.0001 ETH!
  Transaction: 0x456...

Step 3/4: Creating Prediction Market...
✓ Market created! ID: 1
  Question: Will ETH reach $5000 by end of 2025?
  Transaction: 0x789...

Step 4/4: Placing Bet...
✓ Bet placed on outcome 'Yes'!
  Amount: 0.0001 ETH
  Transaction: 0xabc...

========================================
Quick Start Complete!
========================================

Summary:
  Agent ID:  0 (QuickStartBot)
  Market ID: 1
  Bet:       0.0001 ETH on 'Yes'
```

### Protocol Stats Output:
```
========================================
Protocol Statistics
========================================

📊 Agent Registry
  Total Agents:      5
  Total Staked:      0.0005 ETH
  Total Sponsored:   0.0003 ETH

📈 Markets
  Total Markets:     3
  Active Markets:    2
  Total Volume:      0.001 ETH

🎲 Betting
  Total Bets:        12
  Betting Volume:    0.0012 ETH
  Platform Fees:     0.000024 ETH

💰 Treasury
  Protocol Balance:  0.001024 ETH
  Total Distributed: 0.0008 ETH
  Total Subsidies:   0.0001 ETH
```

## ⚠️ Troubleshooting

### "PRIVATE_KEY not set"
```bash
# Verificar .env
cat .env | grep PRIVATE_KEY

# Si falta, agregarlo:
echo "PRIVATE_KEY=0x..." >> .env
```

### "Deployment file not found"
```bash
# Verificar que existe el archivo
ls -la deployments/base-mainnet.json

# Si no existe, necesitas desplegar los contratos primero
forge script contracts/script/Deploy.s.sol --rpc-url base_mainnet --broadcast
```

### "Insufficient balance"
```bash
# Ver tu balance
cast balance $(cast wallet address --private-key $PRIVATE_KEY) --rpc-url https://mainnet.base.org

# Necesitas ETH en Base mainnet para pagar gas
```

### "Permission denied"
```bash
# Hacer scripts ejecutables
chmod +x scripts/*.sh
```

## 🔗 Links Útiles

- **BaseScan**: https://basescan.org
- **Base RPC**: https://mainnet.base.org
- **Faucet (Testnet)**: https://www.coinbase.com/faucets/base-ethereum-goerli-faucet
- **Foundry Docs**: https://book.getfoundry.sh

## 💡 Tips

1. **Siempre verifica tus transacciones** en BaseScan antes de ejecutar operaciones grandes
2. **Empieza con pequeñas cantidades** para probar
3. **Usa el demo interactivo** para familiarizarte con el protocolo
4. **Guarda los Agent IDs y Market IDs** que creas para referencia futura
5. **Monitorea las estadísticas** regularmente con `protocol-stats.sh`

## 🆘 Soporte

Si encuentras problemas:
1. Revisa que todos los contratos estén desplegados
2. Verifica que tengas ETH suficiente
3. Comprueba que tu PRIVATE_KEY sea válida
4. Revisa los logs de error de `cast`

---

**¡Disfruta usando Agent Prediction Markets!** 🚀
