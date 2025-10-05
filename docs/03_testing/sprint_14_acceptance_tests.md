# Sprint 14 Acceptance Tests

**Sprint**: Sprint 14 - AI Insights & Advanced Search
**Test Date**: October 5, 2025
**Test Environment**: iOS Simulator (iPhone 16, iOS 18.5)
**Test Tool**: XcodeBuildMCP

---

## Test Overview

This document defines acceptance test scenarios for Sprint 14 user stories:
- **US-S14-001**: Proactive AI Insights
- **US-S14-002**: Advanced Search & Filtering

---

## US-S14-001: Proactive AI Insights

### Test Scenario 1.1: Generate Daily Insights
**Objective**: Verify that daily insights are generated from today's journal entry

**Preconditions**:
- App installed and API key configured
- At least 1 journal entry exists for today
- Knowledge graph entities extracted

**Test Steps**:
1. Launch app
2. Navigate to Insights tab/screen
3. Verify "Daily Insights" section exists
4. Tap "Generate Daily Insights" button
5. Wait for AI generation (loading indicator visible)
6. Verify insights displayed (3-5 insights)

**Expected Results**:
- ✅ Loading indicator shows during generation
- ✅ 3-5 insights displayed within 10 seconds
- ✅ Each insight has: icon, title, description
- ✅ Insights relevant to today's entry content
- ✅ Confidence score visible (0.0-1.0)

**Pass Criteria**:
- All expected results achieved
- No errors or crashes
- UI responsive during generation

---

### Test Scenario 1.2: Weekly Pattern Insights
**Objective**: Verify weekly pattern analysis across past 7 days

**Preconditions**:
- At least 5 entries in past 7 days
- Entities extracted from entries
- Knowledge graph relationships exist

**Test Steps**:
1. Open Insights screen
2. Scroll to "Weekly Patterns" section
3. Tap "Generate Weekly Insights" button
4. Wait for AI analysis
5. Review generated insights (5-7 expected)
6. Tap on an insight to view details

**Expected Results**:
- ✅ 5-7 weekly insights generated
- ✅ Insight types include: frequency, temporal, emotional, social, topical
- ✅ Each insight shows evidence (linked entities/entries)
- ✅ Tap insight → navigate to detail view
- ✅ Detail view shows related entities and entries
- ✅ Can navigate to source entries from detail

**Pass Criteria**:
- Insights reflect actual patterns in data
- Navigation works correctly
- Evidence links are accurate

---

### Test Scenario 1.3: Insight Types Validation
**Objective**: Verify all 5 insight types can be generated

**Preconditions**:
- Diverse journal entries with:
  - Multiple entity mentions (frequency)
  - Time-based patterns (temporal)
  - Mood variations (emotional)
  - People interactions (social)
  - Different topics (topical)

**Test Steps**:
1. Generate daily or weekly insights
2. Review insight types in results
3. Verify presence of each type:
   - 📊 Frequency: "You mentioned X 5 times"
   - ⏰ Temporal: "You write about Y in mornings"
   - 😊 Emotional: "Mood improves after Z"
   - 👥 Social: "You write about family on weekends"
   - 📚 Topical: "Travel is an emerging theme"

**Expected Results**:
- ✅ At least 3 different insight types present
- ✅ Each type has appropriate icon
- ✅ Descriptions are clear and actionable
- ✅ Confidence scores reasonable (>0.6)

**Pass Criteria**:
- Multiple insight types generated
- Insights make sense for the data
- No duplicate insights

---

### Test Scenario 1.4: Tap Insight to View Evidence
**Objective**: Verify navigation from insight to related entries

**Preconditions**:
- Insights already generated
- Related entries exist in database

**Test Steps**:
1. From Insights list, tap on any insight
2. Verify detail view opens
3. Check "Evidence" section shows:
   - Related entities (chips/badges)
   - Related entries (list)
4. Tap on a related entry
5. Verify navigation to EntryDetailView

**Expected Results**:
- ✅ Detail view displays full insight information
- ✅ Related entities shown as tappable chips
- ✅ Related entries listed with date and snippet
- ✅ Tap entry → opens EntryDetailView
- ✅ Back navigation works correctly

