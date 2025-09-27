# Sprint 5 Planning - Calendar Architecture Transition
## Calendar-Based Journal Foundation

**Sprint Duration:** September 27 - October 11, 2025 (14 days)  
**Sprint Goal:** Transition from list-based to calendar-based architecture với data migration và core calendar UI  
**Team Capacity:** 56 hours (extended sprint for major architecture change)  
**Story Points Target:** 15 points

---

## Sprint Overview

### **Sprint Theme:** 📅 **Calendar Foundation Transition**

This sprint represents a **major architectural pivot** từ current list-based journaling approach sang calendar-centric design. The focus is on building calendar UI foundation, implementing one-entry-per-day constraint, và migrating existing data safely.

### **Key Objectives:**
1. **Calendar UI Foundation**: Implement Apple Calendar-style month view với date navigation
2. **Data Migration**: Safely transition existing entries sang date-based structure
3. **Entry Constraint**: Enforce one entry per day với edit-only functionality
4. **Legacy Data Handling**: Resolve conflicts khi multiple entries exist for same date

---

## User Stories và Technical Breakdown

### **US-034: Data Model Migration** *(CRITICAL)*
**Story Points:** 5 | **Priority:** Critical  
**Epic:** Data Migration & Architecture Transition  

**Description:** Là developer, tôi muốn migrate existing entries sang date-based structure để support calendar navigation without data loss.

**Acceptance Criteria:**
- [x] Design migration strategy for existing Entry model
- [x] Add date-based indexing và constraints
- [x] Automatic migration on app launch
- [x] Data integrity validation với rollback capability
- [x] Performance optimization cho large datasets

**Technical Tasks:**
- [x] Update Entry SwiftData model với date primary key
- [x] Create migration script cho existing entries
- [x] Implement conflict resolution logic (multiple entries per day)
- [x] Add migration progress tracking và error handling
- [x] Create rollback mechanism for failed migrations
- [x] Update encryption layer cho new data structure

**Dependencies:** None  
**Risk Level:** High (Data integrity critical)

---

### **US-025: Calendar Month View** *(CRITICAL)*
**Story Points:** 5 | **Priority:** Critical  
**Epic:** Calendar Foundation & UI

**Description:** Là người dùng, tôi muốn xem calendar month view như Apple Calendar để navigate dates intuitively.

**Acceptance Criteria:**
- [x] Month grid layout với proper date alignment
- [x] Current date highlighting và today indicator
- [x] Navigation arrows cho previous/next month
- [x] Content dots hiển thị dates có entries
- [x] Responsive design cho different screen sizes

**Technical Tasks:**
- [x] Design CalendarView SwiftUI component
- [x] Implement month grid với LazyVGrid
- [x] Add date calculation logic và calendar utilities
- [x] Create content indicator system
- [x] Add navigation controls và state management
- [x] Implement accessibility support

**Dependencies:** US-034 (Migration must be completed first)  
**Risk Level:** Medium (Complex UI component)

---

### **US-026: Date Selection & Entry Access** *(CRITICAL)*
**Story Points:** 3 | **Priority:** Critical  
**Epic:** Calendar Foundation & UI

**Description:** Là người dùng, tôi muốn tap vào date để access entry cho ngày đó (create new or edit existing).

**Acceptance Criteria:**
- [x] Tap gesture handling trên calendar dates
- [x] Navigation to entry editing view cho selected date
- [x] Entry creation for empty dates
- [x] Entry editing for dates với existing content
- [x] Save entry với specific date association

**Technical Tasks:**
- [x] Implement date selection handling
- [x] Create DateEntryView component
- [x] Add entry creation/editing logic
- [x] Update entry saving với date constraints
- [x] Add navigation flow management
- [x] Implement date-specific entry retrieval

**Dependencies:** US-025 (Calendar view), US-034 (Data migration)  
**Risk Level:** Low (Straightforward implementation)

---

### **US-028: One Entry Per Day Constraint** *(CRITICAL)*
**Story Points:** 2 | **Priority:** Critical  
**Epic:** Calendar Foundation & UI

**Description:** Là người dùng, mỗi ngày chỉ có một entry duy nhất, edit content thay vì tạo multiple entries.

**Acceptance Criteria:**
- [x] Database constraint: one entry per date maximum
- [x] Edit mode for existing entries instead of creating new
- [x] Clear UI indication when editing vs creating
- [x] Content append/edit functionality
- [x] No duplicate entry creation for same date

**Technical Tasks:**
- [x] Add unique date constraint trong SwiftData model
- [x] Update entry creation logic với date checking
- [x] Implement edit-only mode cho existing entries
- [x] Add UI state management cho create vs edit
- [x] Update service layer với date-based operations
- [x] Add validation và error handling

**Dependencies:** US-026 (Date selection), US-034 (Migration)  
**Risk Level:** Low (Data model constraint)

---

### **US-035: Legacy Data Handling** *(HIGH)*
**Story Points:** 3 | **Priority:** High  
**Epic:** Data Migration & Architecture Transition

**Description:** Là người dùng, multiple entries cùng ngày sẽ được merged hoặc user choice để maintain data integrity.

**Acceptance Criteria:**
- [ ] Detect conflicts khi multiple entries exist for same date
- [ ] Present user với merge options (combine, choose one, manual edit)
- [ ] Conflict resolution UI với preview functionality
- [ ] Data preservation durante merge process
- [ ] Migration summary với conflict resolution results

