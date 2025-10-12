# Export & Import Data Structure Design

**Document Status**: Design Phase (Sprint 17)
**Last Updated**: 2025-10-11
**Related**: [Database Design](04_database_design.md), [Sprint 17 Planning](../01_sprints/sprint_17_planning.md)

---

## Overview

This document defines the data structure for exporting and importing Kioku journal data. The export format must:
- **Completeness**: Include all user data (entries, entities, relationships, insights, conversations)
- **Portability**: Human-readable and machine-parseable
- **Versioning**: Support schema evolution
- **Privacy**: Respect encryption preferences

---

## Export Formats

### 1. JSON Export (Primary Format)

**Purpose**: Complete data backup with full metadata, suitable for import

**File Extension**: `.kioku.json` or `.json`

**Characteristics**:
- Machine-readable and parseable
- Includes all relationships and metadata
- Supports import with conflict resolution
- ~1-5MB for 100 entries with full KG data

### 2. Markdown Export (Secondary Format)

**Purpose**: Human-readable journal backup, read-only

**File Extension**: `.md`

**Characteristics**:
- Plain text format
- Organized chronologically by date
- Includes entity/insight summaries
- No import capability (reference only)
- ~500KB-2MB for 100 entries

---

## JSON Export Schema v1.0

### Top-Level Structure

```json
{
  "version": "1.0",
  "exported_at": "2025-10-11T10:30:00Z",
  "export_metadata": {
    "app_version": "1.0.0",
    "data_version": 2,
    "entry_count": 100,
    "entity_count": 250,
    "relationship_count": 180,
    "insight_count": 45,
    "conversation_count": 15,
    "encryption_enabled": true
  },
  "entries": [...],
  "entities": [...],
  "relationships": [...],
  "insights": [...],
  "conversations": [...]
}
```

### Export Metadata

**Fields**:
- `version: String` - Export schema version (semantic versioning)
- `exported_at: String` - ISO 8601 timestamp
- `app_version: String` - Kioku app version
- `data_version: Int` - Database schema version
- `entry_count: Int` - Number of entries
- `entity_count: Int` - Number of entities
- `relationship_count: Int` - Number of relationships
- `insight_count: Int` - Number of insights
- `conversation_count: Int` - Number of conversations
- `encryption_enabled: Bool` - Whether content is encrypted in export

---

## Entry Export Format

```json
{
  "id": "uuid-string",
  "content": "journal content (encrypted or plain based on user choice)",
  "is_encrypted": true,
  "date": "2025-10-11",
  "created_at": "2025-10-11T09:00:00Z",
  "updated_at": "2025-10-11T09:30:00Z",
  "data_version": 2,

  "kg_tracking": {
    "is_entities_extracted": true,
    "entities_extracted_at": "2025-10-11T10:00:00Z",
    "entities_extraction_model": "openai/gpt-4o-mini",
    "is_relationships_discovered": true,
    "relationships_discovered_at": "2025-10-11T10:05:00Z",
    "relationships_discovery_model": "openai/gpt-4o-mini"
  },

  "entity_ids": ["uuid1", "uuid2"],
  "relationship_ids": ["uuid3", "uuid4"],
  "analysis_ids": ["uuid5"]
}
```

**Field Mapping**:
- `id` ← Entry.id
- `content` ← Entry.content (decrypted or encrypted based on export option)
- `is_encrypted` ← Flag indicating if content is encrypted in export
- `date` ← Entry.date (ISO date string)
- `created_at` ← Entry.createdAt (ISO datetime)
- `updated_at` ← Entry.updatedAt (ISO datetime)
- `data_version` ← Entry.dataVersion
- `kg_tracking` ← KG tracking fields
- `entity_ids` ← Entry.entities.map { $0.id }
- `relationship_ids` ← Entry.relationships.map { $0.id }
- `analysis_ids` ← Entry.analyses.map { $0.id }

---

## Entity Export Format

```json
{
  "id": "uuid-string",
  "type": "people",
  "value": "Minh",
  "confidence": 0.95,
  "aliases": ["Minh", "minh"],
  "metadata": {"custom_field": "value"},
  "created_at": "2025-10-11T10:00:00Z",
  "updated_at": "2025-10-11T10:00:00Z",

  "entry_ids": ["uuid1", "uuid2", "uuid3"],
  "conversation_ids": ["uuid4"]
}
```

