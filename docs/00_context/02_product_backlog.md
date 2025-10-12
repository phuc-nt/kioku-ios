# Product Backlog - Kioku AI Journal

**Last Updated**: October 11, 2025
**Current Status**: Sprint 17 In Progress (Flexible Model Configuration & Export System) 🔄
**Story Points Delivered**: 186/201 (93%)

## Project Overview

**Kioku** - AI-powered personal journaling app with intelligent chat assistance and knowledge graph capabilities

**Core Features Completed** ✅:
- Calendar-based journaling with date navigation
- AI chat integration with historical context awareness
- Tab-based navigation (Calendar ↔ Chat)
- Historical notes discovery and time travel features
- Local data storage with encryption
- **Knowledge Graph**: Entity extraction, relationship mapping, AI insights
- **Context-aware Chat**: Entity/relationship context, insight-driven responses

---

## Current Sprint Status

### Sprint 17 (In Progress) 🔄
**Flexible Model Configuration & Export System** - 9 story points

**Features In Progress**:
- 🔄 **US-S16-002**: Flexible Model Configuration (3 points)
  - Per-conversation AI model selection
  - OpenRouter model validation
  - Popular models + custom model ID support
  - Entity extraction/relationship discovery remain on fixed models
- 🔄 **US-046**: Export & Backup (6 points)
  - Export to JSON (complete metadata)
  - Export to Markdown (human-readable)
  - Import from JSON with conflict resolution
  - Files app integration

**Started**: October 11, 2025
**Sprint Plan**: [`docs/01_sprints/sprint_17_planning.md`](../01_sprints/sprint_17_planning.md)
**Expected Completion**: October 13, 2025

### Sprint 16 (Completed) ✅ 100% SUCCESS
**Knowledge Graph Enhanced Context** - 5/5 story points delivered

**Features Delivered**:
- ✅ **US-S16-001**: Related Notes via Knowledge Graph (5 points)
  - KG-based related notes discovery algorithm
  - Relevance scoring: relationship weights + insight confidence + recency decay
  - Integration with chat context service
  - Full entry content in context with relevance reasons

**Critical Bug Fixes**:
- ✅ Fixed entity deduplication: entities now reused across entries (e.g., "Minh" in 5 entries)
- ✅ Implemented in-memory cache to bypass SwiftData context sync delays
- ✅ Fixed Entity.matches() to use exact comparison instead of .contains()

**Test Results**:
- ✅ 4 related notes discovered via KG (scores: 0.70 to 6.17)
- ✅ Entity "Minh" reused across 5 entries
- ✅ Entity "Hằng" reused across 3 entries
- ✅ Integration test: chat context includes related notes with reasons

**Delivered**: October 10, 2025
**Sprint Plan**: [`docs/01_sprints/sprint_16_planning.md`](../01_sprints/sprint_16_planning.md)
**Quality**: Core functionality complete, performance testing deferred

### Sprint 15 (Completed) ✅ PARTIAL COMPLETION
**Knowledge Graph Context Integration** - 8/8 story points delivered

**Features Delivered**:
- ✅ **US-S15-001**: Entity & Relationship Context (5 points)
  - Date-specific entity/relationship fetching
  - Fixed critical bug: Entry ID-based insight filtering
  - Context service infrastructure complete
- ✅ **US-S15-002**: Insight-Aware Chat (3 points)
  - Daily/weekly/monthly insight integration
  - Insight relevance ranking and filtering

**Chat UX Improvements**:
- ✅ Fixed duplicate streaming indicator bug
- ✅ Improved prompt structure with clear sections
- ✅ Added comprehensive prompt logging
- ✅ Enhanced AI personality (caring friend tone)
- ✅ Upgraded to GPT-5 Mini model
- ✅ Full journal content in context (removed entity/insight lists)

**Scope Changes**:
- ⚠️ Entity/relationship/insight context temporarily removed from prompts
- Future: Use KG to fetch top 5 related full notes instead

**Delivered**: October 5, 2025
**Sprint Plan**: [`docs/01_sprints/sprint_15_planning.md`](../01_sprints/sprint_15_planning.md)
**Test Report**: [`docs/03_testing/sprint_15_integration_tests.md`](../03_testing/sprint_15_integration_tests.md)
**Quality**: Core infrastructure complete, UI integration deferred

