# Kioku - AI-Powered Personal Journal
## Technical Presentation for Interview

**Presenter**: Phuc Nguyen
**Duration**: 10-15 minutes
**Focus**: AI Features & Problem Solving

---

## 1. Problem Statement (2 minutes)

### The Challenge: Traditional Journaling is Limited

**Real-world scenario:**
> "Tôi viết nhật ký mỗi ngày, nhưng khi muốn nhớ lại 'lần cuối tôi gặp Minh là khi nào?', tôi phải lật từng trang, đọc từng dòng. Tốn 30 phút mà vẫn không tìm thấy."

**Core Problems:**
1. **Memory Overload**: Người dùng viết hàng trăm entries nhưng không nhớ được nội dung
2. **No Context Awareness**: Không thể hỏi "Tuần này tôi có vui không?" vì dữ liệu chỉ là text thuần
3. **Lost Connections**: Không nhận ra mối liên hệ giữa người, sự kiện, địa điểm trong cuộc sống
4. **Privacy Concerns**: Các app journal cloud-based không đảm bảo riêng tư

**Why Current Solutions Fail:**
- **Google Docs/Notes**: Chỉ là text editor, không có AI context
- **Day One/Journey**: Cloud-based, không có knowledge graph, AI chỉ trả lời chung chung
- **ChatGPT**: Không có dữ liệu cá nhân, không persistent memory

---

## 2. Solution Overview (2 minutes)

### Kioku: AI-Powered Knowledge Graph Journal

**Core Concept:**
> Transform raw journal text into structured knowledge that AI can understand and reason about.

```
Raw Journal Entry          Knowledge Graph              AI Understanding
─────────────────         ─────────────────            ────────────────
"Hôm nay gặp Minh      →  Entity: Minh (Person)    →  AI biết:
ở Highlands, cảm        →  Entity: Highlands         - Bạn gặp ai
giác rất vui"           →  Relation: met_at          - Ở đâu
                        →  Insight: positive mood    - Cảm xúc ra sao
```

**Tech Stack:**
- **Platform**: iOS 18+ (Swift, SwiftUI, SwiftData)
- **AI Integration**: OpenRouter API (Claude 3.5, GPT-4o, Gemini 2.0)
- **Data Layer**: Local-first with SwiftData, encryption support
- **Architecture**: MVVM + Service Layer, async/await

---

## 3. Key AI Features (8 minutes)

### Feature 1: Entity Extraction (Named Entity Recognition)

**Problem**: Raw text có thông tin nhưng không structured
**Solution**: AI tự động extract entities từ journal entries

**Technical Implementation:**
```swift
// KnowledgeGraphService.swift
func extractEntitiesFromEntry(_ entry: Entry) async throws {
    // 1. Build AI prompt với entry content
    let prompt = """
    Extract entities from this journal entry:
    - PERSON: Tên người
    - LOCATION: Địa điểm
    - EVENT: Sự kiện
    - EMOTION: Cảm xúc

    Entry: \(entry.content)
    """

    // 2. Call OpenRouter API
    let response = try await openRouterService.complete(prompt)

    // 3. Parse JSON response
    let entities = try JSONDecoder().decode([Entity].self, from: response)

    // 4. Save to SwiftData with deduplication
    for entity in entities {
        let existing = findOrCreateEntity(entity)
        entry.entities.append(existing)
    }
}
```

**Example Output:**
```
Input Entry (Oct 8):
"Hôm nay gặp Minh và Hằng ở Highlands, bàn về dự án mới"

Extracted Entities:
┌─────────────┬──────────┬──────────────┬────────────┐
│ Entity      │ Type     │ Confidence   │ Context    │
├─────────────┼──────────┼──────────────┼────────────┤
│ Minh        │ PERSON   │ 0.95         │ met with   │
│ Hằng        │ PERSON   │ 0.92         │ met with   │
│ Highlands   │ LOCATION │ 0.88         │ meeting at │
│ Dự án mới   │ EVENT    │ 0.85         │ discussed  │
└─────────────┴──────────┴──────────────┴────────────┘
```

