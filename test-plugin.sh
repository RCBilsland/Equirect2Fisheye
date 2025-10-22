#!/bin/bash

# Test script for OBS Metal Fisheye Filter Plugin
# This script verifies the plugin installation and functionality

echo "🧪 Testing OBS Metal Fisheye Filter Plugin"
echo "=========================================="

# Check if OBS Studio is installed
if [ -d "/Applications/OBS.app" ]; then
    echo "✅ OBS Studio is installed"
else
    echo "❌ OBS Studio not found. Please install OBS Studio first."
    exit 1
fi

# Check if plugin is installed
PLUGIN_PATH="$HOME/Library/Application Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin"
if [ -d "$PLUGIN_PATH" ]; then
    echo "✅ Plugin is installed at: $PLUGIN_PATH"
else
    echo "❌ Plugin not found. Please run build-plugin.sh first."
    exit 1
fi

# Check plugin structure
echo ""
echo "📁 Plugin structure:"
ls -la "$PLUGIN_PATH/Contents/"

echo ""
echo "📦 Resources:"
ls -la "$PLUGIN_PATH/Contents/Resources/"

# Check code signature
echo ""
echo "🔐 Code signature:"
codesign --verify --verbose "$PLUGIN_PATH" 2>&1

# Check Metal library
METAL_LIB="$PLUGIN_PATH/Contents/Resources/equirectangular_to_fisheye.metallib"
if [ -f "$METAL_LIB" ]; then
    echo ""
    echo "✅ Metal library found: $(basename "$METAL_LIB")"
    echo "📊 Size: $(ls -lh "$METAL_LIB" | awk '{print $5}')"
else
    echo "❌ Metal library not found"
fi

echo ""
echo "🎉 Plugin installation test completed!"
echo ""
echo "📋 Next steps:"
echo "1. Open OBS Studio"
echo "2. Add a video source (Media Source, Camera, etc.)"
echo "3. Right-click on the source → Filters"
echo "4. Click '+' → Look for 'Metal Fisheye Filter'"
echo "5. Adjust the FOV, Pan, Tilt, Yaw, and Alpha parameters"
echo ""
echo "🔧 If the plugin doesn't appear:"
echo "1. Restart OBS Studio"
echo "2. Check OBS Studio logs for any errors"
echo "3. Verify the plugin is properly code signed"
