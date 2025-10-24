# Kioku - AI Journal
## 15-Minute Technical Presentation

**Format**: Demo-First + Technical Deep Dive
**Time**: 15 minutes (12 min present + 3 min Q&A)
**Style**: Show → Explain → Impress

---

## Timing Breakdown

```
0:00 - 1:00   Opening + Problem (1 min)
1:00 - 4:00   Live Demo (3 min)
4:00 - 10:00  Technical Deep Dive (6 min)
10:00 - 12:00 Architecture + Results (2 min)
12:00 - 15:00 Q&A (3 min)
```

---

# Part 1: Opening (1 minute)

## Slide 1: The Problem
```
❌ "Tôi viết nhật ký mỗi ngày, nhưng..."
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Sau 3 tháng:
  "Lần cuối tôi gặp Minh là khi nào?"
  → Phải lật 100 entries, đọc từng dòng 😓

Traditional journals:
  ❌ No memory
  ❌ No context understanding
  ❌ No pattern discovery
  ❌ Privacy concerns (cloud-based)
```

**Say:**
> "Imagine bạn viết nhật ký mỗi ngày. Sau 3 tháng có 100 entries. Một ngày bạn muốn nhớ 'lần cuối gặp Minh là khi nào?' - bạn phải làm gì? Lật từng trang, đọc từng dòng, tốn 30 phút mà vẫn không chắc tìm được.
>
> Đó là lý do tôi build Kioku - một journal app có AI memory, hiểu context, và tự động discover patterns trong cuộc sống bạn."

---

# Part 2: Live Demo (3 minutes)

## Demo Script

### Setup (pre-demo):
- App có sẵn 5 entries về Minh
- Đã extract entities và relationships

### Demo Flow:

**Step 1: Show Calendar Tab (30s)**
```
Action: Open app → Calendar tab
Point out:
  • "Đây là giao diện chính - calendar-based journaling"
  • Tap vào Oct 8 entry
  • "Entry này viết về meeting với Minh và Hằng ở Highlands"
```

**Step 2: Show Knowledge Graph (45s)**
```
Action: Navigate to Graph tab
Point out:
  • "AI đã tự động extract entities từ entries"
  • Tap vào entity "Minh"
  • "Minh xuất hiện trong 5 entries khác nhau"
  • "AI discovered relationships: Minh-Highlands (met_at), Minh-Hằng (colleague)"
  • Scroll qua entity list
```

**Step 3: Show AI Insights (45s)**
```
Action: Navigate to Insights tab
Point out:
  • "AI phân tích patterns từ entries"
  • Read insight: "Bạn gặp Minh 4 lần tuần này - người bạn gặp nhiều nhất"
  • "80% meetings ở Highlands correlate với positive mood"
  • "AI không chỉ trích dẫn data, mà discover patterns"
```

**Step 4: Show Context-Aware Chat (60s)**
```
Action: Back to Calendar → Tap "Chat with AI"
Type: "Lần cuối tôi gặp Minh là khi nào?"

Point out:
  • Wait for response
  • AI responds: "Ngày 8/10 tại Highlands, cùng với Hằng..."
  • "AI đọc toàn bộ journal để trả lời - không phải guess"

Follow-up question:
Type: "Chúng tôi hay gặp ở đâu?"

Point out:
  • AI responds: "Highlands 3 lần, Starbucks 2 lần..."
  • "AI nhớ conversation history - natural dialogue"
  • Tap entry link to verify
```

**Demo Conclusion:**
> "Đó là Kioku từ user perspective. Bây giờ tôi sẽ explain làm sao nó hoạt động under the hood."

---

# Part 3: Technical Deep Dive (6 minutes)

## Slide 2: Architecture Overview (1 min)
```
System Design
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌────────────────────────────────────┐
│  SwiftUI Views (Calendar, Graph)   │
└────────────────────────────────────┘
              ↓
┌────────────────────────────────────┐
│  Service Layer                      │
│  • KnowledgeGraphService            │
│  • ChatContextService (RAG)         │
│  • OpenRouterService (AI API)       │
└────────────────────────────────────┘
              ↓
┌────────────────────────────────────┐
│  SwiftData (Local Database)         │
│  Entry → Entity → Relationship      │
└────────────────────────────────────┘
              ↓
┌────────────────────────────────────┐
│  OpenRouter API                     │
│  Claude 3.5 / GPT-4o / Gemini       │
└────────────────────────────────────┘

Tech Stack:
  • iOS 18+ (Swift, SwiftUI, SwiftData)
  • Local-first (privacy + offline)
  • Multi-model AI via OpenRouter
```

