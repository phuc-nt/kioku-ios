import Foundation
import SwiftData

@Observable
public final class InsightsService: @unchecked Sendable {

    public enum InsightsError: Error, LocalizedError {
        case invalidAPIKey
        case networkError(Error)
        case invalidResponse
        case parsingError(String)
        case noDataAvailable

        public var errorDescription: String? {
            switch self {
            case .invalidAPIKey:
                return "Invalid OpenRouter API key"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from AI service"
            case .parsingError(let details):
                return "Failed to parse insights: \(details)"
            case .noDataAvailable:
                return "Not enough data to generate insights. Write more entries!"
            }
        }
    }

    // MARK: - Properties

    private let openRouterService: OpenRouterService
    private let dataService: DataService

    // Configuration
    public var insightsModel = "openai/gpt-4o-mini" // Same as other services for consistent rate limits
    public var minConfidence: Double = 0.6 // Minimum confidence for insights
    public var cacheExpiryHours = 24 // Cache insights for 24 hours

    // Progress tracking
    public private(set) var isGenerating = false
    public private(set) var progress: Double = 0.0

    // Caching
    private var cachedDailyInsights: (date: Date, insights: [Insight])?
    private var cachedWeeklyInsights: (date: Date, insights: [Insight])?

    // MARK: - Init

    public init(
        openRouterService: OpenRouterService = .shared,
        dataService: DataService
    ) {
        self.openRouterService = openRouterService
        self.dataService = dataService
    }

    // MARK: - Daily Insights

    /// Generates insights for a specific date
    public func generateDailyInsights(for date: Date) async throws -> [Insight] {
        guard openRouterService.hasAPIKey else {
            throw InsightsError.invalidAPIKey
        }

        // Check cache
        if let cached = cachedDailyInsights,
           Calendar.current.isDate(cached.date, inSameDayAs: date),
           Date().timeIntervalSince(cached.date) < TimeInterval(cacheExpiryHours * 3600) {
            print("📊 Returning cached daily insights")
            return cached.insights
        }

        await MainActor.run {
            isGenerating = true
            progress = 0.0
        }

        defer {
            Task { @MainActor in
                isGenerating = false
                progress = 1.0
            }
        }

        // Fetch entries for the date
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            throw InsightsError.noDataAvailable
        }

        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        let allEntries = try dataService.modelContext.fetch(descriptor)

        // Filter entries for the specific date
        let startDate = startOfDay
        let endDate = endOfDay
        let entries = allEntries.filter { entry in
            guard let entryDate = entry.date else { return false }
            return entryDate >= startDate && entryDate < endDate
        }

        guard !entries.isEmpty else {
            throw InsightsError.noDataAvailable
        }

        await MainActor.run { progress = 0.2 }

        // Fetch entities for the date
        let entryIds = entries.map { $0.id }
        let entities = dataService.fetchAllEntities().filter { entity in
            !entity.entries.filter { entryIds.contains($0.id) }.isEmpty
        }

        await MainActor.run { progress = 0.4 }

        // Build prompt
        let prompt = buildDailyInsightsPrompt(entries: entries, entities: entities)

        await MainActor.run { progress = 0.6 }

        // Call AI
        let response = try await openRouterService.completeText(
            prompt: prompt,
            systemMessage: dailyInsightsSystemPrompt,
            model: insightsModel
        )

        await MainActor.run { progress = 0.8 }

        // Parse response
        let insights = try parseDailyInsightsResponse(response, entries: entries, entities: entities)

        // Save insights to database
        await MainActor.run {
            for insight in insights {
                dataService.modelContext.insert(insight)
            }
            try? dataService.modelContext.save()
            print("💾 Saved \(insights.count) daily insights to database")
        }

        // Cache
        cachedDailyInsights = (date: Date(), insights: insights)

        await MainActor.run { progress = 1.0 }

