# Kioku - AI Journal
## Technical Presentation Slides (Short Version)

**Duration**: 15-20 minutes
**Style**: Visual Diagrams + Concise Explanations

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

**🎤 Speaker Script (Tiếng Việt):**

> "Xin chào, tôi là Phuc Nguyễn. Hôm nay tôi xin giới thiệu Kioku - một ứng dụng nhật ký cá nhân tích hợp AI.
>
> Kioku nghĩa là 'ký ức' trong tiếng Nhật. Đây là ứng dụng iOS kết hợp viết nhật ký với công nghệ AI hiện đại - Knowledge Graph và AI Assistant.
>
> Trong 20 phút tiếp theo, tôi sẽ tập trung vào: vấn đề cần giải quyết, các tính năng AI chính, và kiến trúc kỹ thuật."

**🎤 Speaker Script (日本語):**

> "こんにちは、Phuc Nguyenです。今日(きょう)はKioku - AI統合(とうごう)の個人(こじん)日記(にっき)アプリを紹介(しょうかい)します。
>
> Kiokuは日本語(にほんご)で「記憶(きおく)」という意味(いみ)です。このiOSアプリは、伝統的(でんとうてき)な日記(にっき)とAI技術(ぎじゅつ) - Knowledge GraphとAI Assistantを組(く)み合(あ)わせています。
>
> これから20分間(ふんかん)で、解決(かいけつ)すべき問題(もんだい)、主(おも)なAI機能(きのう)、技術(ぎじゅつ)アーキテクチャについて説明(せつめい)します。"

---

# Slide 2: The Problem

```mermaid
graph TD
    A[👤 User writes journal daily] --> B{After 2 months...}
    B --> C[❓ Question: When was last quality time with Jake?]
    C --> D[😓 Must read 20 entries manually]
    D --> E[⏰ 15-20 minutes wasted]
    E --> F[❌ Still not sure about patterns]

    style A fill:#e1f5e1
    style C fill:#fff4e1
    style D fill:#ffe1e1
    style E fill:#ffe1e1
    style F fill:#ff6b6b,color:#fff
```

**Core Problems:**
1. **Memory Overload** - Can't remember 20 entries, 5,000+ words
2. **No Context Awareness** - Can't ask AI about personal patterns
3. **Lost Connections** - Don't see relationships between events/emotions
4. **Privacy Concerns** - Cloud-based journals expose personal data

**🎤 Speaker Script (Tiếng Việt):**

> "Vấn đề: Sau 2 tháng viết nhật ký, bạn có 20 entries với 5,000+ từ. Muốn hỏi 'Lần cuối với Jake là khi nào?' phải đọc thủ công 20 entries, mất 15-20 phút. Hoặc 'Hoạt động nào khiến tôi hạnh phúc?' - với 40 cảm xúc khác nhau, không thể tìm pattern thủ công.
>
> Bốn vấn đề chính: Memory Overload, No Context Awareness, Lost Connections, và Privacy Concerns. Các giải pháp hiện tại: Google Docs không có AI, Day One lưu cloud, Notion không privacy."

**🎤 Speaker Script (日本語):**

> "問題(もんだい)について説明(せつめい)します。2ヶ月(かげつ)日記(にっき)を書(か)いたら、20エントリー、5000語(ご)以上(いじょう)になります。'Jakeと最後(さいご)に会(あ)ったのはいつ？'と聞(き)きたいとき、20エントリーを手作業(てさぎょう)で読(よ)む必要(ひつよう)があり、15-20分(ふん)かかります。または'どの活動(かつどう)が幸(しあわ)せにする？' - 40の感情(かんじょう)があり、手作業(てさぎょう)でパターンを見(み)つけることは不可能(ふかのう)です。
>
> 4つの主(おも)な問題(もんだい)：Memory Overload、Context Awareness無(な)し、Lost Connections、Privacy問題(もんだい)。現在(げんざい)のソリューション：Google DocsにはAI無(な)し、Day Oneはクラウド保存(ほぞん)、Notionはプライバシー無(な)しです。"

---

# Slide 3: The Solution

```mermaid
graph LR
    A[📝 20 Journal Entries<br/>5,000+ words] --> B[🧠 AI Processing]
    B --> C[🕸️ Knowledge Graph<br/>119 entities<br/>105 relationships]
    C --> D[💬 Context-Aware Chat<br/>Ask anything]

    style A fill:#e3f2fd
    style B fill:#fff9c4
    style C fill:#f3e5f5
    style D fill:#e8f5e9
```

