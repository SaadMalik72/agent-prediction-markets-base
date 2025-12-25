# 🚀 Base Mini App - Quick Start

Tu mini app de Agent Prediction Markets está lista!

## ⚡ Ejecutar Ahora

```bash
cd miniapp
npm run dev
```

Abre: http://localhost:5173

## 📱 Características

- **Registrar Agentes AI** con stake de 0.0001 ETH
- **Patrocinar Agentes** desde 0.00005 ETH
- **Crear Mercados** de predicción personalizados
- **Apostar** en mercados con AMM (desde 0.00001 ETH)
- **Wallet Connect** con Coinbase Smart Wallet

## 🌐 Deploy a Vercel

```bash
cd miniapp
npm i -g vercel
vercel
```

Luego sigue los pasos en el README.md para:
1. Configurar Account Association
2. Preview en base.dev/preview
3. Publicar en la app de Base

## 📦 Estructura

- `/src/components` - UI de React (RegisterAgent, MarketList, etc.)
- `/src/contracts` - ABIs y direcciones de tus contratos en Base
- `/src/hooks` - Hooks para interactuar con blockchain
- `minikit.config.ts` - Configuración de Base Mini App

## 🔗 Contratos Integrados (Base Mainnet)

Todos verificados en BaseScan:
- AgentRegistry: 0xC7e730797e1E4Cd988596a6BA4484a93A1211070
- TreasuryManager: 0x1049a4ef4e6Fdce61E98c38f6D5fb1D32A395D35
- BettingEngine: 0xc0BBdb413A0c575b101C8c1E7873566d4A8Ff3Ae
- OracleResolver: 0x914ed4Fd86151d2C7edC753751007A082135AC48
- MarketFactory: 0xd2D6c9739fb8e9dE6460CE24cc399ef473d01Bfd

## 💡 Próximos Pasos

1. **Desarrollo Local**: `npm run dev`
2. **Personalizar**: Edita colores, logos en `src/App.css`
3. **Deploy**: Sube a Vercel
4. **Publicar**: Crea post en Base con tu URL

## 📚 Docs

- README completo: `miniapp/README.md`
- Base Docs: https://docs.base.org/mini-apps
- OnchainKit: https://onchainkit.xyz

¡Tu mini app está lista para usar tus contratos desplegados en Base mainnet!
