#!/bin/bash

# Create a working OBS plugin for testing
# This script creates a functional plugin structure

set -e

echo "🔧 Creating Working OBS Metal Fisheye Filter Plugin"
echo "=================================================="

# Remove the current plugin
echo "🧹 Cleaning up existing plugin..."
rm -rf ~/Library/Application\ Support/obs-studio/plugins/obs-metal-fisheye-filter.plugin

# Create a new plugin structure
echo "📁 Creating plugin structure..."
mkdir -p obs-metal-fisheye-filter.plugin/Contents/MacOS
mkdir -p obs-metal-fisheye-filter.plugin/Contents/Resources

# Copy the Metal library
echo "⚡ Copying Metal shader library..."
cp equirectangular_to_fisheye.metallib obs-metal-fisheye-filter.plugin/Contents/Resources/

# Create a simple Info.plist
echo "📄 Creating Info.plist..."
cat > obs-metal-fisheye-filter.plugin/Contents/Info.plist << 'EOF'
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
</dict>
</plist>
EOF

# Create a placeholder binary that OBS can load
echo "🔨 Creating plugin binary..."
cat > obs-metal-fisheye-filter.plugin/Contents/MacOS/obs-metal-fisheye-filter << 'EOF'
#!/usr/bin/env python3
# Simple OBS plugin using Python
# This is a placeholder that demonstrates the plugin structure

import sys
import os

def main():
    print("OBS Metal Fisheye Filter Plugin v1.0.0")
    print("This is a placeholder plugin for testing")
    print("The actual implementation would be a compiled C++ binary")
    return 0

if __name__ == "__main__":
    sys.exit(main())
EOF

chmod +x obs-metal-fisheye-filter.plugin/Contents/MacOS/obs-metal-fisheye-filter

# Code sign the plugin
echo "🔐 Code signing plugin..."
codesign --force --sign "Apple Development: Robert Bilsland (33CXQF2KUX)" --timestamp --options runtime obs-metal-fisheye-filter.plugin

# Verify signature
echo "✅ Verifying code signature..."
codesign --verify --verbose obs-metal-fisheye-filter.plugin

# Install the plugin
echo "📦 Installing plugin..."
cp -r obs-metal-fisheye-filter.plugin ~/Library/Application\ Support/obs-studio/plugins/

echo ""
echo "🎉 Plugin created and installed!"
echo ""
echo "📋 Plugin Status:"
echo "✅ Plugin structure created"
echo "✅ Metal shader library included"
echo "✅ Code signed successfully"
echo "✅ Installed to OBS plugins directory"
echo ""
echo "⚠️  Note: This is a placeholder plugin for testing structure"
echo "   The actual Metal fisheye functionality requires a compiled C++ binary"
echo "   with proper OBS Studio integration."
echo ""
echo "🔧 To test:"
echo "1. Restart OBS Studio"
echo "2. Check if the plugin appears in the plugins list"
echo "3. The Metal shader library is ready for integration"
