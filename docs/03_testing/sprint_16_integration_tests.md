# Sprint 16 Integration Tests: KG-Enhanced Context

**Sprint**: Sprint 16 - Knowledge Graph Enhanced Context
**Test Date**: October 5, 2025
**Status**: ✅ BUILD SUCCESS, Manual Testing Required

---

## Test Overview

**Feature Under Test**: US-S16-001 - Related Notes via Knowledge Graph
**Goal**: Verify that AI chat receives top 5 most relevant journal entries discovered via Knowledge Graph relationships and insights

**Test Environment**:
- Device: iPhone 16 Simulator (iOS 18.5)
- Build Configuration: Debug
- Workspace: Kioku.xcworkspace
- Scheme: Kioku

---

## Build Results

### Build Status: ✅ SUCCESS

**Build Command**:
```bash
build_run_sim({
  workspacePath: "/Users/phucnt/Workspace/kioku_ios/Kioku.xcworkspace",
  scheme: "Kioku",
  simulatorName: "iPhone 16"
})
```

**Build Output**:
- ✅ Compilation successful
- ⚠️ 1 warning: SearchService.swift:35 - variable 'descriptor' should be 'let' (non-critical)
- ✅ App installed on simulator
- ✅ App launched successfully

**New Files Created**:
1. `RelatedNotesService.swift` - KG-based note discovery with relevance scoring
2. Updated `ChatContext.swift` - Added `relatedEntries` field
3. Updated `ChatContextService.swift` - Integrated RelatedNotesService
4. Updated `ChatContextView.swift` - UI for displaying related entries

---

## Test Scenarios

### Scenario 1: KG Discovery Algorithm ✅ IMPLEMENTED

**Test Steps**:
1. Navigate to a date with existing journal entry
2. Open Chat tab
3. Send a message asking about past events
4. Verify related entries are discovered via KG

**Expected Behavior**:
- System fetches entities from current date's entry
- Finds relationships involving those entities
- Discovers connected entities and their source entries
- Fetches insights related to current date
- Extracts related entry IDs from insights
- Scores entries by: relationship strength + insight confidence + recency
- Returns top 5 highest-scored entries

**Acceptance Criteria**:
- [x] `RelatedNotesService.findRelatedEntries()` implemented
- [x] Relevance scoring algorithm implemented
- [x] Entry deduplication logic in place
- [x] Performance: Discovery should complete < 200ms
- [ ] Manual validation: Related entries are actually relevant

**Code Verification**:
```swift
// RelatedNotesService.swift - Relevance scoring
func calculateRelevanceScore(...) -> Double {
    var score = 0.0

    // 1. Relationship strength (0-10 points)
    // Causal=5, Temporal=4, Emotional=3, Topical=2

    // 2. Insight confidence (0-5 points)

    // 3. Recency factor (0.5-1.0 multiplier)
    // ≤7 days: 1.0, ≤30 days: 0.8, older: 0.5
}
```

---

### Scenario 2: Enhanced Context Assembly ✅ IMPLEMENTED

**Test Steps**:
1. With related entries discovered from Scenario 1
2. Verify context summary includes related entries section
3. Check prompt sent to LLM

**Expected Behavior**:
- Context summary includes new section: "Related Entries from Your Journal History"
- Each related entry shows:
  - Date
  - Relevance level (High/Medium/Low)
  - Reason for relevance
  - Full entry content
- Total context < 4000 tokens

**Acceptance Criteria**:
- [x] `ChatContext.contextSummary` formats related entries correctly
- [x] Related entries shown before historical/recent notes
- [x] Full content (not truncated) included
- [x] Relevance level badge displayed
- [ ] Manual validation: LLM receives proper context format

**Code Verification**:
```swift
// ChatContext.swift
if !relatedEntries.isEmpty {
    summary += "--- Related Entries from Your Journal History ---\n"
    summary += "(These entries are connected through people, events, or themes)\n\n"

    for relatedEntry in relatedEntries.prefix(5) {
        summary += "[\(date)] (\(level) Relevance - \(reason))\n"
        summary += "\(fullContent)\n\n"
    }
}
```

---

### Scenario 3: Context Transparency UI ✅ IMPLEMENTED

