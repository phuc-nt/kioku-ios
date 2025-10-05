# Sprint 14 Planning: AI Insights & Advanced Search

**Sprint Period**: October 5-12, 2025
**Epic**: EPIC-7 - Advanced AI Features & UX Enhancement
**Story Points**: 8 points (2/2 stories)
**Status**: 🚧 **IN PROGRESS**

**Related Documents**:
- Previous Sprint: [`docs/01_sprints/sprint_13_planning.md`](sprint_13_planning.md)
- Architecture: [`docs/00_context/03_architecture_design.md`](../00_context/03_architecture_design.md)
- Product Backlog: [`docs/00_context/02_product_backlog.md`](../00_context/02_product_backlog.md)

---

## Sprint Goals

Leverage the knowledge graph foundation to deliver intelligent insights and powerful search capabilities:

1. 🧠 **Proactive AI Insights** - Automatic pattern detection and personalized insights
2. 🔍 **Advanced Search** - Entity-based filtering and semantic search

**Strategic Importance**: Transform Kioku from a passive journal to an active AI companion that discovers patterns and helps users find meaningful connections in their writing.

---

## User Stories & Tasks

### US-S14-001: Proactive AI Insights (5 points)

**As a user**, I want the AI to proactively identify patterns and generate insights from my journal entries so I can discover trends and connections I might have missed.

**Problem Statement**:
- Users write journal entries but don't always see patterns
- Valuable insights hidden in accumulated data
- No automatic trend analysis or pattern recognition
- Knowledge graph data (entities + relationships) not surfaced to users

**Requirements** (FR-801, FR-802, FR-803):
- **Daily Insights**: Generate insights based on today's writing
- **Weekly Summary**: Pattern analysis across past 7 days
- **Entity Frequency**: "You've mentioned 'work' 15 times this week"
- **Mood Trends**: "Your mood improves after exercise"
- **Relationship Patterns**: "You write about family most on weekends"
- **Proactive Suggestions**: "You haven't written about hobbies lately"
- **Insight Types**:
  - Frequency patterns (entity mentions)
  - Temporal patterns (when you write about what)
  - Emotional patterns (mood correlations)
  - Social patterns (people interactions)
  - Topic trends (emerging themes)

**Acceptance Criteria**:
- [ ] InsightsService generates insights from knowledge graph data
- [ ] Daily insights: 3-5 observations about today's entry
- [ ] Weekly insights: 5-7 patterns across past 7 days
- [ ] Insights UI accessible from main navigation (tab or menu)
- [ ] Each insight shows: type, description, evidence (linked entities)
- [ ] Tap insight → navigate to related entries
- [ ] Refresh button to regenerate insights
- [ ] Loading state during AI generation
- [ ] Empty state: "Write more to see patterns"
- [ ] Insights cached for performance (24h cache)

**Technical Tasks**:
- [ ] Create InsightsService with OpenRouter integration
- [ ] Design AI prompts for different insight types
- [ ] Fetch entities and relationships from knowledge graph
- [ ] Create Insight model: type, title, description, confidence, relatedEntries
- [ ] Build InsightsView UI with list of insights
- [ ] Add insight detail view with evidence
- [ ] Implement caching logic (UserDefaults or SwiftData)
- [ ] Add refresh/regenerate functionality
- [ ] Handle edge cases (no data, API errors)
- [ ] Write automated tests

**UI/UX Design**:

```
┌─────────────────────────────┐
│  Insights  🧠               │
├─────────────────────────────┤
│  Today                      │
│  ┌─────────────────────┐   │
│  │ 📊 Frequency         │   │
│  │ You mentioned "work" │   │
│  │ 3 times today        │   │
│  │ → See related notes  │   │
│  └─────────────────────┘   │
│                             │
│  This Week                  │
│  ┌─────────────────────┐   │
│  │ 😊 Mood Pattern      │   │
│  │ Your mood improves   │   │
│  │ after exercise       │   │
│  │ → View pattern       │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 👥 Social Insight    │   │
│  │ You write about      │   │
│  │ family on weekends   │   │
│  │ → Explore more       │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

**AI Prompt Strategy**:

```swift
// Daily Insights Prompt
"""
Analyze this journal entry and knowledge graph entities to generate 3-5 insights:

Entry: {today_entry}
Entities: {extracted_entities}
Historical context: {past_week_summary}

Generate insights in JSON format:
{
  "insights": [
    {
      "type": "frequency",
      "title": "Work mentioned frequently",
      "description": "You've mentioned 'work' 3 times today, suggesting it's on your mind",
      "confidence": 0.85,
      "relatedEntities": ["work", "project", "deadline"]
    }
  ]
}
"""

