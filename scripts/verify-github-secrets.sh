#!/bin/bash

# GitHub Secrets Verification Script
# This script helps verify that GitHub Secrets are properly configured

set -e

echo "🔐 GitHub Secrets Verification"
echo "============================="
echo ""

# Check if GitHub CLI is available
if command -v gh &> /dev/null; then
    echo "✅ GitHub CLI found"
    
    # Check if user is authenticated
    if gh auth status &> /dev/null; then
        echo "✅ GitHub CLI authenticated"
        
        # Get repository info
        REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null || echo "")
        if [ -n "$REPO" ]; then
            echo "📁 Repository: $REPO"
            
            # Check if secrets exist (this requires appropriate permissions)
            echo ""
            echo "🔍 Checking GitHub Secrets..."
            echo "Note: You need 'admin' or 'maintain' permissions to view secrets"
            
            # List secrets (this will only work if you have the right permissions)
            if gh secret list &> /dev/null; then
                echo ""
                echo "📋 Current secrets:"
                gh secret list
                echo ""
                
                # Check for required secrets
                REQUIRED_SECRETS=("CERTIFICATE_P12" "CERTIFICATE_PASSWORD" "CERTIFICATE_NAME")
                MISSING_SECRETS=()
                
                for secret in "${REQUIRED_SECRETS[@]}"; do
                    if gh secret list | grep -q "$secret"; then
                        echo "✅ $secret: Found"
                    else
                        echo "❌ $secret: Missing"
                        MISSING_SECRETS+=("$secret")
                    fi
                done
                
                if [ ${#MISSING_SECRETS[@]} -eq 0 ]; then
                    echo ""
                    echo "🎉 All required secrets are configured!"
                    echo ""
                    echo "🚀 Ready to test:"
                    echo "   git tag v1.0.0"
                    echo "   git push origin v1.0.0"
                else
                    echo ""
                    echo "⚠️  Missing secrets: ${MISSING_SECRETS[*]}"
                    echo "   Please add these secrets in GitHub repository settings"
                fi
            else
                echo "⚠️  Cannot access secrets (insufficient permissions)"
                echo "   Please check manually in GitHub repository settings"
            fi
        else
            echo "⚠️  Not in a GitHub repository"
        fi
    else
        echo "⚠️  GitHub CLI not authenticated"
        echo "   Run: gh auth login"
    fi
else
    echo "⚠️  GitHub CLI not found"
    echo "   Install with: brew install gh"
fi

echo ""
echo "📚 Manual Verification:"
echo "======================="
echo ""
echo "1. Go to: https://github.com/RCBilsland/Equirect2Fisheye/settings/secrets/actions"
echo "2. Verify these secrets exist:"
echo "   • CERTIFICATE_P12"
echo "   • CERTIFICATE_PASSWORD" 
echo "   • CERTIFICATE_NAME"
echo ""
echo "3. Test the setup:"
echo "   git tag v1.0.0"
echo "   git push origin v1.0.0"
echo ""

# Check local certificate status
echo "🔍 Local Certificate Status:"
echo "============================"
security find-identity -v -p codesigning | grep -E "(Developer ID|Apple Development)" || echo "No certificates found"

echo ""
echo "✅ Verification complete!"