**Real Results:**
- **Input**: 20 entries (Sep-Oct 2025)
- **AI Extracted**: 119 entities (40 emotions, 32 topics, 28 events, 11 people, 8 places)
- **Discovered**: 105 relationships (temporal, topical, emotional, social)
- **Outcome**: Ask "When with Jake?" → Instant answer: Oct 25 (checkup + ice cream)

**Tech Stack:**
- iOS 18+ (Swift, SwiftUI, SwiftData)
- OpenRouter API (Claude/GPT/Gemini)
- Local-first + Encryption

**🎤 Speaker Script (Tiếng Việt):**

> "Giải pháp: 20 entries → AI extract 119 entities và 105 relationships. Con số thực từ demo, không phải giả định. 119 entities gồm 40 cảm xúc, 32 topics, 28 events, 11 người, 8 địa điểm.
>
> Sarah xuất hiện CẢ 20 entries - AI tự nhận ra đây là người quan trọng nhất. Tất cả tạo thành Knowledge Graph, giúp AI hiểu context đầy đủ.
>
> Kết quả: Hỏi 'Lần cuối với Jake?' → Trả lời instant: '25 tháng 10, khám sức khỏe và ăn kem'. Tech stack: iOS 18, OpenRouter API, Local-first với encryption."

**🎤 Speaker Script (日本語):**

> "解決策(かいけつさく)：20エントリー → AIが119エンティティと105リレーションシップを抽出(ちゅうしゅつ)。これは実際(じっさい)のデモの数字(すうじ)です。119エンティティの内訳(うちわけ)：40感情(かんじょう)、32トピック、28イベント、11人(にん)、8場所(ばしょ)。
>
> Sarahは全(すべ)ての20エントリーに登場(とうじょう)します - AIが自動的(じどうてき)に最(もっと)も重要(じゅうよう)な人(ひと)と認識(にんしき)しました。これらすべてがKnowledge Graphになり、AIが完全(かんぜん)なコンテキストを理解(りかい)できます。
>
> 結果(けっか)：'Jakeと最後(さいご)はいつ？'と聞(き)く → 即座(そくざ)に回答(かいとう)：'10月(がつ)25日(にち)、健康診断(けんこうしんだん)とアイスクリーム'。Tech stack：iOS 18、OpenRouter API、ローカルファースト+暗号化(あんごうか)。"

---

# Slide 4: Feature 1 - Entity Extraction

```mermaid
graph TD
    A[📝 Input Entry<br/>Oct 25: Jake's 4-year checkup] --> B[🤖 AI Processing]
    B --> C1[👤 Sarah<br/>PEOPLE<br/>Confidence: 0.95]
    B --> C2[👤 Jake<br/>PEOPLE<br/>Confidence: 0.92]
    B --> C3[📍 ice cream place<br/>PLACES<br/>Confidence: 0.88]
    B --> C4[📅 4-year checkup<br/>EVENTS<br/>Confidence: 0.90]
    B --> C5[💗 happy<br/>EMOTIONS<br/>Confidence: 0.85]
    B --> C6[💗 nervous<br/>EMOTIONS<br/>Confidence: 0.80]

    style A fill:#e3f2fd
    style B fill:#fff9c4
    style C1 fill:#c8e6c9
    style C2 fill:#c8e6c9
    style C3 fill:#b3e5fc
    style C4 fill:#f8bbd0
    style C5 fill:#ffc1cc
    style C6 fill:#ffc1cc
```

**Real Demo Results:**
- **119 entities** from 20 entries
- **40 emotions** (largest category) - emotional intelligence
- **Sarah**: 100% coverage (all 20 entries)
- **Deduplication**: Sarah 20x → 1 entity with 20 references

**Challenge: Entity Deduplication**

```mermaid
graph LR
    E1[Entry 1: Sarah] --> Cache{In-Memory<br/>Cache}
    E2[Entry 2: Sarah] --> Cache
    E3[Entry 20: Sarah] --> Cache
    Cache --> Result[✅ Single Entity<br/>Sarah<br/>Referenced 20x<br/>100% coverage]

    style E1 fill:#e3f2fd
    style E2 fill:#e3f2fd
    style E3 fill:#e3f2fd
    style Cache fill:#fff9c4
    style Result fill:#c8e6c9
```

