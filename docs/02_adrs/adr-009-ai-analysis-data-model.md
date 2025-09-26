# ADR-009: AI Analysis Data Model Strategy

**Date:** September 25, 2025  
**Status:** Decided  
**Context:** Sprint 3 - US-009 Single Model Processing  
**Decision Maker:** Development Team  
**Related ADRs:** ADR-002 (SwiftData Implementation), ADR-008 (OpenRouter Integration)

## Context

The Kioku app needs to store AI analysis results for journal entries to enable:

1. **Persistent Insights**: Store extracted entities, themes, và sentiment for future reference
2. **Performance Optimization**: Cache analysis results to avoid redundant API calls
3. **Pattern Recognition**: Enable cross-entry analysis và pattern discovery
4. **User Experience**: Quick access to insights without re-processing
5. **Data Evolution**: Support for multiple AI models và evolving analysis capabilities

## Requirements

### Data Model Requirements
- Store structured analysis results (entities, themes, sentiment) efficiently
- Support multiple analysis versions per entry (different models, updated analysis)
- Enable fast queries for pattern discovery và cross-entry insights
- Maintain relationship với parent Entry while supporting independent lifecycle
- Handle schema evolution as AI capabilities expand

### Performance Requirements
- Fast insertion of new analysis results (<100ms)
- Efficient queries for entry-specific insights (<50ms)
- Support for bulk analysis operations
- Minimal storage overhead for structured data
- Optimized for read-heavy workloads (analysis viewed more than updated)

## Decision

**Selected Approach: Embedded Analysis Model với JSON Storage**

### Core Architecture Decision

**Store analysis results as structured data within a separate SwiftData model**, using JSON encoding for complex nested structures while maintaining queryable fields for common access patterns.

### Data Model Design

#### **AIAnalysis SwiftData Model**
```swift
@Model
public final class AIAnalysis {
    public var id: UUID
    public var entryId: UUID // Foreign key to Entry
    public var modelUsed: String // "openai/gpt-4o-mini", "anthropic/claude-3-haiku"
    public var processingDate: Date
    public var analysisVersion: Int // Schema version for future migrations
    
    // Queryable summary fields (for fast filtering)
    public var overallSentiment: String // "positive", "negative", "neutral", "mixed"
    public var sentimentConfidence: Double
    public var entityCount: Int
    public var themeCount: Int
    
    // Detailed results as JSON (for full structure)
    private var analysisData: Data // Encoded EntryAnalysis struct
    
    // Computed property for structured access
    public var analysis: EntryAnalysis? {
        get { /* decode analysisData */ }
        set { /* encode to analysisData */ }
    }
}
```

#### **In-Memory Analysis Structures**
```swift
public struct EntryAnalysis {
    public let entities: [Entity]
    public let themes: [Theme]
    public let sentiment: Sentiment
    public let summary: String
    
    // Rich nested structures for entities, themes, sentiment
    // Codable for JSON serialization
}
```

### Relationship Design

#### **Entry ↔ AIAnalysis Relationship**
- **One-to-Many**: Entry can have multiple analyses (different models, re-analysis over time)
- **Cascade Delete**: When Entry is deleted, all related analyses are deleted
- **Independent Queries**: Analyses can be queried independently of entries
- **Lazy Loading**: Analysis details loaded only when needed

```swift
// In Entry model
@Relationship(deleteRule: .cascade, inverse: \AIAnalysis.entry)
public var analyses: [AIAnalysis] = []

// Convenience computed property
public var latestAnalysis: AIAnalysis? {
    return analyses.max(by: { $0.processingDate < $1.processingDate })
}
```

## Technical Implementation

### JSON Storage Strategy
```swift
// Encoding analysis results
public var analysis: EntryAnalysis? {
    get {
        guard !analysisData.isEmpty else { return nil }
        return try? JSONDecoder().decode(EntryAnalysis.self, from: analysisData)
    }
    set {
        if let newValue = newValue {
            analysisData = (try? JSONEncoder().encode(newValue)) ?? Data()
            // Update queryable fields
            overallSentiment = newValue.sentiment.overall.rawValue
            sentimentConfidence = newValue.sentiment.confidence
            entityCount = newValue.entities.count
            themeCount = newValue.themes.count
        }
    }
}
```