**Say (60s):**
> "Architecture gồm 4 layers. UI layer là SwiftUI với tab-based navigation. Service layer chứa business logic - entity extraction, RAG chat, AI integration. Data layer dùng SwiftData - Apple's modern persistence framework, 100% local. Cuối cùng là OpenRouter API để access multiple AI models.
>
> Key decision: Local-first architecture. Dữ liệu lưu 100% trên máy user, không cloud sync by default. Privacy + performance + offline capability."

---

## Slide 3: Feature 1 - Entity Extraction (1.5 min)
```
🔍 Named Entity Recognition
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Input Entry:
  "Hôm nay gặp Minh và Hằng ở Highlands,
   bàn về dự án AI"

         ↓  AI Prompt Engineering

Extracted Entities:
  ┌───────────┬──────────┬────────────┐
  │ Entity    │ Type     │ Confidence │
  ├───────────┼──────────┼────────────┤
  │ Minh      │ PERSON   │ 0.95       │
  │ Hằng      │ PERSON   │ 0.92       │
  │ Highlands │ LOCATION │ 0.88       │
  │ Dự án AI  │ EVENT    │ 0.85       │
  └───────────┴──────────┴────────────┘

Key Challenge: Deduplication
  Entry 1: "Minh"  ─┐
  Entry 2: "Minh"  ─┼─→ Must be 1 entity
  Entry 5: "Minh"  ─┘

Solution: In-memory cache + fuzzy matching
  → 100% deduplication success rate
```

**Code Example:**
```swift
func extractEntities(from entry: Entry) async throws {
    // 1. Build structured prompt
    let prompt = """
    Extract entities (PERSON, LOCATION, EVENT):
    \(entry.content)
    Return JSON with confidence scores.
    """

    // 2. Call OpenRouter API
    let response = try await openRouter.complete(prompt)

    // 3. Parse & deduplicate
    let entities = try JSONDecoder().decode([Entity].self)
    for entity in entities {
        let existing = cache.findOrCreate(entity)
        entry.entities.append(existing) // Reuse if exists
    }
}
```

**Say (90s):**
> "Entity extraction dùng Named Entity Recognition. AI nhận diện người, địa điểm, sự kiện từ raw text với confidence scores.
>
> Key challenge là deduplication. 'Minh' xuất hiện trong 5 entries khác nhau - phải là cùng 1 entity, không phải 5 entities riêng. Solution là in-memory cache với fuzzy matching. Mỗi lần extract entity mới, check cache trước, nếu đã có thì reuse. Kết quả: 100% deduplication success.
>
> Quick code walkthrough: Build prompt → call API → parse JSON → deduplicate với cache. Simple but effective."

---

## Slide 4: Feature 2 - Knowledge Graph (1.5 min)
```
🕸️ Relationship Discovery
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Entry: "Gặp Minh và Hằng ở Highlands"

AI Discovers Relationships:

        [Minh]
          │
          │ met_at
          ↓
      [Highlands] ←─ location_of ─ [Meeting]
          ↑
          │ met_at
          │
        [Hằng]

Weighted Edges:
  • Frequency → strength
  • Minh-Highlands: 3 meetings → weight 0.85
  • Minh-Hằng: colleague → weight 0.78

Why Knowledge Graph > Vector DB?
  ✅ Explainable (can show "why")
  ✅ Queryable (SQL-like patterns)
  ✅ Structured (typed relationships)
  ✅ Lightweight (no ML inference)
```

**Say (90s):**
> "Relationships tạo knowledge graph. AI không chỉ extract entities riêng lẻ, mà discover mối quan hệ giữa chúng. Minh met_at Highlands, Minh discussed_with Hằng.
>
> Weighted edges: Frequency tăng → relationship strength tăng. Minh-Highlands xuất hiện 3 lần → weight cao hơn.
>
> Câu hỏi hay gặp: Why knowledge graph instead of vector database? Vector DB là black box - 'similar entries found' nhưng không explain được why. Knowledge graph cho structured relationships với explicit types. User có thể query: 'Show me all people I met at Highlands'. Explainable + queryable + lightweight."

---

## Slide 5: Feature 3 - RAG Chat (2 min)
```
�� Context-Aware Chat (RAG Pattern)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

User Question: "Lần cuối tôi gặp Minh?"

Step 1: Parse Query
  Extract entities: "Minh" (PERSON)

Step 2: Query Knowledge Graph
  Find entries WHERE entity = "Minh"
  → 5 entries found

Step 3: Relevance Scoring
  score = relationship_weight × 0.4 +
          insight_confidence × 0.3 +
          recency_factor × 0.3

  Results:
    Oct 8 entry: 0.92 ⭐
    Oct 5 entry: 0.78
    Oct 3 entry: 0.65

Step 4: Build Context
  Include: Top 5 relevant entries + conversation history

Step 5: AI Completion
  Send full context → OpenRouter API
  → Response with citations
```

