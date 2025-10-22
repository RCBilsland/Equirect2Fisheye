#!/bin/bash

# OBS Metal Fisheye Filter - Code Signing Setup Script
# This script helps set up code signing for macOS distribution

set -e

echo "🔐 OBS Metal Fisheye Filter - Code Signing Setup"
echo "================================================"

# Check if we're on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "❌ This script is for macOS only"
    exit 1
fi

# Check for Xcode Command Line Tools
if ! command -v xcrun &> /dev/null; then
    echo "❌ Xcode Command Line Tools not found. Please install them first:"
    echo "   xcode-select --install"
    exit 1
fi

echo "✅ Xcode Command Line Tools found"

# Check for existing certificates
echo ""
echo "🔍 Checking existing code signing certificates..."
echo ""

EXISTING_CERTS=$(security find-identity -v -p codesigning 2>/dev/null | grep -c "valid identities found" || echo "0")

if [ "$EXISTING_CERTS" -gt 0 ]; then
    echo "📋 Found existing certificates:"
    security find-identity -v -p codesigning
    echo ""
fi

# Check for Developer ID certificate
DEVELOPER_ID=$(security find-identity -v -p codesigning 2>/dev/null | grep "Developer ID" || echo "")

if [ -n "$DEVELOPER_ID" ]; then
    echo "✅ Developer ID certificate found!"
    echo "$DEVELOPER_ID"
else
    echo "⚠️  No Developer ID certificate found"
    echo ""
    echo "📝 To create a Developer ID certificate:"
    echo "1. Go to: https://developer.apple.com/account/resources/certificates/list"
    echo "2. Click the '+' button to create a new certificate"
    echo "3. Select 'Developer ID Application'"
    echo "4. Upload the certificate request file: /tmp/certificate_request.csr"
    echo "5. Download and install the certificate"
    echo ""
    echo "📄 Certificate request file created at: /tmp/certificate_request.csr"
    echo "   You can also find the private key at: /tmp/private_key.pem"
    echo ""
fi

# Check for GitHub CLI
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI found"
    GITHUB_CLI_AVAILABLE=true
else
    echo "⚠️  GitHub CLI not found. Install it with: brew install gh"
    GITHUB_CLI_AVAILABLE=false
fi

echo ""
echo "🔧 Next Steps:"
echo "=============="
echo ""
echo "1. 📜 Create Developer ID Certificate:"
echo "   - Visit: https://developer.apple.com/account/resources/certificates/list"
echo "   - Create 'Developer ID Application' certificate"
echo "   - Use the certificate request: /tmp/certificate_request.csr"
echo ""
echo "2. 📦 Export Certificate for GitHub Actions:"
echo "   - Open Keychain Access"
echo "   - Find your 'Developer ID Application' certificate"
echo "   - Right-click → Export → Personal Information Exchange (.p12)"
echo "   - Set a password and save the file"
echo ""
echo "3. 🔑 Convert to Base64:"
echo "   base64 -i your_certificate.p12 -o certificate_base64.txt"
echo ""
echo "4. 🔐 Add GitHub Secrets:"
echo "   - Go to your GitHub repository"
echo "   - Settings → Secrets and variables → Actions"
echo "   - Add these secrets:"
echo "     • CERTIFICATE_P12: (content of certificate_base64.txt)"
echo "     • CERTIFICATE_PASSWORD: (password you set when exporting)"
echo "     • CERTIFICATE_NAME: (name of your certificate)"
echo ""

if [ "$GITHUB_CLI_AVAILABLE" = true ]; then
    echo "5. 🚀 Test the setup:"
    echo "   git tag v1.0.0"
    echo "   git push origin v1.0.0"
    echo "   # This will trigger the GitHub Actions build with code signing"
fi

echo ""
echo "📚 For detailed instructions, see: scripts/setup-code-signing.md"
echo ""
echo "✅ Setup script completed!"
