# Sprint 13 Planning: Knowledge Graph Integration

**Sprint Period**: October 3-17, 2025
**Epic**: EPIC-6 - Knowledge Graph Generation & Querying
**Story Points**: 12 points (4/4 stories)
**Status**: 🚧 **IN PLANNING**

**Related Documents**:
- Previous Sprint: [`docs/01_sprints/sprint_12_planning.md`](sprint_12_planning.md)
- Architecture: [`docs/00_context/03_architecture_design.md`](../00_context/03_architecture_design.md)
- Product Backlog: [`docs/00_context/02_product_backlog.md`](../00_context/02_product_backlog.md)

---

## Sprint Goals

Build foundational knowledge graph capabilities to automatically extract entities and relationships from journal entries, enabling richer AI context and insights:

1. 🎯 **Entity Extraction** - Extract People, Places, Events, Emotions, Topics from notes
2. 🔗 **Relationship Mapping** - Discover connections between entities across notes
3. 📊 **Graph Visualization** - Interactive UI to explore knowledge graph
4. 💬 **Chat Integration** - Convert conversations into knowledge graph entities

**Strategic Importance**: Knowledge graphs transform scattered journal entries into structured, queryable knowledge, enabling advanced AI insights and pattern discovery.

---

## User Stories & Tasks

### US-S13-001: Entity Extraction from Notes (3 points)

**As a user**, I want my journal entries to be automatically analyzed for key entities so I can discover patterns and connections across my notes.

**Problem Statement**:
- Journal entries contain rich information (people, places, events) but are unstructured
- No way to automatically identify recurring themes or entities
- Cannot easily find all mentions of a person, place, or topic
- AI lacks structured knowledge for deeper insights

**Requirements** (FR-701, FR-702, FR-703):
- Extract 5 entity types from journal text:
  - **People**: Names, relationships (friend, family, colleague)
  - **Places**: Locations, cities, venues
  - **Events**: Occurrences, milestones, activities
  - **Emotions**: Mood states, feelings, emotional themes
  - **Topics**: Subjects, interests, categories
- Confidence scoring (0.0-1.0) for each extracted entity
- Deduplication: Merge similar entities ("Mom" = "Mother")
- Single note processing: Extract on save/edit
- Batch processing: Analyze all existing notes
- Store entities in SwiftData with relationships to source notes

**Acceptance Criteria**:
- [ ] EntityExtractionService extracts 5 entity types from text
- [ ] Each entity has: type, value, confidence score (0.0-1.0)
- [ ] Deduplication merges similar entities (case-insensitive, alias matching)
- [ ] Single note: Extract entities on save/update
- [ ] Batch mode: "Analyze All Notes" button in Settings
- [ ] Entities stored in SwiftData with @Model class
- [ ] Entity → Entry relationship (many-to-many)
- [ ] UI shows extraction progress (loading indicator)
- [ ] Minimum confidence threshold: 0.5 (configurable)
- [ ] Test with 10+ diverse journal entries

**Technical Tasks**:
- [ ] Create Entity @Model: type, value, confidence, aliases
- [ ] Create EntityExtractionService with OpenRouter API
- [ ] Design prompt for entity extraction (JSON output)
- [ ] Implement deduplication algorithm
- [ ] Add entity extraction to Entry save workflow
- [ ] Create batch processing UI in Settings
- [ ] Add progress tracking for batch operations
- [ ] Write unit tests for extraction and deduplication
- [ ] Test with edge cases (empty, long, multilingual text)

**UI/UX Notes**:
- Extraction happens in background (non-blocking)
- Progress indicator for batch processing
- Settings option to enable/disable auto-extraction
- Entity count badge on entries

**API Integration**:
```swift
// Prompt design
"""
Extract entities from this journal entry. Return JSON:
{
  "people": [{"name": "John", "relationship": "friend", "confidence": 0.9}],
  "places": [{"location": "Paris", "type": "city", "confidence": 0.95}],
  "events": [{"name": "Birthday party", "date": "2025-01-15", "confidence": 0.8}],
  "emotions": [{"emotion": "happy", "intensity": "high", "confidence": 0.85}],
  "topics": [{"topic": "travel", "confidence": 0.9}]
}

Text: {journal_entry}
"""
```

