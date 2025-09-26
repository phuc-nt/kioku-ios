# Product Backlog
## AI-Powered Personal Journal iOS App

**Created:** September 11, 2025  
**Last Updated:** September 11, 2025  
**Document Version:** 1.0  
**Total Story Points:** 85 (estimated)

***

## Document Cross-References

**← Strategic Context:** BRD.md → Sections 1-2 (Vision & Objectives)  
**→ Implementation Details:** Sprint-X-Planning.md files  
**→ Architecture Decisions:** /docs/adrs/ directory  

***

## Backlog Overview

### Project Status
- **Total Epics**: 6
- **Ready for Development**: 12 user stories (Sprint 1-2)
- **Estimated MVP Release**: 16-20 weeks (based on 2-week sprints)
- **Current Priority**: Foundation features (Epics 1-2)

### Velocity Planning
- **Assumed Team Velocity**: 8-12 story points per sprint
- **Sprint Duration**: 2 weeks
- **MVP Target**: Epics 1-4 completion
- **Enhanced Release**: All 6 epics

***

## Epic Breakdown

### 🏆 **EPIC-1: Core Journaling Experience**
**Business Value**: Foundation cho tất cả AI-powered features  
**Total Story Points**: 15 | **Priority**: Must Have | **Target Release**: MVP  
**Business Context**: ← BRD.md → Section 2.2 Core Objectives #1-2

#### User Stories:

**US-001: Quick Entry Creation**
- **Story Points**: 3 | **Priority**: Critical | **Sprint**: 1
- **Description**: Là người dùng, tôi muốn mở app và ghi nhanh một thought trong vài giây để không bỏ lỡ ý tưởng quan trọng
- **Acceptance Criteria**: App opens to writing interface, auto-focus, immediate typing capability
- **Dependencies**: None
- **→ Implementation**: Sprint-1-Planning.md → US-001

**US-002: Auto-Save Functionality**  
- **Story Points**: 2 | **Priority**: Critical | **Sprint**: 1
- **Description**: Là người dùng, tôi muốn entries tự động save để không lo mất data khi app bị interrupt
- **Acceptance Criteria**: 2-second auto-save, background save, visual indicators
- **Dependencies**: US-001
- **→ Implementation**: Sprint-1-Planning.md → US-002

**US-003: Entry Viewing & Navigation** ✅ **COMPLETED**
- **Story Points**: 2 | **Priority**: High | **Sprint**: 2  
- **Description**: Là người dùng, tôi muốn browse past entries theo date để easily find previous thoughts
- **Acceptance Criteria**: ✅ Entry list view, entry detail view, navigation, swipe-to-delete
- **Dependencies**: US-001, US-002
- **→ Implementation**: Sprint-2-Planning.md → US-003
- **Status**: ✅ Completed September 25, 2025

**US-004: Secure Local Storage** ✅ **COMPLETED**
- **Story Points**: 3 | **Priority**: Critical | **Sprint**: 2
- **Description**: Là người dùng, tôi muốn personal data được securely stored để maintain privacy  
- **Acceptance Criteria**: ✅ AES-256-GCM encryption, iOS Keychain integration, transparent operation
- **Dependencies**: US-001
- **→ Implementation**: Sprint-2-Planning.md → US-004
- **Status**: ✅ Completed September 25, 2025 - Full field-level encryption implemented

**US-005: Basic Search Functionality** ✅ **COMPLETED**
- **Story Points**: 2 | **Priority**: Medium | **Sprint**: 2
- **Description**: Là người dùng, tôi muốn search trong entries để quickly find specific content
- **Acceptance Criteria**: ✅ Text search, case-insensitive filtering, clear functionality, results highlighting
- **Dependencies**: US-003
- **Status**: ✅ Completed September 25, 2025 - Real-time search với responsive UI

**US-006: UI Testing Foundation với XcodeBuildMCP** ✅ **COMPLETED**
- **Story Points**: 1 | **Priority**: Medium | **Sprint**: 2
- **Description**: Là developer, tôi muốn comprehensive UI testing suite để ensure quality và prevent regressions
- **Acceptance Criteria**: ✅ Complete test scenarios cho all Sprint 1-2 features, XcodeBuildMCP automation, regression prevention
- **Dependencies**: US-001, US-002, US-003, US-004, US-005
- **Status**: ✅ Completed September 25, 2025 - Full UI testing coverage với automation