**Pass Criteria**:
- All navigation flows work
- Related data is accurate
- UI is clear and usable

---

### Test Scenario 1.5: Insight Caching
**Objective**: Verify insights are cached for performance

**Preconditions**:
- Fresh app install or cleared cache

**Test Steps**:
1. Generate daily insights (first time)
2. Note the loading time
3. Close insights screen
4. Reopen insights screen
5. Check if insights load instantly (from cache)
6. Wait 24 hours (or simulate)
7. Verify cache expired and new generation needed

**Expected Results**:
- ✅ First generation: 5-10 seconds loading
- ✅ Cached load: <1 second, no loading indicator
- ✅ Cache expires after 24 hours
- ✅ Refresh button forces regeneration

**Pass Criteria**:
- Cache improves performance significantly
- Cache expiration works correctly
- Manual refresh always works

---

### Test Scenario 1.6: Empty State Handling
**Objective**: Verify appropriate messaging when no insights can be generated

**Preconditions**:
- New user with <3 journal entries
- No entities extracted yet

**Test Steps**:
1. Open Insights screen
2. Tap "Generate Insights"
3. Verify empty state message shown

**Expected Results**:
- ✅ Empty state UI displayed
- ✅ Message: "Write more to see patterns" or similar
- ✅ Suggestion to write more entries
- ✅ No error messages or crashes

**Pass Criteria**:
- Empty state is friendly and helpful
- User understands what to do next

---

### Test Scenario 1.7: Error Handling
**Objective**: Verify graceful error handling for API failures

**Preconditions**:
- Invalid API key or network disconnected

**Test Steps**:
1. Disable network or set invalid API key
2. Attempt to generate insights
3. Verify error message shown
4. Re-enable network
5. Tap retry button
6. Verify insights generate successfully

**Expected Results**:
- ✅ User-friendly error message (not technical)
- ✅ Retry button available
- ✅ No app crash
- ✅ Successful retry after network restored

**Pass Criteria**:
- Error messages are clear
- Retry mechanism works
- App remains stable

---

## US-S14-002: Advanced Search & Filtering

### Test Scenario 2.1: Full-Text Search
**Objective**: Verify basic text search across all entries

**Preconditions**:
- Multiple journal entries exist
- Entries contain searchable text

**Test Steps**:
1. Navigate to Search screen
2. Tap search bar
3. Type query: "work"
4. Verify results appear in real-time
5. Check highlighted matches in results

**Expected Results**:
- ✅ Search bar accepts input
- ✅ Results filter in real-time (debounced 300ms)
- ✅ Matches highlighted in yellow/blue
- ✅ Results show: date, snippet, entities
- ✅ Empty results show "No results found"

**Pass Criteria**:
- Search returns accurate results
- Performance <500ms
- Highlighting works correctly

---

### Test Scenario 2.2: Entity-Based Filtering
**Objective**: Verify filtering by extracted entities

**Preconditions**:
- Entries have extracted entities
- At least 3 different people/places/topics

**Test Steps**:
1. Open Search screen
2. Tap "Filters" button
3. Select entity filter (e.g., "Mom")
4. Verify results filtered to entries mentioning "Mom"
5. Add second entity filter (e.g., "Happy")
6. Verify AND logic (both Mom AND Happy)

**Expected Results**:
- ✅ Entity chips displayed for selection
- ✅ Selected filters shown at top
- ✅ Results update immediately
- ✅ Filter count badge shows number of active filters
- ✅ "Clear All" button removes all filters

**Pass Criteria**:
- Filtering logic correct (AND operation)
- UI clearly shows active filters
- Results are accurate

---

### Test Scenario 2.3: Date Range Filtering
**Objective**: Verify filtering by date ranges

**Preconditions**:
- Entries spanning multiple months

**Test Steps**:
1. Open Search filters
2. Select "Date Range" filter
3. Choose preset: "This Week"
4. Verify results limited to past 7 days
5. Change to "Custom Range"
6. Pick start date: Oct 1, end date: Oct 5
7. Verify results in that range

**Expected Results**:
- ✅ Preset ranges work: Today, This Week, This Month, Last Month
- ✅ Custom date picker functional
- ✅ Results correctly filtered by date
- ✅ Date range shown in filter chips