**Data Model**:
```swift
@Model
class Entity {
    var type: EntityType // people, places, events, emotions, topics
    var value: String    // Entity name/value
    var confidence: Double // 0.0-1.0
    var aliases: [String] // Alternative names
    var metadata: String?  // JSON with extra info
    var createdAt: Date

    @Relationship(inverse: \Entry.entities)
    var entries: [Entry]
}

enum EntityType: String, Codable {
    case people, places, events, emotions, topics
}
```

**Testing Focus**:
- Extraction accuracy (precision/recall)
- Deduplication effectiveness
- Batch processing performance (100+ entries)
- API error handling

---

### US-S13-002: Relationship Mapping (4 points)

**As a user**, I want to see how entities are connected across my journal entries so I can understand patterns and relationships in my life.

**Problem Statement**:
- Entities exist in isolation, no connections visible
- Cannot discover how people, events, emotions relate
- Missing temporal patterns (what happened when?)
- AI cannot explain causal chains or emotional journeys

**Requirements** (FR-704, FR-705, FR-706):
- Detect 4 relationship types:
  - **Temporal**: Time-based connections (A happened before/after B)
  - **Causal**: Cause-effect relationships (A led to B)
  - **Emotional**: Emotion-entity associations (Person → Happy)
  - **Topical**: Shared topic connections (Event + Place share topic)
- Cross-note discovery: Find relationships across all entries
- Evidence capture: Store text excerpts supporting each relationship
- Confidence scoring for relationships (0.0-1.0)
- Bidirectional relationships with types

**Acceptance Criteria**:
- [ ] RelationshipService discovers 4 relationship types
- [ ] Each relationship has: fromEntity, toEntity, type, confidence, evidence
- [ ] Evidence includes text excerpt and source entry reference
- [ ] Temporal relationships inferred from dates and temporal phrases
- [ ] Causal relationships detected from causal language ("because", "led to")
- [ ] Emotional relationships link emotions to people/events/places
- [ ] Topical relationships cluster entities by shared topics
- [ ] Relationships stored in SwiftData @Model
- [ ] Batch analysis: "Build Knowledge Graph" in Settings
- [ ] Performance: Process 100 entries in <30 seconds
- [ ] Minimum confidence: 0.6 for relationships

**Technical Tasks**:
- [ ] Create Relationship @Model: from, to, type, confidence, evidence
- [ ] Implement RelationshipService with LLM analysis
- [ ] Design prompts for relationship discovery
- [ ] Build temporal analyzer (date/time parsing)
- [ ] Build causal analyzer (linguistic patterns)
- [ ] Build emotional analyzer (sentiment + entity linking)
- [ ] Build topical analyzer (topic clustering)
- [ ] Create batch processing pipeline
- [ ] Add relationship queries (find all connections for entity)
- [ ] Write tests for each relationship type

**UI/UX Notes**:
- "Build Graph" button shows progress dialog
- Relationship types color-coded in visualization
- Evidence popover on tap

**Relationship Detection Examples**:
```swift
// Temporal
"I met Sarah on Monday. On Tuesday, we went to Paris."
→ (Sarah, Paris, TEMPORAL_SEQUENCE, 0.85)

// Causal
"The promotion made me feel confident and happy."
→ (promotion, happy, CAUSAL, 0.9)

// Emotional
"Spending time with Mom always brings me joy."
→ (Mom, joy, EMOTIONAL, 0.95)

// Topical
"Discussed AI and machine learning at the conference."
→ (AI, machine_learning, TOPICAL, 0.9)
```

**Data Model**:
```swift
@Model
class Relationship {
    var fromEntity: Entity
    var toEntity: Entity
    var type: RelationshipType
    var confidence: Double // 0.0-1.0
    var evidence: String   // Text excerpt
    var sourceEntry: Entry // Where discovered
    var createdAt: Date
}

enum RelationshipType: String, Codable {
    case temporal, causal, emotional, topical
}
```

