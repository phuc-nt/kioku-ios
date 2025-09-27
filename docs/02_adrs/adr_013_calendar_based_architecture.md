# ADR-013: Calendar-Based Data Architecture Transition

**Status:** Proposed  
**Date:** September 27, 2025  
**Deciders:** Development Team  
**Technical Story:** Epic-7, Epic-9 - Calendar Foundation & Data Migration

## Context

The current implementation uses a **list-based journaling approach** where users can create multiple entries at any time, displayed in chronological order. However, user feedback và business requirements clarification revealed that the intended experience should be **calendar-based**, similar to physical journals where each day has a single dedicated space.

### Current Architecture Issues:
- Multiple entries per day creates scattered, unfocused writing experience
- No natural temporal navigation patterns
- Lacks the "nostalgic time travel" feature của physical journals
- Doesn't support easy comparison của same days across years
- Complex for users to find specific daily reflections

### Required Experience:
- **Apple Calendar-style navigation** với month và year views
- **One entry per day** constraint để encourage focused daily reflection
- **Time travel features** để view same day from previous months/years
- **Visual content indicators** (dots) cho quick overview
- **Date-centric workflow** rather than timeline-based

## Decision

We will transition to a **Calendar-Based Data Architecture** với following changes:

### **1. Data Model Changes**
```swift
// Current Entry Model (List-based)
@Model
class Entry {
    var id: UUID
    var content: String
    var createdAt: Date
    var updatedAt: Date
    // ... other fields
}

// New Entry Model (Calendar-based)
@Model  
class Entry {
    var id: UUID
    var content: String
    var date: Date        // Primary date (normalized to day start)
    var createdAt: Date
    var updatedAt: Date
    // ... other fields
    
    // Unique constraint: one entry per date
    init(content: String, date: Date) {
        self.date = Calendar.current.startOfDay(for: date)
        // ...
    }
}
```

### **2. UI Architecture**
- **Primary Interface**: Calendar month view (not entry list)
- **Navigation Pattern**: Calendar → Date Selection → Entry Editing
- **Entry Access**: Tap calendar date để create/edit entry for that day
- **Visual Indicators**: Dots on calendar dates với content

### **3. Data Constraints**
- **Unique Constraint**: Maximum one entry per calendar date
- **Edit-Only Mode**: Existing entries can only be edited, not duplicated
- **Date Normalization**: All dates normalized to start of day (00:00:00)

## Consequences

### **Positive:**
- ✅ **Authentic Journal Experience**: Matches physical journal behavior
- ✅ **Focused Daily Reflection**: One entry per day encourages quality over quantity
- ✅ **Intuitive Navigation**: Calendar interface familiar to all users
- ✅ **Time Travel Features**: Easy comparison across months/years
- ✅ **Visual Content Overview**: Quick dots show writing patterns
- ✅ **Nostalgic Experience**: True "10-year journal" digital implementation

### **Negative:**
- ❌ **Breaking Change**: Major architecture shift requiring migration
- ❌ **Lost Flexibility**: Cannot create multiple entries per day
- ❌ **Complex Migration**: Existing multiple-entries-per-day need resolution
- ❌ **Development Overhead**: New UI components, data migration, testing

### **Neutral:**
- 🔄 **Different UX Mental Model**: Users need to adapt to calendar-first approach
- 🔄 **AI Features Impact**: Knowledge graph will work với dates instead of arbitrary entries
- 🔄 **Search Patterns**: Search will be date-centric rather than content-chronological

## Implementation Strategy

### **Phase 1: Data Migration (Sprint 5)**
1. **Migration Script**: Convert existing entries to date-based structure
2. **Conflict Resolution**: Handle multiple entries per day (merge or user choice)
3. **Data Validation**: Ensure integrity và rollback capability
4. **Backup Strategy**: Complete data backup before migration

### **Phase 2: Calendar UI (Sprint 5-6)**
1. **CalendarView Component**: SwiftUI month view với date grid
2. **Date Selection**: Tap handling và navigation
3. **Content Indicators**: Visual dots cho dates với entries
4. **Navigation Controls**: Month/year switching

### **Phase 3: Entry Constraints (Sprint 5)**
1. **Model Updates**: Add unique date constraints
2. **Service Layer**: Update entry creation/editing logic
3. **UI Updates**: Edit-only mode cho existing entries
4. **Validation**: Prevent duplicate date entries

### **Phase 4: Time Travel (Sprint 6-7)**
1. **Historical Navigation**: Same day previous months/years
2. **Date Picker**: Quick jump to specific dates
3. **Comparison Views**: Side-by-side temporal comparison

## Alternatives Considered

### **Alternative 1: Hybrid Approach**
Allow multiple entries per day but group them by date in UI.
- **Rejected**: Doesn't solve core UX problem và maintains complexity

### **Alternative 2: Keep Current + Add Calendar View**
Maintain list view as primary với optional calendar view.
- **Rejected**: Doesn't enforce focused daily reflection behavior

### **Alternative 3: Week-Based Organization**
Organize entries by week instead of individual days.
- **Rejected**: Doesn't match physical journal inspiration

## Migration Strategy Details

### **Conflict Resolution Options:**
1. **Automatic Merge**: Concatenate multiple entries with timestamps
2. **User Choice**: Present conflict resolution UI for manual selection
3. **Most Recent**: Keep only the latest entry for each date
4. **Longest**: Keep the entry với most content

**Recommended**: **User Choice** with intelligent defaults để maintain user control over data.

### **Migration Process:**
1. **Data Backup**: Complete backup of current entries
2. **Conflict Detection**: Identify dates với multiple entries
3. **User Resolution**: Present conflict UI for user decisions
4. **Data Transformation**: Convert resolved entries to new structure
5. **Validation**: Verify data integrity post-migration
6. **Rollback Option**: Allow reverting migration if issues occur

## Technical Considerations

### **SwiftData Migration:**
- Use SwiftData versioning system cho model updates
- Implement custom migration logic cho complex transformations
- Maintain backward compatibility during transition period

### **Performance Impact:**
- Calendar view requires efficient date-range queries
- Content indicators need optimized counting logic
- Large datasets (years of entries) require lazy loading

### **Date Handling:**
- Timezone normalization critical cho consistent behavior
- Handle daylight saving time transitions
- Support international calendar systems

## Related ADRs

- **ADR-009**: SwiftData Model Design (foundation for this change)
- **ADR-014**: Migration Strategy (to be created)
- **ADR-015**: Calendar UI Components (to be created)

## Review Schedule

- **Initial Review**: Sprint 5 Planning (September 27, 2025)
- **Migration Testing**: October 1, 2025
- **UI Implementation Review**: October 7, 2025
- **Final Validation**: Sprint 5 Review (October 11, 2025)

---

**Decision Approved By:** Development Team  
**Implementation Start:** Sprint 5 (September 27, 2025)  
**Expected Completion:** Sprint 6 (October 25, 2025)