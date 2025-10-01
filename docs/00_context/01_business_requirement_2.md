# Phase 2 Requirements Document
## AI-Powered Chat & Knowledge Graph Integration

**Document Version:** 1.0  
**Created:** October 1, 2025  
**Project:** Kioku - AI Journal App  
**Phase:** 2 (Post-Sprint 10)  
**Related Documents:** 
- ← Context: `docs/00_context/01_business_requirement.md`
- ← Feature Inventory: `docs/00_context/02_product_backlog.md`  
- → Technical Details: `docs/02_adrs/adr_007.md`, `adr_008.md`, `adr_009.md`

***

## 1. Executive Summary

### 1.1 Phase 2 Goals

Transform Kioku from a basic journaling app with simple AI suggestions into an intelligent personal memory system with:

1. **Real-time AI conversations** với streaming responses from Gemini 2.5 Flash
2. **Conversation threading** for managing multiple independent chat sessions
3. **Knowledge graph infrastructure** extracting entities và relationships across notes
4. **Hybrid context discovery** combining date-based và content-based note retrieval

### 1.2 Success Metrics

- **Chat Performance**: <2s first token latency, smooth streaming
- **Context Relevance**: 80%+ suggested related notes deemed relevant
- **KG Generation**: <15s per note, <5min for 50 notes batch
- **User Adoption**: 60%+ active users try chat within first week

***

## 2. Feature Requirements

### EPIC-5: Full LLM Chat Integration (Sprint 11)

#### 2.1 Streaming Chat with Gemini 2.5 Flash

**FR-501: OpenRouter Streaming Integration**

**Requirements:**
- Use OpenRouter API với fixed model: `google/gemini-2.0-flash-exp:free`
- Implement Server-Sent Events (SSE) for token-by-token streaming
- Process streaming tokens và update UI in real-time
- Handle stream interruptions với partial response preservation

**Acceptance Criteria:**
- ✅ Streaming responses appear token-by-token với <100ms latency
- ✅ Stop button immediately halts generation và preserves partial response
- ✅ Network errors show clear user-friendly messages
- ✅ Chat history persists across app restarts

***

**FR-502: Chat UI Implementation**

**Requirements:**
- Chat bubble interface với user/AI message differentiation
- Auto-scroll to bottom as new tokens arrive during streaming
- "Stop Generation" button to interrupt streaming mid-response
- "Regenerate" button to retry last AI response if unsatisfactory
- Visual loading indicators during API calls và streaming

**Acceptance Criteria:**
- ✅ Messages display with clear visual distinction (user vs AI)
- ✅ Auto-scroll smooth and doesn't interrupt user reading
- ✅ Stop button visible and functional during streaming only
- ✅ Regenerate produces new response với same context

***

**FR-503: Message Persistence**

**Requirements:**
- All messages stored in SwiftData với timestamps
- Store context metadata: which notes were used for each response
- Support conversation export for backup/sharing
- Maintain message order và conversation integrity

**Acceptance Criteria:**
- ✅ Messages persist across app restarts và device reboots
- ✅ Context metadata retrievable for transparency
- ✅ Export function produces readable format (JSON or Markdown)

***

#### 2.2 Conversation Threading

**FR-504: Multiple Conversation Management**

**Requirements:**
- Auto-create new conversation on first message in chat tab
- Display conversation list in sidebar với titles
- AI auto-generates descriptive titles from conversation content
- Users can manually edit conversation titles
- Soft delete conversations với confirmation dialog

**Acceptance Criteria:**
- ✅ Users can create unlimited conversations
- ✅ Sidebar shows most recent 50 conversations với scroll
- ✅ Conversation switching takes <500ms
- ✅ Auto-titles accurately reflect conversation topics (>70% user satisfaction)

***

**FR-505: Sidebar UI/UX**

**Requirements:**
- Single chat interface với collapsible history sidebar
- **Sidebar auto-hides** when conversation selected
- Swipe gesture to show/hide sidebar on mobile
- Active conversation highlighted in sidebar
- Empty state message when no conversations exist

**Acceptance Criteria:**
- ✅ Sidebar hidden by default when entering chat
- ✅ Swipe right shows sidebar, tap outside hides it
- ✅ Visual state clearly indicates active conversation
- ✅ Empty state provides helpful guidance