// Weekly Pattern Prompt
"""
Analyze the past 7 days of journal entries to find patterns:

Entities by day: {entities_timeline}
Mood by day: {mood_timeline}
Topics by day: {topics_timeline}

Find 5-7 patterns such as:
- Frequency trends (increasing/decreasing mentions)
- Temporal patterns (what you write about when)
- Correlations (mood ↔ activities, people ↔ emotions)
- Gaps (missing topics, long breaks)

Return JSON with patterns and evidence.
"""
```

**Data Model**:

```swift
@Model
public class Insight {
    public var id: UUID
    public var type: InsightType // frequency, temporal, emotional, social, topical
    public var title: String
    public var description: String
    public var confidence: Double // 0.0-1.0
    public var generatedAt: Date
    public var timeframe: TimeframeType // daily, weekly, monthly

    // Evidence
    public var relatedEntityIds: [UUID] // Links to entities
    public var relatedEntryIds: [UUID] // Links to journal entries
    public var evidence: String // Supporting data

    // Metadata
    public var isRead: Bool
    public var isStarred: Bool
}

public enum InsightType: String, Codable {
    case frequency // Entity mention patterns
    case temporal // Time-based patterns
    case emotional // Mood/emotion patterns
    case social // People/relationship patterns
    case topical // Theme/topic trends
    case suggestion // Proactive suggestions
}

public enum TimeframeType: String, Codable {
    case daily
    case weekly
    case monthly
}
```

**Service Architecture**:

```swift
public class InsightsService {
    private let openRouterService: OpenRouterService
    private let dataService: DataService

    // Generate daily insights
    func generateDailyInsights(for date: Date) async throws -> [Insight]

    // Generate weekly insights
    func generateWeeklyInsights(endDate: Date) async throws -> [Insight]

    // Fetch cached insights
    func getCachedInsights(timeframe: TimeframeType) -> [Insight]

    // Clear cache
    func clearInsightsCache()
}
```

**Testing Strategy**:
- Unit tests: Insight generation with mock data
- Integration tests: AI API calls with real knowledge graph
- UI tests: Navigate insights, tap to view related entries
- Edge cases: No data, API errors, empty insights

---

### US-S14-002: Advanced Search & Filtering (3 points)

**As a user**, I want to search my journal entries by content, entities, and filters so I can quickly find specific notes and discover connections.

**Problem Statement**:
- No way to search across all journal entries
- Cannot filter by entities (e.g., find all mentions of "Mom")
- No date range filtering
- Missing semantic search capabilities
- Knowledge graph entities not leveraged for search

**Requirements** (FR-804, FR-805, FR-806):
- **Full-Text Search**: Search entry content
- **Entity-Based Search**: Filter by people, places, events, emotions, topics
- **Date Range Filter**: Custom or preset ranges (this week, last month)
- **Mood Filter**: Filter by emotional states
- **Weather Filter**: Filter by weather conditions
- **Combined Filters**: AND logic (e.g., "Mom" + "happy" + "last month")
- **Search Results**: Highlight matches, show context snippets
- **Sort Options**: By date (newest/oldest), relevance, mood

**Acceptance Criteria**:
- [ ] SearchView accessible from main navigation
- [ ] Search bar with real-time filtering
- [ ] Entity filter chips (tap to filter by entity)
- [ ] Date range picker (preset + custom)
- [ ] Mood and weather filters
- [ ] Search results show: title, snippet, date, entities
- [ ] Highlighted search terms in results
- [ ] Tap result → navigate to entry detail
- [ ] Empty state: "No results found"
- [ ] Clear all filters button
- [ ] Filter count badge when filters active
- [ ] Performance: Search <500ms for 1000+ entries

**Technical Tasks**:
- [ ] Create SearchService with SwiftData predicates
- [ ] Build search query logic with AND/OR operations
- [ ] Implement entity-based filtering
- [ ] Add date range filtering
- [ ] Create SearchView UI with filters
- [ ] Design search result cards
- [ ] Add search highlighting
- [ ] Implement sort options
- [ ] Cache search results for performance
- [ ] Write unit tests for search logic
- [ ] UI automation tests

**UI/UX Design**:

```
┌─────────────────────────────┐
│  🔍 Search                  │
├─────────────────────────────┤
│  ┌─────────────────────┐   │
│  │ Search entries...    │   │
│  └─────────────────────┘   │
│                             │
│  Filters: [2] ✕  Clear All │
│  ┌───┐ ┌─────┐ ┌───────┐  │
│  │Mom│ │Work │ │Oct '25│  │
│  └───┘ └─────┘ └───────┘  │
│                             │
│  ┌─────────────────────┐   │
│  │ 📅 Oct 5, 2025      │   │
│  │ Minh thi xong...    │   │
│  │ Entities: Minh,     │   │
│  │ school, proud       │   │
│  └─────────────────────┘   │
│                             │
│  ┌─────────────────────┐   │
│  │ 📅 Sep 5, 2025      │   │
│  │ Hằng bị ốm...       │   │
│  │ Entities: Hằng,     │   │
│  │ hospital, worried   │   │
│  └─────────────────────┘   │
└─────────────────────────────┘
```

**Search Query Logic**:

```swift
public class SearchService {
    // Full-text search
    func searchEntries(
        query: String?,
        entityFilters: [Entity]?,
        dateRange: DateRange?,
        moodFilter: String?,
        weatherFilter: String?
    ) -> [Entry]

