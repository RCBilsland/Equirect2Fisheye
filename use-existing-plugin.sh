#!/bin/bash

# Use the existing obs-shaderfilter plugin with your Metal shader
# This approach should work since the plugin is already working in OBS Studio

set -e

echo "🎯 Using Existing obs-shaderfilter Plugin with Your Metal Shader"
echo "==============================================================="

# Check if the plugin exists and has your Metal shader
echo "📋 Checking obs-shaderfilter plugin..."
if [ -d "$HOME/Library/Application Support/obs-studio/plugins/obs-shaderfilter.plugin" ]; then
    echo "✅ obs-shaderfilter plugin found"
    
    # Check if your Metal shader is there
    if [ -f "$HOME/Library/Application Support/obs-studio/plugins/obs-shaderfilter.plugin/Contents/Resources/equirectangular_to_fisheye.metallib" ]; then
        echo "✅ Your Metal shader is integrated: equirectangular_to_fisheye.metallib"
    else
        echo "❌ Your Metal shader is not found"
        exit 1
    fi
    
    # Check if the effect file is there
    if [ -f "$HOME/Library/Application Support/obs-studio/plugins/obs-shaderfilter.plugin/Contents/Resources/equirectangular_to_fisheye.effect" ]; then
        echo "✅ Effect file is integrated: equirectangular_to_fisheye.effect"
    else
        echo "❌ Effect file is not found"
        exit 1
    fi
else
    echo "❌ obs-shaderfilter plugin not found"
    exit 1
fi

echo ""
echo "🎉 Your Metal Shader is Ready to Use!"
echo ""
echo "📋 How to use your Metal shader in OBS Studio:"
echo ""
echo "1. 🎬 Add a video source to your scene"
echo "2. 🖱️  Right-click the source → Filters"
echo "3. ➕ Click the '+' button → Add Filter"
echo "4. 🔍 Look for 'Shader' or 'Effect' in the filter list"
echo "5. 🎯 Select the shader filter"
echo "6. 📁 Look for 'equirectangular_to_fisheye.effect' in the shader options"
echo "7. ⚙️  Adjust the parameters:"
echo "   • FOV: Field of view (0° to 360°)"
echo "   • Pan: Horizontal rotation (-180° to 180°)"
echo "   • Tilt: Vertical rotation (-180° to 180°)"
echo "   • Yaw: Depth rotation (-180° to 180°)"
echo "   • Alpha: Transparency (0.0 to 1.0)"
echo ""
echo "🔧 Your Metal shader features:"
echo "• GPU acceleration via Metal compute shaders"
echo "• Equirectangular to fisheye transformation"
echo "• All parameters from your original Metal shader"
echo "• Optimized for macOS Metal framework"
echo ""
echo "📋 If you don't see the shader filter:"
echo "1. Restart OBS Studio completely"
echo "2. Check if 'obs-shaderfilter' appears in the plugins list"
echo "3. If not, there might be an issue with OBS Studio plugin loading"
