# Sprint 16: Knowledge Graph Enhanced Context

**Sprint Period**: October 5, 2025
**Epic**: EPIC-6 - Knowledge Graph Generation & Querying (Continuation)
**Story Points**: 5 points (1 user story)
**Status**: ✅ COMPLETE (Code Implementation)

## Sprint Goal
Leverage knowledge graph relationships and insights to intelligently fetch and provide the most relevant full journal notes as context for AI chat, replacing raw entity/insight lists with rich, contextualized content.

**Strategic Value**: Transform KG data from passive metadata into active intelligence that finds and surfaces the most relevant past entries, enabling AI to give deeply personalized, context-aware responses.

---

## User Stories

### US-S16-001: Related Notes via Knowledge Graph (5 points)

**As a** user
**I want** the AI to automatically find and reference my most relevant past journal entries
**So that** conversations are enriched with meaningful context from my entire journal history

**Priority**: CRITICAL
**Status**: ✅ COMPLETE (Code Implementation)

**Problem Statement**:
- Current approach (Sprint 15) sends raw entity/insight lists to LLM - not helpful
- LLM needs full journal content, not metadata
- Knowledge graph contains relationship and insight data but not being used optimally
- AI responses lack depth because missing relevant historical context

**Solution Approach**:
Use knowledge graph to intelligently discover related entries:
1. From current date's entities → find relationships → get connected entities
2. From connected entities → find their source entries
3. From insights → extract related entry IDs
4. Rank entries by relevance (relationship strength, insight confidence, recency)
5. Fetch top 5 most relevant full entries
6. Send complete journal content to LLM as context

**Acceptance Criteria**:
- [x] When chatting about a date, system finds up to 5 most related past entries via KG
- [x] Relevance ranking combines: relationship type weights, insight confidence, temporal proximity
- [x] Full entry content (not truncated) is included in chat context
- [x] Context includes: entry date, full content, relevance reason (why it was selected)
- [x] Performance: Related notes discovery algorithm implemented (< 200ms target)
- [ ] Context quality: AI responses reference relevant past events accurately (requires manual testing)
- [x] UI shows which related notes are being used as context (ChatContextView with related entries section)

**Technical Requirements**:

**FR-S16-001: KG-Based Note Discovery**
- Input: Current date's entities and insights
- Process:
  1. Extract entity IDs from current date's entry
  2. Query relationships involving these entities
  3. Find entities connected via relationships (weight by type: Causal=5, Temporal=4, Emotional=3, Topical=2)
  4. Query insights related to current date
  5. Extract all related entry IDs from insights
  6. Combine entry IDs from relationships and insights
  7. Deduplicate and score by:
     - Relationship strength (sum of relationship type weights)
     - Insight confidence (max confidence score)
     - Recency (decay factor: 1.0 for last 7 days, 0.8 for last 30 days, 0.5 for older)
  8. Return top 5 highest-scored entries
- Output: Array of `(Entry, relevanceScore, reason)` tuples

**FR-S16-002: Enhanced Context Assembly**
- Replace entity/insight sections in `ChatContext.contextSummary`
- Add new section: "Related Journal Entries"
- For each related entry:
  ```
  --- Related Entry: [Date] (Relevance: High/Medium/Low) ---
  Reason: Connected via [relationship type] / Mentioned in [insight type]

  [Full entry content]
  ```
- Ensure total context < 4000 tokens (truncate oldest if needed)

**FR-S16-003: Context Transparency**
- In `ChatContextView`, show "Related Notes" section
- Display: Date, first 100 chars, relevance badge
- Tappable to view full entry
- Show relevance reason on tap

**Technical Tasks**:
- [x] Create `RelatedNotesService` with KG-based discovery algorithm
- [x] Implement relevance scoring (relationship + insight + recency)
- [x] Update `ChatContextService.fetchContext()` to use `RelatedNotesService`
- [x] Update `ChatContext.contextSummary` to format related entries
- [x] Remove entity/insight list formatting (already removed in Sprint 15)
- [ ] Add unit tests for relevance scoring algorithm (deferred)
- [ ] Add integration test: Chat with related notes from KG (requires test data)
- [x] Update `ChatContextView` to show related notes section
- [ ] Performance test: Discovery < 200ms with 100+ entries (deferred)

**Files to Create**:
- `KiokuPackage/Sources/KiokuFeature/Services/RelatedNotesService.swift`

**Files to Modify**:
- `KiokuPackage/Sources/KiokuFeature/Services/ChatContextService.swift`
- `KiokuPackage/Sources/KiokuFeature/Models/ChatContext.swift`
- `KiokuPackage/Sources/KiokuFeature/Views/Chat/ChatContextView.swift`

**Dependencies**:
- Sprint 13: Entity & Relationship models ✅
- Sprint 14: Insight model ✅
- Sprint 15: ChatContextService infrastructure ✅

**Definition of Done**:
- [x] Code compiles and app builds successfully
- [x] `RelatedNotesService` implemented with KG discovery algorithm
- [x] Relevance scoring algorithm implemented (manual testing pending)
- [x] Chat context includes top 5 related full entries
- [x] Context transparency: UI shows which notes are being used
- [ ] Performance validated: < 200ms discovery time (requires test data)
- [ ] Integration test: AI accurately references related past events (requires test data)
- [x] Test documentation updated ([sprint_16_integration_tests.md](../../03_testing/sprint_16_integration_tests.md))
- [x] Sprint planning document updated
- [x] All changes committed and pushed
- [ ] Branch merged to master (ready for merge)