    // Build SwiftData predicate
    private func buildPredicate(...) -> Predicate<Entry>

    // Example predicate for "Mom" + "happy" + "last month"
    #Predicate<Entry> { entry in
        entry.content.contains("Mom") &&
        entry.mood == "happy" &&
        entry.date >= lastMonth.start &&
        entry.date <= lastMonth.end
    }
}
```

**Data Model** (Existing, no changes needed):

```swift
// Entry already has all needed properties
@Model
public class Entry {
    public var content: String
    public var date: Date
    public var mood: String?
    public var weather: String?

    @Relationship(deleteRule: .cascade)
    public var entities: [Entity]
}
```

**Performance Considerations**:
- SwiftData indexes on date, mood fields
- Limit results to 100 initially, pagination for more
- Debounce search input (300ms)
- Cache recent searches

**Testing Strategy**:
- Unit tests: Predicate building logic
- Integration tests: Search with various filters
- UI tests: Enter search, apply filters, view results
- Performance tests: Search with 1000+ entries
- Edge cases: Empty query, no results, special characters

---

## Architecture Changes

### New Services

```swift
// Insights Generation
InsightsService.swift
  - generateDailyInsights(for:) async throws -> [Insight]
  - generateWeeklyInsights(endDate:) async throws -> [Insight]
  - getCachedInsights(timeframe:) -> [Insight]
  - clearInsightsCache()

// Search & Filtering
SearchService.swift
  - searchEntries(query:entityFilters:dateRange:moodFilter:weatherFilter:) -> [Entry]
  - buildPredicate(...) -> Predicate<Entry>
  - highlightMatches(in:query:) -> AttributedString
```

### New Views

```swift
// Insights UI
InsightsView.swift
  - Displays list of insights
  - Refresh button
  - Loading/empty states

InsightDetailView.swift
  - Shows insight details
  - Lists evidence (entities + entries)
  - Navigation to related entries

// Search UI
SearchView.swift
  - Search bar
  - Filter chips
  - Results list

SearchFiltersSheet.swift
  - Date range picker
  - Mood/weather filters
  - Entity selection

SearchResultCard.swift
  - Entry preview
  - Highlighted matches
  - Entity badges
```

### New Models

```swift
Insight.swift
  - @Model class for insights
  - InsightType enum
  - TimeframeType enum