**Pass Criteria**:
- All preset ranges accurate
- Custom range picker works
- Results match selected dates

---

### Test Scenario 2.4: Mood & Weather Filtering
**Objective**: Verify filtering by mood and weather metadata

**Preconditions**:
- Entries with various moods (happy, sad, excited)
- Entries with weather data (sunny, cloudy, rainy)

**Test Steps**:
1. Open Search filters
2. Select mood: "Happy"
3. Verify results show only happy mood entries
4. Add weather filter: "Sunny"
5. Verify combined filter (Happy AND Sunny)

**Expected Results**:
- ✅ Mood filter options displayed
- ✅ Weather filter options displayed
- ✅ Results match selected filters
- ✅ Combined filters use AND logic

**Pass Criteria**:
- Mood filtering accurate
- Weather filtering accurate
- Combined filters work correctly

---

### Test Scenario 2.5: Combined Multi-Filter Search
**Objective**: Verify complex queries with multiple filters

**Preconditions**:
- Rich dataset with entities, moods, dates

**Test Steps**:
1. Enter search text: "family"
2. Add entity filter: "Mom"
3. Add date range: "Last Month"
4. Add mood: "Happy"
5. Verify results match ALL criteria
6. Check filter badge shows (4)

**Expected Results**:
- ✅ Results contain "family" in text
- ✅ Results mention entity "Mom"
- ✅ Results within last month date range
- ✅ Results have "Happy" mood
- ✅ Filter count badge accurate

**Pass Criteria**:
- All filters applied correctly (AND logic)
- Results are accurate intersection
- Performance acceptable (<1s)

---

### Test Scenario 2.6: Search Result Navigation
**Objective**: Verify navigation from search results to entry detail

**Preconditions**:
- Search results displayed

**Test Steps**:
1. Perform search
2. Tap on a search result card
3. Verify EntryDetailView opens
4. Verify correct entry displayed
5. Navigate back to search
6. Verify search state preserved

**Expected Results**:
- ✅ Tap result → opens EntryDetailView
- ✅ Correct entry shown
- ✅ Back button returns to search
- ✅ Search query and filters preserved
- ✅ Results list position maintained

**Pass Criteria**:
- Navigation smooth and correct
- State preservation works
- No data loss

---

### Test Scenario 2.7: Clear Filters
**Objective**: Verify clearing individual and all filters

**Preconditions**:
- Multiple filters active

**Test Steps**:
1. Apply 3+ filters
2. Tap X on one filter chip
3. Verify that filter removed
4. Tap "Clear All" button
5. Verify all filters removed
6. Verify results show all entries

**Expected Results**:
- ✅ Individual filter removal works
- ✅ "Clear All" removes all filters
- ✅ Results update immediately
- ✅ Filter count badge updates
- ✅ Empty filter state restored

**Pass Criteria**:
- Filter removal works correctly
- UI updates properly
- Results refresh accurately

---

### Test Scenario 2.8: Empty Search Results
**Objective**: Verify empty state for no matching results

**Preconditions**:
- Database with entries

**Test Steps**:
1. Enter search query: "zzzzzznonexistent"
2. Verify no results
3. Check empty state message

**Expected Results**:
- ✅ Empty state UI displayed
- ✅ Message: "No results found"
- ✅ Suggestion to try different query
- ✅ No error or crash

**Pass Criteria**:
- Empty state is clear and helpful
- No technical errors shown

---

### Test Scenario 2.9: Search Performance
**Objective**: Verify search performance with large dataset

**Preconditions**:
- 100+ journal entries in database

**Test Steps**:
1. Type search query
2. Measure time from input to results
3. Apply multiple filters
4. Measure filter application time

**Expected Results**:
- ✅ Search results appear <500ms
- ✅ Filter application <300ms
- ✅ No UI lag or freezing
- ✅ Smooth scrolling in results

**Pass Criteria**:
- Performance targets met
- UI remains responsive
- No memory issues

---

### Test Scenario 2.10: Sort Options
**Objective**: Verify result sorting functionality

**Preconditions**:
- Search results displayed

