# ADR-002: Data Model Schema Design

**Status:** Approved  
**Date:** September 12, 2025  
**Deciders:** Solo Developer/Product Owner  
**Related Sprint:** Sprint-1-Planning.md → Task 1.3  
**Related ADR:** ADR-001 (Architecture Pattern), ADR-003 (Core Data Concurrency)

***

## Context

The AI-Powered Personal Journal app requires a Core Data schema that supports:

- **Sprint 1 Requirements**: Basic journal entry creation, storage, and retrieval
- **Future AI Integration**: Knowledge graph generation, entity extraction, relationship mapping  
- **Encryption Support**: Field-level encryption for sensitive personal content
- **Performance**: Efficient queries for calendar navigation and search functionality
- **Schema Evolution**: Clean migration path as AI features are added in future sprints

### Current Scope (Sprint 1)
- Store journal entries with content, timestamps, and metadata
- Support calendar-based browsing and date filtering
- Enable encrypted storage of personal content
- Maintain data integrity across app lifecycle

### Future Scope (Sprint 4+)
- AI-generated metadata (themes, entities, emotions, relationships)
- Knowledge graph nodes and connections
- Chat conversation history
- Multiple AI model analysis results

***

## Decision

**Selected Schema: Minimal Viable Entity Model with Future Extensibility**

### Sprint 1 Core Data Model

#### **Entry Entity (Primary)**
```
Entry
├── id: UUID (Primary Key, non-optional)
├── content: String (Encrypted, non-optional) 
├── createdAt: Date (non-optional)
├── modifiedAt: Date (non-optional)
├── version: Int16 (Schema version, default: 1)
└── encryptionMetadata: String? (IV, salt info for decryption)
```

#### **Core Data Configuration**
- **Model Name**: `JournalDataModel.xcdatamodeld`
- **Entity Codegen**: `Manual/None` (custom NSManagedObject subclasses)
- **Delete Rule**: Cascade for future relationships
- **Validation**: Content length max 50,000 characters
- **Migration**: Lightweight migration enabled

### Future Schema Extensions (Sprint 4+)

#### **Planned Entities** *(Not implemented in Sprint 1)*
```
AIAnalysis
├── id: UUID
├── entryId: UUID (FK to Entry)
├── modelName: String (GPT-4, Claude, etc.)
├── extractedEntities: String (JSON)
├── sentiment: String
├── themes: String (JSON array)
├── processedAt: Date
└── version: Int16

KnowledgeNode  
├── id: UUID
├── type: String (Person, Place, Event, Emotion)
├── name: String
├── metadata: String (JSON)
└── createdAt: Date

KnowledgeRelation
├── id: UUID  
├── fromNodeId: UUID (FK to KnowledgeNode)
├── toNodeId: UUID (FK to KnowledgeNode)
├── relationType: String
├── strength: Float
└── sourceEntryId: UUID (FK to Entry)

ChatMessage
├── id: UUID
├── content: String (Encrypted)
├── isFromUser: Bool
├── relatedEntryId: UUID? (FK to Entry)
├── conversationId: UUID
└── timestamp: Date
```

***

## Rationale

### **Why Minimal Schema for Sprint 1:**
- **Agile Principles**: Start simple, evolve based on actual needs[6]
- **Development Speed**: Faster Sprint 1 completion with fewer entities
- **Risk Reduction**: Avoid over-engineering without real AI integration experience
- **Testing Simplicity**: Easier unit testing and data validation

### **Why Single Entry Entity Initially:**
- **Core Data Best Practices**: Start with essential entities, add relationships later[2]
- **Encryption Focus**: Simpler encryption implementation with single content field
- **Performance**: Minimal joins required for basic journaling operations
- **Migration Safety**: Easier to add entities than restructure existing relationships

### **Future Extensibility Design:**
- **UUID Primary Keys**: Enable easy relationship creation without ID conflicts
- **Version Fields**: Support schema evolution and data migration tracking
- **JSON Metadata**: Flexible storage for AI-generated structured data
- **Separate AI Entities**: Clean separation between user content and AI analysis

### **Encryption Integration:**
- **Field-Level Encryption**: Only `content` field encrypted, metadata remains queryable[3]
- **Encryption Metadata**: Store IV and salt info for proper decryption
- **Performance Balance**: Encrypt sensitive data while maintaining query performance

***

## Implementation Guidelines

### **Entry NSManagedObject Implementation:**
```swift
@objc(Entry)
public class Entry: NSManagedObject {
    
    // Encrypted content with transparent encryption/decryption
    var encryptedContent: String {
        get {
            guard let encrypted = content else { return "" }
            return EncryptionService.shared.decrypt(encrypted, 
                                                  metadata: encryptionMetadata) ?? ""
        }
        set {
            let (encrypted, metadata) = EncryptionService.shared.encrypt(newValue)
            content = encrypted
            encryptionMetadata = metadata
            modifiedAt = Date()
        }
    }
    
    // Convenience computed properties
    var dayKey: String {
        Calendar.current.dateInterval(of: .day, for: createdAt)?.start
            .formatted(.iso8601.year().month().day()) ?? ""
    }
}
```