**Key Technical Challenges Solved:**
1. **Entity Deduplication**: "Minh" trong 5 entries khác nhau → 1 entity duy nhất
2. **Context Awareness**: AI biết "Minh" là PERSON, không phải tên địa điểm
3. **Confidence Scoring**: Mỗi entity có confidence score để filter false positives

---

### Feature 2: Relationship Discovery

**Problem**: Entities tồn tại riêng lẻ, không có context
**Solution**: AI discovers relationships between entities

**Technical Implementation:**
```swift
// Relationship.swift model
class Relationship: Identifiable {
    var sourceEntity: Entity      // "Minh"
    var targetEntity: Entity      // "Highlands"
    var type: RelationType        // .metAt
    var context: String           // "Discussed new project"
    var confidence: Double        // 0.85
    var discoveredDate: Date
}

// Discovery algorithm
func discoverRelationships(for entry: Entry) async throws {
    let entities = entry.entities

    // AI analyzes entity pairs
    let prompt = """
    Given these entities: \(entities.map(\.value))
    What relationships exist? Format: (source, relation, target)
    """

    let relationships = try await openRouterService.complete(prompt)

    // Create relationship graph
    for rel in relationships {
        let relationship = Relationship(
            source: rel.source,
            target: rel.target,
            type: RelationType(rawValue: rel.type),
            context: entry.content
        )
        modelContext.insert(relationship)
    }
}
```

**Example Relationship Graph:**

```
Entry (Oct 8): "Gặp Minh và Hằng ở Highlands, bàn về dự án"

Discovered Relationships:
─────────────────────────

      [Minh]
        │
        │ met_at
        ↓
    [Highlands] ←──── location_of ──── [Meeting]
        ↑
        │ met_at
        │
      [Hằng]

      [Minh]
        │
        │ discussed_with
        ↓
      [Hằng] ────→ about ────→ [Dự án mới]
```

**Advanced Features:**
- **Temporal Relationships**: Track how relationships evolve over time
- **Weighted Edges**: Frequency of co-occurrence increases relationship strength
- **Transitive Discovery**: If A→B and B→C, infer potential A→C relationship

---

### Feature 3: AI-Generated Insights

**Problem**: User không nhận ra patterns trong cuộc sống
**Solution**: AI generates insights from entity/relationship patterns

**Technical Implementation:**
```swift
// InsightService.swift
enum InsightType {
    case emotionalPattern    // "You're happiest when meeting friends"
    case relationshipDepth   // "Minh appears in 15 entries over 3 months"
    case activityTrend      // "Coffee shop visits increased 40%"
    case locationPattern    // "Highlands is your most productive location"
}

func generateInsights(for dateRange: DateInterval) async throws -> [AIInsight] {
    // 1. Aggregate data from knowledge graph
    let entities = fetchEntities(in: dateRange)
    let relationships = fetchRelationships(in: dateRange)
    let entries = fetchEntries(in: dateRange)

    // 2. Build statistical summary
    let summary = """
    Period: \(dateRange)
    Entries: \(entries.count)
    People met: \(entities.filter { $0.type == .person }.count)
    Locations visited: \(entities.filter { $0.type == .location }.count)
    Emotional tone: \(analyzeEmotionalTone(entries))
    """

    // 3. Ask AI to generate insights
    let prompt = """
    Analyze this journal data and generate 3-5 insights:
    \(summary)

    Focus on:
    - Relationship patterns
    - Emotional trends
    - Activity correlations
    """

    let insights = try await openRouterService.complete(prompt)

    // 4. Parse and save insights
    return insights.map { insight in
        AIInsight(
            type: classifyInsightType(insight),
            content: insight.text,
            confidence: insight.confidence,
            supportingEntries: insight.entryIds
        )
    }
}
```

**Example Insights:**

```
Weekly Insights (Oct 1-7):

1. 🤝 Social Pattern (Confidence: 0.92)
   "You met Minh 4 times this week - your most frequent contact.
    Meetings at Highlands correlate with positive mood (80% entries)"

   Supporting Data:
   - Oct 1: Minh at Highlands → "felt productive"
   - Oct 3: Minh at Highlands → "great conversation"
   - Oct 5: Minh at Starbucks → "okay but distracted"
   - Oct 7: Minh at Highlands → "very happy"

2. 📍 Location Insight (Confidence: 0.88)
   "Highlands appears in 6 entries. Activities: work (4), social (2).
    Your 'flow state' location for deep work."

3. 😊 Emotional Trend (Confidence: 0.85)
   "Mood improved 30% compared to last week.
    Correlation: increased social interactions (↑50%)"
```

