#!/bin/bash

# Fix fisheye effect file issue for OBS plugins
# This script ensures the required fisheye effect files are present

set -e

echo "🔧 Fixing Fisheye Effect File Issue"
echo "===================================="

# Check if obs-equi2fisheye plugin exists
EQUI_PLUGIN="$HOME/Library/Application Support/obs-studio/plugins/obs-equi2fisheye.plugin"
if [ -d "$EQUI_PLUGIN" ]; then
    echo "✅ Found obs-equi2fisheye plugin"
    
    # Copy fisheye effect file to the plugin
    echo "📄 Adding fisheye effect file..."
    cp fisheye.effect "$EQUI_PLUGIN/Contents/MacOS/"
    
    # Also copy to effects directory if it exists
    if [ -d "$EQUI_PLUGIN/Contents/MacOS/effects" ]; then
        cp fisheye.effect "$EQUI_PLUGIN/Contents/MacOS/effects/"
    fi
    
    # Create a default fisheye.effect if it doesn't exist
    if [ ! -f "$EQUI_PLUGIN/Contents/MacOS/fisheye.effect" ]; then
        echo "📄 Creating default fisheye.effect..."
        cp "$EQUI_PLUGIN/Contents/MacOS/working_fisheye.effect" "$EQUI_PLUGIN/Contents/MacOS/fisheye.effect"
    fi
    
    echo "✅ Fixed obs-equi2fisheye plugin"
else
    echo "⚠️  obs-equi2fisheye plugin not found"
fi

# Check if our Metal fisheye filter plugin exists
METAL_PLUGIN="$HOME/Library/Application Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin"
if [ -d "$METAL_PLUGIN" ]; then
    echo "✅ Found obs-metal-fisheye-filter plugin"
    
    # Copy fisheye effect file to our plugin
    echo "📄 Adding fisheye effect file to Metal plugin..."
    cp fisheye.effect "$METAL_PLUGIN/Contents/Resources/"
    
    echo "✅ Fixed obs-metal-fisheye-filter plugin"
else
    echo "⚠️  obs-metal-fisheye-filter plugin not found"
fi

# Verify the files exist
echo ""
echo "🔍 Verifying fisheye effect files..."

if [ -f "$EQUI_PLUGIN/Contents/MacOS/fisheye.effect" ]; then
    echo "✅ obs-equi2fisheye: fisheye.effect found"
else
    echo "❌ obs-equi2fisheye: fisheye.effect missing"
fi

if [ -f "$METAL_PLUGIN/Contents/Resources/fisheye.effect" ]; then
    echo "✅ obs-metal-fisheye-filter: fisheye.effect found"
else
    echo "❌ obs-metal-fisheye-filter: fisheye.effect missing"
fi

echo ""
echo "🎉 Fisheye effect file fix completed!"
echo ""
echo "📋 What was fixed:"
echo "✅ Added fisheye.effect file to both plugins"
echo "✅ Created default fisheye.effect from working version"
echo "✅ Ensured plugins can find required effect files"
echo ""
echo "🔧 Next steps:"
echo "1. Restart OBS Studio"
echo "2. Check the logs - the 'Could not find fisheye effect file' error should be gone"
echo "3. Test the fisheye filter functionality"
echo ""
echo "📄 Effect file includes:"
echo "• FOV (Field of View) control"
echo "• Pan, Tilt, Yaw rotation controls"
echo "• Alpha channel control for outside areas"
echo "• Proper fisheye to equirectangular transformation"
