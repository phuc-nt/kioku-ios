# Architecture Design Document (Phase 2)
## AI Chat & Knowledge Graph Integration

**Version:** 1.0  
**Date:** October 1, 2025  
**Related:** Phase 2 Requirements Document

***

## 1. System Architecture

### 1.1 High-Level Overview

```
┌─────────────────── Kioku App Phase 2 ──────────────────┐
│                                                         │
│  ┌──────────────────┐      ┌───────────────────┐      │
│  │  Chat System     │◄────►│  KG System        │      │
│  │                  │      │                   │      │
│  │ Streaming        │      │ Entity Extract    │      │
│  │ Conversation Mgr │      │ Relationship Map  │      │
│  │ Context Service  │      │ Graph Query       │      │
│  └──────────────────┘      └───────────────────┘      │
│           ↓                         ↓                  │
│  ┌──────────────────────────────────────────┐         │
│  │    Existing Core (Phase 1)               │         │
│  │  - DateContextService                    │         │
│  │  - DataService (SwiftData)               │         │
│  │  - CalendarView, EntryDetailView         │         │
│  └──────────────────────────────────────────┘         │
└─────────────────────────────────────────────────────────┘
           ↓                         ↓
    OpenRouter API           SwiftData Storage
  (Gemini 2.5 Flash)         (Local SQLite)
```

***

## 2. Component Architecture

### 2.1 Chat System Components

**StreamingChatService**
- SSE connection với OpenRouter API
- Token-by-token streaming processing
- Stop/regenerate request handling

**ConversationManager**
- CRUD operations for conversations
- Auto-title generation
- Message persistence

**ChatContextService**
- Parallel context discovery (similarity + graph)
- Context merging và ranking
- Format context for AI prompts

### 2.2 Knowledge Graph Components

**EntityExtractionService**
- Extract 5 entity types via Gemini API
- Assign confidence scores
- Entity deduplication

**RelationshipMappingService**
- Discover 4 relationship types
- Calculate strength scores
- Extract evidence text

**KnowledgeGraphService**
- Orchestrate extraction + mapping
- Handle batch conversion workflows
- Single note và conversation conversion

**GraphQueryService**
- BFS/DFS graph traversal
- Entity similarity calculation
- Support graph explain screen data

***

## 3. Data Models

### 3.1 Chat Models (Sprint 11)

#### Conversation
```swift
@Model
class Conversation {
    var id: UUID
    var title: String                    // Auto-generated or user-edited
    var createdAt: Date
    var updatedAt: Date
    var associatedDate: Date?           // Optional calendar link
    var hasKnowledgeGraph: Bool         // Conversion status flag
    
    @Relationship(deleteRule: .cascade)
    var messages: [ChatMessage]
}
```

#### ChatMessage
```swift
@Model
class ChatMessage {
    var id: UUID
    var conversationId: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var contextUsed: String?            // JSON array: ["entry-id-1", "entry-id-2"]
    var wasRegenerated: Bool            // Track regeneration
}
```

### 3.2 Knowledge Graph Models (Sprint 12)

#### KnowledgeEntity
```swift
@Model
class KnowledgeEntity {
    var id: UUID
    var type: String                    // Person | Place | Event | Emotion | Topic
    var name: String                    // Entity name
    var metadata: String?               // JSON: {aliases: [], attributes: {}}
    var sourceEntryIds: [String]        // Notes mentioning this entity
    var sourceConversationIds: [String]?// Conversations mentioning entity
    var confidence: Double              // 0.0 - 1.0 extraction confidence
    var createdAt: Date
    var lastUpdatedAt: Date
}
```

#### KnowledgeRelation
```swift
@Model
class KnowledgeRelation {
    var id: UUID
    var fromEntityId: UUID              // Source entity
    var toEntityId: UUID                // Target entity
    var relationType: String            // Temporal | Causal | Emotional | Topical
    var strength: Double                // 0.0 - 1.0 relationship confidence
    var sourceEntryId: String?          // Note establishing relation
    var sourceConversationId: String?   // Conversation establishing relation
    var evidence: String?               // Supporting text excerpt
    var createdAt: Date
}
```