**US-007: Entry Editing Capabilities** *(Moved from US-005)*
- **Story Points**: 2 | **Priority**: High | **Sprint**: 3
- **Description**: Là người dùng, tôi muốn edit past entries để correct mistakes hoặc add thoughts
- **Acceptance Criteria**: ✅ Full CRUD operations, version tracking, edit indicators
- **Dependencies**: US-003
- **Status**: ✅ **Completed September 26, 2025** - Sprint 3

***

### 🧠 **EPIC-2: AI Knowledge Processing Foundation**
**Business Value**: Transform raw entries thành structured insights  
**Total Story Points**: 18 | **Priority**: Must Have | **Target Release**: MVP  
**Business Context**: ← BRD.md → Section 2.2 Core Objectives #3

#### User Stories:

**US-008: OpenRouter API Integration** *(Renumbered from US-007)*
- **Story Points**: 3 | **Priority**: Critical | **Sprint**: 3
- **Description**: Là developer, tôi muốn integrate với OpenRouter API để access multiple AI models
- **Acceptance Criteria**: ✅ API client, authentication, error handling, basic model access
- **Dependencies**: US-004 (secure key storage)
- **Status**: ✅ **Completed September 26, 2025** - Sprint 3
- **Technical Notes**: HTTP client, retry logic, rate limiting - Full implementation

**US-009: Single Model Processing** *(Renumbered from US-008)*
- **Story Points**: 3 | **Priority**: High | **Sprint**: 3  
- **Description**: Là người dùng, tôi muốn AI analyze một entry để extract basic themes và entities
- **Acceptance Criteria**: ✅ Process single entry, extract entities, basic sentiment analysis, UI integration
- **Dependencies**: US-008 (OpenRouter API)
- **Status**: ✅ **Completed September 26, 2025** - Sprint 3
- **Technical Notes**: GPT-4o-mini default model, full AI analysis service implemented

**US-009: Knowledge Graph Generation**
- **Story Points**: 8 | **Priority**: High | **Sprint**: 5
- **Description**: Là người dùng, tôi muốn system automatically create connections giữa entries để discover patterns
- **Acceptance Criteria**: Entity relationship mapping, connection storage, relationship types
- **Dependencies**: US-008  
- **Technical Notes**: Graph database choice, entity recognition pipeline

**US-010: Batch Processing Capability**
- **Story Points**: 2 | **Priority**: Medium | **Sprint**: 6
- **Description**: Là người dùng, tôi muốn reprocess entire journal với updated AI models để improve insights
- **Acceptance Criteria**: Background processing, progress indicators, selective reprocessing  
- **Dependencies**: US-009

***

### 🔍 **EPIC-3: Intelligent Memory Review**
**Business Value**: Enhanced self-reflection experience  
**Total Story Points**: 12 | **Priority**: Should Have | **Target Release**: MVP+1  
**Business Context**: ← BRD.md → Section 1.2 Value Proposition

#### User Stories:

**US-011: Multi-Dimensional Entry Views**
- **Story Points**: 4 | **Priority**: High | **Sprint**: 7
- **Description**: Là người dùng, tôi muốn view entries theo different dimensions (date, theme, emotion, people)
- **Acceptance Criteria**: Calendar view, theme clusters, people mentioned, emotion timeline
- **Dependencies**: US-009 (knowledge graph)

**US-012: AI-Suggested Connections**
- **Story Points**: 5 | **Priority**: High | **Sprint**: 7  
- **Description**: Là người dùng, tôi muốn see "related experiences" và "similar thoughts" từ past entries
- **Acceptance Criteria**: "On this day" feature, similar content suggestions, pattern recognition
- **Dependencies**: US-009, US-011

**US-013: Contextual Review Actions**
- **Story Points**: 3 | **Priority**: Medium | **Sprint**: 8
- **Description**: Là người dùng, tôi muốn seamlessly transition từ viewing entries sang deeper exploration
- **Acceptance Criteria**: "Talk about this" buttons, "See patterns" actions, smooth navigation
- **Dependencies**: US-012

***

### 💬 **EPIC-4: Conversational AI Companion**  
**Business Value**: Personalized insights và guidance  
**Total Story Points**: 15 | **Priority**: Should Have | **Target Release**: MVP+1  
**Business Context**: ← BRD.md → Section 2.2 Core Objectives #4

#### User Stories:

**US-014: Basic Chat Interface**
- **Story Points**: 3 | **Priority**: High | **Sprint**: 8
- **Description**: Là người dùng, tôi muốn chat với AI về my personal experiences
- **Acceptance Criteria**: Chat UI, message threading, typing indicators, response streaming
- **Dependencies**: US-007 (API integration)

