# Essential Commands for Kioku Development

## Build & Run
```bash
# Open in Xcode (always use workspace)
open Kioku.xcworkspace

# Build for simulator
xcodebuild -workspace Kioku.xcworkspace -scheme Kioku -destination 'platform=iOS Simulator,name=iPhone 16' build

# Run tests
xcodebuild test -workspace Kioku.xcworkspace -scheme Kioku -destination 'platform=iOS Simulator,name=iPhone 16'
```

## XcodeBuildMCP Testing (MANDATORY for features)
```bash
# Build and run on simulator
build_run_sim({ workspacePath: "Kioku.xcworkspace", scheme: "Kioku", simulatorName: "iPhone 16" })

# UI automation
screenshot({ simulatorUuid })
describe_ui({ simulatorUuid })
tap({ simulatorUuid, x, y })
type_text({ simulatorUuid, text })
```

## Git Workflow
```bash
# Stage changes
git add .

# Commit with clear message
git commit -m "feat: description" or "fix: description"

# Push to remote
git push origin <branch>
```

## Development Tasks
```bash
# Check Swift package
cd KiokuPackage && swift build

# Format Swift code (if swiftformat installed)
swiftformat KiokuPackage/Sources/

# Run Swift tests
swift test --package-path KiokuPackage/
```

## Documentation Updates
```bash
# After completing feature
# 1. Update sprint doc: docs/01_sprints/sprint_XX_planning.md
# 2. Update test scenarios: docs/03_testing/
# 3. Create ADR if needed: docs/02_adrs/adr-XXX-decision.md

# After sprint completion
# Update: docs/00_context/02_product_backlog.md
```

## macOS Utilities (Darwin)
```bash
# List files
ls -la

# Search in files
grep -r "pattern" KiokuPackage/Sources/

# Find files
find . -name "*.swift"

# Watch logs
tail -f ~/Library/Logs/DiagnosticReports/*.crash
```

## Common Development Actions
1. **Add new view**: Create in `KiokuPackage/Sources/KiokuFeature/Views/`
2. **Add model**: Create in `KiokuPackage/Sources/KiokuFeature/Models/`
3. **Add service**: Create in `KiokuPackage/Sources/KiokuFeature/Services/`
4. **Test feature**: Use XcodeBuildMCP automation (MANDATORY)
5. **Update docs**: Sprint planning + test scenarios