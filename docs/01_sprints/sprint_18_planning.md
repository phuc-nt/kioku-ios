# Sprint 18: Data Management Enhancements

**Sprint Period**: October 22-23, 2025
**Epic**: EPIC-7 - User Empowerment & Data Portability
**Story Points**: 7 points (3 user stories completed)
**Status**: ✅ COMPLETED (2025-10-23)

## Sprint Goal
**Part 1**: Fix critical data cleanup functionality with reliable "Clear All Data"
**Part 2**: Enable minimal JSON import (entries only) for easy conversion of raw journal data
**Part 3**: Remove redundant Chat tab (Chat with AI button is sufficient)

**Strategic Value**:
- Users gain confidence through a robust "Clear All Data" that works without crashes
- Users can easily import journal entries from any format (via AI conversion to JSON)
- Simplified navigation with 4 tabs instead of 5 (Calendar has Chat with AI button)

---

## User Stories

### US-049: Minimal JSON Import (3 points)

**As a** user
**I want** to import journal entries using simple JSON format (only date + content)
**So that** I can easily convert raw journal data from any format and import into Kioku

**Priority**: HIGH
**Status**: ✅ COMPLETED (2025-10-23)

**Problem Statement**:
- ImportService required full export format with all fields (entities, relationships, metadata)
- Cannot import simple journal entries without complex JSON structure
- Difficult to convert raw journal data (text files, notes) to importable format
- Users need AI assistance to generate proper JSON with all required fields

**Solution Approach**:
1. Make ExportData fields optional (entities, relationships, metadata)
2. Make ExportedEntry fields optional with sensible defaults
3. Support minimal JSON format: `{"version": "1.0", "entries": [{"date": "...", "content": "..."}]}`
4. Create SIMPLE_ENTRY_FORMAT.md guide for AI conversion
5. Add DEBUG export to project folder for testing

**Acceptance Criteria**:
- [x] Import works with minimal JSON (only version + entries array)
- [x] Entry fields auto-fill defaults: id=UUID(), createdAt=now, isEncrypted=false
- [x] KG tracking defaults to "not extracted" (AI will extract after import)
- [x] Empty arrays default for entities/relationships/insights/conversations
- [x] Simple format doc created for AI conversion tools
- [x] DEBUG export to project folder works
- [x] Successfully import real journal data from draft_1.md

**Technical Implementation**:

**FR-S18-020: Minimal Import Support**
- Modified `ExportData` struct:
  - `exportedAt`: Optional (was required)
  - `exportMetadata`: Optional (was required)
  - `entities`, `relationships`, `insights`, `conversations`: Default to empty arrays
  - Custom `init(from:)` decoder with defaults
- Modified `ExportedEntry` struct:
  - `id`: Generate UUID() if missing
  - `isEncrypted`: Default false
  - `createdAt`, `updatedAt`: Default to now
  - `dataVersion`: Default to 2
  - `kgTracking`: Default to not extracted
  - `entityIds`, `relationshipIds`, `analysisIds`: Default to empty arrays
  - Custom `init(from:)` decoder with all defaults

**FR-S18-021: Simple Format Documentation**
- Created `docs/04_import_format/SIMPLE_ENTRY_FORMAT.md`:
  - Minimal JSON structure (date + content only)
  - Date format conversion guide (MM.DD → ISO 8601)
  - AI conversion prompt template
  - Real example using draft_1.md
  - Quick import steps
- Simplified from comprehensive JSON_IMPORT_FORMAT.md
- Focused on entry-only imports (no entities/relationships)

**FR-S18-022: DEBUG Export to Project Folder**
- Added DEBUG-only "Export to Project Folder" button
- Exports directly to `/Users/phucnt/Workspace/kioku_ios/exports/`
- Creates exports/ folder if doesn't exist
- Added `exports/` to .gitignore
- Useful for testing import without Files app

**Technical Tasks**:
- [x] Modify ExportData struct with optional fields and custom decoder
- [x] Modify ExportedEntry struct with defaults and custom decoder
- [x] Fix ExportedKGTracking default initialization
- [x] Create SIMPLE_ENTRY_FORMAT.md guide
- [x] Add DEBUG export to project folder button
- [x] Update .gitignore for exports/
- [x] Convert draft_1.md to draft_1.json (21 entries)
- [x] Test import with minimal JSON format
- [x] Verify AI entity extraction works after import
- [x] Manual testing: Clear → Import → Extract → Chat

