# Security Setup Guide

## API Key Management for Testing

### 🔒 Security Policy

**NEVER commit real API keys to Git!** All API keys must be stored locally and excluded from version control.

### 📋 Quick Start

#### 1. Setup Local API Key File

```bash
# Copy the template file
cp APIKeys.swift.template APIKeys.swift

# Edit APIKeys.swift and add your real API key
# This file is gitignored and won't be committed
```

#### 2. Get Your OpenRouter API Key

1. Visit [OpenRouter](https://openrouter.ai/)
2. Sign up for a free account
3. Navigate to API Keys section
4. Generate a new API key
5. Copy the key (format: `sk-or-v1-...`)

#### 3. Add Key to Local File

Edit `APIKeys.swift`:

```swift
enum TestAPIKeys {
    static let openRouterKey = "sk-or-v1-YOUR_ACTUAL_KEY_HERE"

    static func getKey() -> String? {
        // ... (keep the rest of the code)
    }
}
```

### 🧪 Using API Keys in Tests

For XcodeBuildMCP automated tests:

```swift
// In your test code
if let apiKey = TestAPIKeys.getKey() {
    // Use the key for testing
    settingsService.saveAPIKey(apiKey)
} else {
    print("⚠️ Skipping test - API key not configured")
}
```

For manual testing:
1. Use the Settings tab in the app
2. Enter your API key directly in the UI
3. Key is stored securely in Keychain

### ✅ What's Safe to Commit

✅ **SAFE**:
- `APIKeys.swift.template` - Template with placeholder
- Code with placeholders like `"sk-or-v1-..."`
- Validation logic checking for `"sk-or-v1-"` prefix
- Documentation mentioning key format

❌ **NEVER COMMIT**:
- `APIKeys.swift` - Contains real key
- Any file with real API keys (64 hex characters after prefix)
- Debug views with hardcoded keys
- Test files with actual keys

### 🔍 Pre-Commit Checklist

Before `git push`, always run:

```bash
# Check for exposed API keys
git grep -n "sk-or-v1-[a-f0-9]\{64\}"

# Should return nothing!
# If it finds anything, DO NOT COMMIT
```

### 🛡️ Git Hook Protection

A pre-commit hook is configured to automatically block commits containing real API keys.

If you see this error:
```
⛔️ COMMIT BLOCKED: Potential API key detected!
```

**Action**: Remove the real API key and use the template system instead.

### 🚨 If You Accidentally Commit an API Key

1. **IMMEDIATELY** revoke the key on OpenRouter dashboard
2. Generate a new API key
3. Contact repository admin to remove from Git history
4. Update local `APIKeys.swift` with new key

### 📁 File Structure

```
kioku_ios/
├── .gitignore                    # Blocks APIKeys.swift
├── APIKeys.swift.template        # Safe template (committed)
├── APIKeys.swift                 # Your local keys (gitignored)
├── SECURITY_SETUP.md            # This file
└── KiokuPackage/
    └── Sources/
        └── KiokuFeature/
            └── Views/
                └── Settings/
                    └── SettingsView.swift  # Production key input
```

### 🔐 Keychain Storage

Production API keys are stored in iOS Keychain:
- **Service**: `com.phucnt.kioku.openrouter`
- **Account**: `api-key`
- **Accessibility**: `kSecAttrAccessibleAfterFirstUnlock`

This ensures:
- Keys encrypted at rest
- Secure across app restarts
- Not accessible to other apps
- Automatic cleanup on app uninstall

### 📚 References

- [OpenRouter API Documentation](https://openrouter.ai/docs)
- [iOS Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- Sprint 12 Planning: `docs/01_sprints/sprint_12_planning.md`
