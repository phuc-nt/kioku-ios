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
        let currentEntities = currentEntries.flatMap { $0.entities }
        let currentEntityIds = Set(currentEntities.map { $0.id })
        print("   → Found \(currentEntityIds.count) entities in current entries")

        // 3. Collect all related entry IDs from relationships
        var relatedEntryIds = Set<UUID>()
        var relationshipScores: [UUID: Double] = [:]

        for entity in currentEntities {
            // Get entities connected via outgoing relationships
            for relationship in entity.outgoingRelationships {
                let connectedEntity = relationship.toEntity
                let weight = relationshipTypeWeight(relationship.type) * relationship.confidence

                // Add all entries containing the connected entity
                for entry in connectedEntity.entries where !currentEntryIds.contains(entry.id) {
                    relatedEntryIds.insert(entry.id)
                    relationshipScores[entry.id, default: 0] += weight
                }
            }

            // Get entities connected via incoming relationships
            for relationship in entity.incomingRelationships {
                let connectedEntity = relationship.fromEntity
                let weight = relationshipTypeWeight(relationship.type) * relationship.confidence

                // Add all entries containing the connected entity
                for entry in connectedEntity.entries where !currentEntryIds.contains(entry.id) {
                    relatedEntryIds.insert(entry.id)
                    relationshipScores[entry.id, default: 0] += weight
                }
            }
        }

        print("   → Found \(relatedEntryIds.count) related entry IDs via relationships")

        // 4. Fetch insights related to current entries
        let insights = try await fetchInsights(for: currentEntryIds)
        print("   → Found \(insights.count) insights")

        // Add entry IDs from insights
        var insightScores: [UUID: Double] = [:]
        for insight in insights {
            let score = insight.confidence * 5.0 // Scale to 0-5
            for entryId in insight.relatedEntryIds where !currentEntryIds.contains(entryId) {
                relatedEntryIds.insert(entryId)
                insightScores[entryId, default: 0] = max(insightScores[entryId, default: 0], score)
            }
        }

        print("   → Total collected \(relatedEntryIds.count) related entry IDs")

        guard !relatedEntryIds.isEmpty else {
            print("   → No related entries found")
            return []
        }

        // 5. Fetch all related entries
        let relatedEntriesData = try await fetchEntriesByIds(relatedEntryIds)
        print("   → Fetched \(relatedEntriesData.count) related entries")

        // 6. Calculate relevance scores
        var scoredEntries: [RelatedEntry] = []
        for entry in relatedEntriesData {
            let relationshipScore = relationshipScores[entry.id, default: 0]
            let insightScore = insightScores[entry.id, default: 0]
            let recencyFactor = calculateRecencyFactor(entry: entry, currentDate: date)

            let finalScore = (relationshipScore + insightScore) * recencyFactor
            let reason = generateReason(
                relationshipScore: relationshipScore,
                insightScore: insightScore,
                recency: recencyFactor
            )

            scoredEntries.append(RelatedEntry(
                entry: entry,
                relevanceScore: finalScore,
                reason: reason
            ))
        }

        // 7. Sort by relevance and return top N
        let topEntries = scoredEntries
            .sorted { $0.relevanceScore > $1.relevanceScore }
            .prefix(limit)
            .map { $0 }

        print("   → Top \(topEntries.count) related entries:")
        for (index, relatedEntry) in topEntries.enumerated() {
            let dateStr = relatedEntry.entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown"
            print("      \(index + 1). [\(dateStr)] Score: \(String(format: "%.2f", relatedEntry.relevanceScore)) - \(relatedEntry.reason)")
        }

        return topEntries
    }

    // MARK: - Scoring & Reasoning

    /// Calculate recency factor (0.5-1.0)
    private func calculateRecencyFactor(entry: Entry, currentDate: Date) -> Double {
        let entryDate = entry.date ?? entry.createdAt
        let daysDiff = abs(Calendar.current.dateComponents([.day], from: entryDate, to: currentDate).day ?? 0)

        if daysDiff <= 7 {
            return 1.0
        } else if daysDiff <= 30 {
            return 0.8
        } else {
            return 0.5
        }
    }

    /// Get weight for relationship type
    private func relationshipTypeWeight(_ type: RelationshipType) -> Double {
        switch type {
        case .causal:
            return 5.0
        case .temporal:
            return 4.0
        case .emotional:
            return 3.0
        case .topical:
            return 2.0
        }
    }

    /// Generate human-readable reason for relevance
    private func generateReason(relationshipScore: Double, insightScore: Double, recency: Double) -> String {
        var reasons: [String] = []

        if relationshipScore > 0 {
            if relationshipScore >= 8 {
                reasons.append("Strongly connected via relationships")
            } else if relationshipScore >= 4 {
                reasons.append("Connected via relationships")
            } else {
                reasons.append("Weakly connected")
            }
        }

        if insightScore > 0 {
            if insightScore >= 4 {
                reasons.append("High-confidence insight connection")
            } else if insightScore >= 2 {
                reasons.append("Mentioned in insights")
            }
        }

        if recency == 1.0 {
            reasons.append("Recent (last 7 days)")
        } else if recency == 0.8 {
            reasons.append("Recent (last 30 days)")
        }

        return reasons.isEmpty ? "Related entry" : reasons.joined(separator: ", ")
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
public struct RelatedEntry: Identifiable, Sendable {
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
