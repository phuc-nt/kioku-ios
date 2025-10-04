# Product Backlog - Kioku AI Journal

**Last Updated**: October 5, 2025
**Current Status**: Sprint 12 Completed + Chat UI Unified ✅
**Story Points Delivered**: 153/163 (94%)

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

### Sprint 12 (Completed) ✅ 100% SUCCESS
**Chat UX Improvements & Enhanced Context** - 8/8 story points delivered

**Features Delivered**:
- ✅ **US-S12-001**: Production API Key Management (2 points)
  - Settings tab with secure Keychain storage
  - Real-time validation with visual feedback
  - Show/hide toggle, help section
  - **Tests**: 5/5 automated tests PASSED
- ✅ **US-S12-002**: Stop/Regenerate During Streaming (2 points)
  - Stop button (red icon) during streaming
  - Regenerate button (refresh icon) after completion
  - **Bug Fix**: Keychain identifier mismatch resolved
- ✅ **US-S12-003**: Conversation Date Association (2 points)
  - Auto-creates/loads conversations per date
  - Date-based conversation management
- ✅ **US-S12-004**: Enhanced Context Display (2 points)
  - Individual note cards with discovery badges
  - Color-coded: Blue (Today), Green (Same day), Purple (Related)
  - Tappable cards with full entry view
  - Empty state handling

**Delivered**: October 3, 2025
**Test Report**: 5/5 automated tests PASSED (US-S12-001)
**Sprint Plan**: `docs/01_sprints/sprint_12_planning.md`
**Quality**: Production-ready, critical bug fixed

**Post-Sprint Work (October 5, 2025)**:
- ✅ **Chat UI Unification**: Merged Chat Tab and "Chat with AI from note detail" into single `AIChatView`
  - Deleted 3 redundant components (~500 lines)
  - Added streaming features: animated indicator, stop button
  - **Tests**: 6/6 automated scenarios PASSED
  - **Test Report**: `docs/03_testing/chat_ui_unification_test_results.md`

### Sprint 11 (Completed) ✅
**Full LLM Chat Integration + UI Refinement** - 18/18 story points
- ✅ Streaming chat with Gemini 2.0 Flash
- ✅ Conversation threading with sidebar
- ✅ UI unification and white screen bug fix

### Sprint 10 (Completed) ✅
**AI Chat Integration** - 13 story points
- ✅ Context-aware chat with historical notes
- ✅ Tab-based navigation architecture

---

## Known Issues

### Issue 1: Entity Extraction API Rate Limiting
**Status**: 🔴 Open - High Priority
**Discovered**: October 5, 2025
**Component**: Entity Extraction Service
**Severity**: Medium

**Description**:
Entity extraction feature is hitting OpenRouter API rate limits when processing journal entries. This causes extraction failures and impacts the knowledge graph functionality.

**Symptoms**:
- Rate limit errors during entity extraction
- Successful chat interactions (not affected)
- Only affects batch processing of entries

**Impact**:
- ❌ Entity extraction fails for existing notes
- ❌ Knowledge graph cannot be populated
- ✅ Chat functionality works normally (separate service)

**Root Cause**:
Suspected issues:
1. Too many concurrent API requests during batch processing
2. Missing rate limit handling/retry logic
3. No request throttling or queuing system

**Proposed Solutions**:
1. Add request queue with rate limiting (1 request per second)
2. Implement exponential backoff retry logic
3. Add batch processing with delays between requests
4. Consider local LLM for entity extraction (future)

**Priority**: High - Blocks Knowledge Graph Epic (Sprint 13+)
**Assigned To**: Next sprint task
**Related Epic**: Epic 6 - Knowledge Graph Generation

---

## Next Priorities (Sprint 13+)

### Immediate Priorities (Sprint 13)
**Focus**: Fix Entity Extraction + Knowledge Graph Integration
**Estimated**: 11-14 story points
**Priority**: High

**🔥 US-S13-000: Fix Entity Extraction Rate Limiting (CRITICAL)**
- Implement request queue with rate limiting
- Add exponential backoff retry logic
- Batch processing with configurable delays
- Monitor and log rate limit metrics
- **Priority**: Critical | **Complexity**: Medium (2 points)
- **Blocks**: All Knowledge Graph stories

**US-S13-001: Entity Extraction from Notes**
- Extract 5 entity types: People, Places, Events, Emotions, Topics
- Confidence scoring and deduplication
- Single note and batch conversion workflows
- **Priority**: High | **Complexity**: Medium (3 points)
- **Depends On**: US-S13-000

**US-S13-002: Relationship Mapping**
- 4 relationship types: Temporal, Causal, Emotional, Topical
- Cross-note relationship discovery
- Evidence capture with text excerpts
- **Priority**: High | **Complexity**: High (4 points)

**US-S13-003: Graph Visualization Screen**
- Access from chat and note detail
- Interactive entity and relationship navigation
- Path explanation with breadcrumbs
- **Priority**: Medium | **Complexity**: Medium (3 points)

**US-S13-004: Conversation to Knowledge Graph**
- "Convert to KG" button in conversations
- Entity extraction from chat messages
- Cross-linking with note entities
- **Priority**: Medium | **Complexity**: Medium (2 points)

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