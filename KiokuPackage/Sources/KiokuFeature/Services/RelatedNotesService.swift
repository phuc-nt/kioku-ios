import Foundation
import SwiftData

/// Service for discovering related journal entries using Knowledge Graph data
@MainActor
public final class RelatedNotesService {
    private let modelContext: ModelContext

    public init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public API

    /// Discovers the most relevant journal entries related to a specific date using KG data
    /// - Parameters:
    ///   - date: The target date to find related entries for
    ///   - limit: Maximum number of related entries to return (default: 5)
    /// - Returns: Array of related entries with relevance scores and reasons
    public func findRelatedEntries(for date: Date, limit: Int = 5) async throws -> [RelatedEntry] {
        // 1. Fetch current date's entry
        let currentEntries = try await fetchEntries(for: date)
        guard !currentEntries.isEmpty else {
            print("📊 No entries found for date: \(date.formatted())")
            return []
        }

        let currentEntryIds = Set(currentEntries.map { $0.id })
        print("📊 Finding related entries for date: \(date.formatted()) (Entry IDs: \(currentEntryIds.count))")

        // 2. Fetch all entities for current date's entries
        let currentEntities = try await fetchEntities(for: currentEntryIds)
        let currentEntityIds = Set(currentEntities.map { $0.id })
        print("   → Found \(currentEntityIds.count) entities in current entries")

        // 3. Fetch relationships involving current entities
        let relationships = try await fetchRelationships(involving: currentEntityIds)
        print("   → Found \(relationships.count) relationships")

        // 4. Fetch insights related to current date
        let insights = try await fetchInsights(for: currentEntryIds)
        print("   → Found \(insights.count) insights")

        // 5. Collect all related entry IDs from relationships and insights
        var relatedEntryIds = Set<UUID>()

        // From relationships: get entries of connected entities
        for relationship in relationships {
            let connectedEntityIds = Set(relationship.entityIds).subtracting(currentEntityIds)
            if !connectedEntityIds.isEmpty {
                let connectedEntities = try await fetchEntitiesByIds(connectedEntityIds)
                for entity in connectedEntities {
                    relatedEntryIds.formUnion(entity.sourceEntryIds)
                }
            }
        }

        // From insights: get related entry IDs
        for insight in insights {
            relatedEntryIds.formUnion(insight.relatedEntryIds)
        }

        // Exclude current entries
        relatedEntryIds.subtract(currentEntryIds)
        print("   → Collected \(relatedEntryIds.count) potential related entry IDs")

        guard !relatedEntryIds.isEmpty else {
            print("   → No related entries found")
            return []
        }

        // 6. Fetch all related entries
        let relatedEntriesData = try await fetchEntriesByIds(relatedEntryIds)
        print("   → Fetched \(relatedEntriesData.count) related entries")

        // 7. Calculate relevance scores
        var scoredEntries: [RelatedEntry] = []
        for entry in relatedEntriesData {
            let score = calculateRelevanceScore(
                entry: entry,
                currentDate: date,
                currentEntityIds: currentEntityIds,
                relationships: relationships,
                insights: insights
            )

            let reason = determineRelevanceReason(
                entry: entry,
                relationships: relationships,
                insights: insights,
                currentEntityIds: currentEntityIds
            )

            scoredEntries.append(RelatedEntry(
                entry: entry,
                relevanceScore: score,
                reason: reason
            ))
        }

        // 8. Sort by relevance and return top N
        let topEntries = scoredEntries
            .sorted { $0.relevanceScore > $1.relevanceScore }
            .prefix(limit)
            .map { $0 }

        print("   → Top \(topEntries.count) related entries:")
        for (index, relatedEntry) in topEntries.enumerated() {
            print("      \(index + 1). Score: \(String(format: "%.2f", relatedEntry.relevanceScore)) - \(relatedEntry.reason)")
        }

        return topEntries
    }

    // MARK: - Relevance Scoring

