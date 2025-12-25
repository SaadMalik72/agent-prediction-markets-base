# 📋 Base Mini App Manifest - Guía Completa

## ✅ Archivos Creados

Tu mini app ya tiene la estructura completa del manifest:

```
miniapp/
├── public/
│   ├── .well-known/
│   │   └── farcaster.json       ✓ Manifest completo
│   └── images/
│       ├── icon-template.svg    ✓ Plantilla ícono
│       ├── splash-template.svg  ✓ Plantilla splash
│       ├── hero-template.svg    ✓ Plantilla hero
│       └── README.md            ✓ Instrucciones
└── scripts/
    └── generate-images.sh       ✓ Script de generación
```

## 🎨 Paso 1: Generar Imágenes PNG

### Opción A: Usar el Script Automático (Recomendado)

```bash
# Instalar dependencia (solo una vez)
# En Linux:
sudo apt-get install librsvg2-bin

# En Mac:
brew install librsvg

# Generar todas las imágenes
npm run generate-images
```

Esto generará automáticamente:
- ✅ `icon-1024.png` (1024×1024px)
- ✅ `splash-200.png` (200×200px)
- ✅ `hero-1200x630.png` (1200×630px)
- ✅ `og-1200x630.png` (1200×630px)

### Opción B: Herramientas Online

Si no puedes instalar librerías:

1. Ve a https://svgtopng.com/
2. Sube cada archivo SVG desde `public/images/`
3. Configura los tamaños:
   - `icon-template.svg` → 1024×1024
   - `splash-template.svg` → 200×200
   - `hero-template.svg` → 1200×630
4. Guarda los PNG en `public/images/`

### Opción C: Usar Figma/Photoshop

1. Importa los SVG
2. Exporta como PNG con los tamaños especificados
3. Guarda en `public/images/`

## 📸 Paso 2: Tomar Screenshots (Opcional pero Recomendado)

1. Ejecuta tu app: `npm run dev`
2. Abre DevTools (F12)
3. Activa Device Toolbar (Ctrl+Shift+M)
4. Configura viewport personalizado: **1284×2778px** (iPhone 14 Pro Max)
5. Navega por las secciones y toma screenshots:
   - Screenshot 1: Vista de Markets
   - Screenshot 2: Vista de Agents
   - Screenshot 3: Vista de Create Market
6. Guárdalas como:
   - `public/images/screenshot-1.png`
   - `public/images/screenshot-2.png`
   - `public/images/screenshot-3.png`

## 🚀 Paso 3: Deploy Inicial a Vercel

```bash
# Instalar Vercel CLI
npm i -g vercel

# Deploy
vercel
```

Sigue los prompts:
- Set up and deploy? **Y**
- Which scope? **Selecciona tu cuenta**
- Link to existing project? **N**
- What's your project's name? **agent-markets-miniapp**
- In which directory is your code located? **./miniapp**
- Want to override settings? **N**

**Copia la URL de producción** (ej: `https://agent-markets-miniapp.vercel.app`)

## 🔧 Paso 4: Actualizar Manifest con tu URL

1. Edita `public/.well-known/farcaster.json`

2. Reemplaza **TODAS** las instancias de `https://your-app.vercel.app` con tu URL real:

```json
{
  "miniapp": {
    "homeUrl": "https://TU-APP.vercel.app",
    "iconUrl": "https://TU-APP.vercel.app/images/icon-1024.png",
    "splashImageUrl": "https://TU-APP.vercel.app/images/splash-200.png",
    "heroImageUrl": "https://TU-APP.vercel.app/images/hero-1200x630.png",
    "screenshotUrls": [
      "https://TU-APP.vercel.app/images/screenshot-1.png",
      "https://TU-APP.vercel.app/images/screenshot-2.png",
      "https://TU-APP.vercel.app/images/screenshot-3.png"
    ],
    "ogImageUrl": "https://TU-APP.vercel.app/images/og-1200x630.png",
    "webhookUrl": "https://TU-APP.vercel.app/api/webhook"
  }
}
```

## 🔐 Paso 5: Configurar Account Association

### A. Deshabilitar Deployment Protection

1. Ve a tu proyecto en Vercel
2. Settings → Deployment Protection
3. **Deshabilita** la protección

### B. Generar Credenciales

