# Kioku - AI Journal
## Technical Presentation Slides

**Duration**: 10-15 minutes

---

# Slide 1: Title
```
╔════════════════════════════════════════╗
║                                        ║
║         KIOKU AI JOURNAL              ║
║   Knowledge Graph + AI Assistant       ║
║                                        ║
║        Phuc Nguyen                     ║
║      Technical Presentation            ║
║                                        ║
╚════════════════════════════════════════╝
```

**Speaker Notes:**
- Xin chào, tôi là Phuc
- Hôm nay tôi sẽ giới thiệu Kioku - một ứng dụng nhật ký cá nhân với AI
- Tập trung vào: AI features, problem solving, technical architecture

---

# Slide 2: The Problem
```
❌ Traditional Journaling Challenges
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Memory Overload
   "Tôi viết 100 entries nhưng không nhớ gì"

2. No Context Awareness
   "Không thể hỏi: Tuần này tôi có vui không?"

3. Lost Connections
   "Không thấy patterns trong cuộc sống"

4. Privacy Concerns
   "Dữ liệu gửi lên cloud, không an toàn"
```

**Speaker Notes:**
- Kể story: User viết nhật ký mỗi ngày
- Sau 3 tháng, muốn tìm "lần cuối gặp Minh" → phải lật từng trang
- Current solutions: Google Docs (no AI), Day One (cloud, basic AI)

---

# Slide 3: The Solution
```
✨ Kioku = Journal + Knowledge Graph + AI
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

    Raw Text          Knowledge Graph          AI Chat
    ────────────  →   ───────────────────  →   ─────────
    "Gặp Minh         Entity: Minh             "Bạn gặp Minh
    ở Highlands"      Entity: Highlands        lần cuối vào
                      Relation: met_at         ngày 8/10 tại
                                               Highlands"

Key Tech:
• iOS 18 (Swift, SwiftUI, SwiftData)
• OpenRouter API (Claude, GPT, Gemini)
• Local-first + Encryption
```

**Speaker Notes:**
- Transform raw text → structured knowledge → AI understanding
- Local-first: dữ liệu 100% trên máy user
- Multi-model: chọn AI model phù hợp cho từng conversation

---

# Slide 4: Feature 1 - Entity Extraction
```
🔍 Automatic Entity Recognition
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Input:
  "Hôm nay gặp Minh và Hằng ở Highlands"

AI Extracts:
  ┌─────────┬──────────┬────────────┐
  │ Entity  │ Type     │ Confidence │
  ├─────────┼──────────┼────────────┤
  │ Minh    │ PERSON   │ 0.95       │
  │ Hằng    │ PERSON   │ 0.92       │
  │Highland │ LOCATION │ 0.88       │
  └─────────┴──────────┴────────────┘

Challenge: Deduplication
  Entry 1: "Minh"  ─┐
  Entry 2: "Minh"  ─┼─→ Same Entity ✅
  Entry 3: "Minh"  ─┘
```

**Speaker Notes:**
- AI tự động nhận diện người, địa điểm, sự kiện
- Không cần manual tagging
- Key challenge: "Minh" trong 5 entries → phải là 1 entity
- Solution: In-memory cache + fuzzy matching

**Demo**: Show Graph view với entities

---

# Slide 5: Feature 2 - Relationship Discovery
```
🕸️ Knowledge Graph Relationships
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

        [Minh]
          │
          │ met_at (0.85)
          ↓
      [Highlands] ←── location_of ─── [Meeting]
          ↑
          │ met_at (0.85)
          │
        [Hằng]

AI discovers:
• Who you met (Minh, Hằng)
• Where you met (Highlands)
• What you discussed (Meeting)
• When it happened (Oct 8)
```

**Speaker Notes:**
- Relationships tạo context giữa các entities
- Weighted edges: frequency → relationship strength
- Temporal tracking: relationships evolve over time

**Demo**: Tap on entity → show relationships

---

# Slide 6: Feature 3 - AI Insights
```
💡 AI-Generated Insights
━━━━━━━━━━━━━━━━━━━━━━━

Weekly Analysis (Oct 1-7):

1. 🤝 Social Pattern (92%)
   "Bạn gặp Minh 4 lần - người bạn gặp nhiều nhất.
    Gặp ở Highlands → mood tích cực (80% entries)"

2. 📍 Location Insight (88%)
   "Highlands = flow state location cho deep work"

3. 😊 Emotional Trend (85%)
   "Mood ↑ 30% so với tuần trước
    Correlation: social interactions ↑ 50%"

Key: Explainable + Actionable
```

**Speaker Notes:**
- AI phân tích patterns từ KG data
- Mỗi insight có confidence score
- Explainability: show supporting entries

**Demo**: Insights tab

---

# Slide 7: Feature 4 - Context-Aware Chat
```
🤖 RAG (Retrieval-Augmented Generation)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

User: "Lần cuối tôi gặp Minh là khi nào?"
  │
  ↓
┌──────────────────────────────────────┐
│ 1. Parse question → entity: "Minh"  │
│ 2. Query KG → find entries with Minh│
│ 3. Score relevance → top 5 entries  │
│ 4. Build context + conversation hist│
│ 5. Call AI with full context        │
└──────────────────────────────────────┘
  │
  ↓
AI: "Ngày 8/10 tại Highlands,
     bàn về dự án mới với Hằng"

Relevance Score Formula:
  score = relationship_weight × 0.4 +
          insight_confidence × 0.3 +
          recency_factor × 0.3
```

