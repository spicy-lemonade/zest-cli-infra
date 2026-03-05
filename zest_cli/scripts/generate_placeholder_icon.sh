#!/bin/bash

# Generate Placeholder Icon for Zest
# Creates a simple placeholder .icns file

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESOURCES_DIR="$(dirname "$SCRIPT_DIR")/resources"
ICONSET_DIR="$RESOURCES_DIR/AppIcon.iconset"

mkdir -p "$ICONSET_DIR"

# Check for ImageMagick
if ! command -v convert &> /dev/null; then
    echo "⚠️  ImageMagick not installed. Creating empty placeholder."
    echo "   Install with: brew install imagemagick"
    echo "   Then re-run this script for a proper placeholder icon."

    # Create a minimal placeholder by using sips to create from a solid color
    # This creates a simple yellow square as placeholder
    mkdir -p "$RESOURCES_DIR"
    touch "$RESOURCES_DIR/icon.icns"
    echo "📦 Empty placeholder created at: $RESOURCES_DIR/icon.icns"
    echo "   Replace with your actual icon before distribution."
    exit 0
fi

echo "🍋 Generating placeholder Zest icon..."

# Generate placeholder icons at required sizes
# Yellow background with "Z" text
SIZES=(16 32 64 128 256 512 1024)
for size in "${SIZES[@]}"; do
    convert -size ${size}x${size} \
        -gravity center \
        -background "#FFD93D" \
        -fill "#1E1E1E" \
        -font "Arial-Bold" \
        -pointsize $((size / 2)) \
        label:"Z" \
        "$ICONSET_DIR/icon_${size}x${size}.png"

    # Create @2x versions for Retina
    if [ $size -le 512 ]; then
        double=$((size * 2))
        convert -size ${double}x${double} \
            -gravity center \
            -background "#FFD93D" \
            -fill "#1E1E1E" \
            -font "Arial-Bold" \
            -pointsize $((double / 2)) \
            label:"Z" \
            "$ICONSET_DIR/icon_${size}x${size}@2x.png"
    fi
done

# Convert to icns
iconutil -c icns "$ICONSET_DIR" -o "$RESOURCES_DIR/icon.icns"

# Clean up iconset
rm -rf "$ICONSET_DIR"

echo "✅ Placeholder icon created at: $RESOURCES_DIR/icon.icns"
echo "   Replace with your actual icon before distribution."
