# ADR-014: Data Migration Strategy for Calendar Architecture

**Status:** Proposed  
**Date:** September 27, 2025  
**Deciders:** Development Team  
**Technical Story:** US-034, US-035 - Data Migration & Legacy Data Handling

## Context

Following ADR-013's decision to transition to calendar-based architecture, we need a robust strategy to migrate existing journal entries from the current list-based structure to date-based organization. 

### Migration Challenges:
- **Multiple Entries Per Day**: Current system allows unlimited entries per day
- **Date Assignment**: Existing entries use `createdAt` timestamp, need calendar date mapping
- **Data Integrity**: Zero data loss tolerance during migration
- **User Experience**: Migration should be seamless và transparent
- **Conflict Resolution**: Multiple entries on same date need user-guided resolution
- **Rollback Capability**: Users should be able to revert if unsatisfied

### Current Data Structure:
```swift
@Model
class Entry {
    var id: UUID
    var content: String
    var createdAt: Date     // Full timestamp
    var updatedAt: Date
    var encryptedContent: Data
    // AI analysis fields...
}
```

### Target Data Structure:
```swift
@Model
class Entry {
    var id: UUID
    var content: String
    var date: Date          // Normalized to day start (00:00:00)
    var createdAt: Date
    var updatedAt: Date
    var encryptedContent: Data
    // Unique constraint on date
}
```

## Decision

We will implement a **Progressive User-Guided Migration Strategy** với following approach:

### **1. Migration Phases**

#### **Phase 1: Pre-Migration Analysis**
- Scan existing entries để identify migration complexity
- Detect date conflicts (multiple entries per day)
- Calculate migration scope và estimated time
- Create complete data backup

#### **Phase 2: User Education & Consent**
- Present migration overview với clear explanation
- Show conflict preview (how many dates have multiple entries)
- Obtain explicit user consent để proceed
- Provide option to backup current data

#### **Phase 3: Conflict Resolution**
- Present conflicts to user với resolution options
- Allow preview của merge strategies
- Enable manual editing of merged content
- Save user preferences for future conflicts

#### **Phase 4: Data Transformation**
- Apply user-selected resolution strategies
- Transform entries to calendar structure
- Update database schema với constraints
- Validate data integrity

#### **Phase 5: Post-Migration Validation**
- Verify all entries correctly migrated
- Test calendar functionality với real data
- Provide migration summary report
- Enable rollback option for 24 hours

### **2. Conflict Resolution Strategies**

#### **Strategy A: Smart Merge (Recommended Default)**
```swift
// Example merged entry
Original Entry 1 (09:30): "Morning reflection on productivity goals"
Original Entry 2 (14:20): "Lunch meeting went well, productive discussion"  
Original Entry 3 (21:15): "Evening summary: accomplished most daily tasks"

Merged Entry: 
"Morning reflection on productivity goals

[14:20] Lunch meeting went well, productive discussion

[Evening] Evening summary: accomplished most daily tasks"
```

#### **Strategy B: User Choice**
- Present all entries for the date
- Allow user to select primary content
- Option to append additional content
- Preserve original timestamps in annotations

#### **Strategy C: Latest Only**
- Keep only the most recent entry for each date
- Archive older entries với reference links
- Maintain original entries in separate "legacy" section

#### **Strategy D: Longest Content**
- Keep entry với most substantial content
- Append brief summaries of other entries
- Preserve key information from all entries

### **3. Migration UI Flow**

```
App Launch → Migration Check → Conflicts Detected
     ↓
Migration Overview Screen
     ↓
Conflict Resolution (per date)
     ↓
Preview Merged Results
     ↓
Confirm & Execute Migration
     ↓
Migration Progress
     ↓
Success Summary + Calendar Launch
```

## Implementation Details

### **Migration Service Architecture**

```swift
class MigrationService {
    // Phase 1: Analysis
    func analyzeMigrationComplexity() -> MigrationAnalysis
    func detectDateConflicts() -> [DateConflict]
    func createBackup() -> BackupResult
    
    // Phase 2: User Interaction
    func presentMigrationOverview() -> UserConsent
    func showConflictResolution() -> [ConflictResolution]
    
    // Phase 3: Execution
    func executeMigration(strategies: [ConflictResolution]) -> MigrationResult
    func validateMigration() -> ValidationResult
    
    // Phase 4: Rollback
    func rollbackMigration() -> RollbackResult
}

struct DateConflict {
    let date: Date
    let entries: [Entry]
    let recommendedStrategy: MergeStrategy
    var userChoice: MergeStrategy?
}

struct MigrationAnalysis {
    let totalEntries: Int
    let conflictDates: Int
    let estimatedTime: TimeInterval
    let recommendedStrategies: [Date: MergeStrategy]
}
```

### **Data Safety Measures**

#### **Backup Strategy:**
1. **SQLite Backup**: Complete database file backup before migration
2. **Export Backup**: JSON export của all entries với full metadata
3. **Encrypted Backup**: Maintain encryption during backup process
4. **Cloud Backup**: Optional upload to user's cloud storage

#### **Rollback Mechanism:**
1. **24-Hour Window**: Allow rollback for 24 hours post-migration
2. **Original Data Preservation**: Keep original entries in separate table during rollback period
3. **State Restoration**: Restore both data và UI state to pre-migration
4. **Selective Rollback**: Option to rollback specific dates if issues found