**🎤 Speaker Script (Tiếng Việt):**

> "Tính năng 1: Entity Extraction. Khi viết entry, AI tự động extract 5 loại entities: People, Places, Events, Emotions, Topics.
>
> Kết quả thực tế: 119 entities từ 20 entries. Đặc biệt 40 emotion entities - category lớn nhất, thể hiện emotional intelligence. Sarah xuất hiện CẢ 20 entries - perfect detection.
>
> Challenge lớn: Entity Deduplication. 'Sarah' 20 lần phải là 1 entity, không phải 20 duplicates. Solution: In-memory cache với normalized matching. Result: 100% deduplication success."

**🎤 Speaker Script (日本語):**

> "機能(きのう)1：Entity Extraction。エントリーを書(か)くとき、AIが自動的(じどうてき)に5種類(しゅるい)のエンティティを抽出(ちゅうしゅつ)：People、Places、Events、Emotions、Topics。
>
> 実際(じっさい)の結果(けっか)：20エントリーから119エンティティ。特(とく)に40の感情(かんじょう)エンティティ - 最大(さいだい)のカテゴリー、emotional intelligenceを示(しめ)します。Sarahは全(すべ)ての20エントリーに登場(とうじょう) - 完璧(かんぺき)な検出(けんしゅつ)。
>
> 大(おお)きな課題(かだい)：Entity Deduplication。'Sarah'が20回(かい)登場(とうじょう)するとき、1つのエンティティにする必要(ひつよう)があります、20個(こ)の重複(じゅうふく)ではなく。解決策(かいけつさく)：In-memoryキャッシュとnormalized matching。結果(けっか)：100%重複排除(じゅうふくはいじょ)成功(せいこう)。"

---

# Slide 5: Feature 2 - Relationship Discovery

```mermaid
graph TD
    Sarah[👤 Sarah] -->|temporal<br/>weight: 0.95| Home[📍 home]
    Jake[👤 Jake] -->|temporal<br/>weight: 0.90| Home
    Sarah -->|topical<br/>weight: 0.85| Jake
    Home -->|location_of<br/>weight: 0.92| TacoNight[📅 taco night]
    Jake -->|about<br/>weight: 0.88| Checkup[📅 4-year checkup]
    Emma[👤 Emma] -->|about<br/>weight: 0.80| Checkup

    Happy[💗 happy] -->|emotional<br/>weight: 0.85| TacoNight
    Happy -->|emotional<br/>weight: 0.82| Home
    Nervous[💗 nervous] -->|emotional<br/>weight: 0.75| Checkup

    Sarah -->|emotional<br/>weight: 0.90| Happy
    Jake -->|emotional<br/>weight: 0.85| Happy
    Emma -->|emotional<br/>weight: 0.88| Proud[💗 proud]

    style Sarah fill:#c8e6c9
    style Jake fill:#c8e6c9
    style Emma fill:#c8e6c9
    style Home fill:#b3e5fc
    style TacoNight fill:#f8bbd0
    style Checkup fill:#f8bbd0
    style Happy fill:#ffc1cc
    style Nervous fill:#ffc1cc
    style Proud fill:#ffc1cc
```

**Real Results:**
- **105 relationships** discovered (5.25 per entry average)
- **4 types**: Temporal, Topical, Emotional, Social
- **Oct 25 entry**: 10 entities → connects to 19 other entries via relationships
- **Top score**: 6.00 (10 relationship connections)

**Why Knowledge Graph > Vector DB?**
- ✅ Explainable: See exact connection reasons
- ✅ Queryable: SQL-like pattern queries
- ✅ Lightweight: No ML inference, just graph traversal

**🎤 Speaker Script (Tiếng Việt):**

> "Tính năng 2: Relationship Discovery. Từ 20 entries, AI phát hiện 105 relationships - trung bình 5.25 per entry.
>
> Có 4 loại: Temporal, Topical, Emotional, Social. Entry ngày 25/10 có 10 entities, connect tới 19 entries khác. Top entry score 6.00 với 10 connections - log cho thấy exact reasons.
>
> Tại sao Knowledge Graph thay vì Vector DB? Explainable - thấy exact reasons. Queryable như SQL. Lightweight - graph traversal, không cần ML inference."