**Key Innovation:**
- **Confidence Scoring**: Each insight has confidence based on data support
- **Explainability**: Show which entries led to each insight
- **Actionable**: Insights suggest patterns user can leverage

---

### Feature 4: Context-Aware AI Chat

**Problem**: ChatGPT-style bots don't know your personal history
**Solution**: RAG (Retrieval-Augmented Generation) with KG context

**Technical Architecture:**

```
User Question: "Lần cuối tôi gặp Minh là khi nào?"
     │
     ↓
┌────────────────────────────────────────────┐
│  ChatContextService.buildContext()         │
│                                            │
│  1. Parse question → extract entities      │
│     → "Minh" (PERSON)                      │
│                                            │
│  2. Query Knowledge Graph:                 │
│     - Find all entries with entity "Minh"  │
│     - Sort by date DESC                    │
│     - Get top 5 most relevant              │
│                                            │
│  3. Relevance Scoring:                     │
│     score = (relationship_weight * 0.4) +  │
│             (insight_confidence * 0.3) +   │
│             (recency_factor * 0.3)         │
│                                            │
│  4. Build context:                         │
│     "Relevant entries about Minh:          │
│      - Oct 8: met at Highlands..."         │
│      - Oct 3: discussed project..."        │
└────────────────────────────────────────────┘
     │
     ↓
┌────────────────────────────────────────────┐
│  OpenRouterService.completeWithHistory()   │
│                                            │
│  Messages:                                 │
│  [                                         │
│    {role: "system", content: context},     │
│    {role: "user", content: question},      │
│    ...conversation history...              │
│  ]                                         │
└────────────────────────────────────────────┘
     │
     ↓
   Answer: "Lần cuối bạn gặp Minh là Oct 8,
           tại Highlands, bàn về dự án mới"
```

**Implementation Code:**

```swift
// ChatContextService.swift
func buildContext(for date: Date, query: String) async -> String {
    // 1. Get current entry
    let currentEntry = fetchEntry(for: date)

    // 2. Extract entities from query
    let queryEntities = extractEntities(from: query)

    // 3. Find related entries via KG
    var relatedEntries: [Entry] = []
    for entity in queryEntities {
        let entries = fetchEntries(containing: entity)
        relatedEntries.append(contentsOf: entries)
    }

    // 4. Score relevance
    relatedEntries.sort { entry1, entry2 in
        let score1 = calculateRelevanceScore(entry1, to: queryEntities)
        let score2 = calculateRelevanceScore(entry2, to: queryEntities)
        return score1 > score2
    }

    // 5. Build context string
    var context = "# Current Entry\n\(currentEntry.content)\n\n"
    context += "# Related Entries\n"
    for entry in relatedEntries.prefix(5) {
        context += "- \(entry.date): \(entry.content)\n"
        context += "  Entities: \(entry.entities.map(\.value).joined())\n"
    }

    return context
}

// Relevance scoring algorithm
func calculateRelevanceScore(_ entry: Entry, to entities: [Entity]) -> Double {
    let relationshipScore = entry.relationships
        .filter { entities.contains($0.sourceEntity) || entities.contains($0.targetEntity) }
        .reduce(0.0) { $0 + $1.confidence } * 0.4

    let insightScore = entry.insights
        .reduce(0.0) { $0 + $1.confidence } * 0.3

    let recencyScore = calculateRecencyFactor(entry.date) * 0.3

    return relationshipScore + insightScore + recencyScore
}
```

**Example Chat Session:**