**Field Mapping**:
- `id` ← Entity.id
- `type` ← Entity.type.rawValue
- `value` ← Entity.value
- `confidence` ← Entity.confidence
- `aliases` ← Entity.aliases
- `metadata` ← Entity.getMetadata() or null
- `created_at` ← Entity.createdAt
- `updated_at` ← Entity.updatedAt
- `entry_ids` ← Entity.entries.map { $0.id }
- `conversation_ids` ← Entity.conversations.map { $0.id }

**Note**: Relationships stored separately in `relationships` array

---

## Relationship Export Format

```json
{
  "id": "uuid-string",
  "type": "causal",
  "from_entity_id": "uuid1",
  "to_entity_id": "uuid2",
  "confidence": 0.85,
  "evidence": "Text excerpt supporting this relationship",
  "created_at": "2025-10-11T10:05:00Z",
  "source_entry_id": "uuid3"
}
```

**Field Mapping**:
- `id` ← EntityRelationship.id
- `type` ← EntityRelationship.type.rawValue
- `from_entity_id` ← EntityRelationship.fromEntity.id
- `to_entity_id` ← EntityRelationship.toEntity.id
- `confidence` ← EntityRelationship.confidence
- `evidence` ← EntityRelationship.evidence
- `created_at` ← EntityRelationship.createdAt
- `source_entry_id` ← EntityRelationship.sourceEntry?.id or null

---

## Insight Export Format

```json
{
  "id": "uuid-string",
  "type": "frequency",
  "title": "Work mentioned frequently",
  "description": "You've mentioned 'work' 5 times this week",
  "confidence": 0.85,
  "generated_at": "2025-10-11T12:00:00Z",
  "timeframe": "weekly",

  "related_entity_ids": ["uuid1", "uuid2"],
  "related_entry_ids": ["uuid3", "uuid4", "uuid5"],
  "evidence": "{\"mentions\": 5, \"context\": \"work stress, deadline\"}",

  "is_read": false,
  "is_starred": false
}
```

**Field Mapping**:
- `id` ← Insight.id
- `type` ← Insight.type.rawValue
- `title` ← Insight.title
- `description` ← Insight.insightDescription
- `confidence` ← Insight.confidence
- `generated_at` ← Insight.generatedAt
- `timeframe` ← Insight.timeframe.rawValue
- `related_entity_ids` ← Insight.relatedEntityIds
- `related_entry_ids` ← Insight.relatedEntryIds
- `evidence` ← Insight.evidence
- `is_read` ← Insight.isRead
- `is_starred` ← Insight.isStarred

---

## Conversation Export Format

```json
{
  "id": "uuid-string",
  "title": "Chat about my week",
  "created_at": "2025-10-11T14:00:00Z",
  "updated_at": "2025-10-11T14:30:00Z",
  "has_knowledge_graph": true,
  "associated_date": "2025-10-11",
  "context_note_ids": ["uuid1", "uuid2"],

  "messages": [...],
  "entity_ids": ["uuid3", "uuid4"]
}
```

**Field Mapping**:
- `id` ← Conversation.id
- `title` ← Conversation.title
- `created_at` ← Conversation.createdAt
- `updated_at` ← Conversation.updatedAt
- `has_knowledge_graph` ← Conversation.hasKnowledgeGraph
- `associated_date` ← Conversation.associatedDate (ISO date or null)
- `context_note_ids` ← Parse Conversation.contextNoteIds (JSON array) or null
- `messages` ← Inline array of messages
- `entity_ids` ← Conversation.extractedEntities.map { $0.id }

### Message Export Format (Nested in Conversation)

```json
{
  "id": "uuid-string",
  "content": "How has my week been?",
  "is_from_user": true,
  "timestamp": "2025-10-11T14:00:00Z",
  "context_data": "{\"entry_count\": 5}",
  "is_streaming": false,
  "is_error": false
}
```

**Field Mapping**:
- `id` ← ChatMessage.id
- `content` ← ChatMessage.content
- `is_from_user` ← ChatMessage.isFromUser
- `timestamp` ← ChatMessage.timestamp
- `context_data` ← ChatMessage.contextData or null
- `is_streaming` ← ChatMessage.isStreaming
- `is_error` ← ChatMessage.isError