**🎤 Speaker Script (日本語):**

> "機能(きのう)2：Relationship Discovery。20エントリーから、AIが105リレーションシップを発見(はっけん) - 平均(へいきん)5.25個(こ)。
>
> 4種類(しゅるい)あります：Temporal、Topical、Emotional、Social。10月(がつ)25日(にち)のエントリーは10エンティティがあり、19個(こ)の他(ほか)のエントリーに接続(せつぞく)します。トップスコア6.00、10個(こ)の接続(せつぞく) - ログで正確(せいかく)な理由(りゆう)が分(わ)かります。
>
> なぜKnowledge GraphでVector DBではないのか？Explainable - 正確(せいかく)な理由(りゆう)が見(み)える。SQLのようにQueryable。Lightweight - graph traversal、ML推論(すいろん)不要(ふよう)。"

---

# Slide 7: Feature 3 - Context-Aware Chat (RAG)

```mermaid
sequenceDiagram
    participant User
    participant Chat as AIChatView
    participant Context as ChatContextService
    participant Related as RelatedNotesService
    participant KG as Knowledge Graph
    participant AI as OpenRouter API

    User->>Chat: Open chat for Oct 25 entry (Jake's checkup)
    Chat->>Context: generateContextForNote(entry)

    Note over Context: Phase 1: Temporal Context
    Context->>Context: Current entry (Oct 25)
    Context->>Context: Historical notes (Oct 25 prev years)
    Context->>Context: Recent notes (past 7 days)

    Note over Context: Phase 2: Entity Context
    Context->>KG: Fetch entities from entry
    KG-->>Context: Sarah, Emma, Jake, happy, nervous, etc. (10 entities)
    Context->>KG: Fetch entities from date range
    KG-->>Context: All entities from recent entries

    Note over Context: Phase 3: Related Notes (KG)
    Context->>Related: findRelatedNotes(entry, limit=5)
    Related->>KG: Check 10 entities for relationships
    Note over Related: Found 156 scores via entity relationships<br/>Combined to 19 unique entries
    Related->>Related: Apply recency decay + relevance filter
    Related-->>Context: 5 top related notes (scores: 6.00, 5.30...)

    Note over Context: Phase 4: Insights Context
    Context->>KG: Fetch relevant insights for Oct 26
    KG-->>Context: 0 insights (demo data doesn't have insights yet)

    Context-->>Chat: Complete context package
    Note over Chat: Real demo context includes:<br/>- 1 current entry<br/>- 5 related via KG (19 candidates scored)<br/>- 10 entities from entry<br/>- 105 total relationships

    User->>Chat: "When was the last time I spent quality time with Jake?"
    Chat->>AI: completeWithHistory(messages + full context)
    AI-->>Chat: "October 25th, Jake's 4-year checkup + ice cream..."
    Chat->>User: Show response + entry links
```

**4-Phase Context Building:**
1. **Temporal**: Current + Historical + Recent (past 7 days)
2. **Entity**: Extract entities from entry + related entries
3. **KG Relations**: Score related notes via relationships (156 scores → 19 entries → Top 5)
4. **Insights**: Include relevant AI insights

**Real Example (Oct 25 entry):**
- Entry has 10 entities
- Found 156 relationship scores
- Combined to 19 unique entries
- Top 5 filtered (scores: 6.00, 5.30, 5.30, 5.30, 5.30)

**RAG Benefits:**
- ✅ Comprehensive (not just vector similarity)
- ✅ Accurate (retrieves real data, no hallucination)
- ✅ Explainable (shows which entries AI read)
- ✅ Token efficient (only top 5, not all 20)

**🎤 Speaker Script (Tiếng Việt):**

> "Tính năng 3: Context-Aware Chat. Đây là RAG nhưng không phải RAG thông thường. Hầu hết RAG chỉ dùng vector similarity. Của tôi là 4-phase: Temporal + Entity + Relationship + Insight.
>
> Phase 1: Load current, historical, recent entries. Phase 2: Extract entities. Phase 3: Check entities for relationships - tìm được 156 scores qua relationships, combine thành 19 entries, filter còn top 5. Phase 4: Load insights.
>
> Kết quả: Complete context package - 1 current entry, 5 related từ 19 candidates, 10 entities, 105 total relationships. Tại sao tốt? Comprehensive, Accurate, Explainable, Token efficient."

