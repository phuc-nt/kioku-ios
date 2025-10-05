import Foundation
import SwiftData

@Observable
@MainActor
class ChatContextService {
    private let dateContextService: DateContextService
    private let dataService: DataService

    init(
        dateContextService: DateContextService,
        dataService: DataService
    ) {
        self.dateContextService = dateContextService
        self.dataService = dataService
    }

    /// Generate comprehensive chat context for the current selected date
    func generateContext() async -> ChatContext {
        let currentNote = dateContextService.getCurrentNote()
        let historicalNotes = dateContextService.getHistoricalNotes()
        let recentNotes = dateContextService.getRecentNotes()

        // Sprint 15: Fetch entities and insights
        let entities = await fetchRelevantEntities(for: dateContextService.selectedDate)
        let insights = await fetchRelevantInsights(for: dateContextService.selectedDate)

        return ChatContext(
            selectedDate: dateContextService.selectedDate,
            currentNote: currentNote,
            historicalNotes: historicalNotes,
            recentNotes: recentNotes,
            entities: entities,
            insights: insights
        )
    }
    
    /// Generate context specifically for a note detail chat
    func generateContextForNote(_ entry: Entry) async -> ChatContext {
        // Use entry date or current date as fallback
        let entryDate = entry.date ?? Date()

        // Update date context to match the entry
        dateContextService.updateSelectedDate(entryDate)

        // Get historical notes for this specific date
        let historicalNotes = dateContextService.getHistoricalNotes()
        let recentNotes = dateContextService.getRecentNotes()

        // Sprint 15: Fetch entities and insights
        let entities = await fetchRelevantEntities(for: entryDate)
        let insights = await fetchRelevantInsights(for: entryDate)

        return ChatContext(
            selectedDate: entryDate,
            currentNote: entry,
            historicalNotes: historicalNotes,
            recentNotes: recentNotes,
            entities: entities,
            insights: insights
        )
    }
    
    /// Create AI prompt with context injection
    func createAIPrompt(userMessage: String, context: ChatContext) -> String {
        let prompt = """
        You are a personal AI assistant helping with journal reflection and insights.

        === USER'S JOURNAL CONTEXT ===
        Below is the user's journal content. Please read and analyze it carefully along with the user's question before responding.

        \(context.contextSummary)

        === USER'S QUESTION ===
        \(userMessage)

        === INSTRUCTIONS ===
        1. Analyze the journal context above combined with the user's question
        2. Respond as a caring friend who listens attentively and genuinely cares about the user
        3. Always reply in the same language the user is using
        4. Be empathetic, warm, and help them explore their thoughts naturally
        """

        // Log context stats for debugging
        print("💬 Creating AI prompt with context:")
        print("  📝 Current note: \(context.currentNote != nil ? "✅" : "❌")")
        print("  📚 Historical notes: \(context.historicalNotes.count)")
        print("  🔖 Recent notes: \(context.recentNotes.count)")
        print("  🏷️ Entities: \(context.entities.count)")
        print("  💡 Insights: \(context.insights.count)")

        if !context.entities.isEmpty {
            let entityTypes = Dictionary(grouping: context.entities, by: { $0.type })
            for type in EntityType.allCases {
                if let count = entityTypes[type]?.count, count > 0 {
                    print("     - \(type.displayName): \(count)")
                }
            }
        }

        if !context.insights.isEmpty {
            print("  💡 Insight details:")
            for (index, insight) in context.insights.prefix(5).enumerated() {
                print("     [\(index+1)] \(insight.timeframe.displayName): \(insight.title) (\(String(format: "%.0f%%", insight.confidence * 100)))")
            }
        }

        print("  📊 Total prompt length: \(prompt.count) chars")

        // Log full prompt for debugging
        print("\n" + String(repeating: "=", count: 80))
        print("📤 FULL PROMPT SENT TO LLM:")
        print(String(repeating: "=", count: 80))
        print(prompt)
        print(String(repeating: "=", count: 80) + "\n")

        return prompt
    }

    // MARK: - Sprint 15: Entity & Insight Fetching