**Test Steps**:
1. Perform search
2. Tap "Sort" button
3. Select "Newest First"
4. Verify results sorted by date descending
5. Select "Oldest First"
6. Verify results sorted by date ascending
7. Select "Most Relevant" (if implemented)

**Expected Results**:
- ✅ Sort options displayed
- ✅ Newest First: Descending date order
- ✅ Oldest First: Ascending date order
- ✅ Sort persists during session
- ✅ Results reorder correctly

**Pass Criteria**:
- All sort options work
- Ordering is accurate
- UI updates properly

---

## Integration Tests

### Test Scenario INT-1: Insights to Search Integration
**Objective**: Verify navigation from insights to search by entity

**Test Steps**:
1. Generate insights
2. Tap on entity mentioned in insight
3. Verify navigates to Search with entity filter pre-applied
4. Verify results show all entries with that entity

**Expected Results**:
- ✅ Smooth navigation
- ✅ Entity filter pre-populated
- ✅ Results accurate

---

### Test Scenario INT-2: Search to Entry to Insights Loop
**Objective**: Verify full user journey across features

**Test Steps**:
1. Search for "family"
2. Open an entry
3. Check entities in entry
4. Navigate to Insights
5. Find insight mentioning same entity
6. Verify consistency

**Expected Results**:
- ✅ Data consistent across features
- ✅ Navigation smooth
- ✅ No data loss or corruption

---

## Performance Benchmarks

| Metric | Target | Critical |
|--------|--------|----------|
| Daily insight generation | <5s | <10s |
| Weekly insight generation | <10s | <15s |
| Search latency (100 entries) | <300ms | <500ms |
| Search latency (1000 entries) | <500ms | <1s |
| Filter application | <200ms | <300ms |
| Insight cache load | <100ms | <200ms |

---

## Accessibility Tests

### Test Scenario ACC-1: VoiceOver Support
**Objective**: Verify VoiceOver accessibility

**Test Steps**:
1. Enable VoiceOver
2. Navigate Insights screen
3. Navigate Search screen
4. Verify all elements readable
5. Verify all actions accessible

**Expected Results**:
- ✅ All buttons have labels
- ✅ Insights read clearly
- ✅ Search results navigable
- ✅ Filters accessible

---

## Edge Cases

### Edge Case 1: No Internet During Insight Generation
- Verify error handling
- Retry mechanism works

### Edge Case 2: Very Long Entry (10000+ words)
- Insight generation completes
- Search performance acceptable

### Edge Case 3: Special Characters in Search
- Search handles: @#$%^&*()
- No crashes or errors

### Edge Case 4: Concurrent Insight Generation
- Multiple taps don't create duplicate requests
- Loading state prevents duplicate operations

---

## Test Execution Log

| Test ID | Test Name | Status | Notes | Date |
|---------|-----------|--------|-------|------|
| 1.1 | Generate Daily Insights | ⏳ Pending | | |
| 1.2 | Weekly Pattern Insights | ⏳ Pending | | |
| 1.3 | Insight Types Validation | ⏳ Pending | | |
| 1.4 | Tap Insight to View Evidence | ⏳ Pending | | |
| 1.5 | Insight Caching | ⏳ Pending | | |
| 1.6 | Empty State Handling | ⏳ Pending | | |
| 1.7 | Error Handling | ⏳ Pending | | |
| 2.1 | Full-Text Search | ⏳ Pending | | |
| 2.2 | Entity-Based Filtering | ⏳ Pending | | |
| 2.3 | Date Range Filtering | ⏳ Pending | | |
| 2.4 | Mood & Weather Filtering | ⏳ Pending | | |
| 2.5 | Combined Multi-Filter Search | ⏳ Pending | | |
| 2.6 | Search Result Navigation | ⏳ Pending | | |
| 2.7 | Clear Filters | ⏳ Pending | | |
| 2.8 | Empty Search Results | ⏳ Pending | | |
| 2.9 | Search Performance | ⏳ Pending | | |
| 2.10 | Sort Options | ⏳ Pending | | |

---

**Test Status Legend**:
- ⏳ Pending
- 🔄 In Progress
- ✅ Passed
- ❌ Failed
- ⚠️ Blocked

---

**Test Report**: To be updated during implementation and testing phases