**Note**: Messages nested within conversation, not top-level array

---

## AIAnalysis Export Format (Optional)

```json
{
  "id": "uuid-string",
  "entry_id": "uuid1",
  "model_used": "openai/gpt-4o-mini",
  "processing_date": "2025-10-11T10:00:00Z",
  "analysis_version": 1,

  "overall_sentiment": "positive",
  "sentiment_confidence": 0.82,
  "entity_count": 3,
  "theme_count": 2,

  "analysis_data": {...}
}
```

**Note**: Legacy model, may be excluded from export by default (user option)

---

## Markdown Export Format

### File Structure

```markdown
# Kioku Journal Export

**Exported**: October 11, 2025 at 10:30 AM
**Entries**: 100 | **Entities**: 250 | **Insights**: 45

---

## October 2025

### Friday, October 11, 2025

Today I met with Minh to discuss the project. We made good progress...

**Entities**: Minh (Person), Project Alpha (Topic), Happy (Emotion)

**Insights**:
- Working on weekends pattern (Frequency, Confidence: 85%)

---

### Thursday, October 10, 2025

...

---

## September 2025

...
```

### Formatting Rules

1. **Header Section**:
   - Export timestamp
   - Summary statistics
   - No encryption info (content always decrypted)

2. **Month Sections**:
   - H2 heading: `## Month YYYY`
   - Entries within month grouped chronologically (newest first)

3. **Entry Sections**:
   - H3 heading: `### Day of week, Month Day, Year`
   - Entry content (paragraphs preserved)
   - **Entities**: Type-grouped, sorted by confidence
   - **Insights**: Top 3 related insights (title, type, confidence)

4. **No Relationships**:
   - Too complex for readable Markdown
   - Relationships implicit through shared entities

5. **No Conversations**:
   - Chat history not included in Markdown export
   - Use JSON export for conversations

---

## Export Options

### User Preferences

```swift
struct ExportOptions {
    let format: ExportFormat // .json or .markdown
    let includeEncrypted: Bool // Encrypt content in export (JSON only)
    let includeLegacyAnalysis: Bool // Include AIAnalysis models
    let includeConversations: Bool // Include chat conversations
    let dateRange: DateRange? // Filter entries by date range
}

enum ExportFormat {
    case json
    case markdown
}

struct DateRange {
    let start: Date?
    let end: Date?
}
```

### Default Settings

- Format: JSON
- Encryption: true (preserve encryption in export)
- Legacy Analysis: false (exclude AIAnalysis)
- Conversations: true (include chat history)
- Date Range: nil (all entries)

---

## Import Process

### Import Validation

**Schema Version Check**:
```swift
guard exportData.version == "1.0" else {
    throw ImportError.unsupportedVersion(exportData.version)
}
```

**Data Integrity Checks**:
- All referenced UUIDs exist in export
- Entity types are valid enum values
- Dates are parseable
- Confidence scores in range 0.0-1.0

### Conflict Resolution Strategies

**Strategy 1: Skip Duplicates (Default)**
- Check if entry ID exists in database
- If exists: skip entry and log warning
- If not: create new entry

**Strategy 2: Merge**
- Check if entry with same date + content hash exists
- If exists: compare `updated_at` timestamps
  - Keep newer version
  - Merge entity/relationship links
- If not: create new entry

**Strategy 3: Replace**
- Delete existing entry with same ID
- Create new entry from import

**User Choice**:
- Present conflict resolution options in UI
- Default: Skip Duplicates (safest)

### Import Order

Critical to maintain referential integrity:

1. **Entities** (no dependencies)
2. **Entries** (references entities via IDs)
3. **Relationships** (references entities + entries)
4. **Insights** (references entities + entries via UUIDs)
5. **Conversations** (references entities)
   - Messages imported inline with conversation

### UUID Handling

**Option A: Preserve UUIDs (Default)**
- Use UUIDs from export
- Enables clean re-import after delete
- Risk: UUID conflicts if partial import

**Option B: Generate New UUIDs**
- Generate new UUIDs on import
- Remap all references
- Safe but loses original IDs

**Recommendation**: Preserve UUIDs with conflict detection

---

## Export Implementation Requirements