#### ConversationKG
```swift
@Model
class ConversationKG {
    var id: UUID
    var conversationId: UUID
    var entities: [String]              // JSON array of entity IDs
    var relationships: [String]         // JSON array of relation IDs
    var generatedAt: Date
    var linkedNoteEntities: [String]?   // Entity IDs linked to existing note entities
}
```

### 3.3 Updated Existing Models

#### Entry (Updated)
```swift
@Model
class Entry {
    // Existing fields
    var content: String
    var date: Date?
    var createdAt: Date
    var updatedAt: Date
    var mood: String?
    var tags: [String]
    
    // NEW: Phase 2 addition
    var hasKnowledgeGraph: Bool         // KG conversion status flag
}
```

#### Removed Models
```
❌ AIAnalysis - Deprecated, replaced by ConversationKG
```

***

## 4. Data Flow Architecture

### 4.1 Streaming Chat Flow

```
User Message Input
    ↓
ChatViewModel.sendMessage()
    ↓
ChatContextService.aggregateContext()
    ↓
┌─────────────── Parallel Context Discovery ────────────────┐
│                                                            │
│  Thread 1: Similarity        Thread 2: Graph Traversal    │
│  - Extract entities          - Query KG for connected     │
│  - Find overlap (5 notes)    - BFS traversal (10 notes)   │
│                                                            │
│            Merge & Rank → Top 15 Notes                     │
└────────────────────────────────────────────────────────────┘
    ↓
StreamingChatService.sendMessage(content + context)
    ↓
OpenRouter API (SSE Stream)
    ↓
Token Loop: onToken() → Update UI real-time
    ↓
Complete: Save ChatMessage to SwiftData
```

### 4.2 Knowledge Graph Generation Flow

```
User: "Convert to KG" Button
    ↓
KnowledgeGraphService.convertNoteToKG(entry)
    ↓
EntityExtractionService.extractEntities(entry.content)
    ↓
Gemini API Call (structured JSON output)
    ├─→ People: ["Mom", "Friend"]
    ├─→ Places: ["Coffee Shop"]
    ├─→ Events: ["Birthday Party"]
    ├─→ Emotions: ["Happy", "Excited"]
    └─→ Topics: ["Family Time"]
    ↓
RelationshipMappingService.mapRelationships(entities)
    ├─→ Temporal: "Birthday happened before Coffee"
    ├─→ Causal: "Party caused Happiness"
    ├─→ Emotional: "Happy similar to Excited"
    └─→ Topical: "Family related to Birthday"
    ↓
Save to SwiftData:
    - KnowledgeEntity records
    - KnowledgeRelation records
    - Update Entry.hasKnowledgeGraph = true
```

### 4.3 Hybrid Context Discovery Flow

```
Chat Request with Current Note
    ↓
Check: Note has KG?
    ↓
YES → Parallel Execution:

┌─────────────────────┐         ┌──────────────────────┐
│  Thread 1           │         │  Thread 2            │
│  Entity Similarity  │         │  Graph Traversal     │
│                     │         │                      │
│  1. Extract entities│         │  1. Query KG         │
│  2. Find overlaps   │         │  2. BFS (depth=2)    │
│  3. Return 5 notes  │         │  3. Return 10 notes  │
└─────────────────────┘         └──────────────────────┘
         ↓                               ↓
         └──────────┬────────────────────┘
                    ↓
            Merge Algorithm:
            - Union both lists
            - Score: overlaps = 2x weight
            - Deduplicate by entry ID
            - Sort by relevance score
                    ↓
            Top 15 Notes → AI Context
```

***

## 5. Service Layer Architecture

### 5.1 Service Dependencies

```
ViewModels (UI Layer)
    ↓
┌───────────────────┬─────────────────────┐
↓                   ↓                     ↓
ConversationMgr  ChatContextSvc  KnowledgeGraphSvc
    ↓                   ↓                     ↓
StreamingChatSvc  ┌────┴────┐         EntityExtractSvc
                  ↓         ↓         RelationshipMapSvc
          DateContextSvc  GraphQuerySvc
                  ↓         ↓
              DataService (SwiftData)
```

