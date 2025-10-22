#!/bin/bash

# Test different approaches to get a plugin to show up in OBS Studio
# Let's try multiple strategies to see what works

set -e

echo "🧪 Testing Different Plugin Approaches"
echo "======================================"

# Strategy 1: Check if OBS Studio is actually loading plugins
echo "📋 Strategy 1: Check OBS Studio plugin loading..."
echo "Current plugins in OBS directory:"
ls -la ~/Library/Application\ Support/obs-studio/plugins/ | grep "\.plugin"

# Strategy 2: Check if there are any OBS logs
echo ""
echo "📋 Strategy 2: Check for OBS logs..."
find ~/Library/Logs -name "*obs*" -type f 2>/dev/null | head -3

# Strategy 3: Try to create a minimal test plugin
echo ""
echo "📋 Strategy 3: Create minimal test plugin..."
mkdir -p test-plugin.plugin/Contents/MacOS
mkdir -p test-plugin.plugin/Contents/Resources

# Create a minimal Info.plist
cat > test-plugin.plugin/Contents/Info.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>test-plugin</string>
    <key>CFBundleIdentifier</key>
    <string>com.test.plugin</string>
    <key>CFBundleName</key>
    <string>Test Plugin</string>
    <key>CFBundlePackageType</key>
    <string>BNDL</string>
    <key>CFBundleVersion</key>
    <string>1.0.0</string>
</dict>
</plist>
EOF

# Create a simple binary
cat > test-plugin.plugin/Contents/MacOS/test-plugin << 'EOF'
#!/bin/bash
echo "Test Plugin v1.0.0"
EOF

chmod +x test-plugin.plugin/Contents/MacOS/test-plugin

# Code sign it
codesign --force --sign "Apple Development: Robert Bilsland (33CXQF2KUX)" test-plugin.plugin

# Install it
cp -r test-plugin.plugin ~/Library/Application\ Support/obs-studio/plugins/

echo "✅ Test plugin created and installed"

# Strategy 4: Check if we can see the plugin in OBS
echo ""
echo "📋 Strategy 4: Instructions for testing..."
echo "1. Restart OBS Studio completely"
echo "2. Check if 'Test Plugin' appears in the plugins list"
echo "3. If it doesn't appear, there might be a deeper issue with OBS plugin loading"
echo "4. If it does appear, we can build from there"

# Strategy 5: Alternative approach - use existing working plugin
echo ""
echo "📋 Strategy 5: Alternative approach..."
echo "Since creating new plugins isn't working, let's try:"
echo "1. Use the existing obs-shaderfilter plugin"
echo "2. Add your Metal shader to it"
echo "3. Create an effect file that uses your shader"
echo "4. The effect should appear in the shader filter options"

echo ""
echo "🎯 Next Steps:"
echo "1. Restart OBS Studio"
echo "2. Check if 'Test Plugin' appears"
echo "3. If not, we'll use the shader filter approach"
echo "4. Look for your effect in the shader filter options"
