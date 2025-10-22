# Sprint 18: Data Management Enhancements

**Sprint Period**: October 22-24, 2025
**Epic**: EPIC-7 - User Empowerment & Data Portability
**Story Points**: 3 points (1 user story - scope reduced)
**Status**: ✅ COMPLETED (2025-10-22)

## Sprint Goal
~~Enhance data management capabilities with improved export options and~~ **Fix critical data cleanup functionality**, giving users reliable tools to reset their journal database completely.

**Strategic Value**: Users gain confidence in long-term app usage through a robust "Clear All Data" feature that works reliably without crashes or data corruption.

---

## User Stories

### US-047: Enhanced Export Options (5 points)

**As a** user
**I want** more export format options and filtering capabilities
**So that** I can export exactly the data I need in the format that works best for my workflow

**Priority**: HIGH
**Status**: 🔄 IN PROGRESS

**Problem Statement**:
- Current export is all-or-nothing (entire journal)
- No date range filtering for exports
- Only JSON and basic Markdown formats available
- No CSV export for spreadsheet analysis
- Cannot export specific data types only (e.g., just entities)

**Solution Approach**:
1. Add date range selection for exports
2. Add CSV export format (entries, entities, relationships as tables)
3. Add selective export (choose what to include: entries, entities, relationships, insights, conversations)
4. Improve Markdown export with better formatting and sections
5. Add export statistics/preview before export

**Acceptance Criteria**:
- [ ] Users can select date range for export (from/to dates)
- [ ] Export to CSV format available
- [ ] CSV exports: separate files for entries, entities, relationships
- [ ] Selective export: checkboxes to include/exclude data types
- [ ] Export preview shows: entry count, entity count, file size estimate
- [ ] Improved Markdown with table of contents and statistics
- [ ] Export settings remembered (last used format, filters)
- [ ] All export formats work with Files app

**Technical Requirements**:

**FR-S18-001: Export Filter UI**
- Date range picker (from/to dates)
- "All dates" option (default)
- Data type selection:
  - ✅ Entries
  - ✅ Entities
  - ✅ Relationships
  - ✅ Insights
  - ✅ Conversations
- Export preview panel:
  - Entry count
  - Entity count
  - Estimated file size
  - Date range summary

**FR-S18-002: CSV Export Service**
- Create `CSVExportService`
- Generate CSV files:
  - `entries.csv`: id, date, content, created_at, modified_at
  - `entities.csv`: id, type, value, confidence, entry_id
  - `relationships.csv`: id, from_entity, to_entity, type, confidence
  - `insights.csv`: id, type, description, confidence, entry_id
- Handle CSV escaping (commas, quotes, newlines)
- Use UTF-8 with BOM for Excel compatibility

**FR-S18-003: Enhanced Markdown Export**
- Add table of contents
- Add statistics section (total entries, date range, entities discovered)
- Better formatting:
  - Headers for each month
  - Bullet lists for entities
  - Indented insights
  - Horizontal rules between entries
- Optional: Include conversations in appendix

**FR-S18-004: Export Settings Persistence**
- Store last used:
  - Export format (JSON/Markdown/CSV)
  - Date range filter
  - Selected data types
- Load preferences on next export
- "Reset to default" option

**Technical Tasks**:
- [ ] Create `ExportFilterView` with date range and data type selection
- [ ] Implement `CSVExportService` with proper escaping
- [ ] Enhance `ExportService.exportToMarkdown()` with better formatting
- [ ] Add export preview calculation
- [ ] Persist export preferences in UserDefaults
- [ ] Update `DataManagementView` with new export options
- [ ] Integration test: Export with filters, verify output
- [ ] Test CSV files open correctly in Excel/Numbers

**Files to Create**:
- `KiokuPackage/Sources/KiokuFeature/Services/CSVExportService.swift`
- `KiokuPackage/Sources/KiokuFeature/Views/Settings/ExportFilterView.swift`

**Files to Modify**:
- `KiokuPackage/Sources/KiokuFeature/Services/ExportService.swift` (add filtering)
- `KiokuPackage/Sources/KiokuFeature/Views/Settings/DataManagementView.swift` (integrate filters)

**Dependencies**:
- Sprint 17: Export & Backup ✅

**Definition of Done**:
- [ ] Date range filtering works for all export formats
- [ ] CSV export generates valid files that open in Excel/Numbers
- [ ] Selective export includes only chosen data types
- [ ] Export preview shows accurate counts and size estimates
- [ ] Enhanced Markdown has TOC and better formatting
- [ ] Export preferences persist between sessions
- [ ] XcodeBuildMCP test: Export with various filters, verify outputs
- [ ] All changes committed and pushed
- [ ] Sprint planning document updated

---

### US-048: Clear All Data Fix (3 points)

**As a** user
**I want** a reliable "Clear All Data" feature that completely resets my journal
**So that** I can start fresh or clear test data without app crashes

**Priority**: HIGH (Critical Bug Fix)
**Status**: ✅ COMPLETED (2025-10-22)

