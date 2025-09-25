# Sprint 2 Planning Document
## AI-Powered Personal Journal iOS App

**Sprint Number:** 2  
**Sprint Duration:** 2 weeks  
**Sprint Dates:** September 25 - October 8, 2025  
**Team Capacity:** 8 story points (adjusted based on Sprint 1 velocity)  
**Sprint Velocity Target:** 8 story points (realistic baseline)

***

## Cross-References

**← Previous Sprint:** Sprint-1-Planning.md → Sprint 1 Retrospective  
**← Strategic Context:** BRD.md → Section 2.2 (Core Objectives)  
**← Story Details:** Product-Backlog.md → EPIC-1 (Core Journaling Experience)  
**→ Sprint Deliverables:** Sprint-2-Retrospective.md (Post-sprint)

***

## Sprint Goal

**Primary Goal:** Complete core journaling experience với entry browsing và secure storage để enable full user functionality trước AI integration.

**Success Definition:** User can create entries, browse past entries via calendar/list view, với all data encrypted locally. Ready for AI features in Sprint 3.

**Sprint Theme:** "Complete the Foundation" - Finish deferred US-003 và US-004 từ Sprint 1.

***

## Sprint Backlog

### Carry-over from Sprint 1 *(High Priority)*

#### **US-003: Entry Viewing & Navigation (2pts)** ✅ **COMPLETED**
*Source: Sprint-1-Planning.md → Deferred items*  
**Sprint Priority:** Critical | **Business Value:** Enable entry browsing và reflection
**Status:** ✅ Completed September 25, 2025 - All acceptance criteria met

#### **US-004: Secure Local Storage (3pts)** ✅ **COMPLETED**
*Source: Sprint-1-Planning.md → Deferred items*  
**Sprint Priority:** Critical | **Business Value:** Privacy foundation for personal data
**Status:** ✅ Completed September 25, 2025 - All acceptance criteria met
**Implementation:** AES-256-GCM encryption với iOS Keychain, transparent operation

### New Sprint 2 Stories

#### **US-005: Basic Search Functionality (2pts)** ✅ **COMPLETED**
*Source: Product-Backlog.md → EPIC-1 → US-005*  
**Sprint Priority:** Medium | **Business Value:** Enable content discovery
**Status:** ✅ Completed September 25, 2025 - All acceptance criteria met
**Implementation:** Real-time search với case-insensitive filtering, search UI với clear functionality

#### **US-006: Unit Testing Foundation (1pt)**
*Source: Sprint-1 learnings*  
**Sprint Priority:** Medium | **Business Value:** Code quality và regression prevention

***

## Technical Task Breakdown

### **US-003: Entry Viewing & Navigation → Technical Tasks**

**Task 3.1: Entry List View Implementation (3h)**
- [ ] Create EntryListView với SwiftUI List
- [ ] Implement @Query để load entries with pagination
- [ ] Add entry preview với date và content snippet
- [ ] Setup navigation to EntryDetailView
- **Dependencies:** Existing Entry model và DataService
- **Testing:** XcodeBuildMCP automated list scrolling và navigation

**Task 3.2: Calendar View Integration (4h)**
- [ ] Implement calendar-style entry browser
- [ ] Add visual indicators cho dates with entries
- [ ] Connect calendar selection với entry filtering
- [ ] Handle empty states gracefully
- **Decision Point:** Native iOS calendar vs custom implementation
- **Testing:** Automated date selection và entry loading

**Task 3.3: Entry Detail View (2h)**
- [ ] Create read-only entry viewing interface
- [ ] Add edit functionality with navigation back
- [ ] Implement entry deletion với confirmation
- [ ] Add sharing functionality (basic)
- **Dependencies:** Task 3.1
- **Testing:** Full CRUD operations testing

### **US-004: Secure Local Storage → Technical Tasks**

**Task 4.1: SwiftData Encryption Research (2h)**
- [ ] Research SwiftData encryption capabilities
- [ ] Evaluate CryptoKit integration options  
- [ ] Design encryption strategy cho existing data
- [ ] Create encryption utility classes
- **→ ADR Required:** ADR-007-SwiftData-Encryption-Strategy.md

**Task 4.2: Data Migration Implementation (3h)**
- [ ] Implement encryption cho existing entries
- [ ] Create secure key generation với Keychain
- [ ] Add data integrity validation
- [ ] Test migration with existing Kioku data
- **Dependencies:** Task 4.1
- **Risk:** Data loss during migration

**Task 4.3: Performance Validation (2h)**
- [ ] Test encryption/decryption performance
- [ ] Validate app launch time with encrypted data
- [ ] Measure battery impact
- [ ] Optimize if necessary
- **Dependencies:** Task 4.2
- **Success Criteria:** <2s app launch, minimal battery impact

### **US-005: Basic Search Functionality → Technical Tasks**

**Task 5.1: Search Implementation (3h)**
- [ ] Add search bar to EntryListView
- [ ] Implement content-based search với SwiftData predicates
- [ ] Add search results highlighting
- [ ] Handle empty search states
- **Dependencies:** Task 3.1
- **Testing:** Search accuracy và performance

**Task 5.2: Search UX Enhancement (2h)**
- [ ] Add search suggestions
- [ ] Implement search history
- [ ] Add filters (date range, etc.)
- [ ] Optimize search performance
- **Dependencies:** Task 5.1

### **US-006: Unit Testing Foundation → Technical Tasks**

**Task 6.1: Testing Framework Setup (2h)**
- [ ] Configure XCTest với Swift Testing
- [ ] Setup test targets và schemes
- [ ] Create mock DataService cho testing
- [ ] Add test data fixtures
- **Goal:** >80% coverage cho business logic

