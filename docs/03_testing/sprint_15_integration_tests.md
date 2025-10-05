# Sprint 15: Knowledge Graph Context Integration - Test Plan

**Sprint**: Sprint 15
**Features**: US-S15-001 (Entity Context), US-S15-002 (Insight Context)
**Test Date**: October 5, 2025
**Simulator**: iPhone 16 (iOS 18.4)

---

## Test Overview

### Objectives
1. Verify entities and relationships are included in AI chat context
2. Verify insights are referenced in AI chat responses
3. Validate context assembly performance (< 150ms)
4. Ensure no regressions in existing chat functionality

### Prerequisites
- App built and installed on simulator
- Sample journal entries with extracted entities
- Generated insights (daily/weekly) exist in database
- OpenRouter API key configured

---

## Test Cases

### Test 1: Entity-Aware Chat Response
**Feature**: US-S15-001
**Objective**: Verify AI chat includes entity context from current date's entry

**Setup:**
1. Create entry for October 5, 2025: "Had lunch with Sarah at Downtown Cafe"
2. Ensure entities extracted: Sarah (Person), Downtown Cafe (Place)
3. Navigate to Chat tab for October 5

**Steps:**
1. Launch app
2. Select October 5, 2025 in Calendar tab
3. Switch to Chat tab
4. Type: "Who did I meet today?"
5. Send message
6. Observe AI response

**Expected Results:**
- ✅ AI response mentions "Sarah" from entity context
- ✅ AI response mentions "Downtown Cafe" if relevant
- ✅ Response demonstrates awareness of extracted entities
- ✅ Response time < 3 seconds

**XcodeBuildMCP Commands:**
```swift
// Launch and navigate
build_run_sim(scheme: "Kioku", simulatorName: "iPhone 16")
tap(x: calendar_tab_x, y: calendar_tab_y)
tap(x: october_5_cell_x, y: october_5_cell_y)
tap(x: chat_tab_x, y: chat_tab_y)

// Type and send
tap(x: message_field_x, y: message_field_y)
type_text(text: "Who did I meet today?")
tap(x: send_button_x, y: send_button_y)

// Validate
screenshot()
describe_ui() // Verify response contains "Sarah"
```

---

### Test 2: Relationship-Aware Chat Response
**Feature**: US-S15-001
**Objective**: Verify AI chat can answer questions about entity relationships

**Setup:**
1. Create entry 1 (Oct 1): "Met Sarah and John for coffee"
2. Create entry 2 (Oct 3): "Sarah introduced me to the new project"
3. Create entry 3 (Oct 5): "Project discussion with John"
4. Entities: Sarah (3 entries), John (2 entries), Relationship: Sarah-John co-occurrence

**Steps:**
1. Navigate to Chat tab for October 5
2. Type: "How often did I meet with Sarah this week?"
3. Send message
4. Observe AI response

**Expected Results:**
- ✅ AI response indicates Sarah was mentioned 3 times this week
- ✅ Response may mention John as related entity
- ✅ Response demonstrates relationship awareness
- ✅ Accurate count based on entity data

**XcodeBuildMCP Commands:**
```swift
tap(x: chat_tab_x, y: chat_tab_y)
tap(x: message_field_x, y: message_field_y)
type_text(text: "How often did I meet with Sarah this week?")
tap(x: send_button_x, y: send_button_y)
screenshot()
```

---

### Test 3: Insight-Aware Chat Response
**Feature**: US-S15-002
**Objective**: Verify AI chat references generated insights in responses

**Setup:**
1. Ensure weekly insight exists: "You had 5 social meetings this week"
2. Ensure daily insight exists for Oct 5: "High energy on social activity days"
3. Navigate to Chat tab for October 5

**Steps:**
1. Type: "How has my social life been lately?"
2. Send message
3. Observe AI response

**Expected Results:**
- ✅ AI response references the weekly insight (5 social meetings)
- ✅ Response may reference daily insight (high energy pattern)
- ✅ Response uses phrases like "Based on your weekly pattern..." or "Your insights show..."
- ✅ Insight context enriches the response quality

**XcodeBuildMCP Commands:**
```swift
tap(x: message_field_x, y: message_field_y)
type_text(text: "How has my social life been lately?")
tap(x: send_button_x, y: send_button_y)
screenshot()
describe_ui() // Verify response contains insight reference
```

---

### Test 4: Multi-Date Entity Context
**Feature**: US-S15-001
**Objective**: Verify entity context spans multiple recent entries (not just current date)

**Setup:**
1. Create entries for Oct 1-5 with recurring entities (Sarah, Coffee Shop, Work)
2. Navigate to Chat tab for October 5

**Steps:**
1. Type: "What are the main topics I've been writing about?"
2. Send message
3. Observe AI response

**Expected Results:**
- ✅ AI response identifies recurring entities (Sarah, Coffee Shop, Work)
- ✅ Response demonstrates awareness of patterns across multiple days
- ✅ Entity ranking shows most frequent entities first
- ✅ Max 50 entities included in context

