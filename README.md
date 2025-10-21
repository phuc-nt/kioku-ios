# Kioku - AI-Powered Personal Journal

A modern iOS journaling app with AI chat integration, built using SwiftUI and SwiftData. Kioku helps users reflect on their thoughts through intelligent conversations with AI that understands their journal history.

## Features

- **📅 Calendar-based Journaling**: Write and organize entries by date
- **🤖 AI Chat Integration**: Context-aware AI conversations about your journal patterns
- **📖 Historical Context**: AI accesses current and historical entries for deeper insights
- **🧠 Knowledge Graph**: Entity extraction, relationship mapping, and AI-powered insights
- **⚙️ Flexible AI Models**: Choose from popular models or use custom OpenRouter models per conversation
- **💾 Export & Backup**: Export journal data to JSON or Markdown, import from JSON with conflict resolution
- **🔒 Privacy-First**: All data stored locally with encryption support
- **🎨 Clean Design**: Native SwiftUI interface with tab-based navigation

## Current Status (Sprint 17 Complete)

✅ **Core journaling functionality**
✅ **Tab-based navigation** (Calendar ↔ Chat)
✅ **AI chat with OpenRouter API integration**
✅ **Context-aware AI** (current + historical notes)
✅ **Context transparency** (users see what AI accesses)
✅ **Historical notes discovery** (same day across months)
✅ **Knowledge Graph** (entities, relationships, insights, semantic search)
✅ **Flexible model configuration** (per-conversation AI model selection)
✅ **Export/Import system** (JSON backup, Markdown export, conflict resolution)

## AI Assistant Rules Files

This template includes **opinionated rules files** for popular AI coding assistants. These files establish coding standards, architectural patterns, and best practices for modern iOS development using the latest APIs and Swift features.

### Included Rules Files
- **Claude Code**: `CLAUDE.md` - Claude Code rules
- **Cursor**: `.cursor/*.mdc` - Cursor-specific rules
- **GitHub Copilot**: `.github/copilot-instructions.md` - GitHub Copilot rules

### Customization Options
These rules files are **starting points** - feel free to:
- ✅ **Edit them** to match your team's coding standards
- ✅ **Delete them** if you prefer different approaches
- ✅ **Add your own** rules for other AI tools
- ✅ **Update them** as new iOS APIs become available

### What Makes These Rules Opinionated
- **No ViewModels**: Embraces pure SwiftUI state management patterns
- **Swift 6+ Concurrency**: Enforces modern async/await over legacy patterns
- **Latest APIs**: Recommends iOS 18+ features with optional iOS 26 guidelines
- **Testing First**: Promotes Swift Testing framework over XCTest
- **Performance Focus**: Emphasizes @Observable over @Published for better performance

**Note for AI assistants**: You MUST read the relevant rules files before making changes to ensure consistency with project standards.

## Quick Start

1. **Open Workspace**: `Kioku.xcworkspace` in Xcode
2. **Build & Run**: Select iPhone simulator and run
3. **Start Journaling**: Create entries in Calendar tab
4. **Chat with AI**: Switch to Chat tab for insights

## Architecture Overview

**Tech Stack**: SwiftUI + SwiftData + OpenRouter AI  
**Navigation**: Tab-based (Calendar ↔ Chat)  
**Data**: Local SQLite with encryption support  
**AI Context**: Date-aware with historical pattern recognition  

```
Kioku/
├── Kioku.xcworkspace/              # Open this file in Xcode
├── KiokuPackage/Sources/KiokuFeature/  # 🚀 Main feature code
│   ├── Models/                     # Entry, AIAnalysis, ChatMessage
│   ├── Services/                   # DateContext, ChatContext, OpenRouter
│   └── Views/                      # Calendar, Chat, Navigation
├── docs/00_context/                # 📋 Design documents
│   ├── 01_business_requirement.md
│   ├── 02_product_backlog.md
│   └── 03_architecture_design.md   # Technical details
└── docs/01_sprints/                # Sprint planning & progress
```

## Key Architecture Points

### Workspace + SPM Structure
- **App Shell**: `Kioku/` contains minimal app lifecycle code
- **Feature Code**: `KiokuPackage/Sources/KiokuFeature/` is where most development happens
- **Separation**: Business logic lives in the SPM package, app target just imports and displays it

### Buildable Folders (Xcode 16)
- Files added to the filesystem automatically appear in Xcode
- No need to manually add files to project targets
- Reduces project file conflicts in teams

## Development

### For New Developers
1. **Read Architecture**: `docs/00_context/03_architecture_design.md` for technical overview
2. **Check Current Sprint**: `docs/01_sprints/` for current development status  
3. **Main Development**: `KiokuPackage/Sources/KiokuFeature/` for feature code

### Next Features (Planned)
- **🎤 Voice Integration**: Voice-to-text entry creation and voice conversations
- **📊 Advanced Analytics**: Enhanced insight visualization and trend analysis
- **🎨 UI/UX Polish**: Animations, accessibility improvements, dark mode optimization

### Public API Requirements
Types exposed to the app target need `public` access:
```swift
public struct NewView: View {
    public init() {}
    
    public var body: some View {
        // Your view code
    }
}
```

### Adding Dependencies
Edit `KiokuPackage/Package.swift` to add SPM dependencies:
```swift
dependencies: [
    .package(url: "https://github.com/example/SomePackage", from: "1.0.0")
],
targets: [
    .target(
        name: "KiokuFeature",
        dependencies: ["SomePackage"]
    ),
]
```

### Test Structure
- **Unit Tests**: `KiokuPackage/Tests/KiokuFeatureTests/` (Swift Testing framework)
- **UI Tests**: `KiokuUITests/` (XCUITest framework)
- **Test Plan**: `Kioku.xctestplan` coordinates all tests

## Configuration

### XCConfig Build Settings
Build settings are managed through **XCConfig files** in `Config/`:
- `Config/Shared.xcconfig` - Common settings (bundle ID, versions, deployment target)
- `Config/Debug.xcconfig` - Debug-specific settings  
- `Config/Release.xcconfig` - Release-specific settings
- `Config/Tests.xcconfig` - Test-specific settings

### Entitlements Management
App capabilities are managed through a **declarative entitlements file**:
- `Config/Kioku.entitlements` - All app entitlements and capabilities
- AI agents can safely edit this XML file to add HealthKit, CloudKit, Push Notifications, etc.
- No need to modify complex Xcode project files

### Asset Management
- **App-Level Assets**: `Kioku/Assets.xcassets/` (app icon, accent color)
- **Feature Assets**: Add `Resources/` folder to SPM package if needed

### SPM Package Resources
To include assets in your feature package:
```swift
.target(
    name: "KiokuFeature",
    dependencies: [],
    resources: [.process("Resources")]
)
```

### Generated with XcodeBuildMCP
This project was scaffolded using [XcodeBuildMCP](https://github.com/cameroncooke/XcodeBuildMCP), which provides tools for AI-assisted iOS development workflows.