### 5.2 Initialization Pseudocode

```swift
class AppServices {
    // Existing
    let dataService: DataService
    let dateContextService: DateContextService
    
    // Phase 2 Chat
    let streamingChatService: StreamingChatService
    let conversationManager: ConversationManager
    
    // Phase 2 KG
    let entityExtractionService: EntityExtractionService
    let relationshipMappingService: RelationshipMappingService
    let graphQueryService: GraphQueryService
    let knowledgeGraphService: KnowledgeGraphService
    
    // Phase 2 Hybrid
    let chatContextService: ChatContextService
    
    init() {
        // Initialize in dependency order
        dataService = DataService()
        dateContextService = DateContextService(dataService)
        
        streamingChatService = StreamingChatService()
        conversationManager = ConversationManager(dataService)
        
        entityExtractionService = EntityExtractionService()
        relationshipMappingService = RelationshipMappingService()
        graphQueryService = GraphQueryService(dataService)
        knowledgeGraphService = KnowledgeGraphService(
            entityExtraction,
            relationshipMapping,
            dataService
        )
        
        chatContextService = ChatContextService(
            dateContextService,
            knowledgeGraphService,
            graphQueryService
        )
    }
}
```

***

## 6. UI Architecture

### 6.1 Chat UI Structure

```
ChatTabView
├── ChatSidebarView (auto-hide)
│   ├── ConversationList
│   └── NewConversationButton
│
└── ChatInterfaceView
    ├── MessageScrollView
    │   ├── UserMessageBubble
    │   └── AIMessageBubble
    │       └── RelatedNotesButton → GraphExplain
    ├── StreamingControls
    │   ├── StopButton
    │   └── RegenerateButton
    └── MessageInput
```

### 6.2 Knowledge Graph UI Structure

```
EntryDetailView (existing)
└── ConvertToKGButton
    ├── Single: Direct conversion
    └── Batch: Modal Dialog
        ├── "This note only"
        └── "All unconverted" → ProgressView

GraphExplainView (new)
├── CurrentNoteSection
│   └── ExtractedEntitiesList
├── ConnectedNotesSection
│   └── ConnectedNoteRow
│       ├── RelationshipBadges
│       └── PathExplanation
└── EntityDetailView
```

***

## 7. API Integration Patterns

### 7.1 Streaming Chat Pattern

```
Pseudocode:

func sendStreamingMessage(content, context):
    prompt = buildPrompt(content, context)
    request = createSSERequest(prompt, model="gemini-2.0-flash")
    
    streamTask = URLSession.bytes(request)
    for line in streamTask:
        if line.startsWith("data:"):
            token = parseSSE(line)
            onToken(token)  // Update UI
            fullResponse += token
    
    onComplete(fullResponse)
    saveMessage(fullResponse)
```

### 7.2 Entity Extraction Pattern

```
Pseudocode:

func extractEntities(content, sourceId):
    prompt = """
    Extract entities from: {content}
    Return JSON: {
      people: [{name, confidence}],
      places: [...],
      events: [...],
      emotions: [...],
      topics: [...]
    }
    """
    
    response = geminiAPI.call(prompt)
    entities = parseJSON(response)
    
    for entity in entities:
        save KnowledgeEntity(
            type, name, confidence,
            sourceId
        )
    
    return entities
```

***

## 8. Error Handling Strategy

```swift
enum ChatError: LocalizedError {
    case networkFailure
    case apiRateLimited
    case streamInterrupted
    case contextTooLarge
}

enum KGError: LocalizedError {
    case extractionFailed(reason)
    case batchPartialFailure(success, failure)
    case graphQueryTimeout
}
```

***

## 9. Implementation Roadmap

### Sprint 11: Chat System (Week 1-2)
- **Week 1**: Streaming service, basic UI, conversation persistence
- **Week 2**: Sidebar, stop/regenerate, hybrid context (similarity)

### Sprint 12: Knowledge Graph (Week 3-4)
- **Week 3**: Entity extraction, data models, single conversion
- **Week 4**: Batch conversion, graph query, graph explain screen