```
User: "Lần cuối tôi gặp Minh là khi nào?"

[System builds context]
Context includes:
- Current entry (Oct 10)
- 5 related entries mentioning "Minh" (Oct 8, 5, 3, 1, Sep 28)
- Entity: Minh (PERSON, confidence: 0.95)
- Relationships: Minh-Highlands (met_at), Minh-Hằng (colleague)

AI Response:
"Lần cuối bạn gặp Minh là ngày 8/10 (2 ngày trước) tại Highlands.
Lúc đó bạn và Minh cùng Hằng bàn về dự án mới, và bạn cảm thấy
rất productive. Trước đó bạn cũng gặp Minh vào ngày 5/10 và 3/10."

[User can verify by clicking entry references]

User: "Chúng tôi hay gặp nhau ở đâu nhất?"

[System queries relationship graph]
- Query: Minh + Location entities
- Find: Highlands (6 times), Starbucks (2 times), Office (1 time)

AI Response:
"Bạn và Minh hay gặp nhau ở Highlands nhất (6 lần trong tháng này).
Tại Highlands, bạn thường làm việc hiệu quả hơn và mood tích cực hơn
so với các địa điểm khác (80% entries có positive sentiment)."
```

**Technical Highlights:**
- **RAG Pattern**: Retrieval-Augmented Generation ensures accuracy
- **Conversation Memory**: Full message history sent to maintain context
- **Explainable AI**: User sees which entries AI referenced
- **Relevance Ranking**: Smart scoring algorithm finds best matches

---

## 4. Technical Architecture (2 minutes)

### System Design Overview

```
┌─────────────────────────────────────────────────────────────┐
│                         UI Layer (SwiftUI)                   │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Calendar │  │ Insights │  │ Graph    │  │ Settings │   │
│  │ TabView  │  │ View     │  │ View     │  │ View     │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                    Service Layer (Business Logic)            │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │ OpenRouterService│  │ ChatContextServ. │                │
│  │ - completeText() │  │ - buildContext() │                │
│  │ - withHistory()  │  │ - relevanceScore │                │
│  └──────────────────┘  └──────────────────┘                │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │ KnowledgeGraphSvc│  │ EntityExtraction │                │
│  │ - extract()      │  │ - deduplicate()  │                │
│  │ - discover()     │  │ - confidence()   │                │
│  └──────────────────┘  └──────────────────┘                │
│                                                              │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │ InsightService   │  │ ExportService    │                │
│  │ - generate()     │  │ - exportJSON()   │                │
│  │ - analyze()      │  │ - importJSON()   │                │
│  └──────────────────┘  └──────────────────┘                │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                  Data Layer (SwiftData)                      │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  Entry   │  │  Entity  │  │ Relation │  │ Insight  │   │
│  │ @Model   │  │ @Model   │  │ @Model   │  │ @Model   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│                                                              │
│              Local SQLite Database (Encrypted)               │
└─────────────────────────────────────────────────────────────┘
                              │
                              ↓
┌─────────────────────────────────────────────────────────────┐
│                  External API (OpenRouter)                   │
│         Claude 3.5 Sonnet / GPT-4o / Gemini 2.0             │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow Example: "Write Entry → Extract Entities → Chat"

```
Step 1: User writes entry
┌──────────────────────────────────────┐
│ CalendarTabView                      │
│ → EntryDetailView                    │
│ → Save Entry to SwiftData            │
└──────────────────────────────────────┘
           │
           ↓
Step 2: Background extraction (async)
┌──────────────────────────────────────┐
│ KnowledgeGraphService                │
│ → extractEntitiesFromEntry()         │
│ → Call OpenRouter API                │
│ → Parse entities & relationships     │
│ → Save to SwiftData                  │
└──────────────────────────────────────┘
           │
           ↓
