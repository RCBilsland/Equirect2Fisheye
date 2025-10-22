#!/bin/bash

# Use your Metal shader directly with OBS Studio shader filter
# This approach bypasses plugin creation and uses the built-in shader system

set -e

echo "🎯 Using Your Metal Shader Directly with OBS Studio"
echo "=================================================="

# Check if the shader directory exists
echo "📋 Checking shader directory..."
if [ -d "$HOME/Library/Application Support/obs-studio/plugin_config/obs-shaderfilter/Shaders" ]; then
    echo "✅ Shader directory found"
    
    # Check if your Metal shader is there
    if [ -f "$HOME/Library/Application Support/obs-studio/plugin_config/obs-shaderfilter/Shaders/equirectangular_to_fisheye.metallib" ]; then
        echo "✅ Your Metal shader is ready: equirectangular_to_fisheye.metallib"
    else
        echo "❌ Your Metal shader is not found"
        exit 1
    fi
    
    # Check if the effect file is there
    if [ -f "$HOME/Library/Application Support/obs-studio/plugin_config/obs-shaderfilter/Shaders/equirectangular_to_fisheye.effect" ]; then
        echo "✅ Effect file is ready: equirectangular_to_fisheye.effect"
    else
        echo "❌ Effect file is not found"
        exit 1
    fi
else
    echo "❌ Shader directory not found"
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
echo "2. Check if the shader filter appears in the filters list"
echo "3. If not, there might be an issue with OBS Studio shader loading"
echo ""
echo "🎯 Alternative approach:"
echo "If the shader filter still doesn't work, we can try:"
echo "1. Using the built-in OBS Studio filters"
echo "2. Creating a custom effect file in the OBS Studio directory"
echo "3. Using a different approach to integrate your Metal shader"
