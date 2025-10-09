import Foundation
import SwiftData

/// Service for finding related notes via Knowledge Graph
/// Sprint 16: Uses entities, relationships, and insights to discover relevant past entries
@Observable
public final class RelatedNotesService: @unchecked Sendable {

    private let dataService: DataService

    public init(dataService: DataService) {
        self.dataService = dataService
    }

    /// Find up to N most relevant entries related to the given entry via Knowledge Graph
    /// - Parameters:
    ///   - entry: The current entry to find related notes for
    ///   - limit: Maximum number of related notes to return (default: 5)
    ///   - minRelevance: Minimum relevance score (0.0-1.0) to include (default: 0.3)
    /// - Returns: Array of related notes sorted by relevance (highest first)
    public func findRelatedNotes(for entry: Entry, limit: Int = 5, minRelevance: Double = 0.3) -> [RelatedNoteInfo] {
        print("\n🔍 Finding related notes for entry: \(entry.id)")
        print("   Entry has \(entry.entities.count) entities")

        var scoredEntries: [UUID: (entry: Entry, score: Double, reasons: [String])] = [:]

        // Phase 1: Score via Entity Relationships
        let entityRelationshipScores = scoreViaEntityRelationships(for: entry)
        print("   Phase 1: Found \(entityRelationshipScores.count) scores via entity relationships")
        for (entryId, score, reason) in entityRelationshipScores {
            if let relatedEntry = try? dataService.fetchEntry(by: entryId) {
                if var existing = scoredEntries[entryId] {
                    existing.score += score
                    existing.reasons.append(reason)
                    scoredEntries[entryId] = existing
                } else {
                    scoredEntries[entryId] = (relatedEntry, score, [reason])
                }
            }
        }

        // Phase 2: Score via Insights (if available)
        let insightScores = scoreViaInsights(for: entry)
        print("   Phase 2: Found \(insightScores.count) scores via insights")
        for (entryId, score, reason) in insightScores {
            if let relatedEntry = try? dataService.fetchEntry(by: entryId) {
                if var existing = scoredEntries[entryId] {
                    existing.score += score
                    existing.reasons.append(reason)
                    scoredEntries[entryId] = existing
                } else {
                    scoredEntries[entryId] = (relatedEntry, score, [reason])
                }
            }
        }

        print("   Combined: \(scoredEntries.count) unique entries scored")

        // Phase 3: Apply recency decay
        let now = Date()
        for (entryId, var data) in scoredEntries {
            let recencyFactor = calculateRecencyFactor(entryDate: data.entry.createdAt, currentDate: now)
            data.score *= recencyFactor
            scoredEntries[entryId] = data
        }

        // Phase 4: Filter, sort, and limit
        let relatedNotes = scoredEntries.values
            .filter { $0.entry.id != entry.id } // Exclude self
            .filter { $0.score >= minRelevance }
            .sorted { $0.score > $1.score }
            .prefix(limit)
            .map { RelatedNoteInfo(entry: $0.entry, relevanceScore: $0.score, reason: $0.reasons.joined(separator: "; ")) }

        print("   Final: \(relatedNotes.count) related notes (after filtering minRelevance=\(minRelevance))")
        for (index, note) in relatedNotes.enumerated() {
            print("     [\(index+1)] Score: \(String(format: "%.2f", note.relevanceScore)) - \(note.reason)")
        }

        return Array(relatedNotes)
    }

    // MARK: - Private Helpers

    /// Score entries connected via entity relationships
    /// Returns: [(entryId, score, reason)]
    private func scoreViaEntityRelationships(for entry: Entry) -> [(UUID, Double, String)] {
        var scores: [(UUID, Double, String)] = []

        // Get all entities from the current entry
        let currentEntities = entry.entities
        print("      → Checking \(currentEntities.count) entities for relationships")

        for entity in currentEntities {
            // Get all relationships involving this entity (both outgoing and incoming)
            let relationships = dataService.fetchRelationships(for: entity)
            print("         Entity '\(entity.value)' (\(entity.type.rawValue)) has \(relationships.count) relationships")

            for relationship in relationships {
                // Determine the connected entity (other end of relationship)
                let connectedEntity = relationship.fromEntity.id == entity.id ? relationship.toEntity : relationship.fromEntity

                print("            → Relationship: \(relationship.fromEntity.value) --[\(relationship.type.rawValue)]--> \(relationship.toEntity.value)")
                print("            → Connected entity '\(connectedEntity.value)' appears in \(connectedEntity.entries.count) entries")

                // Find all entries containing the connected entity
                for relatedEntry in connectedEntity.entries {
                    let weight = relationshipWeight(relationship.type)
                    let reason = "Connected via \(relationship.type.rawValue) relationship through \(entity.value)"
                    scores.append((relatedEntry.id, weight, reason))
                }
            }
        }

        return scores
    }

    /// Score entries referenced in insights
    /// Returns: [(entryId, score, reason)]
    private func scoreViaInsights(for entry: Entry) -> [(UUID, Double, String)] {
        var scores: [(UUID, Double, String)] = []

        // Get all insights that might reference this entry
        let descriptor = FetchDescriptor<Insight>()
        guard let allInsights = try? dataService.modelContext.fetch(descriptor) else {
            return scores
        }

        // Filter insights related to current entry's date
        let calendar = Calendar.current
        let entryDate = entry.createdAt

        for insight in allInsights {
            // Check if insight references the entry's date
            // (Insights store relatedEntryIds as UUID arrays)
            if insight.relatedEntryIds.contains(entry.id) {
                // This insight connects to other entries
                for relatedEntryId in insight.relatedEntryIds where relatedEntryId != entry.id {
                    let score = insight.confidence * 0.5 // Scale confidence to reasonable score
                    let reason = "Mentioned in \(insight.type.rawValue) insight: \(insight.title)"
                    scores.append((relatedEntryId, score, reason))
                }
            }
        }

        return scores
    }

    /// Calculate recency decay factor
    /// - Returns: Factor between 0.5 and 1.0
    private func calculateRecencyFactor(entryDate: Date, currentDate: Date) -> Double {
        let daysDiff = abs(Calendar.current.dateComponents([.day], from: entryDate, to: currentDate).day ?? 0)

        if daysDiff <= 7 {
            return 1.0 // Last 7 days: full weight
        } else if daysDiff <= 30 {
            return 0.8 // Last 30 days: 80% weight
        } else {
            return 0.5 // Older: 50% weight
        }
    }

    /// Weight mapping for relationship types (based on Sprint 16 spec)
    /// Causal relationships are strongest signal, topical are weakest
    private func relationshipWeight(_ type: RelationshipType) -> Double {
        switch type {
        case .causal:
            return 0.9 // Strongest signal
        case .emotional:
            return 0.7 // Strong signal
        case .temporal:
            return 0.5 // Medium signal
        case .topical:
            return 0.4 // Weaker signal
        }
    }
}