**Problem Statement**:
- Existing "Clear All Data" and "Drop Database" both cause app crashes
- SQLite errors: "vnode unlinked while in use"
- App hangs with infinite loading spinner after clearing
- Database left in corrupt state after failed clear attempts
- Fatal error: "Cannot remove Entity from relationship" due to wrong deletion order

**Solution Approach**:
1. Merge "Clear All Data" and "Drop Database" into single reliable function
2. Fix deletion order: Delete entries FIRST to trigger cascade delete
3. Dismiss Settings UI before cleanup to avoid SwiftUI observation crashes
4. Use async/await properly with MainActor isolation
5. Exit app cleanly after successful cleanup

**Acceptance Criteria**:
- [x] Merge 2 conflicting cleanup buttons into 1 clear function
- [x] Fix deletion order to avoid relationship constraint errors
- [x] No SQLite "vnode unlinked" errors
- [x] No app hangs or infinite loading spinners
- [x] App exits cleanly after cleanup completes
- [x] Reopen app shows completely empty database
- [x] All data types deleted: entries, conversations, entities, relationships, insights, analyses
- [x] Orphaned entities/relationships automatically cleaned up

**Technical Implementation**:

**FR-S18-010: Unified Clear All Data Function**
- Merge `clearAllData()` and `dropDatabase()` into single `dropDatabase()` async function
- Deletion order (critical):
  1. Entries first → triggers cascade delete of related entities/relationships
  2. Conversations → cascade deletes messages
  3. Insights
  4. AIAnalysis
  5. Orphaned relationships (cleanup)
  6. Orphaned entities (cleanup)
- Detailed logging with deletion counts
- Proper error handling with exit on failure

**FR-S18-011: UI Integration**
- Remove separate "Clear All Data" button
- Rename "Drop Database (Nuclear)" → "Clear All Data & Restart"
- Updated alert message explaining complete data deletion
- Auto-dismiss Settings view before cleanup (prevents UI observation crashes)
- Use `Task.detached` to avoid Sendable issues

**Technical Tasks**:
- [x] Convert `dropDatabase()` to async throws function
- [x] Fix deletion order: entries → conversations → insights → analyses → orphans
- [x] Add orphan cleanup for remaining entities/relationships
- [x] Update SettingsView: remove old button, rename new button
- [x] Add auto-dismiss before cleanup
- [x] Proper async/await with MainActor isolation
- [x] Detailed logging for debugging
- [x] Manual testing: Clear → Exit → Reopen → Verify empty

**Files Modified**:
- ✅ `KiokuPackage/Sources/KiokuFeature/Services/TestDataService.swift`
  - Converted `dropDatabase()` to async
  - Fixed deletion order
  - Added orphan cleanup
  - Detailed logging with counts
- ✅ `KiokuPackage/Sources/KiokuFeature/Views/Settings/SettingsView.swift`
  - Removed "Clear All Data" button and state
  - Renamed "Drop Database" → "Clear All Data & Restart"
  - Updated alert message
  - Auto-dismiss before cleanup
  - Proper Task.detached usage

**Files Deprecated**:
- `TestDataService.clearAllData()` - marked @available(*, deprecated)

**Definition of Done**:
- [x] Single "Clear All Data & Restart" button works reliably
- [x] No SQLite errors or crashes
- [x] App exits cleanly after cleanup
- [x] Reopen shows empty database (all data types cleared)
- [x] Orphaned data automatically cleaned
- [x] Manual testing passed with Import Test Data
- [x] Sprint planning document updated
- [x] Changes committed and pushed

---

## Testing Strategy

### Unit Tests
- CSV escaping logic (commas, quotes, newlines)
- Date range filtering
- Fuzzy matching algorithm for duplicates
- Cascade delete logic

### Integration Tests

**Test 1: Filtered CSV Export**
1. Create entries across 3 months
2. Export to CSV with date range: last month only
3. Verify CSV contains only last month's entries
4. Open CSV in Excel/Numbers → verify formatting
5. Check all columns present and properly escaped

**Test 2: Selective Export**
1. Create data with entries, entities, relationships
2. Export JSON with only entries selected
3. Verify JSON contains entries but no entities/relationships
4. Repeat with different selections
5. Verify each export includes only selected types

**Test 3: Bulk Delete**
1. Create 20 entries across 2 months
2. Bulk delete first month
3. Verify only second month entries remain
4. Check entities/relationships updated correctly
5. Verify orphaned data handled

**Test 4: Orphaned Entity Cleanup**
1. Create entries with entities
2. Delete entries manually
3. Run "Clean Orphaned Entities"
4. Verify orphaned entities removed
5. Check related relationships also removed

**Test 5: Duplicate Detection**
1. Create duplicate entities: "Minh", "Mỉnh", "Minh "
2. Run duplicate detection
3. Verify all 3 detected as duplicates
4. Merge into one entity
5. Verify all entry links preserved

### XcodeBuildMCP Test Scenarios