### ExportService API

```swift
public class ExportService {
    func exportToJSON(
        options: ExportOptions = .default
    ) async throws -> Data

    func exportToMarkdown(
        options: ExportOptions = .default
    ) async throws -> String

    func estimateExportSize(
        format: ExportFormat
    ) -> Int // Bytes
}
```

### ImportService API

```swift
public class ImportService {
    func validateImport(
        data: Data
    ) throws -> ImportValidationResult

    func importFromJSON(
        data: Data,
        conflictStrategy: ConflictStrategy = .skipDuplicates,
        progress: @escaping (Double, String) -> Void
    ) async throws -> ImportResult
}

struct ImportValidationResult {
    let isValid: Bool
    let errors: [ImportError]
    let warnings: [String]
    let summary: ImportSummary
}

struct ImportSummary {
    let entryCount: Int
    let entityCount: Int
    let relationshipCount: Int
    let insightCount: Int
    let conversationCount: Int
}

struct ImportResult {
    let success: Bool
    let summary: ImportSummary
    let skipped: Int
    let errors: [ImportError]
}
```

---

## Error Handling

### Export Errors

```swift
enum ExportError: Error {
    case encryptionFailed(String)
    case diskSpaceInsufficient
    case serializationFailed(String)
    case partialExportFailed([String]) // List of failed items
}
```

### Import Errors

```swift
enum ImportError: Error {
    case unsupportedVersion(String)
    case invalidFormat(String)
    case missingRequiredField(String)
    case invalidUUID(String)
    case duplicateEntry(UUID)
    case referentialIntegrityViolation(String)
    case decryptionFailed(String)
}
```

---

## Performance Considerations

### Export Performance

**Target**: < 10 seconds for 100 entries with full KG

**Optimization Strategies**:
1. Batch fetch all models upfront
2. Use parallel serialization for large datasets
3. Chunked writing for large JSON files
4. Progress callbacks every 10%

### Import Performance

**Target**: < 15 seconds for 100 entries with full KG

**Optimization Strategies**:
1. Validate before import (fail fast)
2. Batch insert (100 entities at a time)
3. Relationship reconstruction in memory first
4. Single save at end (avoid multiple context saves)
5. Progress callbacks every 10%

### Memory Considerations

**Large Exports** (1000+ entries):
- Stream JSON writing instead of building full structure in memory
- Process in chunks of 100 entries
- Estimated memory usage: ~50MB per 100 entries

---

## Security Considerations

### Encryption Options

**Export Encrypted** (default):
- Entry content remains encrypted in export file
- Export file can be safely stored in cloud
- Requires encryption key to import (same device or key sharing)

**Export Decrypted**:
- Entry content decrypted in export file
- Warning shown to user about security implications
- Suitable for migration to other apps

### Privacy Notes

- User IDs, device IDs NOT included in export
- API keys NOT included
- Export file contains only user's journal data

---

## Testing Strategy

### Unit Tests

1. **JSON Serialization**:
   - Round-trip test: Export → Import → Verify equality
   - All fields populated correctly
   - UUID references maintained

2. **Markdown Formatting**:
   - Date grouping correct
   - Entities formatted properly
   - Special characters escaped

3. **Conflict Resolution**:
   - Skip duplicates works
   - Merge logic correct
   - Replace works

### Integration Tests

1. **Full Export-Import Cycle**:
   - Export 50 entries with full KG
   - Delete all data
   - Import from export
   - Verify 100% data restoration

2. **Large Dataset**:
   - Export 500+ entries
   - Memory usage < 100MB
   - Performance < 30 seconds

---

## Version Migration

### Future Schema Changes

**Version 1.0 → 2.0** (hypothetical):

If new field added to Entry:
```json
{
  "version": "2.0",
  "entries": [{
    ...existing fields...,
    "new_field": "new value"
  }]
}
```

**Import Strategy**:
- Version 1.0 exports compatible with v2.0 app
- New fields use default values
- Version 2.0 exports NOT compatible with v1.0 app

**Recommendation**: Include `min_app_version` in export metadata

---

## Document Control

- **Version**: 1.0 (Design Phase)
- **Author**: AI Assistant
- **Status**: Ready for Implementation
- **Sprint**: 17
- **Next Review**: After implementation complete
