# Task Completion Checklist

## When a Task is Complete

### 1. Code Quality ✅
- [ ] Code compiles successfully
- [ ] No Swift compiler warnings
- [ ] Follows code style conventions (see code_style_conventions.md)
- [ ] Public APIs properly documented
- [ ] Date handling uses `calendar.isDate(_:inSameDayAs:)` pattern

### 2. Testing (MANDATORY) ✅
- [ ] Build succeeds: `build_sim()` or `build_run_sim()`
- [ ] XcodeBuildMCP UI automation tests created and PASS
- [ ] Test scenarios documented in `docs/03_testing/`
- [ ] No regressions in existing functionality
- [ ] Performance validated: app launch <2s, smooth interactions

### 3. Documentation Updates ✅
- [ ] Sprint document updated with progress
- [ ] Test scenarios added to testing docs
- [ ] ADR created if significant technical decision made
- [ ] Comments added for complex logic

### 4. Git Workflow ✅
```bash
# Stage changes
git add .

# Clear commit message
git commit -m "feat: description" or "fix: description"

# Push
git push origin <branch>
```

### 5. Sprint Tracking ✅
- [ ] Update current sprint file: `docs/01_sprints/sprint_XX_planning.md`
- [ ] Mark tasks as completed only when ALL tests pass
- [ ] Update product backlog when sprint completes

## Quality Gates Checklist

✅ **Code compiles**
✅ **UI tests pass** (XcodeBuildMCP automation)
✅ **No regressions**
✅ **Security validated** (encryption working)
✅ **Documentation updated**
✅ **Clean commit pushed**

## Common Issues to Check
- ⚠️ Date timezone issues (use calendar comparison)
- ⚠️ Public types need public init()
- ⚠️ Encryption properly implemented
- ⚠️ SwiftData relationships correctly defined
- ⚠️ @Observable pattern used for services