**US-015: Context-Aware Conversations**  
- **Story Points**: 5 | **Priority**: High | **Sprint**: 9
- **Description**: Là người dùng, tôi muốn AI remember previous conversations và journal context
- **Acceptance Criteria**: Conversation history, context injection, cross-session memory
- **Dependencies**: US-014, US-009 (knowledge graph)

**US-016: AI Insight Generation**
- **Story Points**: 5 | **Priority**: Medium | **Sprint**: 10  
- **Description**: Là người dùng, tôi muốn AI provide proactive insights về patterns trong journal
- **Acceptance Criteria**: Pattern observations, growth suggestions, trend analysis
- **Dependencies**: US-015, US-012

**US-017: Conversation Memory Integration**
- **Story Points**: 2 | **Priority**: Low | **Sprint**: 11
- **Description**: Là người dùng, tôi muốn chat conversations contribute back to knowledge graph
- **Acceptance Criteria**: Extract insights from conversations, update graph, track conversation topics
- **Dependencies**: US-016

***

### 🎨 **EPIC-5: Multi-Model AI & UI/UX Enhancement** *(NEW)*
**Business Value**: Advanced AI flexibility và polished user experience  
**Total Story Points**: 13 | **Priority**: Nice to Have | **Target Release**: Enhanced  
**Business Context**: ← BRD.md → Section 1.2 Flexible AI Experience

#### User Stories:

**US-018: AI Model Selection Interface**
- **Story Points**: 3 | **Priority**: Medium | **Sprint**: 12
- **Description**: Là người dùng, tôi muốn choose different AI models để experiment với different analysis approaches
- **Acceptance Criteria**: Model selection UI, model comparison info, switching capability
- **Dependencies**: US-007 (API integration)
- **Technical Notes**: Support GPT-4, Claude-3, Llama, Gemini models

**US-019: Multiple Knowledge Base Management**
- **Story Points**: 4 | **Priority**: Medium | **Sprint**: 12
- **Description**: Là người dùng, tôi muốn maintain different knowledge bases generated by different models
- **Acceptance Criteria**: KB switching, model attribution, comparison views
- **Dependencies**: US-018, US-009

**US-020: Enhanced UI/UX Polish**  
- **Story Points**: 4 | **Priority**: Medium | **Sprint**: 13
- **Description**: Là người dùng, tôi muốn polished, intuitive interface để enhance overall experience
- **Acceptance Criteria**: Refined animations, improved typography, better visual hierarchy, accessibility
- **Dependencies**: All core features completed
- **Technical Notes**: Focus on writing flow, navigation smoothness, visual feedback

**US-021: Model Performance Analytics**
- **Story Points**: 2 | **Priority**: Low | **Sprint**: 14  
- **Description**: Là người dùng, tôi muốn understand which AI models work best cho my writing style
- **Acceptance Criteria**: Model usage tracking, insight quality metrics, recommendation system
- **Dependencies**: US-019, US-016

***

### 🔒 **EPIC-6: Privacy & Data Control** *(Moved from EPIC-5)*
**Business Value**: User trust và data sovereignty  
**Total Story Points**: 12 | **Priority**: Must Have | **Target Release**: MVP+1  
**Business Context**: ← BRD.md → Section 4.3 Security Requirements

#### User Stories:

**US-022: Google Drive Backup Integration**
- **Story Points**: 5 | **Priority**: High | **Sprint**: 15
- **Description**: Là người dùng, tôi muốn optional backup tới personal Google Drive để avoid data loss
- **Acceptance Criteria**: Drive API integration, encrypted uploads, sync status, user control
- **Dependencies**: US-004 (encryption foundation)

**US-023: Data Export/Import Functionality**
- **Story Points**: 3 | **Priority**: Medium | **Sprint**: 16
- **Description**: Là người dùng, tôi muốn export journal data để maintain full control over personal information
- **Acceptance Criteria**: JSON export, encrypted backups, import validation, data portability
- **Dependencies**: US-022

**US-024: Privacy Controls Dashboard**
- **Story Points**: 4 | **Priority**: Medium | **Sprint**: 17
- **Description**: Là người dùng, tôi muốn granular control over AI processing và data sharing
- **Acceptance Criteria**: Privacy settings, AI processing toggles, data usage transparency
- **Dependencies**: US-007, US-022

***

## Future Releases (Not Prioritized)

### 🎤 **EPIC-7: Voice Integration**
**Estimated Story Points**: 20  
**Business Value**: Accessibility và convenience enhancement

#### Potential User Stories:
- **US-025**: Voice-to-text entry creation
- **US-026**: Audio memo attachments  
- **US-027**: Voice conversations với AI assistant
- **US-028**: Multilingual voice support