### **Performance Considerations**

#### **Migration Performance:**
- **Batch Processing**: Process entries in batches of 50-100
- **Background Processing**: Use background tasks để avoid UI blocking
- **Progress Tracking**: Real-time progress updates với ETA
- **Memory Management**: Release processed entries to avoid memory pressure

#### **Post-Migration Performance:**
- **Index Creation**: Add indexes on date field for fast calendar queries
- **Query Optimization**: Optimize date range queries cho calendar view
- **Lazy Loading**: Load only visible month data initially

## User Experience Design

### **Migration Overview Screen:**
```
📅 Updating Kioku to Calendar View

Your journal is being upgraded to a calendar-based 
experience, just like a physical journal!

✨ What's changing:
• Each day will have one focused entry
• Navigate by calendar dates
• Compare same days across years

📊 Your data:
• 127 total entries to migrate
• 23 dates with multiple entries need attention
• Estimated time: 2-3 minutes

[Preview Conflicts] [Start Migration]
```

### **Conflict Resolution Screen:**
```
📅 September 15, 2025 (3 entries)

How would you like to combine these entries?

○ Smart merge (recommended)
   "Morning thoughts... [2:30 PM] Lunch update... 
    [Evening] Daily summary..."

○ Choose primary entry
   [Preview each entry separately]

○ Manual edit
   [Open text editor with combined content]

[Preview Result] [Apply to Similar Dates] [Next]
```

## Testing Strategy

### **Migration Testing:**
1. **Unit Tests**: Test migration logic với various data scenarios
2. **Integration Tests**: Full migration flow với sample datasets
3. **Performance Tests**: Large dataset migration (1000+ entries)
4. **Error Handling Tests**: Network interruption, low storage, etc.
5. **User Experience Tests**: Migration flow usability

### **Test Data Scenarios:**
- **Simple Case**: No conflicts, straightforward date mapping
- **Heavy Conflicts**: Multiple entries per day for most dates
- **Edge Cases**: Same-minute entries, timezone changes, corrupt data
- **Large Dataset**: Stress test với years of entries
- **Empty Dataset**: New user với no existing entries

## Risk Mitigation

### **High-Risk Scenarios:**

#### **Data Loss Risk**
- **Mitigation**: Multiple backup layers, validation at each step
- **Detection**: Checksum validation before và after migration
- **Recovery**: Automatic rollback if data loss detected

#### **Migration Failure Mid-Process**
- **Mitigation**: Atomic transactions, checkpoint system
- **Detection**: Progress validation và integrity checks
- **Recovery**: Resume from last successful checkpoint

#### **User Abandonment During Migration**
- **Mitigation**: Save migration state, allow resuming later
- **Detection**: Track migration progress và user interactions
- **Recovery**: Graceful migration resumption on next app launch

#### **Performance Issues With Large Datasets**
- **Mitigation**: Background processing, progress indication
- **Detection**: Monitor memory usage và processing time
- **Recovery**: Batch size adjustment, user notification options

## Rollback Strategy

### **Rollback Triggers:**
- User explicitly requests rollback within 24 hours
- Data integrity validation fails
- Critical bugs discovered in calendar functionality
- User satisfaction survey indicates major issues

### **Rollback Process:**
1. **Data Restoration**: Restore original entries from backup
2. **Schema Reversion**: Revert database schema to pre-migration
3. **UI State Reset**: Return to list-based interface
4. **User Notification**: Explain rollback reason và next steps
5. **Feedback Collection**: Gather user feedback for improvement

## Alternatives Considered

### **Alternative 1: Automatic Merge Without User Input**
- **Rejected**: Users should have control over their personal data consolidation

### **Alternative 2: Gradual Migration**
- **Rejected**: Would create inconsistent user experience während transition period

### **Alternative 3: Optional Migration**
- **Rejected**: Would maintain two different data models indefinitely

### **Alternative 4: Background Migration**
- **Rejected**: Complex conflicts require user attention và decision-making

## Success Metrics

### **Migration Success Criteria:**
- **Data Integrity**: 100% data preservation với no content loss
- **User Satisfaction**: >90% user approval post-migration
- **Performance**: Migration completes within estimated time
- **Error Rate**: <1% migration failures requiring rollback
- **Calendar Functionality**: All calendar features work với migrated data

### **Monitoring Metrics:**
- Migration completion rate
- Conflict resolution preferences
- Rollback requests și reasons
- Performance benchmarks
- User engagement post-migration

## Related ADRs

- **ADR-013**: Calendar-Based Data Architecture (parent decision)
- **ADR-009**: SwiftData Model Design (data layer foundation)
- **ADR-015**: Calendar UI Components (UI implementation)

## Implementation Timeline

- **Week 1**: Migration service development + testing
- **Week 2**: Conflict resolution UI + user experience design  
- **Week 3**: Integration testing + performance validation
- **Week 4**: User acceptance testing + rollback testing

---

**Decision Approved By:** Development Team  
**Implementation Start:** Sprint 5 (September 27, 2025)  
**Expected Completion:** Sprint 5 (October 11, 2025)