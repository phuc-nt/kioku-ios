# Sprint 11 Planning: Full LLM Chat Integration

**Sprint Period**: October 1-15, 2025
**Epic**: EPIC-5 - Full LLM Chat Integration (Phase 2)
**Story Points**: 13 points
**Status**: 🚧 In Progress

**Related Documents**:
- Requirements: `docs/00_context/01_business_requirement_2.md` (EPIC-5)
- Architecture: `docs/00_context/03_architecture_design_2.md`
- Previous Sprint: `docs/01_sprints/sprint_10_planning.md`

---

## Sprint Goals

Transform the basic AI chat from Sprint 10 into a full-featured conversational interface with:

1. ✅ **Streaming Responses** - Real-time token-by-token responses using Gemini 2.0 Flash
2. ✅ **Conversation Threading** - Multiple independent chat sessions with sidebar
3. ✅ **Enhanced Context Discovery** - Parallel processing (entity similarity + graph traversal)
4. ✅ **Conversation Knowledge Graph** - Convert conversations to KG, remove AIAnalysis model

---

## User Stories & Tasks

### US-S11-001: Streaming Chat with Gemini 2.0 Flash (5 points)

**As a user**, I want AI responses to appear in real-time so I can start reading while the AI is still generating.

**Requirements** (FR-501, FR-502, FR-503):
- OpenRouter API integration với `google/gemini-2.0-flash-exp:free`
- Server-Sent Events (SSE) for token streaming
- Stop button to interrupt generation mid-response
- Regenerate button to retry last response
- Message persistence with SwiftData

**Acceptance Criteria**:
- [ ] Streaming responses appear token-by-token với <100ms latency
- [ ] Stop button halts generation và preserves partial response
- [ ] Regenerate produces new response với same context
- [ ] Messages persist across app restarts
- [ ] Network errors show user-friendly messages

**Technical Tasks**:
- [ ] Create `StreamingService.swift` với SSE handling
- [ ] Update `ChatMessage` model với streaming state
- [ ] Implement stop/regenerate UI controls
- [ ] Add token accumulation logic
- [ ] Handle stream interruptions gracefully

**Testing**:
- [ ] TC-S11-001: Verify streaming token display
- [ ] TC-S11-002: Test stop button during generation
- [ ] TC-S11-003: Test regenerate functionality
- [ ] TC-S11-004: Verify message persistence

---

### US-S11-002: Conversation Threading (3 points)

**As a user**, I want to organize my chats into separate conversations so I can keep different topics organized.

**Requirements** (FR-504, FR-505, FR-506):
- Multiple conversation support với sidebar
- Auto-generate conversation titles using AI
- Sidebar auto-hides when conversation selected
- Optional date association for conversations

**Acceptance Criteria**:
- [ ] Users can create unlimited conversations
- [ ] Sidebar shows most recent 50 conversations
- [ ] Conversation switching takes <500ms
- [ ] Auto-titles reflect conversation topics (>70% accuracy)
- [ ] Sidebar hidden by default when entering chat

**Technical Tasks**:
- [ ] Create `Conversation` SwiftData model
- [ ] Build sidebar UI với conversation list
- [ ] Implement auto-hide sidebar behavior
- [ ] Add AI title generation endpoint
- [ ] Add date association linking

**Testing**:
- [ ] TC-S11-005: Create multiple conversations
- [ ] TC-S11-006: Test sidebar show/hide
- [ ] TC-S11-007: Verify conversation switching
- [ ] TC-S11-008: Test auto-title generation

---

### US-S11-003: Enhanced Context Discovery (3 points)

**As a user**, I want AI to find the most relevant notes using both similarity and relationships so conversations reference my best context.

**Requirements** (FR-507, FR-508, FR-509):
- Parallel processing: Thread 1 (entity similarity → 5 notes) + Thread 2 (KG traversal → 10 notes)
- Merge results với ranking (overlapping notes scored higher)
- Context transparency: display "X related notes"
- Smart routing: KG → Similarity → Date → Recent → Empty

**Acceptance Criteria**:
- [ ] Context aggregation completes in <3s
- [ ] Parallel threads execute simultaneously
- [ ] Merged results ranked by relevance score
- [ ] Context never exceeds 15 notes
- [ ] Users can expand to see note previews

**Technical Tasks**:
- [ ] Create `ContextDiscoveryService.swift` với parallel processing
- [ ] Implement entity similarity algorithm
- [ ] Implement KG traversal query
- [ ] Add result merging và ranking logic
- [ ] Update chat UI với context display