**Task 6.2: Core Logic Testing (3h)**
- [ ] Test Entry model operations
- [ ] Test DataService CRUD operations  
- [ ] Test encryption/decryption logic
- [ ] Add UI testing với XcodeBuildMCP integration
- **Dependencies:** Task 6.1, Task 4.2

***

## Architecture Decision Points

### **Critical ADRs for Sprint 2:**

**ADR-007: SwiftData Encryption Strategy**
- **Context:** Field-level vs database-level encryption approach
- **Decision Needed:** Week 1, Day 2
- **Impact:** Performance, security, migration complexity

**ADR-008: Calendar UI Implementation**
- **Context:** Native EventKit vs custom SwiftUI calendar
- **Decision Needed:** Week 1, Day 3
- **Impact:** Development time, maintenance, user experience

**ADR-009: Search Architecture**
- **Context:** Real-time vs indexed search approach
- **Decision Needed:** Week 1, Day 4
- **Impact:** Performance, battery usage, search capabilities

### **Deferred Decisions:**
- AI integration patterns → Sprint 3
- Advanced search features → Sprint 4
- Export/backup mechanisms → Sprint 5

***

## Definition of Done

### **User Story Level:**
- [ ] All acceptance criteria met và verified through XcodeBuildMCP testing
- [ ] Unit tests written với >80% coverage for new code
- [ ] Manual testing completed on 2+ device types
- [ ] Code review approved (self-review + documentation)
- [ ] No memory leaks detected via automated testing
- [ ] Basic accessibility implemented

### **Sprint Level:**
- [~] All 4 user stories completed và integrated (3/4 completed: US-003 ✅, US-004 ✅, US-005 ✅)
- [~] App provides complete journaling experience (create ✅, browse ✅, search ✅, secure ✅)
- [✅] Encryption implemented và validated (AES-256-GCM with Keychain)
- [✅] Performance benchmarks met (launch <2s, smooth scrolling, transparent encryption)
- [✅] Critical ADRs documented (ADR-007-SwiftData-Encryption-Strategy.md)
- [ ] Sprint retrospective completed

### **Technical Quality Gates:**
- [ ] No compiler warnings
- [ ] SwiftLint rules passing (setup in Sprint 2)
- [ ] All XcodeBuildMCP automated tests passing
- [ ] Encryption working correctly (no plaintext storage)
- [ ] Search functionality responsive (<1s results)

***

## Risk Management

### **High Priority Risks:**

| Risk | Probability | Impact | Mitigation Strategy |
|------|-------------|--------|-------------------|
| SwiftData encryption complexity blocking development | Medium | High | Research early, có fallback plan với manual encryption |
| Calendar UI implementation exceeding estimates | Medium | Medium | Start với simple list, enhance later |
| Data migration breaking existing entries | Low | High | Thorough backup strategy, staged rollout |
| Search performance issues with large datasets | Low | Medium | Implement pagination, optimize queries |

### **Technical Blockers:**
- **SwiftData limitations:** May need custom encryption layer
- **iOS 17.0+ features:** Ensure compatibility across versions
- **Performance constraints:** Encryption may impact battery life

### **Scope Management:**
- **Must-have:** Entry browsing, basic security
- **Should-have:** Calendar view, search functionality  
- **Could-have:** Advanced search filters, sharing features
- **Won't-have:** AI integration, advanced analytics

***

## Success Metrics

### **Functional Metrics:**
- [ ] **Entry Management:** Create, view, edit, delete operations working
- [ ] **Browsing Experience:** Calendar và list views functional
- [ ] **Search Capability:** Content search với reasonable performance
- [ ] **Data Security:** All entries encrypted, no plaintext storage
- [ ] **Performance:** App launch <2s, smooth UI interactions

### **Technical Metrics:**
- [ ] **Test Coverage:** >80% unit test coverage
- [ ] **Code Quality:** 0 compiler warnings, SwiftLint passing
- [ ] **Security Validation:** No sensitive data in logs/storage
- [ ] **Memory Usage:** No significant leaks detected
- [ ] **Battery Impact:** <5% additional drain from encryption

### **User Experience:**
- [ ] **Intuitive Navigation:** Easy switching between create/browse modes
- [ ] **Search Efficiency:** Quick content discovery
- [ ] **Data Confidence:** User trusts app với personal information
- [ ] **Performance Satisfaction:** No noticeable lag during normal usage

***

## Sprint Ceremonies

### **Daily Standup Questions:**
1. **Progress:** What tasks moved closer to Sprint Goal yesterday?
2. **Today's Focus:** Which user story am I advancing today?
3. **Blockers:** Any architecture decisions or dependencies blocking progress?
4. **Integration:** How does today's work connect với overall user experience?

### **Sprint Events:**
- **Sprint Planning:** September 25, 2025 (this document)
- **Mid-Sprint Review:** October 1, 2025 - assess progress, adjust scope
- **Sprint Review:** October 8, 2025 - demo complete journaling experience
- **Sprint Retrospective:** October 8, 2025 - learnings for Sprint 3

***

## Preparation for Sprint 3

### **Expected Deliverables:**
- [ ] Complete journaling app với security
- [ ] Clean architecture ready for AI integration
- [ ] Comprehensive test suite
- [ ] Performance benchmarks established

### **Sprint 3 Preview:**
- **Theme:** "Intelligence Integration"  
- **Focus:** OpenRouter API integration, AI-powered insights
- **Prerequisites:** Stable foundation with encrypted data storage

***

**Sprint Planning Completed By:** Solo Developer/Product Owner  
**Sprint Commitment:** 8 story points (realistic capacity)  
**Success Definition:** Complete core journaling experience với security foundation  
**Next Planning Session:** Sprint 3 Planning (October 9, 2025)