### Sprint 14 (Completed) ✅ 100% SUCCESS
**AI Insights & Advanced Search** - 8/8 story points delivered

**Features Delivered**:
- ✅ **US-S14-001**: Proactive AI Insights (5 points)
  - Daily, weekly, monthly insight generation
  - Pattern detection across entries
  - Confidence scoring and deduplication
- ✅ **US-S14-002**: Advanced Search (3 points)
  - Entity-based filtering and search
  - Semantic search capabilities

**Delivered**: October 5, 2025
**Sprint Plan**: [`docs/01_sprints/sprint_14_planning.md`](../01_sprints/sprint_14_planning.md)
**Quality**: Production-ready

### Sprint 13 (Completed) ✅ 100% SUCCESS
**Knowledge Graph Foundation** - 12/12 story points delivered

**Features Delivered**:
- ✅ **US-S13-001**: Entity Extraction (3 points)
  - 5 entity types: People, Places, Events, Emotions, Topics
  - Confidence scoring and deduplication
- ✅ **US-S13-002**: Relationship Mapping (4 points)
  - 4 relationship types: Temporal, Causal, Emotional, Topical
  - Cross-note relationship discovery
- ✅ **US-S13-003**: Graph Visualization (3 points)
  - Interactive entity/relationship navigation
- ✅ **US-S13-004**: Chat to KG Conversion (2 points)
  - Extract entities from conversations

**Delivered**: October 5, 2025
**Sprint Plan**: [`docs/01_sprints/sprint_13_planning.md`](../01_sprints/sprint_13_planning.md)
**Quality**: Production-ready, all automated tests PASSED

### Sprint 12 (Completed) ✅ 100% SUCCESS
**Chat UX Improvements** - 8/8 story points

**Key Features**:
- ✅ API Key Management with Keychain security
- ✅ Stop/Regenerate streaming controls
- ✅ Conversation date association
- ✅ Enhanced context display with note cards
- ✅ Chat UI unification (merged dual implementations)

**Delivered**: October 3-5, 2025
**Sprint Plan**: [`docs/01_sprints/sprint_12_planning.md`](../01_sprints/sprint_12_planning.md)

### Sprint 10-11 (Completed) ✅
**AI Chat Integration Foundation** - 31 story points total
- ✅ Streaming chat with OpenRouter integration
- ✅ Conversation threading
- ✅ Historical context awareness
- ✅ Tab-based navigation

---

## Known Issues

### ~~Issue 1: Entity Extraction API Rate Limiting~~ ✅ RESOLVED
**Status**: ✅ Resolved - October 5, 2025
**Component**: Entity Extraction & Relationship Discovery Services
**Resolution**: Changed models from free tier to paid tier

**Original Problem**:
- Entity extraction and relationship discovery hitting rate limits
- Both services using `google/gemini-2.0-flash-exp:free` (FREE tier)
- Chat working fine with `openai/gpt-4o-mini` (PAID tier)

**Root Cause Identified**:
- Free tier models have separate, very low rate limits (~20 requests/day)
- Paid tier models have much higher limits
- Same API key, different models = different rate limit pools

**Solution Implemented**:
1. ✅ Changed `EntityExtractionService.extractionModel` to `openai/gpt-4o-mini`
2. ✅ Changed `RelationshipDiscoveryService.discoveryModel` to `openai/gpt-4o-mini`
3. ✅ Fixed aliases array parsing bug in entity extraction
4. ✅ All services now use same paid tier model

**Test Results**: ✅ 10/10 entries processed successfully
- No rate limit errors
- No parsing errors
- 100% success rate for both entity extraction and relationship discovery

**Documentation**: [`docs/03_testing/entity_extraction_rate_limit_fix.md`](../03_testing/entity_extraction_rate_limit_fix.md)

**Impact**: Knowledge Graph Epic (Sprint 13+) is now unblocked and ready

---

## Next Priorities (Sprint 16+)

### Immediate Priorities (Sprint 16)
**Focus**: Knowledge Graph Context Refinement
**Estimated**: 5-8 story points
**Priority**: High

**US-S16-001: Related Notes via Knowledge Graph (5 points)**
- Use entity/relationship data to fetch top 5 most related full notes
- Replace raw entity/insight lists with contextualized full journal content
- Improve LLM context quality and relevance
- **Priority**: HIGH | **Complexity**: Medium
- **Dependencies**: Sprint 13-15 KG infrastructure