### 📊 **EPIC-8: Analytics & Advanced Insights**  
**Estimated Story Points**: 25  
**Business Value**: Data-driven self-improvement

#### Potential User Stories:
- **US-029**: Personal analytics dashboard
- **US-030**: Mood tracking integration
- **US-031**: Goal setting và progress tracking
- **US-032**: Habit correlation analysis

### 🌐 **EPIC-9: Social & Community Features**
**Estimated Story Points**: 30  
**Business Value**: Community building và shared growth

#### Potential User Stories:
- **US-033**: Anonymous insight sharing
- **US-034**: Community challenges
- **US-035**: Mentor-mentee connections
- **US-036**: Group reflection sessions

***

## Backlog Refinement Notes

### Recent Updates
- **[Sept 11, 2025]**: Created initial backlog from BRD requirements
- **[Sept 11, 2025]**: Moved multi-model switching to new EPIC-5 với UI enhancements
- **[Sept 11, 2025]**: Reorganized privacy features to EPIC-6 for better logical grouping

### Prioritization Strategy
- **MoSCoW Method**: Must Have (Epics 1-2, 6), Should Have (Epics 3-4), Could Have (Epic 5)
- **Value vs Effort**: Prioritizing high-value, lower-effort items first
- **Risk Mitigation**: Technical foundation items prioritized to reduce later risks

### Dependencies Management
- **Critical Path**: US-001 → US-007 → US-009 → US-015 (core value chain)
- **Parallel Development**: UI work can proceed alongside AI integration
- **Risk Areas**: OpenRouter API integration, knowledge graph complexity

***

## Sprint Assignment Overview

### **Phase 1: Foundation (Sprints 1-3)** ✅ **COMPLETED**
- **Sprint 1**: ✅ US-001, US-002, US-003, US-004 (Core journaling) 
- **Sprint 2**: ✅ US-005 (Entry editing) 
- **Sprint 3**: ✅ US-007, US-008, US-009 (Entry editing + AI integration foundation)

### **Phase 2: Advanced AI Features (Sprints 4-6)**  
- **Sprint 4**: US-010 (Knowledge graph generation), US-011 (Batch processing)
- **Sprint 5**: US-012, US-013 (AI insights + contextual actions)  
- **Sprint 6**: US-014, US-015 (Conversational interface)

### **Phase 3: Smart Features (Sprints 7-11)**
- **Sprint 7**: US-011, US-012 (Review features)
- **Sprint 8**: US-013, US-014 (Contextual actions + chat)
- **Sprint 9**: US-015 (Context-aware conversations)
- **Sprint 10**: US-016 (AI insights)
- **Sprint 11**: US-017 (Conversation integration)

### **Phase 4: Enhancement (Sprints 12-17)**  
- **Sprint 12**: US-018, US-019 (Multi-model support)
- **Sprint 13**: US-020 (UI polish)
- **Sprint 14**: US-021 (Model analytics)
- **Sprint 15**: US-022 (Google Drive backup)
- **Sprint 16**: US-023 (Export/import)
- **Sprint 17**: US-024 (Privacy controls)

***

## Cross-References & Maintenance

### **Document Relationships**
```
BRD.md (Strategic Vision)
├── Validates → Epic business values
└── Informs → Story prioritization

Product-Backlog.md (This Document)  
├── Sources from ← BRD epics và objectives
├── Feeds into → Sprint Planning (story selection)
└── Updated by ← Sprint Retrospectives (refinement)

Sprint-X-Planning.md (Implementation)
├── Selects from ← Product Backlog stories
├── References ← BRD for business context  
└── Generates → Updated story estimates và ADRs
```

### **Weekly Refinement Checklist**
- [ ] Review completed stories và update estimates
- [ ] Adjust priorities based on sprint learnings  
- [ ] Add new stories from stakeholder feedback
- [ ] Update story point estimates với actual data
- [ ] Review dependencies và adjust sprint assignments
- [ ] Archive completed epics và celebrate progress

### **Backlog Health Metrics**
- **Ready Stories**: 3+ sprints worth of detailed stories
- **Estimation Coverage**: 80%+ of near-term stories estimated  
- **Dependency Clarity**: All critical path dependencies mapped
- **Business Value**: Each story links back to BRD objectives

***

**Document Maintained By**: Product Owner (Self)  
**Review Frequency**: Weekly backlog refinement  
**Next Major Review**: After Sprint 1 completion  
**Archive Policy**: Completed stories moved to sprint retrospectives
