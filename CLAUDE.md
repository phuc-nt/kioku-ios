### Startup Workflow (Each Session)

1. **Check current status**: `docs/00_context/02_product_backlog.md` - Sprint completion status and next priorities
2. **Understand architecture**: `docs/00_context/03_architecture_design.md` - Technical overview and current implementation
3. **Latest sprint**: `docs/01_sprints/sprint_10_planning.md` - Most recent completed work (AI Chat Integration)

**Current Status**: Sprint 10 completed (AI Chat Integration). Ready for Sprint 11+ advanced AI features.

### Task Management Process

Task Lifecycle:
  1. Identify task: From the current sprint planning document or user request.
  2. Focus mode: Work on one task at a time, do not jump around.
  3. Check dependencies: Review related ADRs for architecture decisions.
  4. Implement feature: Code implementation with proper error handling.
  5. UI Automation Testing: MANDATORY - Test feature using XcodeBuildMCP tools for integration validation.
  6. Test Suite Update: Create or update test scenarios in `/docs/03_testing/` directory.
  7. Quality validation: All automated tests must PASS before marking a task as complete.
  8. Update progress: Update the sprint document only when ALL TESTS PASS.
  9. Commit clean: Use a clear commit message following conventions.
  10. Update status: Update sprint document and create new ADRs if needed.

Quality Gates:
  - Code compiles: The build must succeed with `build_sim()` or `build_run_sim()`.
  - UI Integration Tests: All XcodeBuildMCP automated tests must PASS.
  - No regressions: Existing functionality must not be broken (validated via UI automation).
  - Security validation: Encryption and key management working properly (transparent to user).
  - Documentation: Update sprint progress with test results and scenarios.

Test Requirements:
  - Every new feature requires corresponding UI test scenarios.
  - XcodeBuildMCP automation must validate feature end-to-end before completion.
  - UI workflows must be tested: tap(), type_text(), swipe(), gesture(), screenshot().
  - Test scenarios documented in `/docs/03_testing/` with clear acceptance criteria.
  - Performance validation: app launch <2s, smooth UI interactions, no memory leaks.

XcodeBuildMCP Testing Workflow:
  1. **Setup**: build_run_sim() với appropriate scheme và simulator.
  2. **Interaction**: Use tap(), type_text(), swipe(), gesture() for user actions.
  3. **Validation**: screenshot() để capture states, describe_ui() để get coordinates.
  4. **Coverage**: Test happy path, edge cases, error conditions, performance.
  5. **Documentation**: Record test scenarios với expected results trong testing docs.

### Role of Document Groups

**`00_context/` - Essential Context (READ-ONLY)**:
- `02_product_backlog.md`: Current project status, next priorities, user stories
- `03_architecture_design.md`: Technical architecture, data models, services structure

**`01_sprints/` - Sprint History**:
- `sprint_10_planning.md`: Latest completed sprint (AI Chat Integration)
- Create new sprint files for future work

**`02_adrs/` - Technical Decisions**:
- Reference existing ADRs for technical context
- Create new ADRs for significant technical decisions

**`03_testing/` - Testing Documentation**:
- Update test scenarios for each completed feature
- XcodeBuildMCP automation workflows

### Documentation Update Rules

**For New Features/Sprints**:
1. Create new `sprint_11_planning.md` (or next number) for new work
2. Update `02_product_backlog.md` status only when sprint completes
3. Create ADRs for major technical decisions
4. Update test scenarios in `03_testing/` for completed features

**Key Principles**:
- Reference existing docs instead of duplicating content
- Technical architecture decisions go in ADRs, not sprint docs
- Sprint docs focus on current tasks and acceptance criteria
- Keep context docs (`00_context/`) as reference material only

**Current Architecture Foundation**:
- SwiftUI + SwiftData with @Observable pattern
- Tab-based navigation (Calendar ↔ Chat)
- OpenRouter AI integration with context awareness
- Local-first data with encryption
- XcodeBuildMCP for UI automation testing