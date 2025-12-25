# 🚀 Usage Scripts - Quick Reference

Scripts bash listos para usar que interactúan con tus contratos desplegados en Base mainnet.

## 📁 Scripts Disponibles

```
scripts/
├── demo.sh              # Demo interactivo completo
├── quick-start.sh       # Ejemplo automático end-to-end
├── protocol-stats.sh    # Estadísticas del protocolo
├── register-agent.sh    # Registrar un agente
├── view-agent.sh        # Ver info de un agente
├── view-market.sh       # Ver info de un mercado
└── README.md            # Documentación completa
```

## ⚡ Quick Start (1 comando)

Ejecuta un ejemplo completo automáticamente:

```bash
chmod +x scripts/quick-start.sh
./scripts/quick-start.sh
```

**Esto hará:**
1. ✅ Registrar un agente "QuickStartBot" (0.0001 ETH)
2. ✅ Patrocinarlo con 0.0001 ETH adicional
3. ✅ Crear un mercado "Will ETH reach $5000 by end of 2025?"
4. ✅ Hacer una apuesta de 0.0001 ETH en "Yes"

**Output esperado:**
```
========================================
Quick Start Complete!
========================================

Summary:
  Agent ID:  0 (QuickStartBot)
  Market ID: 1
  Bet:       0.0001 ETH on 'Yes'

View on BaseScan:
  Agent:  https://basescan.org/address/0xC7e7...
  Market: https://basescan.org/address/0xd2D6...

Next steps:
  - Run './scripts/view-agent.sh 0' to see agent details
  - Run './scripts/view-market.sh 1' to see market details
  - Run './scripts/demo.sh' for interactive demo
```

## 🎮 Demo Interactivo

Para explorar todas las funcionalidades:

```bash
chmod +x scripts/demo.sh
./scripts/demo.sh
```

**Menú interactivo con:**
- Registrar agentes
- Patrocinar agentes
- Ver información de agentes
- Crear mercados de predicción
- Hacer apuestas
- Ver información de mercados
- Estadísticas del protocolo
- Ver totales de agentes y mercados

## 📊 Ver Estadísticas

```bash
chmod +x scripts/protocol-stats.sh
./scripts/protocol-stats.sh
```

**Muestra:**
```
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

## 🤖 Registrar Agente

Forma rápida:
```bash
./scripts/register-agent.sh
```

Con parámetros personalizados:
```bash
./scripts/register-agent.sh "MyPredictionBot" "ipfs://QmHash123" "0.0002"
```

**Parámetros:**
- Nombre del agente (default: "MyAgent")
- URI de metadata (default: "ipfs://QmDefaultMetadata")
- Cantidad a stakear en ETH (default: "0.0001")

## 🔍 Ver Información

**Ver agente:**
```bash
./scripts/view-agent.sh 0  # Agent ID 0
```

**Ver mercado:**
```bash
./scripts/view-market.sh 1  # Market ID 1
```

## 💡 Ejemplos de Uso

### Escenario 1: Crear tu primer agente

```bash
# 1. Ver estadísticas actuales
./scripts/protocol-stats.sh

# 2. Registrar tu agente
./scripts/register-agent.sh "TradingBot" "ipfs://metadata" "0.0001"
# Output: Agent ID: 5

# 3. Ver tu agente
./scripts/view-agent.sh 5

# 4. Conseguir sponsors (compartir el ID)
# Otros pueden patrocinar tu agente con:
# cast send $AGENT_REGISTRY "sponsorAgent(uint256)" 5 --value 0.00005ether
```

### Escenario 2: Workflow completo automatizado

```bash
# Ejecuta todo el flujo automáticamente
./scripts/quick-start.sh

# Verifica los resultados
./scripts/protocol-stats.sh
```

### Escenario 3: Exploración interactiva

```bash
# Abre el menú interactivo
./scripts/demo.sh