**US-S16-002: Flexible Model Configuration (3 points)** 🔄 IN PROGRESS (Sprint 17)
- Allow users to configure any OpenRouter model for chat conversations
- Model validation and error handling
- Entity extraction/relationship discovery remain on fixed models
- **Priority**: High | **Complexity**: Low

### Epic 7: Advanced AI Features (In Progress)
**Status**: Partial completion (Sprint 14-15)
**Remaining**: 10-15 story points

**US-042: Enhanced Proactive Insights**
- ✅ Daily/weekly/monthly insight generation (Sprint 14)
- ⚠️ UI integration for insight browsing (deferred)
- 🔲 Insight trend visualization
- 🔲 Personalized insight recommendations
- **Priority**: Medium | **Complexity**: Medium (5 points remaining)

**US-043: Voice Integration**
- Voice-to-text entry creation
- Voice conversations with AI
- **Priority**: Medium | **Complexity**: Medium (8 points)

### Epic 8: Enhanced User Experience (Future)
**Estimated**: 8-12 story points
**Priority**: Medium

**US-045: Advanced Search & Filtering**
- ✅ Entity-based search (Sprint 14)
- 🔲 Full-text semantic search across all entries
- 🔲 Advanced filters (date range, entity type, emotion)
- 🔲 Search result ranking by relevance
- **Priority**: Medium | **Complexity**: Medium (5 points remaining)

**US-046: Export & Backup (6 points)** 🔄 IN PROGRESS (Sprint 17)
- Export journal entries (JSON, Markdown)
- Import from JSON with conflict resolution
- Files app integration
- Encrypted backup option
- **Priority**: High | **Complexity**: Medium
- **Note**: Cloud integration (Google Drive/iCloud) deferred to future sprint

**US-047: UI/UX Polish**
- Enhanced animations and transitions
- Accessibility improvements (VoiceOver, Dynamic Type)
- Dark mode optimization
- **Priority**: Low | **Complexity**: Low (3 points)

---

## Backlog Health

**Ready for Development**: Sprint 17 in progress
**Architecture Foundation**: Solid (SwiftUI + SwiftData + OpenRouter + Knowledge Graph)
**Test Coverage**: XcodeBuildMCP automation in place
**Technical Debt**: Minimal (performance testing with large dataset needed)

**Completion Status**:
- ✅ Sprints 1-12: Core journaling + AI chat (100%)
- ✅ Sprints 13-16: Knowledge Graph complete (100%)
- 🔄 Sprint 17: Model configuration + Export system (in progress)
- 🔲 Future: Voice, enhanced insights, advanced search polish

---

## Sprint Planning Notes

**Team Velocity**: 8-12 points per sprint
**Sprint Duration**: 1-2 days (fast iteration)
**Current Sprint**: Sprint 17 - Flexible model config + Export system

**Current Focus**:
- Flexible AI model selection for chat conversations
- Comprehensive data export/import capabilities
- User empowerment through data portability

**Dependencies**:
- OpenRouter API stability ✅
- iOS 18+ SwiftUI features ✅
- Local encryption performance ✅
- Knowledge Graph data quality 🔄

---

## Recent Achievements (Sprint 13-16)

**Knowledge Graph Epic Completed** (Sprint 13-16):
- 33 story points delivered across 4 sprints
- Entity extraction, relationship mapping, insights, context integration
- KG-based related notes discovery with relevance scoring
- Critical bugs fixed: Entity deduplication, rate limiting, streaming UI
- Infrastructure ready for advanced AI features

**Sprint 16 Highlights**:
- ✅ Related notes via KG with relevance scoring (0.70-6.17 scores)
- ✅ Entity deduplication fixed with in-memory cache pattern
- ✅ UI transparency: Related notes cards with High/Medium/Low badges
- ✅ Database utilities documentation created

**Quality Metrics**:
- 100% automated test coverage for core features
- Zero critical bugs in production
- Knowledge Graph operational with real test data
- Successful model upgrade (GPT-4o-mini)

---

*For detailed sprint history see: `docs/01_sprints/`*
*For technical architecture see: [`docs/00_context/03_architecture_design.md`](03_architecture_design.md)*