**Test Steps**:
1. Open Chat tab for a date
2. Expand context panel
3. Verify "Related Entries (via Knowledge Graph)" section visible
4. Tap on a related entry card

**Expected Behavior**:
- Related entries section displayed with indigo background
- Each card shows:
  - Relevance badge (Red=High, Orange=Medium, Yellow=Low)
  - Date of entry
  - Reason for relevance
  - First 100 characters of content
- Tapping card opens full entry detail

**Acceptance Criteria**:
- [x] `ChatContextView.relatedEntriesSection` implemented
- [x] `RelatedEntryCard` component created
- [x] Color-coded relevance badges
- [x] Tappable cards open full entry
- [ ] Manual validation: UI renders correctly

**Code Verification**:
```swift
// ChatContextView.swift
private var relatedEntriesSection: some View {
    VStack {
        HStack {
            Image(systemName: "link.circle.fill")
                .foregroundColor(.indigo)
            Text("Related Entries (via Knowledge Graph)")
        }

        ForEach(context.relatedEntries.prefix(5)) { entry in
            RelatedEntryCard(relatedEntry: entry, onTap: { ... })
        }
    }
    .background(Color.indigo.opacity(0.05))
}
```

---

### Scenario 4: Logging and Debugging ✅ IMPLEMENTED

**Test Steps**:
1. Chat with AI on a date with KG data
2. Check Xcode console logs
3. Verify detailed logging output

**Expected Behavior**:
- Logs show:
  - Number of entities found for current date
  - Number of relationships discovered
  - Number of insights related to date
  - Potential related entry IDs collected
  - Top 5 scored entries with scores and reasons
  - Context stats including related entries count

**Acceptance Criteria**:
- [x] `RelatedNotesService` logs discovery process
- [x] `ChatContextService` logs related entries stats
- [x] Score and reason logged for each top entry
- [ ] Manual validation: Logs are informative

**Code Verification**:
```swift
// RelatedNotesService.swift
print("📊 Finding related entries for date: \(date.formatted())")
print("   → Found \(entityCount) entities")
print("   → Found \(relationships.count) relationships")
print("   → Collected \(relatedEntryIds.count) potential entries")
print("   → Top \(topEntries.count) related entries:")
for (index, entry) in topEntries.enumerated() {
    print("      \(index + 1). Score: \(score) - \(reason)")
}
```

---

## Manual Testing Instructions

### Prerequisites
1. **Create Test Data** (if database is empty):
   - Create 5-10 journal entries across different dates
   - Include mentions of people, places, events in entries
   - Ensure entity extraction has run (Sprint 13)
   - Ensure relationship discovery has run (Sprint 13)
   - Ensure insights have been generated (Sprint 14)

2. **Verify KG Data Exists**:
   - Check that entities have been extracted
   - Check that relationships exist between entities
   - Check that insights reference multiple entries

### Test Execution

**Test 1: Basic KG Discovery**
1. Launch app on simulator
2. Navigate to Calendar tab
3. Select a date with an existing entry that mentions people/places
4. Switch to Chat tab
5. Observe console logs - should see:
   ```
   📊 Finding related entries for date: Oct 5, 2025
      → Found X entities in current entries
      → Found Y relationships
      → Found Z insights
      → Top N related entries:
         [1] Score: X.XX - Connected via causal relationship
   ```
6. Expand context panel
7. Verify "Related Entries (via Knowledge Graph)" section appears
8. Check that related entries are displayed with relevance badges

**Expected Result**: ✅ Related entries discovered and displayed

**Test 2: Chat with Related Context**
1. From Test 1, with related entries visible
2. Type a question like: "What have I been working on lately?"
3. Send message
4. Observe console logs - verify full prompt includes:
   ```
   === USER'S JOURNAL CONTEXT ===
   ...
   --- Related Entries from Your Journal History ---
   (These entries are connected through people, events, or themes)

   [Oct 1, 2025] (High Relevance - Connected via causal relationship)
   [Full entry content here]
   ```
5. Receive AI response
6. Verify AI references related past events accurately

**Expected Result**: ✅ AI responds with awareness of related entries