**Speaker Notes:**
- RAG: Retrieve relevant context trước khi generate response
- Conversation history: AI nhớ toàn bộ conversation
- Explainable: User thấy AI đọc entries nào

**Demo**: Chat session

---

# Slide 8: Technical Architecture
```
System Design
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

┌─────────────────────────────┐
│  UI Layer (SwiftUI)         │
│  Calendar | Insights | Chat │
└─────────────────────────────┘
            ↓
┌─────────────────────────────┐
│  Service Layer              │
│  • OpenRouterService        │
│  • ChatContextService       │
│  • KnowledgeGraphService    │
│  • InsightService           │
└─────────────────────────────┘
            ↓
┌─────────────────────────────┐
│  Data Layer (SwiftData)     │
│  Entry | Entity | Relation  │
│  Local SQLite (Encrypted)   │
└─────────────────────────────┘
            ↓
┌─────────────────────────────┐
│  External API (OpenRouter)  │
│  Claude 3.5 | GPT-4o        │
└─────────────────────────────┘
```

**Speaker Notes:**
- MVVM + Service Layer architecture
- SwiftData: Modern Swift-native persistence
- Local-first: Privacy + Performance
- OpenRouter: Multi-model flexibility

---

# Slide 9: Key Technical Challenges
```
🔧 Problems Solved
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Entity Deduplication
   Problem: "Minh" appears 5 times → 5 entities
   Solution: In-memory cache + fuzzy matching
   Result: 1 entity reused across all entries ✅

2. SwiftData Deletion Order
   Problem: Delete entity → CRASH (constraint violation)
   Solution: Reverse dependency order (entries → relations → entities)
   Result: Reliable data cleanup ✅

3. Token Limit Management
   Problem: Long conversation + KG context > 8K tokens
   Solution: Sliding window + compression
   Result: Fits within limits ✅
```

**Speaker Notes:**
- Real challenges faced during development
- Shows problem-solving approach
- Learned SwiftData gotchas the hard way

---

# Slide 10: Results & Impact
```
📊 Metrics
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Development:
  • Duration: 3 months (10 sprints)
  • Story Points: 204 delivered (101%)
  • Code: ~8,000 lines Swift
  • Testing: Manual + XcodeBuildMCP automation

Performance:
  • Entity Extraction: < 3s per entry
  • Chat Response: < 2s
  • Database: Handles 1000+ entries
  • Memory: < 50MB

Quality:
  • Entity Accuracy: 92%
  • Relationship Discovery: 85%
  • Deduplication: 100% success
```

**Speaker Notes:**
- Shipped real product, not just prototype
- Performance tested with real data
- Quality metrics based on manual review

---

# Slide 11: Future Roadmap
```
🚀 Next Steps
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Phase 1: Enhanced Export (Sprint 19)
  • CSV export
  • Date range filtering
  • Selective export

Phase 2: Data Cleanup Tools
  • Orphaned entity cleanup
  • Duplicate detection

Phase 3: Advanced AI
  • Sentiment analysis timeline
  • Predictive insights
  • Auto journaling prompts

Phase 4: Visualization
  • Interactive KG graph
  • Emotional heatmap
```

**Speaker Notes:**
- Clear roadmap for future development
- Prioritized by user value
- Shows long-term thinking

---

# Slide 12: Q&A
```
❓ Questions?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Common Questions:
  • Why KG vs Vector DB?
  • How handle AI hallucinations?
  • Performance with 10K entries?
  • Why OpenRouter vs local LLM?
  • Data security?

(See detailed answers in full presentation doc)
```

**Speaker Notes:**
- Open for questions
- Prepared answers in full doc
- Show confidence in technical decisions

---

# Slide 13: Thank You
```
╔════════════════════════════════════════╗
║                                        ║
║           THANK YOU!                   ║
║                                        ║
║    Kioku - AI-Powered Journal          ║
║                                        ║
║    GitHub: phuc-nt/kioku-ios           ║
║    Tech: Swift, SwiftUI, SwiftData     ║
║          OpenRouter API                ║
║                                        ║
║    Built in 3 months, 204 story points ║
║                                        ║
╚════════════════════════════════════════╝
```

**Speaker Notes:**
- Recap: Problem → Solution → Features → Architecture → Results
- Key message: Built real product with AI + KG
- Thank interviewer for their time

---

# Presentation Checklist

**Before Presentation:**
- [ ] Practice timing (aim for 12-13 minutes, leave 2-3 for Q&A)
- [ ] Test demo on simulator (build_run_sim with fresh data)
- [ ] Review technical questions and answers
- [ ] Prepare 1-2 backup slides if they want more depth

**During Presentation:**
- [ ] Start with quick demo (30 seconds)
- [ ] Use diagrams/visuals (not just text)
- [ ] Show 1-2 code snippets (keep brief)
- [ ] Highlight problem-solving approach
- [ ] Leave time for questions

**Key Messages:**
1. **Problem-Solving**: Identified real pain points → built solution
2. **Technical Depth**: Not just UI - KG, RAG, async/await
3. **Shipped Product**: 204 story points, real testing
4. **Learning Mindset**: Each sprint taught something new

**Confidence Tips:**
- You built this from scratch
- You solved hard technical problems
- You can explain complex concepts clearly
- You're prepared for common questions

**Good luck! 🚀**
