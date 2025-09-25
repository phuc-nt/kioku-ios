### Startup Workflow (Each Session)

1. Check the project setup.
2. **Read `docs/00_context/01_business_requirement.md`** - To understand the project vision and core objectives.
3. **Check `docs/00_context/02_product_backlog.md`** - To understand current sprint scope and story priorities.
4. **Reference current sprint** - `docs/01_sprints/sprint_xx_planning.md` for active tasks and progress.
5. **Review architecture decisions** - `docs/02_adrs/` folder for technical context as needed.

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

**`00_context/` - Strategic Foundation (READ-ONLY, DO NOT EDIT WITHOUT EXPLICIT APPROVAL)**:
- `01_business_requirement.md`: Business vision, value proposition, high-level requirements.
- `02_product_backlog.md`: Complete feature inventory, user stories, epic breakdown, sprint assignments.

**`01_sprints/` - Sprint Execution (UPDATED DAILY)**:
- `sprint_*_planning.md`: Detailed Sprint tasks, acceptance criteria, technical breakdown.

**`02_adrs/` - Architecture Decisions (CREATED AS NEEDED)**:
- `adr_*.md`: Technical decisions for iOS architecture, data models, concurrency, UI libraries, encryption, and key management.
- Create new ADRs when making significant technical decisions during implementation.

**`03_testing/` - UI Testing Documentation (UPDATED PER FEATURE)**:
- `ui_test_scenarios.md`: Comprehensive UI test scenarios với XcodeBuildMCP automation.
- Test case documentation với step-by-step XcodeBuildMCP commands.
- Performance benchmarks và regression test suites.

### Documentation Rules

Update Rules:
  - `sprint_*.md`: Update daily for task progress, completion status, blockers.
  - `00_context/*.md`: Never update without explicit approval (business requirements, product backlog).
  - `02_adrs/*.md`: Create new ADRs for major technical decisions during development.
  - `03_testing/*.md`: Update test scenarios và automation workflows for each completed feature.

Maintenance Principles:
  - AVOID DUPLICATION: Reference other documents using cross-links.
  - KEEP CONCISE: Sprint docs focus on current tasks, context docs provide background.
  - SINGLE SOURCE OF TRUTH: Business logic in BRD, technical decisions in ADRs, tasks in sprint docs.
  - CROSS-REFERENCE: Link sprint tasks back to product backlog user stories.
  - STATUS FIRST: Always show current sprint progress and blockers clearly.

Writing Style:
  - Concise and actionable for sprint documentation.
  - Use status indicators: Not Started, In Progress, Completed, Blocked.
  - Include time estimates and actual time spent for each task.
  - Link to related ADRs and user stories instead of duplicating content.
  - Technical decisions get their own ADR documents.

Document Flow: 
  - Strategic: `01_business_requirement.md` → `02_product_backlog.md`
  - Tactical: `product_backlog.md` → `sprint_*.md` → task implementation
  - Technical: `sprint_*.md` → `02_adrs/adr_*.md` → code implementation
  - Testing: `sprint_*.md` → `03_testing/*.md` → XcodeBuildMCP automation validation
  
Never put detailed technical architecture in sprint documents - create ADRs instead.
Never put sprint task details in business requirement or product backlog documents.