#!/bin/bash

# Script to generate PNG images from SVG templates
# Requires: librsvg (rsvg-convert) or ImageMagick (convert)

set -e

echo "🎨 Generating mini app images..."

# Check if rsvg-convert is available
if command -v rsvg-convert &> /dev/null; then
    CONVERTER="rsvg"
    echo "✓ Using librsvg (rsvg-convert)"
elif command -v convert &> /dev/null; then
    CONVERTER="imagemagick"
    echo "✓ Using ImageMagick (convert)"
else
    echo "❌ Error: Neither rsvg-convert nor ImageMagick is installed"
    echo ""
    echo "Install one of:"
    echo "  - librsvg: sudo apt-get install librsvg2-bin  (Linux)"
    echo "            brew install librsvg              (Mac)"
    echo "  - ImageMagick: sudo apt-get install imagemagick  (Linux)"
    echo "                brew install imagemagick          (Mac)"
    exit 1
fi

cd "$(dirname "$0")/.."

# Create output directory
mkdir -p public/images

# Generate Icon (1024x1024)
echo "📱 Generating icon-1024.png..."
if [ "$CONVERTER" = "rsvg" ]; then
    rsvg-convert -w 1024 -h 1024 public/images/icon-template.svg -o public/images/icon-1024.png
else
    convert public/images/icon-template.svg -resize 1024x1024 public/images/icon-1024.png
fi

# Generate Splash (200x200)
echo "✨ Generating splash-200.png..."
if [ "$CONVERTER" = "rsvg" ]; then
    rsvg-convert -w 200 -h 200 public/images/splash-template.svg -o public/images/splash-200.png
else
    convert public/images/splash-template.svg -resize 200x200 public/images/splash-200.png
fi

# Generate Hero (1200x630)
echo "🖼️  Generating hero-1200x630.png..."
if [ "$CONVERTER" = "rsvg" ]; then
    rsvg-convert -w 1200 -h 630 public/images/hero-template.svg -o public/images/hero-1200x630.png
else
    convert public/images/hero-template.svg -resize 1200x630 public/images/hero-1200x630.png
fi

# Copy hero as OG image
echo "🔗 Copying to og-1200x630.png..."
cp public/images/hero-1200x630.png public/images/og-1200x630.png

echo ""
echo "✅ All images generated successfully!"
echo ""
echo "Generated files:"
echo "  - public/images/icon-1024.png"
echo "  - public/images/splash-200.png"
echo "  - public/images/hero-1200x630.png"
echo "  - public/images/og-1200x630.png"
echo ""
echo "📝 Next steps:"
echo "  1. Take 3 screenshots of your app (1284×2778px recommended)"
echo "  2. Save them as screenshot-1.png, screenshot-2.png, screenshot-3.png"
echo "  3. Update the URLs in public/.well-known/farcaster.json with your domain"
echo "  4. Deploy to Vercel and configure Account Association"
echo ""