    /// Fetch relevant entities for a specific date (US-S15-001)
    /// Returns up to 50 most relevant entities from recent entries
    nonisolated private func fetchRelevantEntities(for date: Date) async -> [Entity] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)

        // Get date range: 7 days before to current date
        guard let startDate = calendar.date(byAdding: .day, value: -7, to: startOfDay),
              let endDate = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        return await MainActor.run {
            do {
                // Fetch all entries in date range
                let entryDescriptor = FetchDescriptor<Entry>(
                    sortBy: [SortDescriptor(\.date, order: .reverse)]
                )

                let allEntries = try dataService.modelContext.fetch(entryDescriptor)

                // Filter entries in date range
                let entries = allEntries.filter { entry in
                    guard let entryDate = entry.date else { return false }
                    return entryDate >= startDate && entryDate < endDate
                }

                // Collect all entities from these entries
                var allEntities: [Entity] = []
                for entry in entries {
                    allEntities.append(contentsOf: entry.entities)
                }

                // Deduplicate and rank entities
                let rankedEntities = self.deduplicateAndRankEntities(allEntities)

                // Return top 50
                return Array(rankedEntities.prefix(50))

            } catch {
                print("❌ Error fetching entities: \(error)")
                return []
            }
        }
    }

    /// Deduplicate entities by value and rank by relevance
    /// Ranking criteria: (1) Confidence score, (2) Recency, (3) Relationship count
    private func deduplicateAndRankEntities(_ entities: [Entity]) -> [Entity] {
        // Group by value (case-insensitive)
        var entityMap: [String: Entity] = [:]

        for entity in entities {
            let key = entity.value.lowercased()

            if let existing = entityMap[key] {
                // Keep entity with higher confidence
                if entity.confidence > existing.confidence {
                    entityMap[key] = entity
                }
            } else {
                entityMap[key] = entity
            }
        }

        // Sort by relevance: confidence desc, relationship count desc, mention count desc
        return entityMap.values.sorted { a, b in
            if a.confidence != b.confidence {
                return a.confidence > b.confidence
            }
            if a.relationshipCount != b.relationshipCount {
                return a.relationshipCount > b.relationshipCount
            }
            return a.mentionCount > b.mentionCount
        }
    }

    /// Fetch relevant insights for a specific date (US-S15-002)
    /// Returns up to 5 most relevant insights filtered by related entry IDs
    nonisolated private func fetchRelevantInsights(for date: Date) async -> [Insight] {
        return await MainActor.run {
            do {
                // First, find entries for the target date
                let calendar = Calendar.current
                let startOfDay = calendar.startOfDay(for: date)
                let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

                let entryDescriptor = FetchDescriptor<Entry>(
                    predicate: #Predicate<Entry> { entry in
                        entry.date ?? entry.createdAt >= startOfDay &&
                        entry.date ?? entry.createdAt < endOfDay
                    }
                )
                let dateEntries = try dataService.modelContext.fetch(entryDescriptor)
                let entryIds = Set(dateEntries.map { $0.id })

                print("📊 fetchRelevantInsights for \(date.formatted(date: .abbreviated, time: .omitted)):")
                print("   Found \(dateEntries.count) entries for this date")
                print("   Entry IDs: \(entryIds)")

                // Fetch all insights
                let descriptor = FetchDescriptor<Insight>(
                    sortBy: [SortDescriptor(\.generatedAt, order: .reverse)]
                )
                let allInsights = try dataService.modelContext.fetch(descriptor)
                print("   Total insights in DB: \(allInsights.count)")

                // Filter insights that reference entries from this date
                let relevantInsights = allInsights.filter { insight in
                    let hasMatchingEntry = !Set(insight.relatedEntryIds).isDisjoint(with: entryIds)
                    if hasMatchingEntry {
                        print("   ✅ Insight '\(insight.title)' matches (relatedEntryIds: \(insight.relatedEntryIds))")
                    }
                    return hasMatchingEntry
                }

                print("   Filtered to \(relevantInsights.count) relevant insights")

                // Prioritize: daily > weekly > monthly, then by confidence
                let sortedInsights = relevantInsights.sorted { a, b in
                    let priorityA = a.timeframe == .daily ? 0 : (a.timeframe == .weekly ? 1 : 2)
                    let priorityB = b.timeframe == .daily ? 0 : (b.timeframe == .weekly ? 1 : 2)

                    if priorityA != priorityB {
                        return priorityA < priorityB
                    }
                    return a.confidence > b.confidence
                }

                let result = Array(sortedInsights.prefix(5))
                print("   📊 Returning \(result.count) insights")
                for (index, insight) in result.enumerated() {
                    print("      [\(index+1)] \(insight.timeframe.displayName): \(insight.title) (\(String(format: "%.0f%%", insight.confidence * 100)))")
                }

                return result
            } catch {
                print("❌ Error fetching insights: \(error)")
                return []
            }
        }
    }
}