### **Core Data Stack Configuration:**
```swift
// DataController.swift
class DataController: ObservableObject {
    let container = NSPersistentContainer(name: "JournalDataModel")
    
    init() {
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        // Configure for development
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
```

### **Data Service Protocol:**
```swift
protocol DataServiceProtocol {
    func createEntry(content: String) -> Entry
    func fetchEntries(for date: Date) -> [Entry]
    func fetchAllEntries() -> [Entry]
    func updateEntry(_ entry: Entry, content: String)
    func deleteEntry(_ entry: Entry)
    func save() throws
}
```

***

## Consequences

### **Positive:**
- **Fast Sprint 1 Development**: Minimal schema reduces complexity and development time
- **Clean Architecture**: Simple entity model aligns with MVVM pattern from ADR-001
- **Future-Ready**: UUID keys and version fields enable smooth AI integration
- **Testable**: Single entity simplifies unit testing and mock data creation
- **Encryption-Friendly**: Schema designed for transparent field-level encryption
- **Performance**: Minimal overhead for basic journaling operations

### **Negative:**
- **Future Refactoring**: May require data migration when adding AI entities in Sprint 4+
- **Limited Queries**: Single entity limits advanced filtering until knowledge graph addition
- **JSON Storage**: AI metadata in JSON reduces query efficiency compared to normalized schema
- **Schema Debt**: Will accumulate technical debt that must be addressed in future sprints

### **Mitigation Strategies:**
- **Migration Planning**: Design version fields and migration strategy from Sprint 1
- **API Abstraction**: Use service protocols to hide schema complexity from ViewModels
- **Progressive Enhancement**: Add entities incrementally rather than big-bang migrations
- **Documentation**: Maintain clear migration path documentation for each sprint

***

## Migration Strategy

### **Sprint 1 → Sprint 4 (AI Integration):**
```swift
// Lightweight migration steps:
// 1. Add AIAnalysis entity with Entry relationship
// 2. Add KnowledgeNode and KnowledgeRelation entities  
// 3. Update Entry.version to 2
// 4. Migrate existing entries to new relationship structure

// Migration validation:
// - Verify all existing entries maintain data integrity
// - Test encryption/decryption across schema versions
// - Validate performance with new entity relationships
```

### **Core Data Versioning:**
- **Model Version 1**: Sprint 1 (Entry entity only)
- **Model Version 2**: Sprint 4 (AI entities added)
- **Model Version 3**: Sprint 8 (Chat entities added)
- **Lightweight Migration**: Enabled for entity additions, relationship creation

***

## Validation Criteria

### **Sprint 1 Success Metrics:**
- [ ] **CRUD Operations**: All basic entry operations work correctly
- [ ] **Encryption**: Content properly encrypted/decrypted transparently
- [ ] **Performance**: <100ms for typical entry save/load operations
- [ ] **Data Integrity**: No data loss across app restarts and background operations
- [ ] **Calendar Integration**: Efficient date-based filtering for calendar view

### **Future Integration Readiness:**
- [ ] **Migration Path**: Clear strategy for adding AI entities without data loss
- [ ] **Relationship Design**: UUID keys enable efficient foreign key relationships
- [ ] **Query Performance**: Current schema supports future complex queries
- [ ] **Extensibility**: Version fields and metadata support future enhancements

### **Review Triggers:**
- **Sprint 4**: Validate AI entity integration approach
- **Sprint 8**: Assess chat message storage strategy
- **Performance Issues**: If queries exceed 1-second response time
- **Storage Growth**: When entry count exceeds 10,000 records

***

## Alternatives Considered

### **Normalized Multi-Entity Schema (Sprint 1)**
- ✅ **Pros**: Clean separation, better query performance
- ❌ **Cons**: Over-engineering for current needs, slower Sprint 1 development

### **SQLite Direct (No Core Data)**  
- ✅ **Pros**: Full SQL control, potentially better performance
- ❌ **Cons**: More boilerplate, no NSManagedObjectContext benefits, conflicts with SwiftUI patterns

### **JSON Document Storage**
- ✅ **Pros**: Flexible schema, no migration complexity
- ❌ **Cons**: Poor query performance, no Core Data integration, encryption complexity

### **Realm Database**
- ✅ **Pros**: Simpler than Core Data, good performance
- ❌ **Cons**: External dependency, less SwiftUI integration, additional learning curve

***

## References

- [Apple Developer: Creating a Core Data Model](https://developer.apple.com/documentation/coredata/creating-a-core-data-model)
- [WWDC22: Evolve your Core Data Schema](https://developer.apple.com/videos/play/wwdc2022/10120/)
- **Related Decisions**: ADR-001 (MVVM Architecture), ADR-005 (Encryption Strategy)
- **Implementation**: Sprint-1-Planning.md → Tasks 1.3, 4.3

***

**Decision Made By:** Solo Developer  
**Implementation Start:** Sprint 1, Week 1, Day 2  
**Next Review:** Sprint 4 (AI Entity Integration Planning)  
**Schema Version:** 1.0 (Sprint 1 baseline)