**Testing Focus**:
- Relationship detection accuracy
- Cross-note discovery correctness
- Evidence quality (relevance of excerpts)
- Performance on large graphs (1000+ entities)

---

### US-S13-003: Graph Visualization Screen (3 points)

**As a user**, I want to see my knowledge graph visually so I can explore connections and understand my journaling patterns.

**Problem Statement**:
- Knowledge graph data exists but is invisible
- Cannot explore entity connections interactively
- No way to see "big picture" of life patterns
- Difficult to discover unexpected connections

**Requirements** (FR-707, FR-708, FR-709):
- Graph visualization screen accessible from:
  - Chat sidebar → "View Graph" button
  - Entry detail → "Show in Graph" button
- Interactive entity nodes (tap to expand connections)
- Relationship edges with type indicators (color/style)
- Path explanation with breadcrumbs
- Filter by entity type and relationship type
- Zoom and pan gestures
- Node size based on entity frequency (# of mentions)
- Search entities in graph

**Acceptance Criteria**:
- [ ] GraphView displays entities as nodes, relationships as edges
- [ ] Access from Chat (toolbar button) and Entry detail
- [ ] Tap entity node → expand connected entities
- [ ] Relationship edges color-coded by type:
  - Temporal: Blue
  - Causal: Orange
  - Emotional: Pink
  - Topical: Green
- [ ] Node size reflects entity frequency
- [ ] Zoom in/out with pinch gesture
- [ ] Pan graph with drag gesture
- [ ] Search bar filters visible entities
- [ ] Selected path shows breadcrumbs (A → B → C)
- [ ] Tap edge → show evidence popover
- [ ] Empty state when no graph data
- [ ] Loading state during graph computation

**Technical Tasks**:
- [ ] Create GraphView with Canvas/SwiftUI
- [ ] Implement force-directed graph layout algorithm
- [ ] Add zoom/pan gesture handlers
- [ ] Create node rendering (circles with labels)
- [ ] Create edge rendering (lines with colors)
- [ ] Build search and filter UI
- [ ] Add breadcrumb navigation component
- [ ] Implement graph computation service
- [ ] Add "View Graph" button to Chat toolbar
- [ ] Add "Show in Graph" button to Entry detail
- [ ] Test performance with large graphs (500+ nodes)

**UI/UX Notes**:
- Smooth animations for node expansion
- Clear legend for relationship types
- Haptic feedback on node tap
- Dark mode support

**Graph Layout**:
- Force-directed layout (Spring physics)
- Central entity has strongest pull
- Related entities cluster together
- Edge length ~ relationship strength

**Navigation Flow**:
```
Chat → "View Graph" → GraphView (shows entities from current context)
Entry Detail → "Show in Graph" → GraphView (centered on entry's entities)
```

**Testing Focus**:
- Layout algorithm correctness
- Gesture responsiveness
- Performance with large graphs
- Visual clarity and readability

---

### US-S13-004: Conversation to Knowledge Graph (2 points)

**As a user**, I want my AI conversations to be converted into knowledge graph entities so I don't lose insights discussed in chat.

**Problem Statement**:
- AI conversations contain valuable insights but are ephemeral
- Chat messages not integrated into knowledge graph
- Cannot reference conversation insights in future analysis
- Duplicate effort: Discussing same topics in chat repeatedly

**Requirements** (FR-710, FR-711):
- "Convert to KG" button in conversation view
- Extract entities from chat messages (user + AI)
- Link chat entities to existing journal entities
- Create new entities for net-new discoveries
- Visual confirmation of conversion success
- Prevent duplicate conversions (button disabled after conversion)

**Acceptance Criteria**:
- [ ] "Convert to KG" button in Chat toolbar
- [ ] Extracts entities from all messages in conversation
- [ ] Links to existing entities when matches found
- [ ] Creates new entities for new discoveries
- [ ] Shows conversion progress indicator
- [ ] Success message: "Added X entities, Y relationships"
- [ ] Button disabled after conversion (one-time operation)
- [ ] Conversation metadata tracks conversion status
- [ ] Entity → Conversation relationship (for provenance)
- [ ] Test with 10+ message conversations

**Technical Tasks**:
- [ ] Add "Convert to KG" button to Chat toolbar
- [ ] Create ConversationKGService
- [ ] Extract entities from chat messages
- [ ] Implement entity matching algorithm
- [ ] Create Conversation → Entity relationships
- [ ] Add conversion status to Conversation model
- [ ] Build success confirmation UI
- [ ] Test with various conversation types
- [ ] Handle API failures gracefully

**UI/UX Notes**:
- Conversion happens in background
- Progress dialog shows extraction status
- Success shows entity count badge
- Button grayed out after conversion

**Conversion Flow**:
```
1. User taps "Convert to KG"
2. Extract entities from all messages
3. Match against existing entities (fuzzy match)
4. Create new entities for unknowns
5. Link conversation to entities
6. Show success: "Added 5 entities, 3 relationships"
7. Disable button (already converted)
```

**Data Model Update**:
```swift
@Model
class Conversation {
    // ... existing fields
    var knowledgeGraphConverted: Bool = false
    var convertedAt: Date?

    @Relationship
    var extractedEntities: [Entity]
}
```

**Testing Focus**:
- Entity matching accuracy
- Duplicate prevention
- API error handling
- Conversion status persistence

---

## Technical Architecture

### New Components

**Services**:
```swift
// Entity extraction
class EntityExtractionService {
    func extractEntities(from text: String) async throws -> [Entity]
    func deduplicateEntities(_ entities: [Entity]) -> [Entity]
}

// Relationship discovery
class RelationshipService {
    func discoverRelationships(for entities: [Entity]) async throws -> [Relationship]
    func findTemporalRelationships() -> [Relationship]
    func findCausalRelationships() -> [Relationship]
    func findEmotionalRelationships() -> [Relationship]
    func findTopicalRelationships() -> [Relationship]
}

// Graph computation
class KnowledgeGraphService {
    func buildGraph(from entries: [Entry]) async throws
    func getGraph(for entity: Entity) -> Graph
    func searchEntities(query: String) -> [Entity]
}

// Conversation conversion
class ConversationKGService {
    func convertToKnowledgeGraph(conversation: Conversation) async throws
}
```

**Views**:
```swift
// Graph visualization
struct GraphView: View
struct EntityNode: View
struct RelationshipEdge: View
struct GraphControls: View

// Settings
struct KnowledgeGraphSettingsView: View
```

**Models**:
```swift
@Model class Entity
@Model class Relationship
```

### Data Flow

```
Journal Entry
    ↓
EntityExtractionService
    ↓
[Entity] stored in SwiftData
    ↓
RelationshipService
    ↓
[Relationship] stored in SwiftData
    ↓
KnowledgeGraphService
    ↓
GraphView renders visualization
```

### API Integration

**OpenRouter Prompts**:
- Entity extraction: Structured JSON output
- Relationship discovery: JSON with evidence
- Confidence scoring: 0.0-1.0 range

**Error Handling**:
- API failures → graceful degradation
- Partial results → save what works
- Retry logic with exponential backoff

---

## Sprint Timeline

**Week 1 (Oct 3-10)**:
- Day 1-2: US-S13-001 Entity Extraction (3 points)
- Day 3-4: US-S13-002 Relationship Mapping (4 points)

**Week 2 (Oct 10-17)**:
- Day 1-2: US-S13-003 Graph Visualization (3 points)
- Day 3: US-S13-004 Conversation to KG (2 points)
- Day 4: Testing, bug fixes, documentation

**Milestones**:
- Oct 10: Core extraction & relationship services complete
- Oct 15: Graph visualization functional
- Oct 17: Sprint 13 complete, all tests passing

---

## Testing Strategy

### Unit Tests
- Entity extraction accuracy (precision/recall)
- Deduplication algorithm correctness
- Relationship detection for each type
- Graph layout algorithm

### Integration Tests (XcodeBuildMCP)
- **TC-S13-001**: Extract entities from sample entry
- **TC-S13-002**: Build graph from 10 entries
- **TC-S13-003**: Visualize graph with 50+ nodes
- **TC-S13-004**: Convert conversation to KG
- **TC-S13-005**: Search entities in graph
- **TC-S13-006**: Navigate relationships in UI
- **TC-S13-007**: Batch process 100 entries
- **TC-S13-008**: Handle API failures gracefully

### Performance Tests
- Extraction: 100 entries in <1 minute
- Relationship discovery: 500 entities in <30 seconds
- Graph rendering: 1000 nodes at 60 FPS
- Search: <100ms for entity lookup

### Acceptance Tests
- All user stories meet acceptance criteria
- No critical bugs
- Knowledge graph accurately reflects journal content
- UI responsive and intuitive

---

## Dependencies & Risks

### Technical Dependencies
- OpenRouter API (entity extraction, relationship analysis)
- SwiftData relationships (many-to-many)
- Graph rendering performance (SwiftUI Canvas)
- JSON parsing reliability

### Risks

**Risk 1: Entity extraction accuracy**
- **Probability**: Medium
- **Impact**: High (poor UX if entities wrong)
- **Mitigation**: Fine-tune prompts, confidence thresholds, manual review option
- **Contingency**: Fall back to keyword extraction

**Risk 2: Graph visualization performance**
- **Probability**: Medium
- **Impact**: High (laggy UI with large graphs)
- **Mitigation**: Limit visible nodes, lazy loading, simplify layout
- **Contingency**: Paginated graph view

**Risk 3: Relationship discovery complexity**
- **Probability**: High
- **Impact**: Medium (fewer relationships discovered)
- **Mitigation**: Start with simple heuristics, iterate
- **Contingency**: Focus on temporal relationships first

**Risk 4: API costs**
- **Probability**: Low
- **Impact**: Medium (batch processing expensive)
- **Mitigation**: Caching, batch optimization, user controls
- **Contingency**: Limit batch size to 100 entries

---

## Definition of Done

**Story-Level DoD**:
- [ ] All acceptance criteria met
- [ ] Integration tests passing (XcodeBuildMCP)
- [ ] Code reviewed and refactored
- [ ] No critical bugs
- [ ] Documentation updated

**Sprint-Level DoD**:
- [ ] All 4 user stories complete (12/12 points)
- [ ] Knowledge graph functional end-to-end
- [ ] Graph visualization performant (60 FPS)
- [ ] Test document updated with results
- [ ] Architecture document updated
- [ ] Product backlog updated
- [ ] Demo-ready for stakeholder review

---

## Success Metrics

**Functional Metrics**:
- ✅ Extract 5 entity types with >80% accuracy
- ✅ Discover 4 relationship types across notes
- ✅ Render graphs with 500+ nodes at 60 FPS
- ✅ Convert conversations to KG in <5 seconds

**Quality Metrics**:
- ✅ 100% of integration tests passing
- ✅ 0 critical bugs at sprint end
- ✅ Code coverage >70% for services

**User Experience Metrics**:
- ✅ Graph visualization intuitive (subjective)
- ✅ Entity search fast (<100ms)
- ✅ Smooth animations and transitions

---

## Sprint Retrospective Template

(To be filled at end of sprint)

### What Went Well
- [To be completed]

### What Could Be Improved
- [To be completed]

### Action Items for Next Sprint
- [To be completed]

### Metrics Achieved
- Story points delivered: __/12
- Test pass rate: __/8 integration tests
- Sprint duration: __ days
- Bugs found: __ critical, __ minor

---

**Sprint Start**: October 3, 2025
**Sprint End**: October 17, 2025 (Target)
**Sprint Review**: TBD
**Test Report**: [`docs/03_testing/sprint_13_acceptance_tests.md`](../03_testing/sprint_13_acceptance_tests.md)

---

## Next Steps

1. Begin US-S13-001: Create Entity model and extraction service
2. Set up XcodeBuildMCP test scenarios
3. Daily progress updates in this document
4. Create ADR for knowledge graph data structure decisions