Step 3: User opens chat
┌──────────────────────────────────────┐
│ AIChatView                           │
│ → User asks question                 │
│ → ChatContextService.buildContext()  │
│   - Query entities from SwiftData    │
│   - Score relevance                  │
│   - Build prompt with KG context     │
│ → OpenRouterService.withHistory()    │
│ → Display streaming response         │
└──────────────────────────────────────┘
```

### Key Technical Decisions

**1. Why SwiftData over Core Data?**
- Modern Swift-native API (@Model, @Query)
- Better async/await integration
- Automatic observation with @Observable
- Less boilerplate code

**2. Why OpenRouter over direct OpenAI?**
- Access to multiple models (Claude, GPT, Gemini)
- Per-conversation model selection
- Fallback options if one model is down
- Unified API interface

**3. Why Local-First Architecture?**
- Privacy: User owns 100% of data
- Offline capability: No internet required for reading
- Performance: No API latency for data queries
- Export control: Easy backup/restore

**4. Why Knowledge Graph over Vector DB?**
- Explainability: Can show "why" AI made a connection
- Structured: Entities and relationships have types
- Queryable: SQL-like queries for complex patterns
- Lightweight: Runs on-device without ML model

---

## 5. Demo Scenarios (Optional)

### Scenario 1: Entity Extraction

**Setup:**
- App has 0 entries
- User writes first entry

**Steps:**
1. Open Calendar tab → Select Oct 10
2. Write: "Hôm nay gặp Minh và Hằng ở Highlands, bàn về dự án AI"
3. Save entry
4. Wait 2 seconds (background extraction)
5. Navigate to Graph tab
6. See: 4 entities extracted (Minh, Hằng, Highlands, Dự án AI)
7. Tap "Minh" → See relationships: met_at(Highlands), discussed_with(Hằng)

**Key Points:**
- Automatic extraction (no manual tagging)
- Real-time processing (< 3 seconds)
- Visual graph representation

### Scenario 2: Context-Aware Chat

**Setup:**
- App has 5 entries over 1 week
- All mention "Minh" at different locations

**Steps:**
1. Open Calendar tab → Oct 10
2. Tap "Chat with AI" button
3. Ask: "Lần cuối tôi gặp Minh là khi nào?"
4. AI responds: "Oct 8 at Highlands" (with entry link)
5. Ask follow-up: "Chúng tôi hay gặp nhau ở đâu?"
6. AI responds: "Highlands (3 times), Starbucks (2 times)"
7. Tap entry links to verify

**Key Points:**
- AI remembers conversation history
- References specific entries
- Quantitative insights from KG data

### Scenario 3: Export & Import

**Setup:**
- App has 10 entries with entities/relationships

**Steps:**
1. Settings → Data Management
2. Export to JSON
3. Open Files app → See exported file
4. Clear all data
5. Import JSON back
6. Verify: All entries, entities, relationships restored

**Key Points:**
- Data portability
- Backup/restore capability
- User owns data completely

---

## 6. Technical Challenges & Solutions

### Challenge 1: Entity Deduplication

**Problem:**
```
Entry 1: "Gặp Minh ở Highlands"   → AI extracts: "Minh"
Entry 2: "Minh rủ đi café"        → AI extracts: "Minh"
Entry 3: "Minh và Hằng"           → AI extracts: "Minh"

Result: 3 separate "Minh" entities in database ❌
```

**Solution: In-Memory Cache + Fuzzy Matching**
```swift
class EntityCache {
    private var cache: [String: Entity] = [:]