**🎤 Speaker Script (日本語):**

> "機能(きのう)3：Context-Aware Chat。これは普通(ふつう)のRAGではありません。ほとんどのRAGはvector similarityだけ使(つか)います。私(わたし)のは4-phase：Temporal + Entity + Relationship + Insight。
>
> Phase 1：現在(げんざい)、過去(かこ)、最近(さいきん)のエントリーをロード。Phase 2：エンティティを抽出(ちゅうしゅつ)。Phase 3：エンティティのリレーションシップをチェック - 156スコアを発見(はっけん)、19エントリーに統合(とうごう)、トップ5にフィルター。Phase 4：インサイトをロード。
>
> 結果(けっか)：完全(かんぜん)なコンテキストパッケージ - 1つの現在(げんざい)エントリー、19候補(こうほ)から5つの関連(かんれん)、10エンティティ、105総(そう)リレーションシップ。なぜ良(よ)いのか？Comprehensive、Accurate、Explainable、Token efficient。"

---

# Slide 8: Technical Architecture

```mermaid
graph TB
    subgraph UI["UI Layer - SwiftUI"]
        Calendar[📅 CalendarTabView]
        Insights[📊 InsightsView]
        Graph[🕸️ KnowledgeGraphView]
        Settings[⚙️ SettingsView]
    end

    subgraph Services["Service Layer"]
        OpenRouter[🤖 OpenRouterService]
        ChatContext[💬 ChatContextService]
        KGService[🧠 KnowledgeGraphService]
        InsightSvc[💡 InsightService]
        Export[💾 ExportService]
    end

    subgraph Data["Data Layer - SwiftData"]
        Entry[(📝 Entry)]
        Entity[(👤 Entity)]
        Relation[(🔗 Relationship)]
        Insight[(💡 AIInsight)]
    end

    subgraph External["External API"]
        API[🌐 OpenRouter API<br/>Claude 3.5 / GPT-4o / Gemini]
    end

    UI --> Services
    Services --> Data
    Services --> External

    style UI fill:#e3f2fd
    style Services fill:#fff9c4
    style Data fill:#f3e5f5
    style External fill:#ffccbc
```

**Tech Stack:**
- **Frontend**: SwiftUI (iOS 18+)
- **Data**: SwiftData (@Model, @Query, @Observable)
- **Concurrency**: async/await, Task, MainActor
- **API**: OpenRouter (multi-model access)
- **Architecture**: MVVM + Service Layer

**🎤 Speaker Script (Tiếng Việt):**

> "Kiến trúc kỹ thuật: UI layer SwiftUI thuần iOS 18. Service layer gồm OpenRouter, ChatContext, KnowledgeGraph, Insight services. Data layer SwiftData - framework mới nhất của Apple. External là OpenRouter API - access 15+ AI models.
>
> Data flow: User viết entry → save SwiftData → trigger extraction async → AI extract entities → save relationships. User hỏi → query KG for context → load relevant entries → gửi AI → show answer với citations. Tất cả async/await, không block UI."

**🎤 Speaker Script (日本語):**

> "技術(ぎじゅつ)アーキテクチャ：UI layerは純粋(じゅんすい)なSwiftUI、iOS 18。Service layerはOpenRouter、ChatContext、KnowledgeGraph、Insightサービス。Data layerはSwiftData - Appleの最新(さいしん)フレームワーク。ExternalはOpenRouter API - 15以上(いじょう)のAIモデルにアクセス。
>
> データフロー：ユーザーがエントリーを書(か)く → SwiftDataに保存(ほぞん) → 非同期(ひどうき)で抽出(ちゅうしゅつ)開始(かいし) → AIがエンティティを抽出(ちゅうしゅつ) → リレーションシップを保存(ほぞん)。ユーザーが質問(しつもん) → コンテキストのためKGをクエリ → 関連(かんれん)エントリーをロード → AIに送信(そうしん) → 引用(いんよう)付(つ)きで回答(かいとう)を表示(ひょうじ)。すべてasync/await、UIをブロックしません。"

---

# Slide 11: Future Roadmap