***

**FR-506: Date Association**

**Requirements:**
- Conversations can optionally be linked to calendar dates
- Access conversation from date selection in calendar view
- Single conversation can reference multiple dates
- Date linking optional, not required for all conversations

**Acceptance Criteria:**
- ✅ Date-linked conversations accessible from calendar
- ✅ Conversation can be associated with date after creation
- ✅ Date association doesn't restrict conversation topic

***

#### 2.3 Enhanced Context Discovery

**FR-507: Hybrid Context Aggregation**

**Requirements:**
- **Parallel processing approach**:
  - Thread 1: Entity similarity analysis → 5 candidate notes
  - Thread 2: Knowledge graph traversal → 10 connected notes
  - Merge: Union với ranking (overlapping notes scored higher)
- **Context priority**: Current Note → KG Related → Historical by Date → Recent
- **Context size limit**: Maximum 15 notes per chat context

**Acceptance Criteria:**
- ✅ Context aggregation completes in <3s
- ✅ Parallel threads execute simultaneously without blocking
- ✅ Merged results ranked by relevance score
- ✅ Context never exceeds 15 notes to avoid token overflow

***

**FR-508: Context Transparency**

**Requirements:**
- Display "X related notes" in chat UI (e.g., "3 related notes")
- Tap to expand: reveal note titles và preview text
- Link to "Graph Explain" screen for detailed relationships
- Show which notes AI used as context for specific response

**Acceptance Criteria:**
- ✅ Related notes count accurate và clickable
- ✅ Preview text shows first 100 characters of note
- ✅ Graph explain accessible with 2 taps from chat
- ✅ Users understand which data informed AI response

***

**FR-509: Smart Context Routing**

**Requirements:**
- **With KG**: Use graph traversal when current note has knowledge graph
- **Without KG**: Fall back to entity similarity và date-based context
- **Fallback chain**: KG → Similarity → Date → Recent → Empty context warning
- Graceful degradation when no context available

**Acceptance Criteria:**
- ✅ System correctly detects if note has KG data
- ✅ Fallback chain executes in order without errors
- ✅ Empty context shows informative message to user
- ✅ Context quality maintained across different routing paths

***

#### 2.4 Convert Conversation to Knowledge Graph

**FR-510: Conversation Analysis**

**Requirements:**
- "Convert to KG" button in conversation detail view
- Extract entities từ **both user messages AND AI responses**
- Identify relationships: temporal, causal, emotional, topical
- Link conversation entities to existing note entities when matching

**Acceptance Criteria:**
- ✅ Button visible in conversation detail header
- ✅ Extraction processes all messages in conversation
- ✅ Entities from conversation appear in graph explain view
- ✅ Linked entities show connections between conversation và notes

***

**FR-511: Conversation KG Model**

**Requirements:**
- Separate model: `ConversationKG` distinct from note-based KG
- **Remove `AIAnalysis` model** entirely (replaced by ConversationKG)
- Cross-link conversation entities với note entities
- Store: conversation ID, message IDs, extraction timestamp

**Acceptance Criteria:**
- ✅ ConversationKG model stores all required metadata
- ✅ No references to deprecated AIAnalysis model in codebase
- ✅ Cross-links queryable from both conversation và note sides
- ✅ Graph explain displays conversation entities

***

### EPIC-6: Knowledge Graph Generation & Querying (Sprint 12)

#### 2.5 Entity Extraction from Notes

**FR-601: Entity Recognition**

**Requirements:**
- **Entity types**: People, Places, Events, Emotions, Topics/Themes
- AI processing using Gemini 2.5 Flash với structured output
- Confidence score (0.0-1.0) for each extracted entity
- Deduplication: merge similar entities (e.g., "Mom" và "Mother")

**Acceptance Criteria:**
- ✅ All 5 entity types extracted from test notes
- ✅ Confidence scores reflect extraction quality
- ✅ Similar entities automatically merged với user confirmation
- ✅ Entity accuracy >80% on validation dataset

***

**FR-602: Single Note Conversion**

**Requirements:**
- "Convert to Knowledge Graph" button in note detail view
- Progress spinner during API call (15s avg)
- Success feedback: "✓ Knowledge graph generated"
- Error handling với retry option on failure