**Scenario 1**: CSV Export Workflow
```swift
// 1. Launch app with test data
build_run_sim()

// 2. Navigate to Settings → Data Management
tap(x: settingsTab, y: settingsTab)
swipe(preset: "scroll-down") // Scroll to Data Management
tap(x: dataManagement, y: dataManagement)

// 3. Open export filters
tap(x: exportButton, y: exportButton)
tap(x: csvFormat, y: csvFormat)

// 4. Select date range
tap(x: dateRangeFilter, y: dateRangeFilter)
// ... select dates

// 5. Export
tap(x: confirmExport, y: confirmExport)
screenshot() // Verify Files app dialog
```

**Scenario 2**: Data Cleanup Workflow
```swift
// 1. Launch app
build_run_sim()

// 2. Navigate to Data Cleanup
tap(x: settingsTab, y: settingsTab)
swipe(preset: "scroll-down")
tap(x: dataCleanup, y: dataCleanup)

// 3. Check cleanup statistics
screenshot() // Verify orphaned count

// 4. Run orphaned cleanup
tap(x: cleanOrphanedButton, y: cleanOrphanedButton)
tap(x: confirmButton, y: confirmButton)

// 5. Verify cleanup complete
screenshot() // Verify "0 orphaned" after cleanup
```

---

## Success Metrics

- **Export Flexibility**: Users can export specific date ranges and data types
- **CSV Quality**: CSV files open correctly in Excel/Numbers without formatting issues
- **Cleanup Effectiveness**: Orphaned entity cleanup reduces database size by 10-30%
- **User Safety**: Zero accidental data loss from cleanup operations
- **Performance**: Cleanup operations < 5 seconds for 1000+ entries

---

## Technical Notes

### CSV Export Design Decisions

**Why Separate CSV Files?**
- Entries, entities, relationships have different schemas
- Single CSV would require complex nested structure
- Separate files easier to import into spreadsheets/databases

**Why UTF-8 with BOM?**
- Excel on Windows requires BOM to detect UTF-8
- Numbers and Excel on Mac work with or without BOM
- BOM ensures widest compatibility

**CSV Escaping Rules**:
- Fields with commas → wrap in quotes
- Fields with quotes → escape as double quotes ("")
- Fields with newlines → wrap in quotes
- Always use CRLF line endings for Excel compatibility

### Data Cleanup Design Decisions

**Why Two-Step Confirmation for Delete All?**
- Prevents accidental catastrophic data loss
- Common pattern in destructive operations (GitHub, AWS)
- Typing "DELETE" ensures user fully understands action

**Why Fuzzy Matching for Duplicates?**
- Exact matching misses typos and variations
- Levenshtein distance catches common errors
- Users still approve merges (not automatic)

**Cascade Delete Strategy**:
- Entry deleted → remove entity links (not entities themselves)
- Entity deleted → remove relationships involving it
- Orphaned entities kept until explicit cleanup
- Safer than aggressive cascade delete

**Why Preview Before Cleanup?**
- User sees exactly what will be removed
- Builds trust in cleanup operations
- Allows user to cancel if preview looks wrong

---

## Sprint Retrospective

**Status**: Sprint 18 - COMPLETED (2025-10-22)

**What Went Well**:
- ✅ Root cause analysis was thorough and accurate
- ✅ Fixed critical bug that was blocking users from clearing test data
- ✅ Deletion order fix (entries first) resolved relationship constraint errors
- ✅ Auto-dismiss Settings before cleanup prevented SwiftUI observation crashes
- ✅ Clear logging made debugging much easier
- ✅ Manual testing with Import Test Data validated the fix completely

**What Could Be Improved**:
- ⚠️ Should have had unit tests for deletion order logic
- ⚠️ Initial approach (deleting database files while app running) was wrong - wasted time
- ⚠️ Could have used XcodeBuildMCP automation for regression testing

**Bugs Fixed During Testing**:
1. **SQLite "vnode unlinked while in use" error** - Fixed by not deleting files, deleting objects instead
2. **Fatal error: Cannot remove Entity from relationship** - Fixed by deleting entries FIRST
3. **App hangs with loading spinner** - Fixed by auto-dismissing Settings view before cleanup
4. **Sendable concurrency warnings** - Fixed with proper Task.detached usage

**Key Learnings**:
1. **SwiftData deletion order matters**: Deleting parent objects (entries) first triggers proper cascade deletes
2. **UI observation during data changes causes crashes**: Must dismiss views observing data before bulk deletes
3. **Never delete database files while app is running**: SQLite keeps file handles open
4. **@MainActor isolation is tricky**: Use Task.detached with captured references to avoid Sendable issues
5. **Detailed logging is invaluable**: Step-by-step logs helped pinpoint exact failure points

**Technical Decisions**:
- ✅ **Merged 2 cleanup functions into 1**: Simpler UX, less confusion for users
- ✅ **Async/await for cleanup**: Proper modern Swift concurrency
- ✅ **Exit app after cleanup**: Safest way to ensure clean restart without corrupt state
- ✅ **Orphan cleanup**: Extra safety to catch any missed cascade deletes
- ✅ **Deprecate old clearAllData()**: Keep for backwards compat but mark deprecated

---

**Document Control**

- **Version**: 1.0
- **Author**: AI Assistant
- **Reviewed**: Pending
- **Approved**: Pending
- **Next Review**: After sprint completion