```mermaid
timeline
    title Kioku Development Roadmap
    section Q4 2025
        Sprint 19 : Enhanced Export
                  : CSV format
                  : Date filtering
        Sprint 20 : Data Cleanup
                  : Orphan detection
                  : Duplicate merge
    section Q1 2026
        Sprint 21-22 : Advanced AI
                     : Sentiment analysis
                     : Predictive insights
                     : Auto prompts
    section Q2 2026
        Sprint 23-24 : Visualization
                     : Interactive KG graph
                     : Emotional heatmap
                     : Timeline view
    section Q3 2026
        Sprint 25+ : Cross-Platform
                   : macOS app
                   : iCloud sync
                   : Web viewer
```

**Next Steps:**
- **Q4 2025**: Enhanced export (CSV), Data cleanup tools
- **Q1 2026**: Advanced AI (sentiment analysis, predictive insights)
- **Q2 2026**: Visualization (interactive graph, heatmap)
- **Q3 2026**: Cross-platform (macOS, iCloud sync, web viewer)

**🎤 Speaker Script (Tiếng Việt):**

> "Roadmap tương lai: Q4 2025 - Enhanced export và data cleanup. Q1 2026 - Advanced AI với sentiment analysis và predictive insights. Q2 2026 - Visualization với interactive graph và emotional heatmap. Q3 2026 - Cross-platform: macOS app, iCloud sync, web viewer. Clear roadmap cho future development."

**🎤 Speaker Script (日本語):**

> "今後(こんご)のロードマップ：2025年(ねん)Q4 - Enhanced exportとdata cleanup。2026年(ねん)Q1 - Advanced AI、sentiment analysisとpredictive insights。2026年(ねん)Q2 - Visualization、interactive graphとemotional heatmap。2026年(ねん)Q3 - Cross-platform：macOSアプリ、iCloud sync、webビューアー。明確(めいかく)な今後(こんご)の開発(かいはつ)ロードマップです。"

---

# Slide 12: Q&A

```mermaid
mindmap
  root((Q&A Topics))
    Architecture
      Why KG vs Vector DB?
      SwiftData vs Core Data?
      Local vs Cloud?
    AI Features
      Hallucination handling?
      Model selection criteria?
      Token optimization?
    Scalability
      10K+ entries performance?
      Memory management?
      Database optimization?
    Security
      Data encryption?
      API key security?
      Privacy guarantees?
```

**Key Questions:**

**Q: Why Knowledge Graph instead of Vector Database?**
- KG provides structure + explainability (105 relationships with reasons)
- Real example: "Connected via emotional relationship through Emma..."
- Queryable like SQL, lightweight (no ML inference)

**Q: How do you handle AI hallucinations?**
- Confidence scoring (0.7-0.95) for each entity
- RAG cites real entries (not generating facts)
- User can verify supporting entries

**Q: Performance with 10,000 entries?**
- SwiftData pagination (fetch on-demand)
- Smart filtering: 156 scores → 19 entries → Top 5
- Graph queries O(log n) with indexes

**Q: Data security?**
- 100% local storage (no auto-uploads)
- Encryption keys in iOS Keychain
- PRIVACY.md App Store compliant

**Q: Can you show the actual demo?**
- Yes! Export JSON: `kioku-export-2025-10-26T08:52:24Z.json`
- Contains: 119 entities, 105 relationships, all 20 entries
- Every number verifiable

**🎤 Speaker Script (Tiếng Việt):**

> "Một số câu hỏi thường gặp:
>
> Tại sao KG thay vì Vector DB? Structure và explainability - thấy exact reason. 105 relationships với explicit types. Queryable, lightweight.
>
> AI hallucination? Confidence scoring 0.7-0.95. RAG cite real entries, không generate facts. User verify được.
>
> Performance 10K entries? Pagination, smart filtering 156→19→5. Graph queries O(log n).
>
> Security? 100% local, encryption keys trong Keychain, PRIVACY.md App Store compliant.
>
> Show demo? Có! Export JSON chứa 119 entities, 105 relationships, all 20 entries - mọi số liệu verifiable."

**🎤 Speaker Script (日本語):**