**Acceptance Criteria:**
- ✅ Button placement intuitive and discoverable
- ✅ Processing completes in <15s for typical note
- ✅ Success message clear and reassuring
- ✅ Retry mechanism works after network failures

***

**FR-603: Batch Conversion**

**Requirements:**
- **Trigger**: When clicking convert on note with unconverted notes present
- **Modal choice**: "Convert this note only" vs "Convert all unconverted notes"
- Background processing với progress tracking
- Cancel option to stop batch operation
- Results summary: X converted, Y failed, Z skipped

**Acceptance Criteria:**
- ✅ Modal appears only when unconverted notes exist
- ✅ Batch processes all selected notes in background
- ✅ Progress indicator updates in real-time
- ✅ Cancel stops processing cleanly without data corruption
- ✅ Summary accurate and informative

***

**FR-604: Re-Conversion**

**Requirements:**
- User clicks "Re-convert" after editing note content
- Full rebuild: replace existing KG data với fresh analysis
- Confirmation warning that existing relationships may change
- Version tracking: store KG generation timestamp

**Acceptance Criteria:**
- ✅ Re-convert button visible only for notes with existing KG
- ✅ Confirmation dialog prevents accidental re-conversion
- ✅ Existing KG data fully replaced, not merged
- ✅ Timestamp updated to reflect latest generation

***

#### 2.6 Relationship Mapping

**FR-605: Relationship Types**

**Requirements:**
- **Temporal**: "happened before", "happened after", "same time as"
- **Causal**: "caused", "led to", "resulted from"
- **Emotional**: "feels similar to", "contrasts with", "reminds me of"
- **Topical**: "related theme", "same topic", "subtopic of"

**Acceptance Criteria:**
- ✅ All 4 relationship types extracted from notes
- ✅ Relationships accurately reflect note content
- ✅ Relationship types distinguishable in UI

***

**FR-606: Relationship Discovery**

**Requirements:**
- AI identifies relationships between entities in single note
- Find relationships between entities across different notes
- Strength scoring (0.0-1.0) for each relationship
- Evidence capture: store text excerpt supporting relationship

**Acceptance Criteria:**
- ✅ Intra-note relationships discovered during entity extraction
- ✅ Cross-note relationships found during graph building
- ✅ Strength scores reflect relationship confidence
- ✅ Evidence text visible in graph explain view

***

**FR-607: Graph Storage**

**Requirements:**
- Normalized SwiftData models: `KnowledgeEntity` và `KnowledgeRelation`
- Bi-directional queryability from either entity
- Metadata: source note/conversation ID, creation timestamp, confidence
- Efficient queries for graph traversal operations

**Acceptance Criteria:**
- ✅ Models support all required relationships
- ✅ Queries execute in <500ms for 1000+ entities
- ✅ Bi-directional navigation works correctly
- ✅ Metadata complete và accurate

***

#### 2.7 Graph Explain Screen

**FR-608: Access Points**

**Requirements:**
- **From chat**: Tap "3 related notes" → Navigate to graph explain
- **From note detail**: "View Knowledge Graph" button
- **Deep link support**: Accept note ID parameter for direct navigation

**Acceptance Criteria:**
- ✅ All 3 access points functional
- ✅ Deep linking works from external sources
- ✅ Navigation preserves context for back button
- ✅ Screen loads in <1s

***

**FR-609: Content Display**

**Requirements:**
- **Current note**: Highlighted as central focus
- **Connected notes**: List all notes linked via knowledge graph
- **Entity display**: Show entities extracted from current note
- **Relationship details**: "Related by: Person X, Event Y"
- **Path explanation**: "Connected via: Mom → Birthday Event → Celebration Theme"

**Acceptance Criteria:**
- ✅ Current note visually distinguished from others
- ✅ Connected notes list complete và accurate
- ✅ Entity display clear and organized
- ✅ Path explanations help users understand connections

***

**FR-610: Navigation**

**Requirements:**
- Tap note title to navigate to that note detail
- Tap entity to see all notes containing it
- Breadcrumbs show navigation path for deep exploration
- Back navigation preserves previous context

**Acceptance Criteria:**
- ✅ All interactive elements respond within 200ms
- ✅ Navigation preserves user's place in graph
- ✅ Breadcrumbs accurate and helpful
- ✅ Back button returns to correct previous screen