```

---

## Technical Risks & Mitigation

| Risk | Impact | Mitigation | Priority |
|------|--------|------------|----------|
| AI insights too generic/unhelpful | High | Detailed prompts, examples, user feedback loop | High |
| Slow insight generation | Medium | Cache insights, generate in background | Medium |
| Search performance with many entries | Medium | SwiftData indexes, pagination, debouncing | High |
| Entity filters too complex | Low | Simple chip UI, clear all button | Low |
| Too many insights overwhelm user | Medium | Limit to top 5-7, prioritize by confidence | Medium |

---

## Definition of Done

### Code Quality
- [ ] All acceptance criteria met for both USs
- [ ] Code compiles without warnings
- [ ] Swift 6 concurrency compliance
- [ ] Follows existing code patterns
- [ ] No memory leaks

### Testing
- [ ] Unit tests for InsightsService and SearchService
- [ ] Integration tests with real data
- [ ] UI automation tests with XcodeBuildMCP
- [ ] Edge cases tested
- [ ] Performance benchmarks met

### Documentation
- [ ] Sprint planning updated with progress
- [ ] Test scenarios documented
- [ ] Acceptance tests passed
- [ ] ADRs created if needed

### User Experience
- [ ] iOS Human Interface Guidelines followed
- [ ] VoiceOver support
- [ ] Error messages user-friendly
- [ ] Loading states clear
- [ ] Smooth animations

---

## Success Metrics

### Performance Targets
- **Insight generation**: <5s for daily, <10s for weekly
- **Search latency**: <500ms for 1000 entries
- **Insight cache hit**: >80% for same-day requests
- **UI responsiveness**: No lag during search input

### Quality Targets
- **Test pass rate**: 100%
- **Bug count**: 0 critical, <3 minor
- **Insight relevance**: >70% user satisfaction (future survey)
- **Search accuracy**: >90% relevant results

### User Experience Goals
- **Insight discovery**: Users find 2+ valuable insights per week
- **Search usage**: >50% of users use search feature
- **Time saved**: 3x faster to find entries vs scrolling
- **Engagement**: Increased daily active usage

---

## Dependencies

### External
- OpenRouter API for insight generation
- iOS 18+ for SwiftData features
- Stable network for AI calls

### Internal
- Sprint 13 complete: Knowledge graph with entities + relationships
- EntityExtractionService working
- RelationshipDiscoveryService working
- DataService with entity queries

---

## Sprint Schedule

### Week 1 (Oct 5-8, 2025)

**Day 1-2: US-S14-001 Foundation**
- Create InsightsService
- Design AI prompts
- Implement daily insights generation

**Day 3-4: US-S14-001 UI**
- Build InsightsView
- Add loading/empty states
- Implement caching

### Week 2 (Oct 9-12, 2025)

**Day 5-6: US-S14-002 Foundation**
- Create SearchService
- Build predicate logic
- Implement filters

**Day 7: US-S14-002 UI**
- Build SearchView
- Add filter chips
- Results display

**Day 8: Testing & Polish**
- Run full test suite
- Fix bugs
- UI polish
- Documentation

---

## Testing Strategy

### Unit Tests
- InsightsService: Generation logic, caching
- SearchService: Predicate building, filtering
- Insight model: Validation, serialization

### Integration Tests (XcodeBuildMCP)
- Generate daily insights from real entries
- Generate weekly insights with patterns
- Search with various filter combinations
- Entity-based filtering accuracy
- Date range filtering

### Manual Testing
- Insights UI on various screen sizes
- Search with VoiceOver
- Error handling (network failures)
- Edge cases (no data, empty results)

### Performance Testing
- Insight generation time
- Search latency with large datasets
- Memory usage during operations
- UI responsiveness

---

## Risks & Contingency Plans

### High Priority Risks

**Risk 1: AI insights not valuable to users**
- **Probability**: Medium
- **Impact**: High (core feature value)
- **Mitigation**: Test prompts with sample data, iterate quickly
- **Contingency**: Simplify to basic statistics if AI fails

**Risk 2: Search too slow with many entries**
- **Probability**: Low
- **Impact**: Medium (UX degradation)
- **Mitigation**: SwiftData indexes, pagination, debouncing
- **Contingency**: Limit search scope, add "Advanced Search" option

**Risk 3: Too many insights overwhelm users**
- **Probability**: Medium
- **Impact**: Low (can be tuned)
- **Mitigation**: Limit to top 5-7, sort by confidence
- **Contingency**: Add "View All" expandable section

---

## Sprint Retrospective Template

(To be filled at end of sprint)

### What Went Well
- [To be completed]

### What Could Be Improved
- [To be completed]

### Action Items for Next Sprint
- [To be completed]

### Metrics Achieved
- Story points delivered: __/8
- Test pass rate: ___%
- Sprint duration: __ days
- Bugs found: __ critical, __ minor

---

**Sprint Start**: October 5, 2025
**Sprint End**: TBD (Target: October 12, 2025)
**Sprint Review**: TBD
**Test Report**: [`docs/03_testing/sprint_14_acceptance_tests.md`](../03_testing/sprint_14_acceptance_tests.md)
