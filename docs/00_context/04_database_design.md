# Database Design - Current Implementation

**Document Status**: Implementation Reference (Reflects Current State)
**Last Updated**: 2025-10-11
**Related**: [Architecture Design v2](03_architecture_design.md), [Export Design](05_export_design.md)

---

## Overview

This document describes the current database schema implemented with SwiftData. All models are production-ready and actively used in Sprints 1-16.

---

## SwiftData Schema

All models registered in `DataService.swift`:

```swift
let schema = Schema([
    Entry.self,
    AIAnalysis.self,
    Conversation.self,
    ChatMessage.self,
    Entity.self,
    EntityRelationship.self,
    Insight.self
])
```

---

## Core Models

### 1. Entry (Journal Entry)

**Purpose**: Main journal entry with encrypted content

**Fields**:
- `id: UUID` - Primary key
- `encryptedContent: Data?` - Encrypted journal content
- `_plaintextContent: String?` - Legacy plaintext (deprecated)
- `createdAt: Date` - Creation timestamp
- `updatedAt: Date` - Last modification timestamp
- `date: Date?` - Normalized date (start of day) for calendar navigation
- `dataVersion: Int` - Schema version (current: 2)

**Knowledge Graph Tracking**:
- `isEntitiesExtracted: Bool` - Entity extraction completed flag
- `entitiesExtractedAt: Date?` - Extraction timestamp
- `entitiesExtractionModel: String?` - Model used for extraction
- `isRelationshipsDiscovered: Bool` - Relationship discovery flag
- `relationshipsDiscoveredAt: Date?` - Discovery timestamp
- `relationshipsDiscoveryModel: String?` - Model used for discovery

**Relationships**:
- `analyses: [AIAnalysis]` - AI analyses (cascade delete)
- `entities: [Entity]` - Extracted entities (cascade delete)
- `relationships: [EntityRelationship]` - Entity relationships (cascade delete)

**Computed Properties**:
- `content: String` - Transparent encryption/decryption
- `isEncrypted: Bool` - Check encryption status

**Key Methods**:
- `updateContent(_:)` - Update content and timestamp
- `migrateToEncrypted()` - Migrate legacy plaintext to encrypted
- `isForDate(_:)` - Check if entry is for specific date

---

### 2. Entity (Knowledge Graph Node)

**Purpose**: Extracted entities from journal entries (people, places, events, emotions, topics)

**Fields**:
- `id: UUID` - Primary key
- `type: EntityType` - Entity category (enum: people, places, events, emotions, topics)
- `value: String` - Entity name/value
- `confidence: Double` - Extraction confidence (0.0-1.0)
- `aliases: [String]` - Alternative names for deduplication
- `metadata: String?` - JSON-encoded additional data
- `createdAt: Date` - Creation timestamp
- `updatedAt: Date` - Last modification timestamp

**Relationships**:
- `entries: [Entry]` - Many-to-many with entries (inverse)
- `conversations: [Conversation]` - Many-to-many with conversations (inverse)
- `outgoingRelationships: [EntityRelationship]` - Outgoing edges (cascade delete)
- `incomingRelationships: [EntityRelationship]` - Incoming edges (inverse)

**Computed Properties**:
- `relatedEntities: [Entity]` - All connected entities via relationships
- `relationshipCount: Int` - Total relationship count
- `mentionCount: Int` - Number of entries mentioning this entity

**Key Methods**:
- `matches(query:)` - Exact match (case-insensitive) for deduplication
- `updateMetadata(_:)` - Update metadata from dictionary
- `getMetadata()` - Parse metadata to dictionary

---

### 3. EntityRelationship (Knowledge Graph Edge)

**Purpose**: Relationships between entities

**Fields**:
- `id: UUID` - Primary key
- `type: RelationshipType` - Relationship category (enum: temporal, causal, emotional, topical)
- `confidence: Double` - Confidence score (0.0-1.0)
- `evidence: String` - Text excerpt supporting relationship
- `createdAt: Date` - Creation timestamp

**Relationships**:
- `fromEntity: Entity` - Source entity (required)
- `toEntity: Entity` - Target entity (required)
- `sourceEntry: Entry?` - Entry where relationship was discovered (inverse)

**Key Methods**:
- `connects(_:_:)` - Check if connects two specific entities
- `otherEntity(from:)` - Get the other entity in relationship
- `truncatedEvidence(maxLength:)` - Get truncated evidence excerpt

---

### 4. Insight (AI-Generated Pattern)

**Purpose**: AI-discovered patterns across journal entries

**Fields**:
- `id: UUID` - Primary key
- `type: InsightType` - Pattern type (enum: frequency, temporal, emotional, social, topical, suggestion)
- `title: String` - Insight title
- `insightDescription: String` - Detailed description
- `confidence: Double` - Confidence score (0.0-1.0)
- `generatedAt: Date` - Generation timestamp
- `timeframe: TimeframeType` - Timeframe (enum: daily, weekly, monthly)

**Evidence**:
- `relatedEntityIds: [UUID]` - Links to entities
- `relatedEntryIds: [UUID]` - Links to entries
- `evidence: String` - Supporting data (JSON string)

**User Interaction**:
- `isRead: Bool` - User read status
- `isStarred: Bool` - User starred status

**Note**: Insight is standalone (no SwiftData relationships), uses UUID arrays for links

---