**Code Example:**
```swift
func buildContext(for query: String) async -> String {
    // 1. Extract entities from query
    let entities = extractEntities(from: query)

    // 2. Find related entries via KG
    var related = [Entry]()
    for entity in entities {
        related += fetchEntries(containing: entity)
    }

    // 3. Score & rank
    related.sort { scoreRelevance($0) > scoreRelevance($1) }

    // 4. Build context
    var context = "Current entry: \(current.content)\n\n"
    context += "Related entries:\n"
    for entry in related.prefix(5) {
        context += "- \(entry.date): \(entry.content)\n"
    }

    return context
}
```

**Say (120s):**
> "Context-aware chat dùng RAG pattern - Retrieval-Augmented Generation. Không phải ChatGPT style mà AI guess randomly, mà AI retrieve relevant context trước khi generate response.
>
> 5 steps: Parse query để extract entities. Query knowledge graph để find related entries. Score relevance bằng formula kết hợp relationship strength, insight confidence, và recency. Build context với top 5 entries. Cuối cùng send full context + conversation history đến AI.
>
> Key innovation là relevance scoring algorithm. Không phải lấy ngẫu nhiên, mà smart ranking dựa trên KG data. Entry nào có strong relationship với query entities → score cao hơn.
>
> Code walkthrough: Extract entities → find related → sort by score → build context. Clean separation of concerns."

---

# Part 4: Results & Wrap-up (2 minutes)

## Slide 6: Technical Challenges Solved (1 min)
```
🔧 Real Problems, Real Solutions
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Challenge 1: Entity Deduplication
  Problem: "Minh" × 5 entries = 5 entities ❌
  Solution: In-memory cache + fuzzy matching
  Result: 1 entity reused across all ✅

Challenge 2: SwiftData Deletion Order
  Problem: Delete entity → CRASH (constraint violation)
  Solution: Reverse dependency (entries → relations → entities)
  Result: Reliable data cleanup ✅

Challenge 3: Token Limit Management
  Problem: Long chat + KG context > 8K tokens
  Solution: Sliding window + conversation compression
  Result: Always fits within limits ✅

Learning: Read the docs, test assumptions, iterate fast
```

**Say (60s):**
> "3 biggest challenges during development. Entity deduplication - solved with caching. SwiftData deletion crashes - learned relationship constraints the hard way, fixed với correct deletion order. Token limits - implemented sliding window để compress old messages.
>
> Key learning: Always validate assumptions. Don't assume SwiftData works like Core Data. Test with real data, not just 3 entries. Iterate fast when things break."

---

## Slide 7: Results & Impact (1 min)
```
📊 Delivered Results
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Development:
  ✅ 3 months, 10 sprints
  ✅ 204 story points (101% of plan)
  ✅ ~8,000 lines Swift code
  ✅ Manual + XcodeBuildMCP testing

Performance:
  ✅ Entity extraction: < 3s per entry
  ✅ Chat response: < 2s average
  ✅ Handles 1000+ entries smoothly
  ✅ Memory: < 50MB

Quality:
  ✅ Entity accuracy: 92%
  ✅ Relationship discovery: 85%
  ✅ Deduplication: 100% success
  ✅ 0 known bugs, 0 technical debt

Next: CSV export, data cleanup tools, advanced insights
```

**Say (60s):**
> "Real metrics from real development. 3 tháng build từ zero, 204 story points delivered. Performance tốt: entity extraction under 3 seconds, chat response under 2 seconds, xử lý 1000+ entries smooth.
>
> Quality metrics based on manual testing: 92% entity accuracy, 85% relationship accuracy, 100% deduplication success.
>
> Shipped production-ready code. Không phải prototype, mà real product với real testing. Roadmap tiếp theo: advanced export, data cleanup, predictive insights."

---

## Slide 8: Q&A
```
❓ Questions?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Ready to discuss:
  • Why Knowledge Graph vs Vector DB?
  • AI hallucination handling?
  • Scalability (10K+ entries)?
  • Privacy & security approach?
  • Why OpenRouter vs local LLM?
  • SwiftData vs Core Data decision?
  • Future roadmap & priorities?
```

**Say:**
> "Thank you! I'm ready for questions about the technical implementation, architecture decisions, or anything else."

---