### Query Optimization Patterns
```swift
// Fast sentiment-based queries
let positiveAnalyses = try context.fetch(
    FetchDescriptor<AIAnalysis>(
        predicate: #Predicate { $0.overallSentiment == "positive" },
        sortBy: [SortDescriptor(\.processingDate, order: .reverse)]
    )
)

// Entity-based pattern discovery (requires JSON querying or separate index)
let allAnalyses = try context.fetch(FetchDescriptor<AIAnalysis>())
let analysesWithPerson = allAnalyses.filter { analysis in
    analysis.analysis?.entities.contains { $0.type == .person } ?? false
}
```

### Migration Strategy
```swift
// Version tracking for schema evolution
public var analysisVersion: Int = 1

// Future migration support
public func migrateToVersion(_ version: Int) {
    switch (analysisVersion, version) {
    case (1, 2):
        // Add new fields, transform existing data
        break
    default:
        break
    }
    analysisVersion = version
}
```

## Alternative Approaches Considered

### Fully Normalized Separate Models
**Approach**: Create separate SwiftData models for Entity, Theme, Sentiment
**Pros**: 
- Perfect relational structure
- Excellent query performance for specific entity/theme searches
- Strong type safety

**Cons**: 
- Complex schema with 5+ interconnected models
- More migration complexity
- Overhead for simple analysis display
- Over-engineering for current use cases

**Decision**: Rejected - Too complex for MVP, would slow development

### JSON-Only Storage in Entry Model
**Approach**: Store analysis as JSON directly in Entry model
**Pros**: 
- Simplest implementation
- Single model to manage
- Easy to implement initially

**Cons**: 
- Difficult to query across analyses
- No analysis versioning or model tracking
- Cannot store multiple analyses per entry
- Poor performance for pattern discovery

**Decision**: Rejected - Limits future capabilities, poor scalability

### External Database/Core Data
**Approach**: Use separate database system for analysis storage
**Pros**: 
- More sophisticated querying capabilities
- Better performance for complex queries
- Advanced indexing options

**Cons**: 
- Additional complexity and dependencies
- Breaks from SwiftData consistency
- More complex backup và sync scenarios
- Overkill for current requirements

**Decision**: Rejected - Inconsistent with chosen architecture, too complex

### Document-Based Storage (SQLite JSON)
**Approach**: Use SQLite's JSON capabilities directly
**Pros**: 
- Flexible querying of JSON structures
- Good performance for semi-structured data
- Familiar SQL interface

**Cons**: 
- Bypasses SwiftData benefits
- Manual schema management
- Less SwiftUI integration
- Requires SQL expertise

**Decision**: Rejected - Conflicts với SwiftData strategy

## Benefits of Selected Approach

### **Development Efficiency**
- Single additional SwiftData model (simple to understand và maintain)
- Familiar patterns from existing Entry/DataService implementation  
- Easy to extend with new analysis fields
- Good SwiftUI integration với @Query

### **Performance Characteristics**
- Fast queries for common operations (sentiment, model used, date)
- Efficient storage of complex nested data structures
- Lazy loading of detailed analysis data
- Good performance for batch operations

### **Flexibility và Evolution**
- Support for multiple analysis versions per entry
- Easy to add new AI models và analysis types
- Schema versioning for future enhancements
- Can evolve toward more sophisticated querying as needed

### **Data Integrity**
- Proper relationships với cascade deletes
- Consistent with existing encryption strategy
- Works seamlessly với existing backup systems
- Clear ownership và lifecycle management

## Implementation Plan

### Phase 1: Basic Analysis Storage (Sprint 3)
1. **AIAnalysis Model**: Implement core SwiftData model với JSON storage
2. **Entry Relationship**: Add analyses relationship to Entry model
3. **Basic Queries**: Implement simple analysis retrieval và storage
4. **Integration**: Connect AIAnalysisService với data persistence

### Phase 2: Query Optimization (Sprint 4)
1. **Performance Indexing**: Optimize queries for common access patterns
2. **Batch Operations**: Efficient bulk analysis storage và retrieval
3. **Migration Support**: Implement version tracking và data migration
4. **Advanced Queries**: Cross-entry pattern discovery capabilities

### Phase 3: Advanced Features (Sprint 5+)
1. **Analysis Comparison**: Compare results across different models
2. **Historical Tracking**: Track analysis changes over time
3. **Pattern Discovery**: Advanced querying for insight discovery
4. **Export/Import**: Support for analysis data portability

## Schema Evolution Strategy