**Technical Tasks:**
- [ ] Create conflict detection algorithm
- [ ] Design ConflictResolutionView UI
- [ ] Implement merge strategies (concatenate, user choice)
- [ ] Add preview functionality cho merge results
- [ ] Create migration summary reporting
- [ ] Add undo functionality cho migration decisions

**Dependencies:** US-034 (Data migration)  
**Risk Level:** Medium (Complex user interactions)

---

## Sprint Architecture Decisions

### **ADR-013: Calendar-Based Data Architecture** *(To be created)*
- **Status:** To be created in this sprint
- **Context:** Transition from list-based to date-based entry storage
- **Decision:** SwiftData model với date primary key và unique constraints

### **ADR-014: Migration Strategy** *(To be created)*
- **Status:** To be created in this sprint  
- **Context:** Safe migration của existing entries với conflict resolution
- **Decision:** Progressive migration với user involvement cho conflicts

### **ADR-015: Calendar UI Components** *(To be created)*
- **Status:** To be created in this sprint
- **Context:** SwiftUI calendar implementation strategy
- **Decision:** Custom calendar view vs native DatePicker components

---

## Development Approach

### **Phase 1: Migration Foundation (Days 1-3)**
- Design và implement data migration strategy
- Create migration testing với sample data
- Implement rollback mechanisms
- Basic conflict detection logic

### **Phase 2: Calendar UI Core (Days 4-7)**
- Build CalendarView component
- Implement month navigation
- Add date selection handling
- Basic entry access flow

### **Phase 3: Constraint Implementation (Days 8-10)**
- Implement one-entry-per-day constraint
- Update entry creation/editing logic
- Add date-specific operations
- Testing với edge cases

### **Phase 4: Conflict Resolution (Days 11-12)**
- Build conflict resolution UI
- Implement merge strategies
- User testing với real data conflicts
- Migration summary reporting

### **Phase 5: Integration & Testing (Days 13-14)**
- End-to-end testing migration + calendar flow
- Performance validation với large datasets
- UI polish và accessibility
- Documentation update

---

## Technical Challenges

### **High Priority Risks:**

#### **Data Migration Complexity**
- **Risk:** Data loss during migration from list to calendar structure
- **Mitigation:** Comprehensive backup, rollback mechanisms, staged migration
- **Contingency:** Manual data recovery tools

#### **Calendar Performance**
- **Risk:** Slow rendering với large datasets (years of entries)
- **Mitigation:** Lazy loading, date range optimization, caching strategies
- **Contingency:** Simplified calendar view options

#### **Conflict Resolution UX**
- **Risk:** Complex user decisions during migration overwhelm users
- **Mitigation:** Intelligent defaults, preview functionality, guided workflow
- **Contingency:** Automatic merge strategies với manual override

### **Medium Priority Concerns:**
- SwiftUI calendar component complexity
- Date calculations và timezone handling
- Entry editing state management
- Accessibility implementation cho calendar navigation

---

## Definition of Done

### **Data Migration:**
- [ ] 100% data integrity maintained during migration
- [ ] All existing entries successfully mapped to dates
- [ ] Conflict resolution completed với user approval
- [ ] Migration rollback tested và functional
- [ ] Performance acceptable với large datasets

### **Calendar UI:**
- [ ] Month view displays correctly across screen sizes
- [ ] Date navigation smooth và intuitive
- [ ] Content indicators accurately reflect entry status
- [ ] Accessibility support cho calendar navigation
- [ ] Visual design consistent với app theme

### **Entry Management:**
- [ ] One entry per day constraint enforced
- [ ] Date selection opens appropriate entry (new/existing)
- [ ] Entry editing preserves date associations
- [ ] All acceptance criteria validated
- [ ] No data duplication or conflicts

### **Testing:**
- [ ] Migration tested với various data scenarios
- [ ] Calendar UI tested across device sizes
- [ ] Entry creation/editing flows validated
- [ ] Performance benchmarks met
- [ ] Manual testing completed

---

## Success Metrics

### **Functional Targets:**
- **Migration Success Rate:** 100% data preservation với 0% loss
- **Calendar Performance:** <2 second rendering cho any month view
- **Date Navigation:** <1 second response cho date selection
- **User Experience:** Intuitive calendar flow validated through testing

### **Technical Targets:**
- **Memory Usage:** <200MB peak during migration process
- **Calendar Rendering:** <500ms cho month view switches
- **Entry Access:** <1 second từ date tap đến entry editing
- **Migration Time:** <30 seconds cho 100+ entries

---

## Sprint Events

### **Sprint Planning:** September 27, 2025  
- Story sizing và migration strategy finalization
- Architecture decision documentation
- Risk assessment và mitigation planning

### **Daily Standups:** September 28 - October 10
- Migration progress tracking
- Calendar UI development updates
- Blocker identification và resolution

### **Mid-Sprint Review:** October 3, 2025
- Migration testing results
- Calendar UI demo
- Risk reassessment

### **Sprint Review:** October 11, 2025
- Complete calendar foundation demo
- Migration success validation
- User experience walkthrough

### **Sprint Retrospective:** October 11, 2025
- Architecture transition lessons learned
- Development process improvements
- Sprint 6 preparation

---

## Resource Requirements

### **Development Tools:**
- Xcode 15+ với SwiftUI calendar capabilities
- SwiftData migration testing tools
- Calendar component testing frameworks
- Migration data validation utilities

### **External Dependencies:**
- No external API dependencies for this sprint
- Internal dependency: Existing Entry model và encryption system
- Testing devices với various data sizes

---

*This sprint lays the foundation cho calendar-based journaling experience, enabling future sprints to focus on advanced calendar features và time travel functionality.*