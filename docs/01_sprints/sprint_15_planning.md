# Sprint 15: Knowledge Graph Context Integration

**Sprint Period**: October 5, 2025
**Epic**: EPIC-6 - Knowledge Graph Generation & Querying
**Story Points**: 8 points (2 user stories)
**Status**: 🚧 IN PROGRESS

## Sprint Goal
Integrate extracted knowledge graph entities, relationships, and generated insights into AI chat context to enable intelligent, personalized conversations that leverage the user's journal history.

## User Stories

### US-S15-001: Entity & Relationship Context in Chat (5 points)
**As a** user
**I want** the AI chat to be aware of entities and relationships from my journal entries
**So that** conversations can reference people, places, events, and their connections intelligently

**Priority**: CRITICAL
**Status**: 📋 TODO

**Acceptance Criteria:**
- [ ] When chatting about a specific date, AI has access to all entities extracted from that date's entry
- [ ] Entity context includes: type, name, confidence score, related entities
- [ ] AI can answer questions like "Who did I meet with Sarah?" using relationship data
- [ ] Context window includes up to 50 most relevant entities from recent entries
- [ ] Entity context is formatted clearly for LLM understanding
- [ ] Performance: Context assembly < 100ms

**Technical Tasks:**
- [ ] Extend `ChatContextService` to query entities from date context
- [ ] Add entity/relationship formatting for LLM context
- [ ] Implement entity relevance ranking (by confidence, recency, relationships)
- [ ] Add entity deduplication logic
- [ ] Test entity context with various date ranges
- [ ] Update `ChatService` to include entity context in API calls

**Files to Modify:**
- `KiokuPackage/Sources/KiokuFeature/Services/ChatContextService.swift`
- `KiokuPackage/Sources/KiokuFeature/Services/ChatService.swift`

**Dependencies:**
- Sprint 13: Entity & Relationship models
- Sprint 14: DateContextService

---

### US-S15-002: Insight-Aware Chat Responses (3 points)
**As a** user
**I want** AI to reference generated insights during conversations
**So that** chat responses can leverage patterns discovered from my journal history

**Priority**: HIGH
**Status**: 📋 TODO

**Acceptance Criteria:**
- [ ] AI can reference daily/weekly insights in responses
- [ ] When discussing a topic, AI mentions relevant patterns
- [ ] Insights from Sprint 14 are formatted and included in chat context
- [ ] Maximum 5 most relevant insights per conversation
- [ ] Insight context includes: type, date range, key findings
- [ ] Performance: Insight query < 50ms

**Technical Tasks:**
- [ ] Query `InsightsService` from `ChatContextService`
- [ ] Format insights as structured context bullets
- [ ] Implement insight relevance matching (by date, entities, topics)
- [ ] Add insight caching for performance
- [ ] Test insight context with various conversation topics
- [ ] Handle cases where no insights exist

**Files to Modify:**
- `KiokuPackage/Sources/KiokuFeature/Services/ChatContextService.swift`
- `KiokuPackage/Sources/KiokuFeature/Services/InsightsService.swift`

**Dependencies:**
- Sprint 14: InsightsService and Insight model

---

## Sprint Architecture

### Context Assembly Flow
```
User sends chat message
    ↓
ChatService.sendMessage()
    ↓
ChatContextService.buildContext()
    ├─→ Get current note (existing)
    ├─→ Get entities & relationships (NEW - US-S15-001)
    │   ├─→ Query entities from selected date
    │   ├─→ Query related entities via relationships
    │   ├─→ Rank by relevance (confidence, recency)
    │   └─→ Format for LLM
    └─→ Get relevant insights (NEW - US-S15-002)
        ├─→ Query daily/weekly insights
        ├─→ Match by date range and topics
        └─→ Format as context bullets
    ↓
Combined context → OpenRouter API
    ↓
AI response with entity & insight awareness
```

### Context Format Example
```markdown
## Current Entry
Date: October 5, 2025
Content: Had lunch with Sarah at the new cafe downtown...

## Entities & Relationships
- **People**: Sarah (confidence: 0.95)
  - Relationship: Met with John (3 times this month)
  - Relationship: Works at TechCorp
- **Places**: Downtown Cafe (confidence: 0.88)
  - First visit
- **Events**: Team Meeting (confidence: 0.82)

## Insights
- **Weekly Pattern**: You've had 5 social meetings this week, 3 involving Sarah
- **Daily Insight**: High energy and positive mood on days with social activities
```

---

## Testing Strategy

### Unit Tests
- `ChatContextServiceTests`: Entity context assembly
- `ChatContextServiceTests`: Insight context formatting
- Entity ranking and deduplication logic
- Insight relevance matching

### Integration Tests (XcodeBuildMCP)
- Test 1: Chat with entity-aware responses
- Test 2: Chat references insights correctly
- Test 3: Entity context from multiple dates
- Test 4: Insight context from weekly patterns
- Test 5: Performance validation (context < 150ms total)

### Test Documentation
- `docs/03_testing/sprint_15_integration_tests.md`

---

## Quality Gates

**Must Pass Before Completion:**
- ✅ All unit tests pass
- ✅ All XcodeBuildMCP integration tests pass
- ✅ Build succeeds with no warnings
- ✅ Chat responses demonstrate entity awareness
- ✅ Chat responses reference insights when relevant
- ✅ Performance targets met (context assembly < 150ms)
- ✅ No regressions in existing chat functionality

---

## Sprint Progress

### Session 1: Setup & US-S15-001 Implementation
**Status**: 📋 TODO
- [ ] Create sprint branch ✅
- [ ] Create sprint planning document ✅
- [ ] Create test document ✅
- [ ] Implement entity context in ChatContextService
- [ ] Test entity context integration
- [ ] Commit: "feat(sprint-15): implement entity & relationship context in chat"

### Session 2: US-S15-002 Implementation
**Status**: 📋 TODO
- [ ] Implement insight context in ChatContextService
- [ ] Test insight context integration
- [ ] Comprehensive integration testing
- [ ] Commit: "feat(sprint-15): implement insight-aware chat responses"

### Session 3: Testing & Finalization
**Status**: 📋 TODO
- [ ] Run full XcodeBuildMCP test suite
- [ ] Update sprint planning document
- [ ] Update product backlog
- [ ] Create final summary document
- [ ] Final commit and push
- [ ] Merge to master

---

## Key Technical Decisions

### Entity Context Design
- **Relevance Ranking**: Entities ranked by: (1) Confidence score, (2) Recency, (3) Relationship count
- **Deduplication**: Same entity from multiple dates merged with highest confidence
- **Limit**: Max 50 entities to keep context manageable
- **Format**: Structured markdown for LLM clarity

### Insight Context Design
- **Relevance Matching**: Match insights by date range overlap and entity intersection
- **Limit**: Max 5 insights to avoid context bloat
- **Priority**: Daily insights > Weekly insights for date-specific chats
- **Format**: Bullet points with type, date range, and key findings

### Performance Optimization
- Entity queries use indexes on `entryDate`
- Insight queries cached for 5 minutes
- Context assembly runs concurrently (entities || insights)
- Total context assembly budget: < 150ms

---

## Definition of Done

- [ ] US-S15-001 acceptance criteria met
- [ ] US-S15-002 acceptance criteria met
- [ ] All quality gates passed
- [ ] Documentation updated
- [ ] Tests documented and passing
- [ ] Code committed and pushed
- [ ] Sprint merged to master

---

## References
- Sprint 13: Entity Extraction & Relationship Mapping
- Sprint 14: AI Insights Generation
- ADR-013: Knowledge Graph Schema
- ADR-014: AI Insights Architecture