### Version 1 (Sprint 3): MVP Schema
- Basic entity, theme, sentiment storage
- Single analysis per entry workflow
- JSON encoding for complex structures

### Version 2 (Sprint 4): Enhanced Analytics  
- Multiple analyses per entry support
- Model comparison capabilities
- Enhanced entity relationship mapping

### Version 3 (Sprint 5+): Advanced Insights
- Cross-entry pattern storage
- Analysis confidence tracking
- User feedback integration

### Migration Approach
```swift
// Automatic migration detection
func migrateAnalysisDataIfNeeded() {
    let currentVersion = 1
    let targetVersion = 2
    
    if currentVersion < targetVersion {
        // Perform incremental migrations
        for version in (currentVersion + 1)...targetVersion {
            migrateToVersion(version)
        }
    }
}
```

## Performance Expectations

### Storage Efficiency
- **Per Analysis**: ~2-5KB for typical journal entry analysis
- **JSON Overhead**: ~10-20% compared to fully normalized approach
- **Relationship Overhead**: Minimal with proper SwiftData optimization
- **Total Impact**: <1MB for 1000+ analyzed entries

### Query Performance
- **Single Analysis**: <10ms for entry-specific analysis retrieval
- **Sentiment Queries**: <50ms for filtering by sentiment across 1000+ analyses
- **Pattern Discovery**: 100-500ms for complex cross-entry queries
- **Bulk Operations**: <1s for processing 100+ analyses

### Memory Usage
- **Lazy Loading**: Analysis details loaded only when accessed
- **Caching**: Automatic SwiftData caching for frequently accessed analyses
- **Memory Footprint**: <50MB for typical usage patterns

## Success Criteria

### Functional Success
- [ ] **Data Persistence**: All analysis results stored và retrieved correctly
- [ ] **Relationship Integrity**: Entry-analysis relationships maintained properly
- [ ] **Query Performance**: Fast access to analysis data (<100ms typical queries)
- [ ] **Schema Flexibility**: Easy to add new analysis fields và types

### Quality Metrics
- [ ] **Data Accuracy**: 100% fidelity for stored vs retrieved analysis data
- [ ] **Performance**: Analysis storage <100ms, retrieval <50ms  
- [ ] **Memory Efficiency**: Minimal memory overhead for large datasets
- [ ] **Migration Success**: Seamless schema evolution without data loss

## Risks và Mitigation

### Technical Risks
| Risk | Impact | Probability | Mitigation |
|------|--------|-------------|------------|
| JSON query performance limitations | Medium | Low | Add indexed fields for common queries |
| SwiftData relationship complexity | Medium | Low | Thorough testing, simple relationship design |
| Analysis data corruption | High | Very Low | Validation, backup strategies |
| Schema migration failures | High | Low | Incremental migration, rollback support |

### Future Scalability Concerns
- **Large Dataset Performance**: May need optimization for thousands of analyses
- **Complex Query Requirements**: Might eventually need more sophisticated querying
- **Multi-Device Sync**: Analysis data needs careful sync strategy design

## Future Considerations

### Potential Enhancements
- **Full-Text Search**: Search within analysis summaries và themes
- **Advanced Indexing**: Specialized indexes for entity và theme queries
- **Analysis Caching**: Intelligent caching strategies for frequently accessed patterns
- **Real-Time Updates**: Live updates as new analyses are processed

### Integration Opportunities
- **CloudKit Sync**: Synchronize analyses across devices securely
- **Export Formats**: Export analysis data in various formats (JSON, CSV)
- **Analytics Dashboard**: Aggregate analysis data for personal insights
- **Third-Party Integration**: Connect với other personal analytics tools

## References

- [SwiftData Relationships Documentation](https://developer.apple.com/documentation/swiftdata/modeling-data-with-swiftdata)
- [JSON Storage Best Practices](https://developer.apple.com/documentation/foundation/archives_and_serialization)
- [SwiftData Performance Optimization](https://developer.apple.com/documentation/swiftdata)
- [Core Data to SwiftData Migration Guide](https://developer.apple.com/documentation/swiftdata/migrating-from-core-data-to-swiftdata)

---

**Related Documents:**
- ADR-002-SwiftData-Implementation.md → Base data architecture
- ADR-008-OpenRouter-Integration-Strategy.md → AI service integration
- Sprint-3-Planning.md → Implementation timeline và tasks