### 5. Conversation (Chat Session)

**Purpose**: AI chat conversation with context

**Fields**:
- `id: UUID` - Primary key
- `title: String` - Conversation title
- `createdAt: Date` - Creation timestamp
- `updatedAt: Date` - Last modification timestamp
- `hasKnowledgeGraph: Bool` - KG context flag
- `associatedDate: Date?` - Associated journal date
- `contextNoteIds: String?` - JSON array of note IDs used as context

**Relationships**:
- `messages: [ChatMessage]` - Chat messages (cascade delete)
- `extractedEntities: [Entity]` - Entities from conversation (cascade delete)

**Computed Properties**:
- `messageCount: Int` - Number of messages
- `lastMessageDate: Date?` - Last message timestamp

---

### 6. ChatMessage (Chat Message)

**Purpose**: Individual message in conversation

**Fields**:
- `id: UUID` - Primary key
- `content: String` - Message content
- `isFromUser: Bool` - User vs AI message
- `timestamp: Date` - Message timestamp
- `contextData: String?` - JSON context used for this message
- `isStreaming: Bool` - Streaming in progress flag
- `isError: Bool` - Error message flag

**Relationships**:
- `conversation: Conversation?` - Parent conversation (inverse)

---

### 7. AIAnalysis (Legacy AI Analysis)

**Purpose**: Legacy AI analysis results (pre-Knowledge Graph)

**Fields**:
- `id: UUID` - Primary key
- `entryId: UUID` - Foreign key to Entry
- `modelUsed: String` - Model identifier
- `processingDate: Date` - Analysis timestamp
- `analysisVersion: Int` - Schema version

**Queryable Summary**:
- `overallSentiment: String` - Sentiment category
- `sentimentConfidence: Double` - Confidence score
- `entityCount: Int` - Number of entities
- `themeCount: Int` - Number of themes

**Detailed Results**:
- `analysisData: Data` - Encoded EntryAnalysis struct (JSON)

**Relationships**:
- `entry: Entry?` - Parent entry (inverse)

**Note**: Legacy model, superseded by Knowledge Graph (Entity/Relationship/Insight)

---

## Cascade Delete Rules

| Model | Relationship | Delete Rule | Purpose |
|-------|-------------|-------------|---------|
| Entry → analyses | @Relationship | `.cascade` | Delete analyses when entry deleted |
| Entry → entities | @Relationship | `.cascade` | Delete entities when entry deleted |
| Entry → relationships | @Relationship | `.cascade` | Delete relationships when entry deleted |
| Entity → outgoingRelationships | @Relationship | `.cascade` | Delete outgoing edges when entity deleted |
| Conversation → messages | @Relationship | `.cascade` | Delete messages when conversation deleted |
| Conversation → extractedEntities | @Relationship | `.cascade` | Delete entities when conversation deleted |

**Inverse Relationships** (no cascade, reference only):
- Entity ← entries
- Entity ← conversations
- Entity ← incomingRelationships
- AIAnalysis ← entry
- ChatMessage ← conversation
- EntityRelationship ← sourceEntry

---

## Data Integrity Features

### Entity Deduplication

**Implementation** (Sprint 16):
- Exact matching with `Entity.matches(query:)` (case-insensitive, trimmed)
- In-memory cache during batch extraction to bypass SwiftData context sync delays
- Cache cleared at batch start, populated during processing
- Immediate save after entity insert for visibility

**Cache Pattern**:
```swift
private var entityCache: [String: Entity] = [:] // Key: "type:value"

// 1. Check in-memory cache first
if let cached = entityCache[cacheKey] { ... }

// 2. Check database
let existing = dataService.fetchEntities(type:, searchText:)

// 3. Create new if not found
dataService.modelContext.insert(newEntity)
try? dataService.modelContext.save() // Immediate save
entityCache[cacheKey] = newEntity
```

### Encryption

**Strategy**:
- Entry content encrypted via `EncryptionService.shared`
- Transparent encryption/decryption through computed `content` property
- Entities/relationships/insights NOT encrypted (metadata only)
- Keychain integration for encryption keys

**Migration Support**:
- Legacy plaintext entries supported via `_plaintextContent`
- `migrateToEncrypted()` method for migration
- Graceful fallback if decryption fails

---

## Performance Characteristics

| Operation | Performance | Notes |
|-----------|------------|-------|
| Entry creation | <10ms | With encryption |
| Entity deduplication | ~50ms per entry | With in-memory cache |
| Context loading (KG) | <500ms target | Needs validation with 100+ entries |
| Relationship discovery | 2-5s per entry | API rate limited |

---

## Known Limitations

1. **Relationship Discovery Tracking**:
   - `isRelationshipsDiscovered` field exists but not actively used yet
   - No resume capability implemented (acceptable for current dataset size)
   - Will re-process all entries each time

2. **Performance Testing**:
   - Context loading <500ms not validated with large dataset (100+ entries)
   - Current test data: 11-62 entries

3. **Insight Relationships**:
   - Uses UUID arrays instead of SwiftData relationships
   - Manual ID resolution required for UI display

---

## Database Utilities

For database debugging and maintenance scripts, see: [Database Utilities](04_database_utilities.md)

---

**Document Control**

- **Version**: 2.0 (Implementation Reference)
- **Author**: AI Assistant
- **Last Review**: 2025-10-11
- **Next Review**: When schema changes occur