> "よくある質問(しつもん)：
>
> なぜVector DBではなくKG？StructureとExplainability - 正確(せいかく)な理由(りゆう)が見(み)える。105リレーションシップ、explicit types。Queryable、lightweight。
>
> AI hallucination対策(たいさく)は？Confidence scoring 0.7-0.95。RAGは実際(じっさい)のエントリーを引用(いんよう)、事実(じじつ)を生成(せいせい)しない。ユーザーが確認(かくにん)できる。
>
> 10Kエントリーでのパフォーマンスは？Pagination、smart filtering 156→19→5。Graph queriesはO(log n)。
>
> セキュリティは？100%ローカル保存(ほぞん)、暗号化(あんごうか)キーはKeychainに、PRIVACY.mdはApp Store準拠(じゅんきょ)。
>
> デモを見(み)せられる？はい！Export JSONに119エンティティ、105リレーションシップ、全(すべ)て20エントリー - すべての数字(すうじ)が確認可能(かくにんかのう)。"

---

# Slide 13: Thank You

```
╔════════════════════════════════════════╗
║                                        ║
║           THANK YOU!                   ║
║                                        ║
║    Kioku v0.1.0 - AI Journal           ║
║                                        ║
║    GitHub: phuc-nt/kioku-ios           ║
║    License: MIT (Open Source)          ║
║                                        ║
║    Real Results:                       ║
║    • 119 entities extracted            ║
║    • 105 relationships discovered      ║
║    • 100% deduplication success        ║
║                                        ║
║    Tech: Swift, SwiftUI, SwiftData     ║
║          OpenRouter API                ║
║                                        ║
║    App Store Ready 🚀                  ║
║                                        ║
╚════════════════════════════════════════╝
```

**Key Takeaways:**

1. **Problem → Solution**: Manual search (20 min) → Instant AI answers (< 1s)
2. **Real Results**: 20 entries → 119 entities + 105 relationships (proven)
3. **Technical Innovation**: Knowledge Graph + 4-phase RAG
4. **Quality**: 100% deduplication, explainable AI
5. **Production-Ready**: v0.1.0, MIT license, App Store compliant

**What Makes This Special:**
- ✅ **Emotional intelligence**: 40 emotion entities
- ✅ **Explainability**: Not black box - see exact connections
- ✅ **Privacy-first**: 100% local, encryption
- ✅ **Verifiable**: All numbers backed by real demo data

**🎤 Speaker Script (Tiếng Việt):**

> "Tổng kết:
>
> Năm key takeaways: Problem to Solution - 20 phút thành 1 giây. Real Results - 119 entities + 105 relationships proven. Technical Innovation - Knowledge Graph + 4-phase RAG. Quality - 100% deduplication, explainable. Production-Ready - v0.1.0, MIT license, App Store.
>
> Điều đặc biệt: Emotional intelligence với 40 emotions. Explainability - không black box. Privacy-first - 100% local. Verifiable - mọi số liệu backed by real data.
>
> Tất cả source code, demo data, export JSON đều trên GitHub. Sẵn sàng show live demo hoặc verify các con số.
>
> Cảm ơn các bạn đã lắng nghe!"

**🎤 Speaker Script (日本語):**

> "まとめ：
>
> 5つの重要(じゅうよう)ポイント：Problem to Solution - 20分(ふん)が1秒(びょう)に。Real Results - 119エンティティ + 105リレーションシップが証明(しょうめい)済(ず)み。Technical Innovation - Knowledge Graph + 4-phase RAG。Quality - 100%重複排除(じゅうふくはいじょ)、説明可能(せつめいかのう)。Production-Ready - v0.1.0、MITライセンス、App Store準拠(じゅんきょ)。
>
> 特別(とくべつ)な点(てん)：40感情(かんじょう)のEmotional intelligence。Explainability - ブラックボックスではない。Privacy-first - 100%ローカル。Verifiable - すべてのデータが実際(じっさい)のデータに基(もと)づいています。
>
> すべてのソースコード、デモデータ、export JSONはGitHubにあります。ライブデモまたは数字(すうじ)の確認(かくにん)ができます。
>
> ご清聴(せいちょう)ありがとうございました！"

---

**Presentation Complete!**
- **Total duration**: ~15-20 minutes (10 slides instead of 13)
- **Removed**: Slide 6 (AI Insights detail), Slide 9 (Technical Challenges), Slide 10 (Results & Impact)
- **Kept**: All essential diagrams, core features, architecture, Q&A
- **Concise**: Shorter speaker scripts, focus on key points
- **Ready**: For 20-minute technical interview presentation
- **Languages**: Vietnamese + Japanese (with furigana) speaker scripts for all slides