        return insights
    }

    // MARK: - Weekly Insights

    /// Generates pattern insights for the past 7 days
    public func generateWeeklyInsights(endDate: Date = Date()) async throws -> [Insight] {
        guard openRouterService.hasAPIKey else {
            throw InsightsError.invalidAPIKey
        }

        // Check cache
        let calendar = Calendar.current
        guard let weekStart = calendar.date(byAdding: .day, value: -7, to: endDate) else {
            throw InsightsError.noDataAvailable
        }

        if let cached = cachedWeeklyInsights,
           calendar.isDate(cached.date, inSameDayAs: endDate),
           Date().timeIntervalSince(cached.date) < TimeInterval(cacheExpiryHours * 3600) {
            print("📊 Returning cached weekly insights")
            return cached.insights
        }

        await MainActor.run {
            isGenerating = true
            progress = 0.0
        }

        defer {
            Task { @MainActor in
                isGenerating = false
                progress = 1.0
            }
        }

        // Fetch entries for past 7 days - fetch all then filter
        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\.date, order: .reverse)]
        )

        let allEntries = try dataService.modelContext.fetch(descriptor)

        // Filter entries for the past 7 days
        let startDate = weekStart
        let endDateFilter = endDate
        let entries = allEntries.filter { entry in
            guard let entryDate = entry.date else { return false }
            return entryDate >= startDate && entryDate <= endDateFilter
        }

        guard entries.count >= 3 else {
            throw InsightsError.noDataAvailable
        }

        await MainActor.run { progress = 0.2 }

        // Group entities by day
        let entitiesByDay = buildEntitiesTimeline(entries: entries)

        await MainActor.run { progress = 0.4 }

        // Build prompt
        let prompt = buildWeeklyInsightsPrompt(entries: entries, entitiesByDay: entitiesByDay)

        await MainActor.run { progress = 0.6 }

        // Call AI
        let response = try await openRouterService.completeText(
            prompt: prompt,
            systemMessage: weeklyInsightsSystemPrompt,
            model: insightsModel
        )

        await MainActor.run { progress = 0.8 }

        // Parse response
        let insights = try parseWeeklyInsightsResponse(response, entries: entries)

        // Save insights to database
        await MainActor.run {
            for insight in insights {
                dataService.modelContext.insert(insight)
            }
            try? dataService.modelContext.save()
            print("💾 Saved \(insights.count) weekly insights to database")
        }

        // Cache
        cachedWeeklyInsights = (date: Date(), insights: insights)

        await MainActor.run { progress = 1.0 }

        return insights
    }

    // MARK: - Cache Management

    public func getCachedInsights(timeframe: TimeframeType) -> [Insight]? {
        switch timeframe {
        case .daily:
            if let cached = cachedDailyInsights,
               Date().timeIntervalSince(cached.date) < TimeInterval(cacheExpiryHours * 3600) {
                return cached.insights
            }
            return nil
        case .weekly:
            if let cached = cachedWeeklyInsights,
               Date().timeIntervalSince(cached.date) < TimeInterval(cacheExpiryHours * 3600) {
                return cached.insights
            }
            return nil
        case .monthly:
            return nil // Not implemented yet
        }
    }

    public func clearInsightsCache() {
        cachedDailyInsights = nil
        cachedWeeklyInsights = nil
    }

    // MARK: - Private Methods

    private var dailyInsightsSystemPrompt: String {
        """
        You are an insightful journal analyst. Analyze the user's journal entry and extracted entities to generate 3-5 meaningful insights.

        Focus on:
        - Frequency patterns (what they mention often)
        - Emotional themes (mood and feelings)
        - Social patterns (people they interact with)
        - Topics and interests
        - Proactive suggestions (what they might want to explore)

        Return ONLY a JSON array of insights:
        [
          {
            "type": "frequency|temporal|emotional|social|topical|suggestion",
            "title": "Brief title (max 50 chars)",
            "description": "Clear description (max 200 chars)",
            "confidence": 0.85,
            "evidence": {"mentions": 5, "context": "work stress, deadline"}
          }
        ]

        Confidence scoring:
        - 0.9-1.0: Very clear pattern, strong evidence
        - 0.7-0.9: Clear pattern, good evidence
        - 0.5-0.7: Emerging pattern, moderate evidence

        Keep insights actionable and personalized.
        """
    }

    private var weeklyInsightsSystemPrompt: String {
        """
        You are an insightful journal analyst. Analyze the past week of journal entries to find meaningful patterns and trends.

        Focus on:
        - Frequency trends (increasing/decreasing mentions)
        - Temporal patterns (what they write about when - mornings vs evenings, weekdays vs weekends)
        - Emotional patterns (mood correlations with activities, people, places)
        - Social patterns (who they spend time with, when)
        - Topic evolution (emerging themes, fading interests)
        - Gaps and suggestions (missing activities, long breaks)

        Return ONLY a JSON array of 5-7 insights:
        [
          {
            "type": "frequency|temporal|emotional|social|topical|suggestion",
            "title": "Brief title (max 50 chars)",
            "description": "Clear description with evidence (max 250 chars)",
            "confidence": 0.78,
            "evidence": {"trend": "increasing", "correlation": 0.8, "days": 5}
          }
        ]

        Prioritize insights by confidence and actionability.
        """
    }

    private func buildDailyInsightsPrompt(entries: [Entry], entities: [Entity]) -> String {
        var prompt = "Analyze today's journal entry and generate insights:\n\n"

        // Add entry content
        for (index, entry) in entries.enumerated() {
            prompt += "Entry \(index + 1):\n\(entry.content)\n\n"
        }

        // Add extracted entities
        if !entities.isEmpty {
            prompt += "Extracted Entities:\n"
            let entityGroups = Dictionary(grouping: entities, by: { $0.type })
            for (type, typeEntities) in entityGroups {
                let names = typeEntities.map { $0.value }.joined(separator: ", ")
                prompt += "- \(type.rawValue.capitalized): \(names)\n"
            }
        }

        return prompt
    }

    private func buildWeeklyInsightsPrompt(entries: [Entry], entitiesByDay: [Date: [Entity]]) -> String {
        var prompt = "Analyze the past 7 days of journal entries to find patterns:\n\n"

        // Group entries by day
        let calendar = Calendar.current
        let entriesByDay = Dictionary(grouping: entries.filter { $0.date != nil }) { entry in
            calendar.startOfDay(for: entry.date!)
        }

        let sortedDays = entriesByDay.keys.sorted()

        for day in sortedDays {
            let dayStr = day.formatted(date: .abbreviated, time: .omitted)
            prompt += "\(dayStr):\n"

            if let dayEntries = entriesByDay[day] {
                for entry in dayEntries {
                    prompt += "- \(entry.content.prefix(100))...\n"
                }
            }

            if let dayEntities = entitiesByDay[day] {
                let entityNames = dayEntities.map { $0.value }.joined(separator: ", ")
                prompt += "  Entities: \(entityNames)\n"
            }

            prompt += "\n"
        }

        return prompt
    }

    private func buildEntitiesTimeline(entries: [Entry]) -> [Date: [Entity]] {
        let calendar = Calendar.current
        var timeline: [Date: [Entity]] = [:]

        for entry in entries {
            guard let entryDate = entry.date else { continue }
            let day = calendar.startOfDay(for: entryDate)
            let entities = entry.entities.map { $0 }
            timeline[day, default: []].append(contentsOf: entities)
        }

        return timeline
    }

    private func parseDailyInsightsResponse(_ response: String, entries: [Entry], entities: [Entity]) throws -> [Insight] {
        // Clean response
        var jsonString = response
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Extract JSON array
        if let startIndex = jsonString.firstIndex(of: "["),
           let endIndex = jsonString.lastIndex(of: "]") {
            jsonString = String(jsonString[startIndex...endIndex])
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw InsightsError.parsingError("Cannot convert response to data")
        }

        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw InsightsError.parsingError("Response is not a JSON array")
            }

            var insights: [Insight] = []

            for insightDict in jsonArray {
                guard let typeString = insightDict["type"] as? String,
                      let type = InsightType(rawValue: typeString),
                      let title = insightDict["title"] as? String,
                      let description = insightDict["description"] as? String,
                      let confidence = insightDict["confidence"] as? Double else {
                    print("⚠️ Skipping invalid insight: \(insightDict)")
                    continue
                }

                // Filter by confidence
                guard confidence >= minConfidence else {
                    continue
                }

                let evidenceDict = insightDict["evidence"] as? [String: Any] ?? [:]
                let evidenceData = try? JSONSerialization.data(withJSONObject: evidenceDict)
                let evidenceString = evidenceData.flatMap { String(data: $0, encoding: .utf8) } ?? ""

                let insight = Insight(
                    type: type,
                    title: title,
                    description: description,
                    confidence: confidence,
                    timeframe: .daily,
                    relatedEntityIds: entities.map { $0.id },
                    relatedEntryIds: entries.map { $0.id },
                    evidence: evidenceString
                )

                insights.append(insight)
            }

            return insights.sorted { $0.confidence > $1.confidence }

        } catch {
            throw InsightsError.parsingError(error.localizedDescription)
        }
    }

    private func parseWeeklyInsightsResponse(_ response: String, entries: [Entry]) throws -> [Insight] {
        // Same parsing logic as daily, but with weekly timeframe
        var jsonString = response
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        if let startIndex = jsonString.firstIndex(of: "["),
           let endIndex = jsonString.lastIndex(of: "]") {
            jsonString = String(jsonString[startIndex...endIndex])
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw InsightsError.parsingError("Cannot convert response to data")
        }

        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw InsightsError.parsingError("Response is not a JSON array")
            }

            var insights: [Insight] = []

            for insightDict in jsonArray {
                guard let typeString = insightDict["type"] as? String,
                      let type = InsightType(rawValue: typeString),
                      let title = insightDict["title"] as? String,
                      let description = insightDict["description"] as? String,
                      let confidence = insightDict["confidence"] as? Double else {
                    print("⚠️ Skipping invalid insight: \(insightDict)")
                    continue
                }

                guard confidence >= minConfidence else {
                    continue
                }

                let evidenceDict = insightDict["evidence"] as? [String: Any] ?? [:]
                let evidenceData = try? JSONSerialization.data(withJSONObject: evidenceDict)
                let evidenceString = evidenceData.flatMap { String(data: $0, encoding: .utf8) } ?? ""

                let insight = Insight(
                    type: type,
                    title: title,
                    description: description,
                    confidence: confidence,
                    timeframe: .weekly,
                    relatedEntityIds: [],
                    relatedEntryIds: entries.map { $0.id },
                    evidence: evidenceString
                )

                insights.append(insight)
            }

            return insights.sorted { $0.confidence > $1.confidence }

        } catch {
            throw InsightsError.parsingError(error.localizedDescription)
        }
    }
}

// MARK: - Preview Support

extension InsightsService {
    public static let preview: InsightsService = {
        InsightsService(dataService: DataService.preview)
    }()
}