**Testing**:
- [ ] TC-S11-009: Verify parallel execution <3s
- [ ] TC-S11-010: Test context ranking accuracy
- [ ] TC-S11-011: Verify 15-note limit enforced
- [ ] TC-S11-012: Test fallback chain

---

### US-S11-004: Conversation to Knowledge Graph (2 points)

**As a user**, I want to convert conversations into knowledge graphs so insights from chats become part of my personal knowledge network.

**Requirements** (FR-510, FR-511):
- "Convert to KG" button in conversation view
- Extract entities from both user messages AND AI responses
- Create `ConversationKG` model (replaces AIAnalysis)
- Cross-link conversation entities với note entities

**Acceptance Criteria**:
- [ ] Button visible in conversation detail header
- [ ] Extraction processes all messages
- [ ] Entities from conversation appear in graph explain
- [ ] ConversationKG model stores all metadata
- [ ] No references to deprecated AIAnalysis model

**Technical Tasks**:
- [ ] Create `ConversationKG` SwiftData model
- [ ] Remove `AIAnalysis` model và migrations
- [ ] Add entity extraction for conversations
- [ ] Implement cross-linking logic
- [ ] Add "Convert to KG" button

**Testing**:
- [ ] TC-S11-013: Test conversation KG conversion
- [ ] TC-S11-014: Verify entity extraction from messages
- [ ] TC-S11-015: Test cross-linking với note entities
- [ ] TC-S11-016: Confirm AIAnalysis removed

---

## Architecture Changes

### New Models

```swift
@Model
class Conversation {
    var id: UUID
    var title: String
    var createdAt: Date
    var updatedAt: Date
    var messages: [ChatMessage]
    var hasKnowledgeGraph: Bool
    var associatedDate: Date?
    var contextNoteIds: [String]
}

@Model
class ConversationKG {
    var conversationId: UUID
    var entities: [KnowledgeEntity]
    var relationships: [KnowledgeRelation]
    var generatedAt: Date
    var messageIds: [UUID]
}
```

### New Services

- **StreamingService**: SSE handling for Gemini 2.0 Flash
- **ContextDiscoveryService**: Parallel context aggregation
- **ConversationService**: Conversation CRUD và title generation

### Removed Models

- ~~AIAnalysis~~ → Replaced by ConversationKG

---

## Technical Risks

| Risk | Impact | Mitigation |
|------|--------|------------|
| SSE connection stability | High | Implement reconnection logic với exponential backoff |
| Parallel context timeout | Medium | Set 3s timeout với fallback to single-thread |
| Token overflow với 15 notes | Medium | Dynamic context pruning based on token count |
| Migration from AIAnalysis | High | Create data migration script, test thoroughly |

---

## Definition of Done

- [ ] All acceptance criteria met
- [ ] Code compiles without warnings
- [ ] UI automation tests pass (XcodeBuildMCP)
- [ ] Test scenarios documented in `docs/03_testing/sprint_11_acceptance_tests.md`
- [ ] Performance benchmarks met (<2s first token, <3s context discovery)
- [ ] No memory leaks or crashes during stress testing
- [ ] Code reviewed và follows Swift style guide
- [ ] ADRs created for significant decisions
- [ ] Sprint documentation updated

---

## Success Metrics

**Performance**:
- First token latency: <2s
- Context discovery: <3s
- Conversation switching: <500ms

**Quality**:
- Streaming stability: 95%+ successful streams
- Context relevance: 80%+ relevant notes
- Auto-title accuracy: 70%+ user satisfaction

**Adoption**:
- 60%+ users try conversation threading within first week
- Average 3+ conversations created per active user

---

## Dependencies

- OpenRouter API quota: 50 requests/day (free tier)
- iOS 18+ for SwiftData advanced queries
- Gemini 2.0 Flash model availability

---

## Testing Strategy

**Unit Tests**:
- StreamingService: token accumulation, stop/regenerate
- ContextDiscoveryService: parallel execution, ranking
- ConversationService: CRUD operations

**Integration Tests** (XcodeBuildMCP):
- End-to-end streaming chat flow
- Conversation creation và switching
- Context discovery với real data
- Conversation KG conversion

**Performance Tests**:
- Stream latency monitoring
- Context discovery timeout validation
- Memory usage during long conversations

---

**Sprint Start**: October 1, 2025
**Sprint Review**: October 15, 2025
**Retrospective**: TBD
