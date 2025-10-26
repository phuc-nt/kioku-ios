# Privacy Policy

**Last Updated: October 26, 2025**

## Overview

Kioku ("we", "our", or "the app") is committed to protecting your privacy. This Privacy Policy explains how Kioku handles your personal information and journal data.

**TL;DR**: Your data stays on your device. We don't collect, store, or share anything.

## Data Collection

### What We DON'T Collect

- ❌ **No personal information** - No name, email, phone number, or account
- ❌ **No journal content** - Your entries never leave your device
- ❌ **No analytics** - No usage tracking, crash reports, or telemetry
- ❌ **No location data** - We don't access your GPS location
- ❌ **No contacts** - We don't access your address book
- ❌ **No photos** - We don't access your camera or photo library (v0.1.0)

### What We DO Store (Locally Only)

- ✅ **Journal entries** - Stored in SwiftData on your device
- ✅ **AI-extracted entities** - People, places, events, emotions (local only)
- ✅ **Relationships** - Connections between entities (local only)
- ✅ **Chat conversations** - AI chat history (local only)
- ✅ **User preferences** - App settings (local only)

**Important**: ALL data is stored exclusively on your iPhone using iOS's local database (SwiftData). Nothing is uploaded to servers or cloud storage.

## Third-Party Services

### OpenRouter API (Optional)

When you use AI features, Kioku sends your journal entries to OpenRouter API for processing. This happens ONLY when you:
- Ask AI a question in the Chat tab
- Trigger entity extraction
- Generate AI insights

**What OpenRouter receives**:
- Journal entry text (only entries relevant to your question)
- No identifying information about you
- No device information

**OpenRouter's privacy**:
- See [OpenRouter Privacy Policy](https://openrouter.ai/privacy)
- They process requests but don't store your journal content
- You can choose different AI models with different privacy policies

**You have control**:
- AI features are optional (you can use Kioku without them)
- You can delete your OpenRouter API key at any time
- Deleting the API key disables all AI features

## Data Storage & Security

### Local Storage
- All data stored using **SwiftData** (iOS 18+ native database)
- Data location: Your iPhone's app container (sandboxed)
- **Encryption**: Supported via iOS Keychain for encryption keys
- Data persists until you delete the app or use "Clear All Data"

### Backups
- Your data IS included in iOS backups (iCloud/iTunes)
- Backups are encrypted by iOS (if you enable encryption)
- You can export your data manually (JSON/Markdown format)

### Data Deletion
- **Delete app**: Removes all data permanently
- **Clear All Data**: In Settings → removes all entries, entities, relationships
- **Export before deletion**: Recommended to backup via JSON export

## Your Rights

### Data Ownership
- ✅ You own 100% of your journal data
- ✅ You can export all data at any time (JSON format)
- ✅ You can delete all data at any time
- ✅ No vendor lock-in - exported data is portable

### Data Portability
- **Export to JSON** - Complete backup with all metadata
- **Export to Markdown** - Human-readable text format
- **Import from JSON** - Restore from backups
- Standard formats - can be read by other apps

## Changes to AI Models

Different AI models have different privacy policies:

- **GPT-4 (OpenAI)** - [OpenAI Privacy Policy](https://openai.com/privacy)
- **Claude (Anthropic)** - [Anthropic Privacy Policy](https://www.anthropic.com/privacy)
- **Gemini (Google)** - [Google Privacy Policy](https://policies.google.com/privacy)

**Note**: When you select a model in Kioku, your journal entries are sent to that provider via OpenRouter. Check their privacy policies before use.

## Children's Privacy

Kioku does not knowingly collect data from children under 13. If you are under 13, please do not use this app. If we discover we have collected data from a child under 13, we will delete it immediately.

## Data Breach Notification

Since we don't collect or store your data on servers, there is no risk of data breach from our side. Your data security depends on:
- Your iPhone's passcode/biometric lock
- iOS encryption (if enabled)
- Your iCloud backup security (if enabled)

## Contact & Questions

If you have questions about this Privacy Policy:

- **GitHub Issues**: [https://github.com/phuc-nt/kioku-ios/issues](https://github.com/phuc-nt/kioku-ios/issues)
- **Email**: [Your email here]

## Updates to This Policy

We may update this Privacy Policy from time to time. Changes will be posted in this file with an updated "Last Updated" date.

For significant changes, we will notify users through:
- App update release notes
- In-app notification (if applicable)

## Legal Basis (GDPR Compliance)

For users in the EU/EEA:

- **No data processing**: We don't process your personal data on servers
- **Local processing only**: All processing happens on your device
- **Third-party processing**: OpenRouter processes data when you use AI features (see their GDPR compliance)
- **Your consent**: You consent to OpenRouter processing when you enter an API key

## California Privacy Rights (CCPA)

For California residents:

- **No sale of data**: We don't sell your personal information
- **No sharing**: We don't share your data with third parties (except OpenRouter when you use AI)
- **Access & deletion**: You have full control via export/import and "Clear All Data"

---

**Summary**: Kioku is designed for maximum privacy. Your journal stays on your device. We don't track you. You control your data completely.

If you have concerns about privacy, you can:
1. Use the app without AI features (no OpenRouter API key)
2. Review the source code (open source on GitHub)
3. Export your data anytime (JSON format)

**Made with privacy in mind 🔒**