**Files Created**:
- ✅ `docs/04_import_format/SIMPLE_ENTRY_FORMAT.md` - Simple import guide
- ✅ `raw_data/draft_1.json` - Converted test data (21 entries)

**Files Modified**:
- ✅ `KiokuPackage/Sources/KiokuFeature/Services/ExportService.swift`
  - ExportData: Optional fields + custom decoder
  - ExportedEntry: Defaults + custom decoder
- ✅ `KiokuPackage/Sources/KiokuFeature/Views/Settings/DataManagementView.swift`
  - DEBUG export to project folder button
- ✅ `.gitignore` - Added exports/

**Definition of Done**:
- [x] Minimal JSON import works (only date + content required)
- [x] All optional fields auto-fill with sensible defaults
- [x] SIMPLE_ENTRY_FORMAT.md created and tested
- [x] Successfully imported draft_1.json (21 entries)
- [x] AI entity extraction works after import
- [x] Chat context includes imported entries
- [x] DEBUG export to project folder works
- [x] Manual testing passed: Clear → Import → Extract → Explore → Chat
- [x] Changes committed and pushed
- [x] Sprint planning document updated

---

### US-050: Remove Redundant Chat Tab (1 point)

**As a** user
**I want** a simplified navigation with fewer tabs
**So that** I can focus on the essential features without redundancy

**Priority**: MEDIUM (UX Improvement)
**Status**: ✅ COMPLETED (2025-10-23)

**Problem Statement**:
- App has 5 tabs: Calendar, Chat, Insights, Graph, Settings
- Chat tab is redundant - Calendar already has "Chat with AI" button
- Users confused about difference between Chat tab and Chat with AI button
- Both lead to same AIChatView functionality
- Extra tab clutters navigation

**Solution Approach**:
1. Remove Chat tab from main navigation
2. Keep only "Chat with AI" button in Calendar view
3. Update tab indices: Calendar=0, Insights=1, Graph=2, Settings=3
4. Delete ChatTabView.swift (no longer needed)
5. Simplify navigation to 4 essential tabs

**Acceptance Criteria**:
- [x] Chat tab removed from TabView
- [x] Only 4 tabs visible: Calendar, Insights, Graph, Settings
- [x] ChatTabView.swift deleted
- [x] "Chat with AI" button still works in Calendar view
- [x] Tab indices updated correctly (0-3 instead of 0-4)
- [x] App builds and runs without errors
- [x] Navigation feels simpler and more focused

**Technical Implementation**:

**FR-S18-030: Remove Chat Tab**
- Removed `ChatTabView(selectedDate: $selectedDate)` from ContentView
- Updated tab tags: Insights=1, Graph=2, Settings=3 (was 2, 3, 4)
- Deleted `ChatTabView.swift` file (182 lines removed)
- No changes to AIChatView - still accessible via Calendar

**Rationale**:
- ChatTabView was just a wrapper for AIChatView
- Same functionality already accessible from Calendar view
- Reduces cognitive load for users
- Simpler navigation = better UX
- Follows principle: "One way to do one thing"

**Technical Tasks**:
- [x] Remove ChatTabView from ContentView.swift
- [x] Update tab tags (0, 1, 2, 3 instead of 0, 1, 2, 3, 4)
- [x] Delete ChatTabView.swift file
- [x] Test app with 4 tabs
- [x] Verify "Chat with AI" button still works

**Files Modified**:
- ✅ `KiokuPackage/Sources/KiokuFeature/ContentView.swift` - Removed Chat tab
- ✅ `KiokuPackage/Sources/KiokuFeature/Views/Chat/ChatTabView.swift` - Deleted (182 lines)

**Files Unaffected**:
- ✅ `AIChatView.swift` - Still used by Calendar's "Chat with AI" button
- ✅ `ChatContextService.swift` - Still needed for chat context
- ✅ `ChatMessageView.swift` - Still used by AIChatView
- ✅ `ChatContextView.swift` - Still used by AIChatView

**Definition of Done**:
- [x] Chat tab removed from navigation
- [x] Only 4 tabs visible in app
- [x] ChatTabView.swift deleted
- [x] App builds successfully
- [x] "Chat with AI" from Calendar still works
- [x] No broken references or imports
- [x] Changes committed and pushed
- [x] Sprint planning document updated

---

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

**Status**: Sprint 18 - COMPLETED (2025-10-23)

