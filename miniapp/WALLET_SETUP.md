# 🔐 Wallet Setup - Multi-Wallet Support

La mini app ahora soporta múltiples wallets EVM, no solo Coinbase Wallet.

## 🎯 Wallets Soportadas

### 1. **MetaMask** (Injected)
- ✅ Soportada automáticamente
- Extension de navegador
- Desktop & Mobile
- https://metamask.io/

### 2. **WalletConnect**
- ✅ Conecta 300+ wallets
- QR code para mobile
- Trust Wallet, Rainbow, etc.
- https://walletconnect.com/

### 3. **Coinbase Wallet**
- ✅ Coinbase Wallet (desktop/mobile)
- Smart Wallet support
- https://www.coinbase.com/wallet

### 4. **Otras Wallets Injected**
- Rabby Wallet
- Brave Wallet
- Frame
- Any wallet with window.ethereum

## 🔧 Configuración

### 1. WalletConnect Project ID (Opcional)

Para mejor UX con WalletConnect, obtén un Project ID gratis:

1. Ve a https://cloud.walletconnect.com
2. Crea una cuenta
3. Crea un nuevo proyecto
4. Copia tu Project ID

Luego actualiza en `src/wagmi.config.ts`:

```typescript
walletConnect({
  projectId: 'TU_PROJECT_ID_AQUI', // Reemplaza esto
  metadata: {
    name: 'Agent Prediction Markets',
    description: 'AI-Powered Predictions on Base',
    url: 'https://your-app.vercel.app', // Tu URL
    icons: ['https://your-app.vercel.app/images/icon-1024.png']
  },
  showQrModal: true,
}),
```

### 2. Configurar URLs

Actualiza las URLs en `src/wagmi.config.ts` después de deployar:

```typescript
metadata: {
  url: 'https://TU-APP.vercel.app',
  icons: ['https://TU-APP.vercel.app/images/icon-1024.png']
},
```

Y en:

```typescript
coinbaseWallet({
  appName: 'Agent Prediction Markets',
  appLogoUrl: 'https://TU-APP.vercel.app/images/icon-1024.png',
}),
```

## 🎨 Componente WalletConnect

El nuevo componente `WalletConnect.tsx` proporciona:

- ✅ Múltiples opciones de wallet
- ✅ Display de dirección conectada
- ✅ Botón de disconnect
- ✅ Estados de loading
- ✅ Diseño responsivo

### Uso en tu app:

```tsx
import { WalletConnect } from './components/WalletConnect';

function App() {
  return (
    <div>
      <WalletConnect />
    </div>
  );
}
```

## 📱 Cómo Conectar

### Desktop (MetaMask/Rabby/etc)

1. Instala la extension de wallet
2. Click en "Connect Injected"
3. Aprueba la conexión
4. ¡Listo!

### Mobile (WalletConnect)

1. Click en "Connect WalletConnect"
2. Se abre modal con QR code
3. Escanea con tu wallet mobile
4. Aprueba la conexión

### Coinbase Wallet

1. Click en "Connect Coinbase Wallet"
2. Si tienes la extension: aprueba
3. Si no: descarga desde el modal

## 🔒 Seguridad

### Red Soportada

La app solo funciona en **Base Mainnet (Chain ID: 8453)**

Si conectas con una wallet en otra red:
- Se te pedirá cambiar a Base
- Las transacciones fallarán si no estás en Base

### Switch de Red Automático

Wagmi intentará cambiar automáticamente a Base cuando:
- Conectes tu wallet
- Intentes hacer una transacción

Si tu wallet no soporta el cambio automático:
1. Abre tu wallet
2. Ve a configuración de red
3. Agrega Base Mainnet:
   - **Network Name**: Base
   - **RPC URL**: https://mainnet.base.org
   - **Chain ID**: 8453
   - **Currency**: ETH
   - **Block Explorer**: https://basescan.org

## 🎯 Testing Local

### 1. Con MetaMask

```bash
npm run dev
# Abre http://localhost:5173
# Click "Connect Injected"
# Aprueba en MetaMask
```

### 2. Con WalletConnect

- Necesitas HTTPS para WalletConnect
- Usa ngrok o deploy a Vercel para testing

```bash
# Con ngrok
ngrok http 5173
# Usa la URL HTTPS generada
```

## ⚙️ Personalización

### Agregar Más Wallets

Edita `src/wagmi.config.ts`:

```typescript
import { injected, walletConnect, coinbaseWallet, safe } from 'wagmi/connectors';

export const config = createConfig({
  connectors: [
    injected(),
    walletConnect({ ... }),
    coinbaseWallet({ ... }),
    safe(), // Gnosis Safe
    // Agrega más aquí
  ],
  ...
});
```

### Cambiar Orden de Wallets

El orden en el array `connectors` es el orden que aparecen en UI:

```typescript
connectors: [
  injected(),        // 1ro
  walletConnect(),   // 2do
  coinbaseWallet(),  // 3ro
]
```

### Personalizar Labels

En `WalletConnect.tsx`:

```tsx
<button onClick={() => connect({ connector })}>
  {connector.name === 'Injected' ? 'MetaMask' : connector.name}
</button>
```

## 🐛 Troubleshooting

### "Injected" no aparece

**Problema**: No tienes ninguna wallet extension instalada

**Solución**: Instala MetaMask u otra wallet browser extension

### WalletConnect no funciona

**Problema 1**: Project ID no configurado

**Solución**: Obtén un Project ID de https://cloud.walletconnect.com

**Problema 2**: No estás en HTTPS

**Solución**: WalletConnect requiere HTTPS. Deploy a Vercel o usa ngrok.

### Wrong Network

**Problema**: Wallet en otra red (Ethereum, Polygon, etc)

**Solución**:
1. Abre tu wallet
2. Cambia a Base Mainnet
3. O permite el cambio automático cuando la app lo pida

### Transactions Failing

**Verificar**:
1. ✅ Estás en Base Mainnet (Chain ID: 8453)
2. ✅ Tienes suficiente ETH para gas
3. ✅ Tienes suficiente ETH para la transacción + gas
4. ✅ La wallet está conectada

## 📚 Referencias

- **Wagmi Docs**: https://wagmi.sh
- **WalletConnect**: https://docs.walletconnect.com
- **Base Network**: https://docs.base.org
- **MetaMask**: https://docs.metamask.io

## 🔄 Migración desde Coinbase-Only

Si tenías la versión anterior solo con Coinbase:

**Antes**:
```tsx
import { ConnectWallet } from '@coinbase/onchainkit/wallet';
<ConnectWallet />
```

**Después**:
```tsx
import { WalletConnect } from './components/WalletConnect';
<WalletConnect />
```

Los contratos y hooks siguen igual, solo cambia el componente de conexión.

## ✅ Checklist de Deployment

Antes de deployar:

- [ ] WalletConnect Project ID configurado (opcional)
- [ ] URLs actualizadas en wagmi.config.ts
- [ ] Testeado con MetaMask
- [ ] Testeado con WalletConnect (si tienes Project ID)
- [ ] Testeado en Base Mainnet
- [ ] Build exitoso (`npm run build`)
- [ ] .env.local con configuración (no commitear)

¡Listo! Tu app ahora soporta múltiples wallets EVM 🎉