---

### Test 5: Empty State - No Entities or Insights
**Feature**: US-S15-001, US-S15-002
**Objective**: Verify chat functions correctly when no entities/insights exist

**Setup:**
1. Create a fresh entry with no entities extracted yet
2. No insights generated yet

**Steps:**
1. Navigate to Chat tab for new entry
2. Type: "What did I write today?"
3. Send message
4. Observe AI response

**Expected Results:**
- ✅ Chat works normally without entities/insights
- ✅ AI responds based on note content only (existing behavior)
- ✅ No errors or crashes
- ✅ Graceful handling of missing context data

---

### Test 6: Context Assembly Performance
**Feature**: US-S15-001, US-S15-002
**Objective**: Verify context assembly meets performance targets

**Method**: Code instrumentation or profiling

**Steps:**
1. Measure time to assemble entity context
2. Measure time to assemble insight context
3. Measure total context assembly time

**Expected Results:**
- ✅ Entity context assembly < 100ms
- ✅ Insight context assembly < 50ms
- ✅ Total context assembly < 150ms
- ✅ No blocking UI thread during assembly

**Validation Method:**
```swift
// Add logging in ChatContextService
let start = Date()
let context = await buildContext(for: date)
let duration = Date().timeIntervalSince(start)
print("Context assembly: \(duration * 1000)ms")
```

---

### Test 7: Entity Deduplication
**Feature**: US-S15-001
**Objective**: Verify duplicate entities are merged correctly

**Setup:**
1. Create entries where "Sarah" appears multiple times with varying confidence scores
2. Entry 1: "Sarah" (confidence: 0.95)
3. Entry 2: "Sarah" (confidence: 0.88)

**Steps:**
1. Navigate to Chat tab
2. Verify entity context assembly

**Expected Results:**
- ✅ "Sarah" appears only once in context
- ✅ Highest confidence score (0.95) is used
- ✅ All relationships merged
- ✅ No duplicate entity entries

---

### Test 8: Insight Relevance Filtering
**Feature**: US-S15-002
**Objective**: Verify only relevant insights are included in context

**Setup:**
1. Generate insights for different date ranges (daily, weekly, monthly)
2. Navigate to Chat tab for October 5

**Steps:**
1. Verify insight context for October 5
2. Type a date-specific question

**Expected Results:**
- ✅ Daily insights for Oct 5 included
- ✅ Weekly insights for week of Oct 5 included
- ✅ Irrelevant insights (e.g., from August) excluded
- ✅ Maximum 5 insights in context
- ✅ Most relevant insights prioritized

---

### Test 9: Regression - Existing Chat Functionality
**Feature**: General
**Objective**: Ensure knowledge graph context doesn't break existing chat

**Steps:**
1. Test basic chat without entities/insights
2. Test multi-turn conversation
3. Test chat with long messages
4. Test chat error handling (API failure)

**Expected Results:**
- ✅ All existing chat features work as before
- ✅ No performance degradation
- ✅ No UI glitches or crashes
- ✅ Error handling unchanged

---

## Test Execution Log

### Test Run 1: [Date/Time]

| Test Case | Status | Notes | Duration |
|-----------|--------|-------|----------|
| Test 1: Entity-Aware Chat | ⏳ PENDING | | |
| Test 2: Relationship-Aware Chat | ⏳ PENDING | | |
| Test 3: Insight-Aware Chat | ⏳ PENDING | | |
| Test 4: Multi-Date Entity Context | ⏳ PENDING | | |
| Test 5: Empty State | ⏳ PENDING | | |
| Test 6: Performance | ⏳ PENDING | | |
| Test 7: Entity Deduplication | ⏳ PENDING | | |
| Test 8: Insight Relevance | ⏳ PENDING | | |
| Test 9: Regression Test | ⏳ PENDING | | |

**Overall Status**: ⏳ NOT STARTED

---

## Performance Benchmarks

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| Entity context assembly | < 100ms | - | ⏳ |
| Insight context assembly | < 50ms | - | ⏳ |
| Total context assembly | < 150ms | - | ⏳ |
| Chat response time | < 3s | - | ⏳ |
| Memory usage increase | < 10MB | - | ⏳ |

---

## Known Issues

*None yet - to be updated during testing*

---

## Test Environment

**Device**: iPhone 16 Simulator
**iOS Version**: 18.4
**Xcode Version**: 16.x
**Build Configuration**: Debug
**API**: OpenRouter (gpt-4o-mini)

---

## Success Criteria

Sprint 15 testing is considered **PASSED** when:
- ✅ All 9 test cases pass
- ✅ Performance benchmarks met
- ✅ No critical bugs found
- ✅ No regressions in existing features
- ✅ Entity context demonstrates clear value in chat responses
- ✅ Insight context demonstrates clear value in chat responses

---

## Notes

- Entity extraction must complete before testing (background job from Sprint 13)
- Insights must be generated before testing (Sprint 14)
- Test with realistic journal data for best validation
- Consider testing with various LLM models if time permits