**Part 1: Clear All Data Fix** ✅
- ✅ Root cause analysis was thorough and accurate
- ✅ Fixed critical bug that was blocking users from clearing test data
- ✅ Deletion order fix (relationships → entities → entries) resolved constraint errors
- ✅ Save after each deletion step prevented cascade violations
- ✅ Clear logging made debugging much easier
- ✅ Manual testing validated the fix completely

**Part 2: Minimal JSON Import** ✅
- ✅ Successfully enabled minimal import format (date + content only)
- ✅ Custom Codable decoders with sensible defaults worked perfectly
- ✅ SIMPLE_ENTRY_FORMAT.md provides clear guide for AI conversion
- ✅ Real-world test: Converted and imported 21 journal entries from draft_1.md
- ✅ AI entity extraction works seamlessly after import
- ✅ DEBUG export to project folder speeds up testing workflow

**Part 3: Remove Chat Tab** ✅
- ✅ Simplified navigation from 5 tabs to 4 tabs
- ✅ Removed redundant Chat tab (functionality already in Calendar)
- ✅ Deleted 182 lines of unused code (ChatTabView.swift)
- ✅ Cleaner UX following "one way to do one thing" principle
- ✅ No impact on core chat functionality

**What Went Well**:
- ✅ Three features completed in 2 days (7 story points total)
- ✅ Custom Codable decoders elegantly solved complex JSON parsing
- ✅ Documentation-driven approach (SIMPLE_ENTRY_FORMAT.md) made testing easy
- ✅ Real user data (draft_1.md) validated the entire import workflow
- ✅ Bug fixes were thorough and addressed root causes, not symptoms
- ✅ Code cleanup removed redundancy and simplified UX

**What Could Be Improved**:
- ⚠️ Initial deletion order was wrong - had to iterate 3 times to get it right
- ⚠️ Should have read SwiftData relationship documentation earlier
- ⚠️ Could have used XcodeBuildMCP automation for regression testing
- ⚠️ Need unit tests for deletion order logic and import defaults

**Bugs Fixed During Testing**:

**Part 1 (Clear All Data)**:
1. **SQLite "vnode unlinked while in use" error** - Fixed by not deleting files, deleting objects instead
2. **Fatal error: Cannot remove Entity from relationship** - Fixed deletion order (relationships FIRST)
3. **Constraint violations during save** - Fixed by saving after EACH deletion step
4. **App hangs with loading spinner** - Fixed by auto-dismissing Settings view before cleanup

**Part 2 (Minimal Import)**:
1. **"Failed to parse JSON: data missing" error** - Fixed by making ExportData fields optional
2. **Missing required fields in ExportedEntry** - Fixed with custom decoder and defaults
3. **Wrong ExportedKGTracking field names** - Fixed field names in default initialization

**Key Learnings**:
1. **SwiftData deletion order is CRITICAL**: Relationships → Entities → Entries (reverse dependency order)
2. **Save after each step**: Prevents cascade constraint violations in complex relationships
3. **Custom Codable decoders**: Perfect for backward-compatible JSON with optional fields
4. **Documentation before implementation**: SIMPLE_ENTRY_FORMAT.md guided the entire feature
5. **Test with real data**: draft_1.md revealed edge cases that test data wouldn't
6. **UI observation during data changes causes crashes**: Must dismiss views before bulk operations

**Technical Decisions**:

**Part 1**:
- ✅ **Delete in reverse dependency order**: Relationships → Entities → Entries
- ✅ **Save after each step**: Commit changes to prevent constraint violations
- ✅ **Async/await for cleanup**: Proper modern Swift concurrency
- ✅ **Exit app after cleanup**: Safest way to ensure clean restart

**Part 2**:
- ✅ **Custom Codable decoders**: Clean solution for optional fields with defaults
- ✅ **Minimal format support**: Lowers barrier for importing raw journal data
- ✅ **AI-first documentation**: SIMPLE_ENTRY_FORMAT.md designed for AI conversion tools
- ✅ **DEBUG export to project folder**: Faster testing without Files app

**Part 3**:
- ✅ **Remove redundancy**: Chat tab was duplicate of Calendar's Chat button
- ✅ **Simplify navigation**: 4 tabs clearer than 5 tabs
- ✅ **Delete unused code**: 182 lines removed improves maintainability
- ✅ **"One way to do one thing"**: Single entry point for chat feature

---

**Document Control**

- **Version**: 1.0
- **Author**: AI Assistant
- **Reviewed**: Pending
- **Approved**: Pending
- **Next Review**: After sprint completion
