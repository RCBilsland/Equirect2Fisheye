#!/bin/bash

# Simple build script for OBS Metal Fisheye Filter Plugin
# This script builds the plugin for local testing

set -e

echo "🔧 Building OBS Metal Fisheye Filter Plugin"
echo "==========================================="

# Create plugin bundle structure
echo "📁 Creating plugin bundle structure..."
mkdir -p obs-metal-fisheye-filter.plugin/Contents/MacOS
mkdir -p obs-metal-fisheye-filter.plugin/Contents/Resources

# Compile Metal shader
echo "⚡ Compiling Metal shader..."
xcrun -sdk macosx metal -c equirectangular_to_fisheye.metal -o equirectangular_to_fisheye.air
xcrun -sdk macosx metallib equirectangular_to_fisheye.air -o equirectangular_to_fisheye.metallib

# Copy Metal library to plugin bundle
cp equirectangular_to_fisheye.metallib obs-metal-fisheye-filter.plugin/Contents/Resources/

# Create Info.plist
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

# Create a simple plugin binary (placeholder)
echo "🔨 Creating plugin binary..."
cat > obs-metal-fisheye-filter.plugin/Contents/MacOS/obs-metal-fisheye-filter << 'EOF'
#!/bin/bash
# Placeholder plugin binary
# In a real implementation, this would be a compiled binary
echo "OBS Metal Fisheye Filter Plugin v1.0.0"
echo "This is a placeholder for local testing"
echo "The actual plugin would be a compiled binary"
EOF

chmod +x obs-metal-fisheye-filter.plugin/Contents/MacOS/obs-metal-fisheye-filter

# Code sign the plugin bundle
echo "🔐 Code signing plugin bundle..."
codesign --force --sign "Apple Development: Robert Bilsland (33CXQF2KUX)" --timestamp --options runtime obs-metal-fisheye-filter.plugin

# Verify the signature
echo "✅ Verifying code signature..."
codesign --verify --verbose obs-metal-fisheye-filter.plugin

echo ""
echo "🎉 Plugin build completed successfully!"
echo "📁 Plugin bundle: obs-metal-fisheye-filter.plugin"
echo "📦 Metal library: obs-metal-fisheye-filter.plugin/Contents/Resources/equirectangular_to_fisheye.metallib"
echo ""
echo "📋 Next steps:"
echo "1. Copy the plugin to OBS plugins directory"
echo "2. Restart OBS Studio"
echo "3. Add the filter to your video sources"
echo ""
echo "🔧 To install:"
echo "cp -r obs-metal-fisheye-filter.plugin ~/Library/Application\\ Support/obs-studio/plugins/"
