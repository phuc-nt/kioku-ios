# Changelog

All notable changes to Kioku will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2025-10-26

### 🎉 Initial Release

**Kioku** - AI-powered personal journaling app for iOS 18+

### ✨ Features

#### Core Journaling
- **Daily journal entries** with rich text support
- **Calendar view** for easy navigation and entry browsing
- **Search functionality** to find entries by date or content
- **Local-first architecture** - all data stored securely on device

#### AI-Powered Features
- **Entity Extraction** - Automatically identifies people, places, events, emotions, and topics
- **Knowledge Graph** - Visual relationship map of your life (119 entities, 105+ relationships)
- **Emotional Intelligence** - Tracks 40+ emotion types from your entries
- **AI Insights** - Weekly and daily pattern discovery
- **Context-Aware Chat** - Ask questions about your journal with full conversation history

#### Privacy & Security
- **End-to-end encryption** for all journal entries
- **Local-only storage** - data never leaves your device
- **Secure encryption keys** stored in iOS Keychain
- **No analytics or tracking**

#### Data Management
- **Export to JSON** - backup your entire journal
- **Export to Markdown** - human-readable format
- **Import from JSON** - restore from backups with conflict resolution
- **Files app integration** - easy export/import workflow

#### AI Model Flexibility
- **Multiple AI providers** supported via OpenRouter
- **Per-conversation model selection** - choose different models for different contexts
- **15+ models available** (GPT-4, Claude, Gemini, etc.)

### 📊 Technical Achievements

- **SwiftUI + SwiftData** architecture (iOS 18+)
- **4-phase RAG context building** - Temporal + Entity + Relationship + Insight
- **Knowledge graph relationships** - 105 relationships from 20 demo entries
- **Emotion extraction** - 40 emotion entities with confidence scoring
- **Explainable AI** - shows why entries are related (not black box)

### 🔧 Architecture

- Tab-based navigation: Calendar ↔ Insights ↔ Graph ↔ Settings
- Feature package separation (KiokuFeature)
- OpenRouter integration for AI flexibility
- SwiftData persistence with encryption

### 📝 Known Limitations

- iOS 18.0+ required (uses latest SwiftData features)
- AI features require OpenRouter API key
- Insights generation is async (may take 2-3 minutes for 20 entries)
- No cloud sync (local-only by design for privacy)

### 🙏 Acknowledgments

Built with Claude Code and Claude Sonnet 4.5

---

## [Unreleased]

### Planned Features
- iCloud sync (optional, encrypted)
- Photos and attachments support
- Voice notes transcription
- Advanced search with filters
- Custom AI prompts
- Export to PDF

---

**Legend:**
- ✨ Features - New functionality
- 🐛 Bug Fixes - Fixed issues
- 🔧 Technical - Architecture or infrastructure changes
- 📝 Documentation - Documentation updates
- 🔒 Security - Security improvements