# Quick Prep Checklist (Day Before)

## Technical Review
- [ ] Re-read entity extraction code
- [ ] Re-read RAG implementation
- [ ] Review relevance scoring formula
- [ ] Understand SwiftData deletion order issue
- [ ] Memorize key metrics (92%, 85%, 100%)

## Demo Preparation
- [ ] Build app on simulator with fresh data
- [ ] Import 5-7 test entries mentioning "Minh"
- [ ] Run entity extraction (wait for completion)
- [ ] Test chat with 2-3 questions
- [ ] Verify graph view shows relationships
- [ ] Screenshot backup (in case live demo fails)

## Timing Practice
- [ ] Practice full presentation 2-3 times
- [ ] Time each section (should match breakdown)
- [ ] Practice transitions between slides
- [ ] Practice demo narrative (smooth + confident)

## Mental Prep
- [ ] Review Q&A answers
- [ ] Prepare 1-2 backup slides (if they want more depth)
- [ ] Sleep well (8 hours)
- [ ] Arrive early to test screen sharing

---

# Presentation Flow Summary

```
┌──────────────────────────────────────┐
│ 1. HOOK (1 min)                      │
│    Problem: Traditional journal sucks│
│    → Can't find info, no context     │
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│ 2. DEMO (3 min)                      │
│    Show app working                  │
│    → Entity graph, insights, chat    │
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│ 3. EXPLAIN (6 min)                   │
│    How it works under the hood       │
│    → Architecture, NER, KG, RAG      │
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│ 4. IMPRESS (2 min)                   │
│    Challenges solved + results       │
│    → Real metrics, real product      │
└──────────────────────────────────────┘
              ↓
┌──────────────────────────────────────┐
│ 5. Q&A (3 min)                       │
│    Answer technical questions        │
│    → Show deep understanding         │
└──────────────────────────────────────┘
```

---

# Key Messages (Memorize)

1. **Problem-Solving Focus**
   > "I identified real pain points in traditional journaling and built a solution with AI + knowledge graph."

2. **Technical Depth**
   > "This isn't just a UI app - it's entity extraction, relationship discovery, and RAG-based chat with relevance ranking."

3. **Real Product**
   > "204 story points over 3 months. Tested with 1000+ entries. 92% entity accuracy. Production-ready code."

4. **Learning Mindset**
   > "Each challenge taught me something new - SwiftData constraints, deduplication strategies, RAG optimization."

---

# Confidence Builders

**Remember:**
- ✅ You built this from scratch
- ✅ You solved real technical problems (not tutorial code)
- ✅ You can explain complex concepts clearly
- ✅ You have metrics to back up quality claims
- ✅ You're prepared for common questions

**If nervous:**
- Take deep breath before starting
- Focus on storytelling (not memorizing)
- Demo first → builds confidence
- If demo fails → have screenshots ready
- If stuck → say "Good question, let me think..." (shows thoughtfulness)

**Your strengths:**
- Real project with real challenges
- Clean architecture (MVVM + Services)
- Modern tech (SwiftUI, SwiftData, async/await)
- AI/ML integration (not just CRUD app)
- Problem-solving track record (3 months, 10 sprints)

---

# Final Tips

**DO:**
✅ Start with demo (visual > verbal)
✅ Use diagrams (show flow, architecture)
✅ Tell stories ("When I faced X, I did Y")
✅ Show code briefly (5-10 lines max)
✅ Highlight challenges solved
✅ End with strong metrics

**DON'T:**
❌ Read slides verbatim
❌ Dive too deep into one topic
❌ Apologize for anything
❌ Rush through demo
❌ Skip Q&A time
❌ Downplay your work

**If asked tough question:**
- "Great question!"
- Pause to think (shows thoughtfulness)
- Explain trade-offs honestly
- If don't know → "I haven't explored that yet, but I would approach it by..."

---

# Good Luck! 🚀

**You've got this because:**
- You built a real product (not following tutorial)
- You solved hard problems (deduplication, RAG, SwiftData)
- You can explain clearly (this presentation proves it)
- You have passion (3 months of focused work)

**They're evaluating:**
- Technical skills → You have them (Swift, AI, architecture)
- Problem-solving → You demonstrated it (challenges solved)
- Communication → You're practicing it (clear explanations)
- Learning mindset → You showed it (iterated through 10 sprints)

**Walk in confident. You've earned it.**

---

**Presentation Time: 12-15 minutes**
**Demo Time: 3 minutes (pre-tested)**
**Q&A Time: 3 minutes (prepared answers)**

**Now go practice once more, get good sleep, and crush that interview! 💪**