1. Ve a https://build.base.org/account-association
2. Ingresa tu dominio: `TU-APP.vercel.app` (sin https://)
3. Conecta tu wallet (la misma que desplegó los contratos)
4. Firma el mensaje
5. Copia las 3 credenciales generadas:
   - `header`
   - `payload`
   - `signature`

### C. Actualizar Manifest

Edita `public/.well-known/farcaster.json` y reemplaza:

```json
{
  "accountAssociation": {
    "header": "eyJhbGc...(TU_HEADER)...=",
    "payload": "eyJkb21h...(TU_PAYLOAD)...=",
    "signature": "MHhiZjI...(TU_SIGNATURE)...=="
  },
  "miniapp": {
    ...
  }
}
```

## 🔄 Paso 6: Re-Deploy

Después de actualizar el manifest:

```bash
# Commit cambios
git add .
git commit -m "Update manifest with account association"
git push

# O re-deploy directo
vercel --prod
```

## ✓ Paso 7: Verificar

### A. Verificar Manifest

```bash
# Desde terminal
curl https://TU-APP.vercel.app/.well-known/farcaster.json

# O en el navegador
https://TU-APP.vercel.app/.well-known/farcaster.json
```

Deberías ver el JSON completo con tus credenciales.

### B. Verificar Imágenes

Abre en el navegador:
- https://TU-APP.vercel.app/images/icon-1024.png
- https://TU-APP.vercel.app/images/splash-200.png
- https://TU-APP.vercel.app/images/hero-1200x630.png

Todas deberían cargar correctamente.

## 🎯 Paso 8: Preview en Base

1. Ve a https://base.dev/preview
2. Ingresa tu URL: `https://TU-APP.vercel.app`
3. Verifica que:
   - ✓ El ícono se muestra
   - ✓ El splash aparece al cargar
   - ✓ El botón de launch funciona
   - ✓ Los metadatos son correctos
   - ✓ Las screenshots se ven bien

## 🚀 Paso 9: Publicar en Base

1. Abre la app de Base (https://base.org/app)
2. Crea un nuevo post
3. Incluye tu URL: `https://TU-APP.vercel.app`
4. Publica

Tu mini app ahora está **LIVE** en Base! 🎉

## 📊 Checklist Final

- [ ] Imágenes PNG generadas (icon, splash, hero, og)
- [ ] Screenshots tomados (3 imágenes)
- [ ] Desplegado a Vercel
- [ ] Manifest actualizado con URL real
- [ ] Deployment Protection deshabilitada
- [ ] Account Association configurada
- [ ] Re-desplegado con credenciales
- [ ] Manifest accesible en /.well-known/farcaster.json
- [ ] Todas las imágenes cargan correctamente
- [ ] Preview en base.dev/preview funciona
- [ ] Publicado en la app de Base

## 🔧 Troubleshooting

### Problema: Manifest no se encuentra (404)

**Solución:**
```bash
# Verifica que public/ esté en el directorio correcto
ls -la public/.well-known/farcaster.json

# Re-build y deploy
npm run build
vercel --prod
```

### Problema: Imágenes no cargan

**Solución:**
```bash
# Verifica que las imágenes existan
ls -la public/images/*.png

# Verifica los nombres correctos
# Deben ser: icon-1024.png, splash-200.png, etc.
```

### Problema: Account Association falla

**Solución:**
1. Asegúrate de usar la misma wallet que desplegó los contratos
2. Verifica que Deployment Protection esté deshabilitada
3. Ingresa solo el dominio, sin https:// ni paths
4. Ejemplo correcto: `agent-markets.vercel.app`
5. Ejemplo incorrecto: `https://agent-markets.vercel.app/`

### Problema: Preview no muestra la app

**Solución:**
1. Espera 2-3 minutos después del deploy
2. Verifica que el manifest JSON sea válido en https://jsonlint.com/
3. Asegúrate de que todas las URLs usen HTTPS
4. Verifica que homeUrl sea exactamente tu URL de Vercel

## 📚 Recursos

- **Base Docs**: https://docs.base.org/mini-apps
- **Manifest Spec**: https://docs.base.org/mini-apps/core-concepts/manifest
- **Account Association**: https://build.base.org/account-association
- **Assets Generator**: https://build.base.org/assets
- **Preview Tool**: https://base.dev/preview

## 💡 Tips

1. **Personaliza los SVG** antes de generar los PNG para que se vean únicos
2. **Usa imágenes de alta calidad** para mejor impresión
3. **Toma screenshots reales** de tu app funcionando, no mockups
4. **Prueba en mobile** - la mayoría de usuarios usarán la app desde celular
5. **Actualiza metadatos** si cambias el nombre o descripción de la app

¡Tu mini app está lista para el mundo! 🌍
