# Code Signing Setup for GitHub Actions

This document explains how to set up code signing for the OBS Metal Fisheye Filter plugin to work with GitHub Actions.

## Prerequisites

1. Apple Developer Account (free or paid)
2. Xcode installed on your Mac
3. Access to GitHub repository secrets

## Step 1: Create a Code Signing Certificate

1. Open **Keychain Access** on your Mac
2. Go to **Keychain Access** > **Certificate Assistant** > **Request a Certificate From a Certificate Authority**
3. Fill in the form:
   - User Email Address: Your Apple ID email
   - Common Name: Your name or organization
   - CA Email Address: Leave blank
   - Request is: Saved to disk
4. Click **Continue** and save the certificate request file

## Step 2: Create a Certificate in Apple Developer Portal

1. Go to [Apple Developer Portal](https://developer.apple.com/account/)
2. Navigate to **Certificates, Identifiers & Profiles**
3. Click **Certificates** > **+** to create a new certificate
4. Select **Developer ID Application** (for distribution outside App Store)
5. Upload your certificate request file
6. Download the certificate and double-click to install it in Keychain

## Step 3: Export Certificate for GitHub Actions

1. Open **Keychain Access**
2. Find your **Developer ID Application** certificate
3. Right-click and select **Export**
4. Choose **Personal Information Exchange (.p12)** format
5. Set a password for the export
6. Save the file (e.g., `certificate.p12`)

## Step 4: Convert Certificate to Base64

Run this command in Terminal:

```bash
base64 -i certificate.p12 -o certificate_base64.txt
```

## Step 5: Add GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** > **Secrets and variables** > **Actions**
3. Add the following secrets:

   - **CERTIFICATE_P12**: Paste the content of `certificate_base64.txt`
   - **CERTIFICATE_PASSWORD**: The password you set when exporting the certificate
   - **CERTIFICATE_NAME**: The name of your certificate (e.g., "Developer ID Application: Your Name (XXXXXXXXXX)")

## Step 6: Verify Setup

1. Create a new tag to trigger the build:
   ```bash
   git tag v1.0.0
   git push origin v1.0.0
   ```

2. Check the GitHub Actions workflow to ensure it completes successfully
3. Verify that the released plugin is properly code signed

## Troubleshooting

### Certificate Issues

- **"No identity found"**: Make sure the certificate name in `CERTIFICATE_NAME` matches exactly
- **"Invalid certificate"**: Ensure the certificate is valid and not expired
- **"Permission denied"**: Check that the certificate has the correct permissions

### Build Issues

- **"Metal library not found"**: Ensure the Metal shader compiles correctly
- **"Code signing failed"**: Verify all secrets are set correctly
- **"Plugin not loading"**: Check that the plugin bundle structure is correct

## Security Notes

- Never commit certificate files or passwords to the repository
- Use GitHub Secrets for all sensitive information
- Regularly rotate certificates and update secrets
- Monitor certificate expiration dates

## Alternative: Local Code Signing

If you prefer to sign locally instead of using GitHub Actions:

1. Build the plugin locally:
   ```bash
   mkdir build && cd build
   cmake .. -DCMAKE_BUILD_TYPE=Release
   make -j$(sysctl -n hw.ncpu)
   ```

2. Sign the plugin:
   ```bash
   codesign --force --sign "Developer ID Application: Your Name" --timestamp --options runtime obs-metal-fisheye-filter.plugin
   ```

3. Verify the signature:
   ```bash
   codesign --verify --verbose obs-metal-fisheye-filter.plugin
   ```
