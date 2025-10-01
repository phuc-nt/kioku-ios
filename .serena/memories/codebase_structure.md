# Codebase Structure

## Project Organization

```
Kioku.xcworkspace/              # ⚠️ OPEN THIS in Xcode
├── Kioku/                      # App Shell (minimal code)
│   ├── KiokuApp.swift         # App entry point
│   ├── Assets.xcassets/        # App icon, accent color
│   └── Config/                 # XCConfig, entitlements
├── KiokuPackage/              # 🚀 MAIN DEVELOPMENT HERE
│   ├── Sources/KiokuFeature/
│   │   ├── Models/            # Data models
│   │   │   ├── Entry.swift           # Journal entry with encryption
│   │   │   └── AIAnalysis.swift      # AI analysis results
│   │   ├── Services/          # Business logic
│   │   │   ├── DataService.swift     # SwiftData container
│   │   │   ├── DateContextService.swift  # Date-based discovery
│   │   │   ├── ChatContextService.swift  # AI context aggregation
│   │   │   └── OpenRouterService.swift   # AI API client
│   │   ├── Views/             # UI components
│   │   │   ├── Calendar/      # Calendar tab views
│   │   │   ├── Chat/          # AI chat interface
│   │   │   └── Navigation/    # Tab structure
│   │   └── ContentView.swift  # Main tab container
│   └── Tests/KiokuFeatureTests/  # Swift Testing tests
├── KiokuUITests/              # XCUITest UI tests
└── docs/                      # 📋 Documentation
    ├── 00_context/            # Architecture, backlog
    ├── 01_sprints/            # Sprint planning
    ├── 02_adrs/               # Architecture decisions
    └── 03_testing/            # Test scenarios

## Key Locations
- **Feature Development**: `KiokuPackage/Sources/KiokuFeature/`
- **Models**: Entry (journal), AIAnalysis, AIChatMessage
- **Services**: Date/Chat context, OpenRouter API
- **Views**: Calendar, Chat, Navigation components
- **Documentation**: `docs/` (architecture, sprints, ADRs)