    private func calculateRelevanceScore(
        entry: Entry,
        currentDate: Date,
        currentEntityIds: Set<UUID>,
        relationships: [Relationship],
        insights: [Insight]
    ) -> Double {
        var score = 0.0

        // 1. Relationship strength (0-10 points)
        let relationshipWeights: [RelationshipType: Double] = [
            .causal: 5.0,
            .temporal: 4.0,
            .emotional: 3.0,
            .topical: 2.0
        ]

        let relScore = relationships
            .filter { relationship in
                // Check if this relationship connects to entities in this entry
                let relationshipEntityIds = Set(relationship.entityIds)
                let connectedToCurrentEntities = !relationshipEntityIds.isDisjoint(with: currentEntityIds)

                // Check if any entities from this entry are in the relationship
                // We need to fetch this entry's entities to verify
                // For now, we'll use a simpler heuristic: check if relationship's related entries include this entry
                return connectedToCurrentEntities && relationship.relatedEntryIds.contains(entry.id)
            }
            .reduce(0.0) { sum, relationship in
                sum + (relationshipWeights[relationship.type] ?? 0.0)
            }

        score += min(relScore, 10.0)

        // 2. Insight confidence (0-5 points)
        let insightScore = insights
            .filter { $0.relatedEntryIds.contains(entry.id) }
            .map { $0.confidence }
            .max() ?? 0.0

        score += insightScore * 5.0

        // 3. Recency factor (0.5-1.0 multiplier)
        let entryDate = entry.date ?? entry.createdAt
        let daysDiff = abs(Calendar.current.dateComponents([.day], from: entryDate, to: currentDate).day ?? 0)
        let recencyFactor: Double
        if daysDiff <= 7 {
            recencyFactor = 1.0
        } else if daysDiff <= 30 {
            recencyFactor = 0.8
        } else {
            recencyFactor = 0.5
        }

        score *= recencyFactor

        return score
    }

    private func determineRelevanceReason(
        entry: Entry,
        relationships: [Relationship],
        insights: [Insight],
        currentEntityIds: Set<UUID>
    ) -> String {
        // Check for relationship connections
        let connectedRelationships = relationships.filter { relationship in
            relationship.relatedEntryIds.contains(entry.id) &&
            !Set(relationship.entityIds).isDisjoint(with: currentEntityIds)
        }

        if let firstRelationship = connectedRelationships.first {
            let typeDescription: String
            switch firstRelationship.type {
            case .causal:
                typeDescription = "causal relationship"
            case .temporal:
                typeDescription = "temporal connection"
            case .emotional:
                typeDescription = "similar emotions"
            case .topical:
                typeDescription = "related topic"
            }
            return "Connected via \(typeDescription)"
        }

        // Check for insight mentions
        let relatedInsights = insights.filter { $0.relatedEntryIds.contains(entry.id) }
        if let insight = relatedInsights.first {
            let timeframeDescription: String
            switch insight.timeframe {
            case .daily:
                timeframeDescription = "daily insight"
            case .weekly:
                timeframeDescription = "weekly insight"
            case .monthly:
                timeframeDescription = "monthly insight"
            }
            return "Mentioned in \(timeframeDescription)"
        }

        return "Related entry"
    }

    // MARK: - Data Fetching

    private func fetchEntries(for date: Date) async throws -> [Entry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { entry in
                entry.date ?? entry.createdAt >= startOfDay &&
                entry.date ?? entry.createdAt < endOfDay
            }
        )

        return try modelContext.fetch(descriptor)
    }

    private func fetchEntities(for entryIds: Set<UUID>) async throws -> [Entity] {
        let descriptor = FetchDescriptor<Entity>()
        let allEntities = try modelContext.fetch(descriptor)

        return allEntities.filter { entity in
            !Set(entity.sourceEntryIds).isDisjoint(with: entryIds)
        }
    }

    private func fetchEntitiesByIds(_ entityIds: Set<UUID>) async throws -> [Entity] {
        let descriptor = FetchDescriptor<Entity>()
        let allEntities = try modelContext.fetch(descriptor)

        return allEntities.filter { entityIds.contains($0.id) }
    }

    private func fetchRelationships(involving entityIds: Set<UUID>) async throws -> [Relationship] {
        let descriptor = FetchDescriptor<Relationship>()
        let allRelationships = try modelContext.fetch(descriptor)

        return allRelationships.filter { relationship in
            !Set(relationship.entityIds).isDisjoint(with: entityIds)
        }
    }

    private func fetchInsights(for entryIds: Set<UUID>) async throws -> [Insight] {
        let descriptor = FetchDescriptor<Insight>()
        let allInsights = try modelContext.fetch(descriptor)

        return allInsights.filter { insight in
            !Set(insight.relatedEntryIds).isDisjoint(with: entryIds)
        }
    }

    private func fetchEntriesByIds(_ entryIds: Set<UUID>) async throws -> [Entry] {
        let descriptor = FetchDescriptor<Entry>()
        let allEntries = try modelContext.fetch(descriptor)

        return allEntries.filter { entryIds.contains($0.id) }
    }
}

// MARK: - Supporting Types

/// Represents a related journal entry with relevance information
public struct RelatedEntry: Identifiable {
    public let id: UUID
    public let entry: Entry
    public let relevanceScore: Double
    public let reason: String

    public init(entry: Entry, relevanceScore: Double, reason: String) {
        self.id = entry.id
        self.entry = entry
        self.relevanceScore = relevanceScore
        self.reason = reason
    }

    /// Returns relevance level category
    public var relevanceLevel: String {
        if relevanceScore >= 8.0 {
            return "High"
        } else if relevanceScore >= 4.0 {
            return "Medium"
        } else {
            return "Low"
        }
    }
}
