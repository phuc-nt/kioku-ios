# Product Backlog - Kioku AI Journal

**Last Updated**: October 2, 2025
**Current Status**: Sprint 11 Completed + UI Refinement - 100% Success ✅
**Story Points Delivered**: 145/155 (94%)

## Project Overview

**Kioku** - AI-powered personal journaling app with intelligent chat assistance

**Core Features Completed** ✅:
- Calendar-based journaling with date navigation
- AI chat integration with historical context awareness
- Tab-based navigation (Calendar ↔ Chat)
- Historical notes discovery and time travel features
- Local data storage with encryption

---

## Current Sprint Status

### Sprint 11 (Completed) ✅ 100% SUCCESS - EXCEPTIONAL DELIVERY
**Full LLM Chat Integration + UI Refinement** - 18/18 story points delivered (138% of original 13 points)

**Core Features (13 points)**:
- ✅ Streaming chat infrastructure with Gemini 2.0 Flash (SSE)
- ✅ Conversation threading with sidebar UI (create/switch/delete)
- ✅ Context discovery integration ready
- ✅ Auto-title generation verified ("Seeking a Fun Fact")
- ✅ Live streaming tested and validated with real API
- ✅ API Key management (Keychain integration)

**Additional UI Refinement (5 points)**:
- ✅ UI unification: Both chat entry points use AIChatView_OLD
- ✅ Entry detail improvements: Date in title, floating "Chat with AI" button
- ✅ AI Analysis features removed (~350 lines of legacy code)
- ✅ White screen bug fixed (`.sheet(item:)` solution)
- ✅ @Query in sheet context issue resolved (manual fetch pattern)

**Delivered**: October 2, 2025
**Test Report**: `docs/03_testing/sprint_11_acceptance_tests.md` (20/20 tests PASS - 100%)
**Sprint Plan**: `docs/01_sprints/sprint_11_planning.md`
**Quality**: AAA+ (Production-ready, zero critical bugs)

### Sprint 10 (Completed) ✅
**AI Chat Integration** - 13 story points delivered
- ✅ AI chat access from note detail screens
- ✅ Tab-based navigation architecture
- ✅ Context-aware chat with historical notes
- ✅ Date synchronization between Calendar and Chat tabs

---

## Next Priorities (Sprint 12+)

### Immediate Priorities (Sprint 12)
**Estimated**: 5-7 story points
**Priority**: High

**US-S12-001: Production API Key Management**
- Replace debug APIKeySetupView with Settings UI
- Proper user onboarding flow
- Key validation and error messaging
- **Priority**: High | **Complexity**: Low (2 points)

**US-S12-002: Conversation to Knowledge Graph**
- "Convert to KG" button implementation
- Entity extraction from conversation messages
- Cross-linking with note entities
- **Priority**: High | **Complexity**: Medium (3 points)

**US-S12-003: Enhanced Context Discovery**
- Parallel processing (similarity + KG traversal)
- Result merging and ranking
- Performance optimization (<3s target)
- **Priority**: Medium | **Complexity**: High (2 points)

### Epic 6: Knowledge Graph Generation & Querying
**Estimated**: 10-15 story points
**Priority**: High (Phase 2 continuation, after Sprint 12)

**US-S12-001: Entity Extraction from Notes**
- Extract 5 entity types: People, Places, Events, Emotions, Topics
- Confidence scoring và deduplication
- Single note và batch conversion workflows
- **Priority**: High | **Complexity**: Medium

**US-S12-002: Relationship Mapping**
- 4 relationship types: Temporal, Causal, Emotional, Topical
- Cross-note relationship discovery
- Evidence capture với text excerpts
- **Priority**: High | **Complexity**: High

**US-S12-003: Graph Explain Screen**
- Access from chat và note detail
- Interactive entity và relationship navigation
- Path explanation với breadcrumbs
- **Priority**: Medium | **Complexity**: Medium

### Epic: Advanced AI Features (Future)
**Estimated**: 15-20 story points

**US-041: Multi-Model AI Support**
- Support multiple AI providers (Claude, GPT-4, Gemini)
- Model comparison and selection
- **Priority**: Medium | **Complexity**: High

**US-042: Proactive AI Insights**
- AI-generated daily/weekly insights
- Pattern recognition and trend analysis
- **Priority**: High | **Complexity**: High

**US-043: Voice Integration**
- Voice-to-text entry creation
- Voice conversations with AI
- **Priority**: Medium | **Complexity**: Medium

### Epic: Enhanced User Experience
**Estimated**: 8-12 story points

**US-045: Advanced Search & Filtering**
- Semantic search across journal entries
- AI-powered content discovery
- **Priority**: Medium | **Complexity**: Medium

**US-046: Export & Backup**
- Google Drive integration
- Encrypted backup and restore
- **Priority**: High | **Complexity**: Medium

**US-047: UI/UX Polish**
- Enhanced animations and transitions
- Accessibility improvements
- **Priority**: Low | **Complexity**: Low

---

## Backlog Health

**Ready for Development**: Sprint 11 stories defined  
**Architecture Foundation**: Solid (SwiftUI + SwiftData + OpenRouter)  
**Test Coverage**: XcodeBuildMCP automation in place  
**Technical Debt**: Minimal

---

## Sprint Planning Notes

**Team Velocity**: 8-13 points per sprint  
**Sprint Duration**: 1-2 weeks  
**Next Sprint Target**: US-041, US-043 (conversation memory + insights)

**Dependencies**:
- OpenRouter API stability
- iOS 18+ SwiftUI features
- Local encryption performance

---

*For detailed sprint history see: `docs/01_sprints/sprint_10_planning.md`*  
*For technical architecture see: `docs/00_context/03_architecture_design.md`*