# GitHub Secrets Setup for Code Signing

This guide will help you set up GitHub Secrets for automatic code signing in your GitHub Actions workflow.

## Prerequisites

✅ **Completed:**
- Apple Developer account access
- Certificate request file created (`/tmp/certificate_request.csr`)
- Local code signing test successful

## Step 1: Create Developer ID Certificate

1. **Go to Apple Developer Portal**
   - Visit: https://developer.apple.com/account/resources/certificates/list
   - Click the **"+"** button to create a new certificate

2. **Select Certificate Type**
   - Choose **"Developer ID Application"** (for distribution outside App Store)
   - Click **"Continue"**

3. **Upload Certificate Request**
   - Upload the file: `/tmp/certificate_request.csr`
   - Click **"Continue"**

4. **Download Certificate**
   - Download the `.cer` file
   - Double-click to install it in Keychain Access

## Step 2: Export Certificate for GitHub Actions

1. **Open Keychain Access**
   - Find your **"Developer ID Application"** certificate
   - Right-click → **"Export"**

2. **Choose Format**
   - Select **"Personal Information Exchange (.p12)"**
   - Set a strong password (you'll need this for GitHub Secrets)
   - Save the file (e.g., `developer_id_certificate.p12`)

## Step 3: Convert Certificate to Base64

Run this command in Terminal:

```bash
base64 -i developer_id_certificate.p12 -o certificate_base64.txt
```

## Step 4: Add GitHub Secrets

1. **Go to Your Repository**
   - Navigate to: https://github.com/RCBilsland/Equirect2Fisheye

2. **Access Secrets Settings**
   - Click **"Settings"** tab
   - Click **"Secrets and variables"** → **"Actions"**

3. **Add Required Secrets**
   - Click **"New repository secret"** for each:

   **Secret 1: CERTIFICATE_P12**
   - Name: `CERTIFICATE_P12`
   - Value: (paste the entire content of `certificate_base64.txt`)

   **Secret 2: CERTIFICATE_PASSWORD**
   - Name: `CERTIFICATE_PASSWORD`
   - Value: (the password you set when exporting the .p12 file)

   **Secret 3: CERTIFICATE_NAME**
   - Name: `CERTIFICATE_NAME`
   - Value: (the exact name of your certificate, e.g., "Developer ID Application: Robert Bilsland (XXXXXXXXXX)")

## Step 5: Test the Setup

1. **Create a Test Tag**
   ```bash
   git tag v1.0.0-test
   git push origin v1.0.0-test
   ```

2. **Monitor GitHub Actions**
   - Go to **"Actions"** tab in your repository
   - Watch the build process
   - Check that code signing completes successfully

3. **Verify Release**
   - If successful, a new release will be created
   - Download and test the signed plugin

## Troubleshooting

### Common Issues

**"No identity found"**
- Check that `CERTIFICATE_NAME` matches exactly
- Verify the certificate is installed in Keychain

**"Invalid certificate"**
- Ensure the certificate is valid and not expired
- Check that you're using the correct certificate type

**"Permission denied"**
- Verify the certificate has the correct permissions
- Check that the certificate is not locked

### Getting Certificate Name

To find the exact certificate name:

```bash
security find-identity -v -p codesigning
```

Look for the line with "Developer ID Application" and copy the full name.

## Security Notes

- ⚠️ **Never commit certificate files to the repository**
- ✅ **Use GitHub Secrets for all sensitive information**
- 🔄 **Regularly rotate certificates and update secrets**
- 📅 **Monitor certificate expiration dates**

## Next Steps

Once GitHub Secrets are configured:

1. **Test with a release tag**
2. **Verify the signed plugin works**
3. **Distribute the plugin to users**

The GitHub Actions workflow will automatically:
- Build the plugin
- Sign it with your certificate
- Create a release with the signed plugin
