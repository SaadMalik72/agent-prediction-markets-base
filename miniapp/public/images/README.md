# Mini App Images

Este directorio contiene las plantillas SVG para las imágenes del mini app.

## Archivos Requeridos

Para que tu mini app funcione correctamente, necesitas generar las siguientes imágenes en PNG:

### 1. Icon (1024×1024px)
- **Archivo**: `icon-1024.png`
- **Tamaño**: 1024×1024 píxeles
- **Formato**: PNG
- **Plantilla**: `icon-template.svg`
- **Uso**: Ícono principal de la app

### 2. Splash (200×200px)
- **Archivo**: `splash-200.png`
- **Tamaño**: 200×200 píxeles (recomendado)
- **Formato**: PNG
- **Plantilla**: `splash-template.svg`
- **Uso**: Pantalla de carga

### 3. Hero Image (1200×630px)
- **Archivo**: `hero-1200x630.png`
- **Tamaño**: 1200×630 píxeles (ratio 1.91:1)
- **Formato**: PNG o JPG
- **Plantilla**: `hero-template.svg`
- **Uso**: Imagen destacada en la página de la app

### 4. OG Image (1200×630px)
- **Archivo**: `og-1200x630.png`
- **Tamaño**: 1200×630 píxeles (ratio 1.91:1)
- **Formato**: PNG o JPG
- **Plantilla**: Puedes usar el mismo que hero
- **Uso**: Open Graph para redes sociales

### 5. Screenshots (1284×2778px) - Opcional
- **Archivos**: `screenshot-1.png`, `screenshot-2.png`, `screenshot-3.png`
- **Tamaño**: 1284×2778 píxeles (portrait, recomendado)
- **Formato**: PNG
- **Máximo**: 3 imágenes
- **Uso**: Capturas de pantalla de la app

## Cómo Convertir SVG a PNG

### Opción 1: Usar herramientas online
1. Ve a https://svgtopng.com/ o https://cloudconvert.com/svg-to-png
2. Sube el archivo SVG
3. Configura el tamaño deseado
4. Descarga el PNG

### Opción 2: Usar Figma/Sketch
1. Importa el SVG
2. Exporta como PNG con el tamaño especificado

### Opción 3: Usar ImageMagick (CLI)
```bash
# Instalar ImageMagick
sudo apt-get install imagemagick  # Linux
brew install imagemagick          # Mac

# Convertir
convert icon-template.svg -resize 1024x1024 icon-1024.png
convert splash-template.svg -resize 200x200 splash-200.png
convert hero-template.svg -resize 1200x630 hero-1200x630.png
cp hero-1200x630.png og-1200x630.png
```

### Opción 4: Usar librsvg (CLI)
```bash
# Instalar
sudo apt-get install librsvg2-bin  # Linux
brew install librsvg               # Mac

# Convertir
rsvg-convert -w 1024 -h 1024 icon-template.svg -o icon-1024.png
rsvg-convert -w 200 -h 200 splash-template.svg -o splash-200.png
rsvg-convert -w 1200 -h 630 hero-template.svg -o hero-1200x630.png
cp hero-1200x630.png og-1200x630.png
```

## Personalización

Puedes personalizar los SVG editándolos directamente:

1. **Colores**: Cambia los valores de los gradientes y fills
2. **Texto**: Modifica el contenido del texto
3. **Logo**: Reemplaza el robot con tu propio diseño

## Tomar Screenshots

Para generar los screenshots de tu app:

1. Ejecuta `npm run dev`
2. Abre la app en tu navegador
3. Ajusta el viewport a 1284×2778px (usa DevTools)
4. Toma screenshots de:
   - Vista de Markets
   - Vista de Agents
   - Vista de Betting
5. Guárdalas como `screenshot-1.png`, `screenshot-2.png`, `screenshot-3.png`

## Verificar

Después de generar las imágenes:

1. Asegúrate de que todas estén en `public/images/`
2. Actualiza las URLs en `public/.well-known/farcaster.json` con tu dominio real
3. Verifica que las imágenes se carguen en `http://localhost:5173/images/icon-1024.png`

## Herramientas Recomendadas

- **Base Mini App Assets Generator**: https://build.base.org/assets
- **SVG to PNG**: https://svgtopng.com/
- **Image Resizer**: https://imageresizer.com/
