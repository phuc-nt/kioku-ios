# Kioku - AI-Powered Personal Journaling

> **記憶** (Kioku) - Japanese for "memory"

**Kioku** is an intelligent journaling app for iOS that helps you reflect on your thoughts and discover connections in your life through AI-powered insights.

[![iOS](https://img.shields.io/badge/iOS-18.0+-blue.svg)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-0.1.0-red.svg)](CHANGELOG.md)

## ✨ Features

### 📝 Smart Journaling
- **Calendar view** - Browse entries by day/month/year
- **Quick entry** - Simple, distraction-free writing interface
- **Auto-save** - Never lose your thoughts

### 🤖 AI Chat with Full Context
- Ask questions about your life: *"When did I last meet Sarah?"*
- AI reads your entire journal to provide personalized answers
- **Explainable AI** - See which entries AI referenced
- **4-phase context building** - Temporal + Entity + Relationship + Insight

### 🧠 Knowledge Graph
- **Auto-extract entities** - People, places, events, emotions, topics
- **Relationship discovery** - 105+ relationships from your entries
- **Visual graph** - See connections between entities
- **Emotional intelligence** - Track 40+ emotion types

### 💡 AI Insights
- Weekly and daily pattern analysis
- Discover trends in your life
- Emotion tracking and triggers
- Relationship strength scoring

### 🔒 Privacy First
- **100% local storage** - Your data never leaves your device
- **End-to-end encryption** - Secure by default
- **No cloud, no account** - You own your data completely
- **No analytics** - Zero tracking

### 💾 Full Data Control
- **Export to JSON** - Complete backup with all metadata
- **Export to Markdown** - Human-readable format
- **Import with conflict resolution** - Smart merge strategies
- **Files app integration** - Save to iCloud Drive, Dropbox, etc.

### ⚙️ Flexible AI Models
- **OpenRouter integration** - Access 15+ AI models
- **Per-conversation models** - Choose GPT-4, Claude, Gemini, etc.
- **Model switching** - Different contexts, different models

## 🚀 Quick Start

### Requirements
- iOS 18.0+ (iPhone)
- Xcode 16+ (for building from source)
- OpenRouter API key (for AI features)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/phuc-nt/kioku-ios.git
   cd kioku-ios
   ```

2. **Open in Xcode**
   ```bash
   open Kioku.xcworkspace
   ```

3. **Configure OpenRouter API**
   - Sign up at [openrouter.ai](https://openrouter.ai)
   - Get your API key
   - Launch app → Settings → Enter API key

4. **Build & Run**
   - Select iPhone simulator or device
   - Press Run (⌘R)

## 📖 Usage

### Write Your First Entry
1. Open **Calendar** tab
2. Select today's date
3. Write your thoughts
4. Auto-saves when you navigate away

### Chat with AI
1. Open **Chat** tab
2. Ask questions: *"What did I do last weekend?"*
3. AI reads your journal and responds with context
4. Click entry links to verify sources

### Explore Insights
1. Go to **Insights** tab
2. View auto-extracted entities (people, places, emotions)
3. See relationship graph
4. Read AI-generated patterns

### Export Your Data
1. Settings → **Data Management**
2. **Export to JSON** - Full backup
3. **Export to Markdown** - Text format
4. **Import from JSON** - Restore from backup

## 🛠️ For Developers

### Tech Stack
- **SwiftUI + SwiftData** (iOS 18+)
- **Swift Package Manager** (modular architecture)
- **OpenRouter API** (AI integration)
- **Knowledge Graph** (entity relationships)

### Project Structure
```
Kioku.xcworkspace          # Open this in Xcode
├── Kioku/                 # App target
├── KiokuPackage/          # Feature modules
│   └── Sources/KiokuFeature/
│       ├── Models/        # Entry, Entity, Relationship
│       ├── Services/      # AI, Export, DataService
│       └── Views/         # Calendar, Chat, Settings
└── docs/                  # Architecture & sprints
```

### Key Architecture Decisions
- **4-phase RAG context** - See `docs/02_adrs/ADR-002-rag-context-building.md`
- **Local-first with encryption** - See `docs/02_adrs/ADR-001-local-first-architecture.md`
- **Knowledge graph over vector DB** - Explainable relationships

### Testing
- UI automation with XcodeBuildMCP
- Test scenarios in `docs/03_testing/`
- Run tests: `⌘U` in Xcode

### Contributing
See [CONTRIBUTING.md](CONTRIBUTING.md) for development guidelines.

## 📊 Demo Data

Real extraction results from 20 demo entries:
- **119 entities** (40 emotions, 32 topics, 28 events, 11 people, 8 places)
- **105 relationships** (temporal, topical, emotional, social)
- **100% coverage** - Sarah entity appears in all 20 entries

See `raw_data/presentation_demo.json` for demo dataset.

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

Copyright (c) 2025 PHUC NGUYEN

## 🔐 Privacy Policy

See [PRIVACY.md](PRIVACY.md) for our privacy policy and data handling practices.

## 📝 Changelog

See [CHANGELOG.md](CHANGELOG.md) for release notes and version history.

## 🙏 Acknowledgments

- Built with [Claude Code](https://claude.com/claude-code) and Claude Sonnet 4.5
- Scaffolded with [XcodeBuildMCP](https://github.com/cameroncooke/XcodeBuildMCP)
- AI models via [OpenRouter](https://openrouter.ai)

## 📧 Contact

For questions or feedback:
- GitHub Issues: [Create an issue](https://github.com/phuc-nt/kioku-ios/issues)
- Email: [Your email here]

---

**Made with ❤️ for people who love journaling and self-reflection**

[App Store Badge Coming Soon]