# Sigue las opciones del menú
# 1 -> Registrar agente
# 4 -> Crear mercado
# 5 -> Hacer apuesta
# 7 -> Ver estadísticas
```

## 🔧 Requisitos

- ✅ Foundry instalado (`forge`, `cast`)
- ✅ Archivo `.env` con `PRIVATE_KEY`
- ✅ Contratos desplegados en Base mainnet
- ✅ ETH en tu wallet para gas fees (~0.01 ETH recomendado)

## 📋 Verificación Previa

Antes de ejecutar los scripts:

```bash
# 1. Verificar que .env existe
cat .env | grep PRIVATE_KEY

# 2. Verificar deployment
cat deployments/base-mainnet.json

# 3. Verificar tu balance
cast balance $(cast wallet address --private-key $PRIVATE_KEY) \
  --rpc-url https://mainnet.base.org

# 4. Hacer scripts ejecutables
chmod +x scripts/*.sh
```

## ⚠️ Troubleshooting

### Error: "PRIVATE_KEY not set"
```bash
echo "PRIVATE_KEY=0x..." >> .env
```

### Error: "Deployment file not found"
```bash
# Verifica que el archivo existe
ls deployments/base-mainnet.json

# Si no existe, revisa DEPLOYED.md para las direcciones
```

### Error: "Insufficient balance"
```bash
# Necesitas ETH en Base mainnet
# Mínimo recomendado: 0.01 ETH para gas + operaciones
```

### Error: "Permission denied"
```bash
chmod +x scripts/*.sh
```

## 📖 Documentación Completa

Para información detallada, ver:
- [scripts/README.md](scripts/README.md) - Documentación completa de scripts
- [README.md](README.md) - Documentación del proyecto
- [API.md](API.md) - Referencia de API
- [DEPLOYED.md](DEPLOYED.md) - Info del deployment

## 🎯 Direcciones de Contratos

Tus contratos desplegados en Base mainnet:

```javascript
const contracts = {
  AgentRegistry:   "0xC7e730797e1E4Cd988596a6BA4484a93A1211070",
  TreasuryManager: "0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35",
  BettingEngine:   "0xc0BBdb413A0c575b101C8c1E7873566d4A8Ff3Ae",
  OracleResolver:  "0x914ed4Fd86151d2C7edC753751007A082135AC48",
  MarketFactory:   "0xd2D6c9739fb8e9dE6460CE24cc399ef473d01Bfd"
};
```

## 🔗 Links Útiles

- **BaseScan**: https://basescan.org
- **Your Treasury**: https://basescan.org/address/0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35
- **Your AgentRegistry**: https://basescan.org/address/0xC7e730797e1E4Cd988596a6BA4484a93A1211070

## 💰 Costos Estimados

| Operación | Gas Estimado | Costo @ 0.5 gwei |
|-----------|--------------|------------------|
| Registrar Agente | ~150,000 | ~0.00007 ETH + 0.0001 ETH stake |
| Patrocinar Agente | ~80,000 | ~0.00004 ETH + 0.00005 ETH sponsorship |
| Crear Mercado | ~300,000 | ~0.00015 ETH |
| Hacer Apuesta | ~120,000 | ~0.00006 ETH + apuesta |

*Más el monto de ETH que stakes/sponsoreas/apuestas*

## ✅ Checklist de Uso

- [ ] Foundry instalado
- [ ] `.env` configurado con PRIVATE_KEY
- [ ] Suficiente ETH en wallet (~0.01 ETH)
- [ ] Scripts hechos ejecutables (`chmod +x scripts/*.sh`)
- [ ] Deployment verificado (`cat deployments/base-mainnet.json`)
- [ ] Ejecutar `./scripts/quick-start.sh` exitosamente
- [ ] Ver estadísticas con `./scripts/protocol-stats.sh`
- [ ] Listo para crear tus propios agentes! 🚀

---

**¡Empieza ahora mismo!**

```bash
./scripts/quick-start.sh
```