---

## Technical Design

### Relevance Scoring Algorithm

```swift
func calculateRelevanceScore(
    entry: Entry,
    currentDate: Date,
    relationships: [Relationship],
    insights: [Insight]
) -> Double {
    var score = 0.0

    // 1. Relationship strength (0-10 points)
    let relationshipWeights: [RelationshipType: Double] = [
        .causal: 5.0,
        .temporal: 4.0,
        .emotional: 3.0,
        .topical: 2.0
    ]
    let relScore = relationships
        .filter { $0.relatedEntryIds.contains(entry.id) }
        .reduce(0.0) { $0 + (relationshipWeights[$1.type] ?? 0.0) }
    score += min(relScore, 10.0)

    // 2. Insight confidence (0-5 points)
    let insightScore = insights
        .filter { $0.relatedEntryIds.contains(entry.id) }
        .map { $0.confidence }
        .max() ?? 0.0
    score += insightScore * 5.0

    // 3. Recency factor (0.5-1.0 multiplier)
    let daysDiff = Calendar.current.dateComponents([.day], from: entry.date ?? entry.createdAt, to: currentDate).day ?? 0
    let recencyFactor: Double
    if daysDiff <= 7 {
        recencyFactor = 1.0
    } else if daysDiff <= 30 {
        recencyFactor = 0.8
    } else {
        recencyFactor = 0.5
    }
    score *= recencyFactor

    return score
}
```

### Context Format Example

```
=== USER'S JOURNAL CONTEXT ===
Below is the user's journal content. Please read and analyze it carefully along with the user's question before responding.

Journal Entry for Oct 5, 2025:

Today I had a meeting with Sarah about the new project...

--- Related Entries from Your Journal History ---

[Oct 1, 2025] (High Relevance - Connected via work project)
Sarah and I discussed the initial project scope...

[Sep 28, 2025] (Medium Relevance - Similar emotional theme)
Feeling anxious about upcoming deadlines...

[Sep 15, 2025] (Medium Relevance - Mentioned in weekly insight)
Team brainstorming session was productive...

--- Recent Entries (Past Week) ---
[Full content as before]

=== USER'S QUESTION ===
How is my work with Sarah progressing?

=== INSTRUCTIONS ===
[Same as Sprint 15]
```

---

## Testing Strategy

### Unit Tests
- Relevance scoring with various relationship types
- Recency factor calculation
- Entry deduplication logic
- Performance: scoring 100 entries < 50ms

### Integration Tests
- End-to-end: Date → KG discovery → Context assembly → LLM chat
- Verify AI references past events accurately
- Context quality: Related entries are actually relevant
- Edge cases: No relationships, no insights, duplicate entries

### Test Scenarios
1. **Scenario 1**: Entry with strong causal relationships
   - Expected: Related entries with causal links ranked highest
2. **Scenario 2**: Entry mentioned in high-confidence insight
   - Expected: Insight-related entries included in top 5
3. **Scenario 3**: Recent vs old entries with same relationship strength
   - Expected: Recent entries ranked higher
4. **Scenario 4**: Chat asks about person mentioned in past
   - Expected: AI response references correct past interactions

---

## Success Metrics

- **Context Quality**: AI accurately references past events in 90%+ of conversations
- **Performance**: Related notes discovery < 200ms
- **Relevance**: Top 5 notes are contextually relevant (manual validation)
- **User Value**: Users report AI responses feel more personalized and aware

---

## Sprint Retrospective

**Completion Date**: October 6, 2025
**Duration**: Implementation complete with model fixes
**Status**: ✅ COMPLETE - Build successful, service integrated

**What Went Well**:
- ✅ Fixed data model mismatch - corrected service to use actual EntityRelationship structure
- ✅ Clean architecture: RelatedNotesService properly traverses entity relationships
- ✅ Build successful - no compilation errors
- ✅ Service integration verified via logs - findRelatedEntries() called successfully
- ✅ Graceful handling of empty data - no crashes when no entries/entities/relationships exist
- ✅ UI components (RelatedEntryCard) ready with proper indigo theme
- ✅ Detailed logging for debugging KG discovery process

**What Could Be Improved**:
- ⚠️ Initial remote implementation had incorrect model assumptions (entityIds, relatedEntryIds properties)
- ⚠️ No test data in simulator - feature visible only when KG data exists
- ⚠️ Performance not validated with real data - need entries with relationships/insights
- ⚠️ No automated tests - validation requires manual testing with actual data

**Achievements**:
- ✅ Corrected RelatedNotesService to match EntityRelationship model (fromEntity/toEntity)
- ✅ Added Sendable conformance for concurrency safety
- ✅ Service correctly traverses outgoingRelationships and incomingRelationships
- ✅ Scoring algorithm accumulates relationship weights properly
- ✅ Foundation ready for KG-enhanced AI chat responses

**Technical Fixes Applied**:
- Fixed RelatedNotesService to use entity.outgoingRelationships/incomingRelationships
- Changed from non-existent entityIds/relatedEntryIds to actual fromEntity/toEntity
- Removed incorrect nonisolated wrapper in ChatContextService.fetchRelatedEntries
- Added Sendable to RelatedEntry struct

**Next Sprint Priorities**:
- Create test data: journal entries with entities, relationships, and insights
- Manual validation with actual KG data
- Performance benchmarking with 50+ entries
- User feedback on relevance quality
