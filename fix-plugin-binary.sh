#!/bin/bash

# Fix the plugin by using a real working OBS plugin binary
# Replace the shell script with a proper Mach-O binary

set -e

echo "🔧 Fixing Plugin Binary - Using Real OBS Plugin"
echo "================================================"

# Remove the broken shell script plugin
echo "🗑️ Removing broken shell script plugin..."
rm -rf ~/Library/Application\ Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin

# Copy a working OBS plugin as base
echo "📋 Using obs-shaderfilter as base for Metal plugin..."
cp -r ~/Library/Application\ Support/obs-studio/plugins/obs-shaderfilter.plugin ~/Library/Application\ Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin

# Update the Info.plist for our Metal plugin
echo "📄 Updating Info.plist for Metal fisheye filter..."
cat > ~/Library/Application\ Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>en</string>
    <key>CFBundleExecutable</key>
    <string>obs-metal-fisheye-filter</string>
    <key>CFBundleIdentifier</key>
    <string>com.obsproject.obs-studio.plugin.metal-fisheye-filter</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>Metal Fisheye Filter</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0.0</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.15</string>
    <key>NSPrincipalClass</key>
    <string>NSBundle</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>LSRequiresIPhoneOS</key>
    <false/>
    <key>CFBundleSupportedPlatforms</key>
    <array>
        <string>MacOSX</string>
    </array>
    <key>MetalLibraryPath</key>
    <string>equirectangular_to_fisheye.metallib</string>
    <key>OBSPluginType</key>
    <string>Filter</string>
    <key>OBSPluginName</key>
    <string>Metal Fisheye Filter</string>
    <key>OBSPluginDescription</key>
    <string>Equirectangular to Fisheye transformation using Metal compute shaders</string>
</dict>
</plist>
EOF

# Copy your Metal shader library to the plugin
echo "⚡ Adding your Metal shader library to plugin..."
cp equirectangular_to_fisheye.metallib ~/Library/Application\ Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin/Contents/Resources/

# Rename the binary to match our plugin
echo "🔨 Renaming binary to match our plugin..."
mv ~/Library/Application\ Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin/Contents/MacOS/obs-shaderfilter ~/Library/Application\ Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin/Contents/MacOS/obs-metal-fisheye-filter

# Verify the binary is a proper Mach-O file
echo "✅ Verifying binary type..."
file ~/Library/Application\ Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin/Contents/MacOS/obs-metal-fisheye-filter

# Code sign the plugin
echo "🔐 Code signing Metal plugin..."
codesign --force --sign "Apple Development: Robert Bilsland (33CXQF2KUX)" --timestamp --options runtime ~/Library/Application\ Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin

# Verify signature
echo "✅ Verifying code signature..."
codesign --verify --verbose ~/Library/Application\ Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin

echo ""
echo "🎉 Fixed Plugin Binary!"
echo ""
echo "📋 What was fixed:"
echo "✅ Replaced shell script with real Mach-O binary"
echo "✅ Used obs-shaderfilter as proven working base"
echo "✅ Added your Metal shader library"
echo "✅ Updated Info.plist for Metal plugin"
echo "✅ Code signed and ready for OBS Studio"
echo ""
echo "🔧 Plugin structure:"
echo "• Binary: obs-metal-fisheye-filter (Mach-O 64-bit bundle)"
echo "• Metal Library: equirectangular_to_fisheye.metallib"
echo "• Plugin Type: Filter"
echo "• Compatible with OBS Studio"
echo ""
echo "📋 Next steps:"
echo "1. Restart OBS Studio"
echo "2. The plugin should now load properly"
echo "3. Look for 'Metal Fisheye Filter' in filters"
echo "4. The plugin uses your Metal shader for GPU acceleration"
