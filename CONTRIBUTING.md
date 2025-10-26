# Contributing to Kioku

Thank you for your interest in contributing to Kioku! This document provides guidelines for contributing to the project.

## 🎯 Ways to Contribute

- 🐛 Report bugs
- 💡 Suggest features
- 📝 Improve documentation
- 🔧 Submit code changes
- 🧪 Write tests
- 🌍 Translate the app

## 🚀 Getting Started

### Prerequisites

- macOS 14.0+ (Sonoma or later)
- Xcode 16+
- iOS 18+ device or simulator
- Basic Swift/SwiftUI knowledge
- OpenRouter API key (for AI features)

### Setup Development Environment

1. **Fork & Clone**
   ```bash
   git clone https://github.com/YOUR_USERNAME/kioku-ios.git
   cd kioku-ios
   ```

2. **Open Workspace**
   ```bash
   open Kioku.xcworkspace
   ```

3. **Read Architecture Docs**
   - Start with `docs/00_context/03_architecture_design.md`
   - Review ADRs in `docs/02_adrs/` for design decisions
   - Check latest sprint in `docs/01_sprints/`

4. **Build & Run**
   - Select target: Kioku (iOS)
   - Select destination: iPhone 16 (or any iOS 18+ simulator)
   - Press Run (⌘R)

## 📋 Development Workflow

### 1. Task Planning (See `CLAUDE.md`)

Before starting work:
- Check `docs/00_context/02_product_backlog.md` for priorities
- Review current sprint planning document
- Create a new sprint document if needed

### 2. Code Standards

**Swift Style**
- Follow [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/)
- Use SwiftUI best practices
- Prefer `@Observable` over `ObservableObject` (iOS 17+)
- Use SwiftData for persistence

**Naming Conventions**
- Views: `CalendarTabView`, `EntryDetailView`
- Services: `DataService`, `OpenRouterService`
- Models: `Entry`, `Entity`, `Relationship`

**File Organization**
```
KiokuPackage/Sources/KiokuFeature/
├── Models/           # Data models (Entry, Entity, etc.)
├── Services/         # Business logic (DataService, AI)
├── Views/            # SwiftUI views
│   ├── Calendar/     # Calendar tab views
│   ├── Chat/         # AI chat views
│   └── Settings/     # Settings views
└── Utils/            # Helpers and extensions
```

### 3. Testing Requirements

**Before submitting PR**:
- ✅ Code compiles without warnings
- ✅ UI tests pass (XcodeBuildMCP automation)
- ✅ No regressions in existing features
- ✅ Test scenarios documented in `docs/03_testing/`

**Testing Workflow**
```bash
# Build for simulator
xcodebuild build -workspace Kioku.xcworkspace -scheme Kioku -destination 'platform=iOS Simulator,name=iPhone 16'

# Run UI tests (if available)
xcodebuild test -workspace Kioku.xcworkspace -scheme Kioku -destination 'platform=iOS Simulator,name=iPhone 16'
```

### 4. Commit Guidelines

**Format**: Use [Conventional Commits](https://www.conventionalcommits.org/)

```
<type>: <description>

[optional body]

[optional footer]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring
- `test`: Test updates
- `chore`: Build/tooling changes

**Examples**:
```bash
git commit -m "feat: add emotion filtering to graph view"
git commit -m "fix: crash when deleting entry with relationships"
git commit -m "docs: update architecture decision for RAG context"
```

**Footer** (always include):
```
🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

### 5. Pull Request Process

1. **Create feature branch**
   ```bash
   git checkout -b feat/your-feature-name
   ```

2. **Make changes**
   - Follow code standards
   - Write tests
   - Update documentation

3. **Test thoroughly**
   - Run app on simulator/device
   - Test edge cases
   - No crashes or warnings

4. **Commit with good messages**
   ```bash
   git add .
   git commit -m "feat: your feature description"
   ```

5. **Push to your fork**
   ```bash
   git push origin feat/your-feature-name
   ```

6. **Create Pull Request**
   - Go to GitHub
   - Click "New Pull Request"
   - Fill in template (see below)
   - Link related issues

## 📝 Pull Request Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Built successfully
- [ ] Tested on iOS 18+ simulator
- [ ] Tested on physical device
- [ ] UI tests pass
- [ ] No regressions

## Screenshots (if UI changes)
[Add screenshots here]

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-reviewed code
- [ ] Commented complex logic
- [ ] Updated documentation
- [ ] Added tests
- [ ] All tests pass
```

## 🐛 Bug Reports

**Use GitHub Issues** with this template:

```markdown
**Describe the bug**
Clear description of the bug

**To Reproduce**
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior**
What should happen

**Screenshots**
If applicable

**Environment**
- iOS version: [e.g. 18.0]
- Device: [e.g. iPhone 16]
- App version: [e.g. 0.1.0]

**Additional context**
Any other information
```

## 💡 Feature Requests

**Use GitHub Issues** with this template:

```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution**
Clear description of desired feature

**Describe alternatives**
Other solutions you've considered

**Additional context**
Mockups, examples, etc.
```

## 🏗️ Architecture Decisions

For major changes, create an ADR (Architecture Decision Record):

1. Copy template from `docs/02_adrs/ADR-000-template.md`
2. Number it sequentially (e.g., `ADR-010-your-decision.md`)
3. Fill in:
   - Context: Why is this needed?
   - Decision: What are we doing?
   - Consequences: What are the trade-offs?
4. Include in your PR

## 📚 Documentation

**Update when**:
- Adding new features → Update README.md
- Changing architecture → Create/update ADR
- New APIs → Update inline documentation
- Bug fixes → Update CHANGELOG.md

**Documentation locations**:
- User-facing: `README.md`
- Architecture: `docs/00_context/`, `docs/02_adrs/`
- Development: `CONTRIBUTING.md` (this file)
- Release notes: `CHANGELOG.md`

## 🌍 Translation (Future)

Not yet supported in v0.1.0. Will add localization support in future releases.

## ❓ Questions?

- **GitHub Discussions**: [Ask a question](https://github.com/phuc-nt/kioku-ios/discussions)
- **GitHub Issues**: [Report a bug](https://github.com/phuc-nt/kioku-ios/issues)
- **Email**: [Your email here]

## 📜 Code of Conduct

Be respectful and professional. We follow the [Contributor Covenant](https://www.contributor-covenant.org/).

Key points:
- ✅ Be welcoming and inclusive
- ✅ Respect differing viewpoints
- ✅ Accept constructive criticism
- ❌ No harassment or trolling
- ❌ No personal attacks

## 📄 License

By contributing, you agree that your contributions will be licensed under the MIT License.

---

**Thank you for contributing to Kioku! 🙏**

Every contribution makes the app better for everyone who values privacy and self-reflection.