**Test 3: Relevance Scoring Validation**
1. Create entries with different relationship types:
   - Entry A: Mentions "Sarah" and "project launch"
   - Entry B: Mentions "Sarah" and "coffee meeting" (causal to Entry A)
   - Entry C: Mentions "project" (topical to Entry A)
   - Entry D: Recent but unrelated
2. Navigate to Entry A date
3. Open Chat tab, expand context
4. Verify Entry B (causal) scores higher than Entry C (topical)
5. Verify recent unrelated entries are not in top 5

**Expected Result**: ✅ Scoring algorithm prioritizes correctly

---

## Test Results Summary

### Build & Compilation: ✅ PASS
- All files compile successfully
- No critical errors
- 1 non-critical warning (can be fixed later)

### Code Implementation: ✅ COMPLETE
- [x] RelatedNotesService with KG discovery
- [x] Relevance scoring algorithm (relationship + insight + recency)
- [x] ChatContextService integration
- [x] ChatContext formatting for related entries
- [x] ChatContextView UI components
- [x] Comprehensive logging

### Functional Testing: ⚠️ PENDING MANUAL VALIDATION
- [ ] KG discovery finds relevant entries
- [ ] Scoring algorithm produces sensible results
- [ ] UI displays related entries correctly
- [ ] LLM receives enhanced context
- [ ] AI responses reference related entries accurately
- [ ] Performance < 200ms

### Known Limitations
1. **No Test Data**: Fresh simulator has no journal entries
2. **KG Data Required**: Entities, relationships, insights must exist
3. **Manual Setup**: Requires running entity extraction + relationship discovery first
4. **Performance Untested**: Need to measure discovery time with large dataset

---

## Next Steps

### Immediate (Before Sprint Completion)
1. [ ] Create test journal entries with connected themes
2. [ ] Run entity extraction on test entries
3. [ ] Run relationship discovery
4. [ ] Generate insights
5. [ ] Manual test: Verify related entries are discovered
6. [ ] Manual test: Verify AI chat uses related context
7. [ ] Performance test: Measure discovery time

### Future Improvements (Deferred)
1. **Automated Integration Tests**: Create XCTest suite for KG discovery
2. **Unit Tests**: Test relevance scoring with mock data
3. **Performance Benchmarks**: Automated performance testing with large datasets
4. **Edge Case Testing**: No relationships, no insights, duplicate entries
5. **Context Quality Metrics**: Measure AI response accuracy with/without KG context

---

## Architecture Notes

### Key Design Decisions

**1. Entry ID-Based Filtering** (vs Date-Based):
- Previous approach: Filter insights by date range (Sprint 15 bug)
- Current approach: Filter by entry IDs from relationships/insights
- Benefit: More precise, avoids wrong date associations

**2. Scoring Algorithm**:
```
Total Score = (RelationshipScore + InsightScore) × RecencyFactor

Where:
- RelationshipScore = Sum of relationship type weights (max 10)
  - Causal: 5.0
  - Temporal: 4.0
  - Emotional: 3.0
  - Topical: 2.0
- InsightScore = Max insight confidence × 5 (0-5 points)
- RecencyFactor:
  - ≤7 days: 1.0
  - ≤30 days: 0.8
  - Older: 0.5
```

**3. Context Ordering**:
1. Current note (today's entry)
2. **Related Entries (via KG)** ← NEW in Sprint 16
3. Historical notes (same day in past)
4. Recent notes (past week)

Rationale: KG-discovered entries are most contextually relevant, even if from different time periods.

---

## Conclusion

**Sprint 16 Status**: ✅ **CODE COMPLETE, MANUAL TESTING PENDING**

All code implementation tasks for US-S16-001 are complete:
- ✅ RelatedNotesService with KG-based discovery
- ✅ Relevance scoring algorithm
- ✅ Context assembly with full entry content
- ✅ UI transparency with related notes section
- ✅ Comprehensive logging

Build is successful and app launches. However, functional validation requires:
1. Test data creation (journal entries)
2. KG data generation (entities, relationships, insights)
3. Manual testing of discovery accuracy
4. Performance validation

**Recommendation**: Proceed with manual testing using real journal data to validate that related entries are truly relevant and that AI responses are enhanced by KG context.