    func findOrCreate(_ entityValue: String, type: EntityType) -> Entity {
        // Normalize: lowercase, trim whitespace
        let normalized = entityValue.lowercased().trimmingCharacters(in: .whitespaces)

        // Check cache first
        if let cached = cache[normalized] {
            return cached
        }

        // Query database with fuzzy match
        let existing = fetchEntities(similarTo: normalized, type: type)
        if let match = existing.first {
            cache[normalized] = match
            return match
        }

        // Create new entity
        let newEntity = Entity(value: entityValue, type: type)
        modelContext.insert(newEntity)
        cache[normalized] = newEntity
        return newEntity
    }
}
```

**Result:**
- "Minh" reused across 5 entries ✅
- Cache avoids SwiftData context sync delays
- 10x faster extraction performance

### Challenge 2: Conversation History Token Limits

**Problem:**
```
Long conversation (20 messages) → 8000 tokens
+ KG context (5 entries) → 2000 tokens
+ System prompt → 500 tokens
─────────────────────────────────
Total: 10,500 tokens (exceeds 8K limit for some models)
```

**Solution: Sliding Window + Compression**
```swift
func buildMessageHistory(_ messages: [Message]) -> [ChatMessage] {
    var history: [ChatMessage] = []

    // Always include system message
    history.append(.system(systemPrompt))

    // If conversation too long, use sliding window
    let maxMessages = 10
    let recentMessages = messages.suffix(maxMessages)

    // Compress older context
    if messages.count > maxMessages {
        let summary = summarizeOlderMessages(messages.prefix(messages.count - maxMessages))
        history.append(.system("Previous conversation summary: \(summary)"))
    }

    // Add recent messages
    for msg in recentMessages {
        history.append(msg.isFromUser ? .user(msg.content) : .assistant(msg.content))
    }

    return history
}
```

**Trade-offs:**
- ✅ Fits within token limits
- ✅ Maintains recent context
- ⚠️ Older messages compressed (acceptable loss)

### Challenge 3: SwiftData Deletion Order

**Problem:**
```swift
// Wrong order - CRASHES ❌
modelContext.delete(entity)        // Try to delete entity first
modelContext.delete(relationship)  // But relationship still references it
modelContext.save()                // CRASH: constraint violation
```

**Solution: Reverse Dependency Order**
```swift
func clearAllData() async throws {
    // 1. Delete entries first (triggers cascade)
    let entries = try modelContext.fetch(FetchDescriptor<Entry>())
    entries.forEach { modelContext.delete($0) }
    try modelContext.save()  // Save checkpoint

    // 2. Delete conversations
    let conversations = try modelContext.fetch(FetchDescriptor<Conversation>())
    conversations.forEach { modelContext.delete($0) }
    try modelContext.save()

    // 3. Delete insights
    let insights = try modelContext.fetch(FetchDescriptor<AIInsight>())
    insights.forEach { modelContext.delete($0) }
    try modelContext.save()

    // 4. Delete orphaned relationships
    let relationships = try modelContext.fetch(FetchDescriptor<Relationship>())
    relationships.forEach { modelContext.delete($0) }
    try modelContext.save()

    // 5. Delete orphaned entities
    let entities = try modelContext.fetch(FetchDescriptor<Entity>())
    entities.forEach { modelContext.delete($0) }
    try modelContext.save()
}
```

**Key Lesson:**
- SwiftData relationships have implicit constraints
- Delete in reverse dependency order: leaves → branches → root
- Save after each step to commit changes

---

## 7. Results & Impact

### Quantitative Metrics

**Development:**
- **Duration**: 3 months (10 sprints)
- **Story Points**: 204 points delivered (101% of planned scope)
- **Code**: ~8,000 lines of Swift
- **Tests**: Manual + XcodeBuildMCP automation

**Performance:**
- **Entity Extraction**: < 3 seconds per entry (with OpenRouter API)
- **Chat Response**: < 2 seconds for typical query
- **Database**: Handles 1000+ entries smoothly
- **Memory**: < 50MB for typical usage

**Data Quality:**
- **Entity Accuracy**: ~92% confidence (based on manual review)
- **Relationship Discovery**: ~85% confidence
- **Deduplication**: 100% success rate (same entity reused across entries)

### Qualitative Impact

**User Experience:**
- "Tôi không còn phải lật nhật ký để tìm thông tin" - Search via AI chat
- "AI hiểu context cá nhân của tôi" - RAG with KG context
- "Nhận ra patterns mà bản thân không nhận thấy" - AI-generated insights

**Technical Learnings:**
1. **SwiftData gotchas**: Deletion order, relationship constraints, context sync
2. **AI prompt engineering**: Structured prompts → better entity extraction
3. **RAG architecture**: Knowledge graph >> vector embeddings for structured data
4. **Local-first benefits**: Privacy + performance + offline capability

**Business Value:**
- **Differentiation**: Only iOS journal app with full knowledge graph
- **Privacy-first**: Appeals to security-conscious users
- **Extensibility**: Architecture supports future AI features

---

## 8. Future Roadmap

### Phase 1: Enhanced Export (Sprint 19)
- CSV export for spreadsheet analysis
- Date range filtering
- Selective export (choose data types)

### Phase 2: Data Cleanup Tools
- Orphaned entity cleanup
- Duplicate detection and merge
- Bulk delete by date range

### Phase 3: Advanced AI Features
- Sentiment analysis over time
- Predictive insights ("You might want to call Minh")
- Automatic journaling prompts based on patterns

### Phase 4: Visualization
- Interactive knowledge graph (force-directed layout)
- Timeline view with entity highlights
- Heatmap of emotional patterns

### Phase 5: Cross-Platform
- macOS app (Mac Catalyst)
- iCloud sync (optional, encrypted)
- Web export/viewer

---

## 9. Q&A Preparation

### Expected Questions

**Q1: "Why not use vector database like Pinecone for RAG?"**

**A:** Knowledge graph provides structure + explainability:
- **Vector DB**: "Similar entries found" (black box, hard to explain)
- **Knowledge Graph**: "Entries about Minh at Highlands" (transparent, queryable)

For journal data with clear entities/relationships, KG is better than embeddings.

**Q2: "How do you handle AI hallucinations?"**

**A:** Three strategies:
1. **Confidence Scoring**: Each entity/relationship has confidence (0-1)
2. **Explainability**: Show which entries AI referenced
3. **User Verification**: User can click entry links to verify AI claims

If confidence < 0.7, we show warning icon.

**Q3: "What if user has 10,000 entries? Performance?"**

**A:** Optimizations:
1. **Pagination**: Load entries on-demand (SwiftData @Query with predicates)
2. **Lazy Extraction**: Extract entities only when user views entry
3. **Relevance Ranking**: Only send top 5 relevant entries to AI (not all 10K)
4. **Indexing**: SwiftData indexes on date, entity values

Tested with 1000 entries - smooth performance.

**Q4: "Why OpenRouter instead of running local LLM?"**

**A:** Trade-offs:
- **Local LLM (Core ML)**: Privacy, offline, but limited model quality
- **OpenRouter**: Best models (Claude 3.5, GPT-4o), but requires internet

Current choice: OpenRouter for better AI quality. Future: Hybrid approach (local for extraction, cloud for chat).

**Q5: "How secure is the data?"**

**A:**
- **Storage**: SwiftData with encryption enabled
- **API**: HTTPS only, API key stored in Keychain
- **No Cloud**: 100% local storage, no automatic uploads
- **Export**: User can export JSON and store wherever they want

User has full control.

---

## 10. Presentation Tips

### Time Allocation (15 minutes)
- **Problem (2 min)**: Hook with relatable pain points
- **Solution (2 min)**: High-level concept, tech stack
- **Features (8 min)**: Deep dive into 3-4 key features
- **Architecture (2 min)**: System design diagram
- **Q&A (1 min)**: Leave time for questions

### Delivery Tips
1. **Start with Demo**: Show the app working (30 seconds)
2. **Tell a Story**: "Imagine you wrote 100 journal entries..."
3. **Use Diagrams**: Visual >> text explanations
4. **Show Code**: But keep it brief (5-10 lines max)
5. **Highlight Challenges**: "This was hard because..." → shows problem-solving

### Key Messages
1. **Problem-Solving**: "Traditional journals have limitations → Kioku solves them"
2. **Technical Depth**: "Not just UI - knowledge graph, RAG, async/await"
3. **Real-World Ready**: "Handles 1000+ entries, real user testing"
4. **Continuous Learning**: "Each sprint taught me something new about SwiftData/AI"

### Confidence Builders
- **You built this**: 204 story points over 3 months
- **You solved hard problems**: Entity deduplication, deletion order, RAG architecture
- **You shipped features**: Not just code - real user value

**Remember:** They're evaluating problem-solving + technical communication, not perfection.

---

## Appendix: Technical Glossary

**Entity Extraction**: AI technique to identify named entities (people, places, events) from text

**Knowledge Graph**: Structured representation of entities and relationships (nodes + edges)

**RAG (Retrieval-Augmented Generation)**: AI pattern that retrieves relevant context before generating response

**SwiftData**: Apple's modern data persistence framework (successor to Core Data)

**OpenRouter**: API gateway that provides access to multiple AI models (Claude, GPT, Gemini)

**Confidence Score**: Probability (0-1) that an AI prediction is correct

**Async/Await**: Swift concurrency model for handling asynchronous operations

**MVVM**: Model-View-ViewModel architecture pattern

**Local-First**: Architecture where data is stored locally, not cloud-first

**Deduplication**: Process of identifying and merging duplicate entities

---

**Good luck with your interview! 🚀**

You've built something impressive - now show them how you think, solve problems, and communicate technical concepts clearly.
