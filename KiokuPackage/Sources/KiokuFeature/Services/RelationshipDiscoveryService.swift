import Foundation
import SwiftData

@Observable
public final class RelationshipDiscoveryService: @unchecked Sendable {

    public enum DiscoveryError: Error, LocalizedError {
        case invalidAPIKey
        case networkError(Error)
        case invalidResponse
        case parsingError(String)
        case noRelationshipsFound
        case insufficientEntities

        public var errorDescription: String? {
            switch self {
            case .invalidAPIKey:
                return "Invalid OpenRouter API key"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from AI service"
            case .parsingError(let details):
                return "Failed to parse relationships: \(details)"
            case .noRelationshipsFound:
                return "No relationships found"
            case .insufficientEntities:
                return "Need at least 2 entities to discover relationships"
            }
        }
    }

    // MARK: - Properties

    private let openRouterService: OpenRouterService
    private let dataService: DataService

    // Discovery configuration
    public var discoveryModel = "openai/gpt-4o-mini" // Same as chat for consistent rate limits
    public var minConfidence: Double = 0.6 // Higher threshold for relationships
    public var batchSize = 5 // Process N entries at a time

    // Progress tracking
    public private(set) var isDiscovering = false
    public private(set) var progress: Double = 0.0
    public private(set) var currentEntry: String?

    // MARK: - Init

    public init(
        openRouterService: OpenRouterService = .shared,
        dataService: DataService
    ) {
        self.openRouterService = openRouterService
        self.dataService = dataService
    }

    // MARK: - Cancellation

    public func cancelDiscovery() {
        isDiscovering = false
    }

    // MARK: - Discovery Methods

    /// Discovers relationships for entities in a single entry
    public func discoverRelationships(for entry: Entry) async throws -> [EntityRelationship] {
        guard openRouterService.hasAPIKey else {
            throw DiscoveryError.invalidAPIKey
        }

        guard entry.entities.count >= 2 else {
            throw DiscoveryError.insufficientEntities
        }

        let systemPrompt = """
        You are an expert relationship discovery system for knowledge graphs.
        Analyze the journal entry and find meaningful relationships between the extracted entities.

        Relationship Types:
        - TEMPORAL: Time-based relationships (A happened before/after B, A and B occurred simultaneously)
        - CAUSAL: Cause-effect relationships (A led to B, A caused B, A resulted in B)
        - EMOTIONAL: Emotion-entity connections (Person/Event → Emotion, A made me feel B)
        - TOPICAL: Shared topic relationships (A and B are related by topic/theme)

        For each relationship, provide:
        1. fromEntity: The source entity value (exact match from list)
        2. toEntity: The target entity value (exact match from list)
        3. type: One of (temporal, causal, emotional, topical)
        4. confidence: 0.0-1.0 score based on evidence clarity
        5. evidence: Brief text excerpt supporting this relationship (max 100 chars)

        Return ONLY a JSON array of relationships, no other text:
        [
          {"fromEntity": "Sarah", "toEntity": "Paris", "type": "temporal", "confidence": 0.85, "evidence": "Met Sarah on Monday. On Tuesday, went to Paris."},
          {"fromEntity": "product launch", "toEntity": "happy", "type": "emotional", "confidence": 0.9, "evidence": "The product launch made me feel happy"}
        ]

        If no clear relationships found, return empty array: []
        """

        // Build entity list
        let entityList = entry.entities.map { "- \($0.value) (\($0.type.displayName))" }.joined(separator: "\n")

        let userPrompt = """
        Journal Entry:
        \(entry.content)

        Extracted Entities:
        \(entityList)

        Discover relationships between these entities based on the journal entry content.
        """

        do {
            let response = try await openRouterService.completeText(
                prompt: userPrompt,
                systemMessage: systemPrompt,
                model: discoveryModel
            )

            let relationships = try parseRelationshipsResponse(response, sourceEntry: entry)

            // Filter by confidence
            let filteredRelationships = relationships.filter { $0.confidence >= minConfidence }

            // Link to database entities
            let linkedRelationships = try await linkToDatabaseEntities(filteredRelationships, sourceEntry: entry)

            return linkedRelationships

        } catch let error as OpenRouterService.OpenRouterError {
            throw DiscoveryError.networkError(error)
        } catch {
            throw error
        }
    }

    /// Discovers relationships from multiple entries in batch with tracking support
    /// Skips entries that have already been processed (isRelationshipsDiscovered = true)
    /// Can be cancelled and resumed without re-processing completed entries
    public func discoverRelationshipsFromBatch(
        entries: [Entry],
        onProgress: @escaping @MainActor @Sendable (Double, String) -> Void
    ) async throws {
        guard !isDiscovering else {
            throw DiscoveryError.networkError(NSError(
                domain: "RelationshipDiscoveryService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Discovery already in progress"]
            ))
        }

        await MainActor.run {
            isDiscovering = true
            progress = 0.0
        }

        let totalEntries = entries.count
        var processedCount = 0

        for entry in entries {
            // Check if discovery was cancelled
            guard await MainActor.run(body: { isDiscovering }) else {
                print("⚠️ Discovery cancelled by user")
                await MainActor.run {
                    onProgress(progress, "Cancelled")
                }
                return
            }

            // Skip if already discovered (KEY FEATURE: Incremental processing)
            if entry.isRelationshipsDiscovered {
                processedCount += 1
                await MainActor.run {
                    progress = Double(processedCount) / Double(totalEntries)
                    onProgress(progress, "Skipped (already discovered)")
                }
                continue
            }

            // Skip entries without enough entities
            guard entry.entities.count >= 2 else {
                processedCount += 1
                await MainActor.run {
                    progress = Double(processedCount) / Double(totalEntries)
                    onProgress(progress, "Skipped (< 2 entities)")
                }
                continue
            }

            // Update progress
            await MainActor.run {
                currentEntry = String(entry.content.prefix(50))
                progress = Double(processedCount) / Double(totalEntries)
                onProgress(progress, currentEntry ?? "")
            }

            do {
                // Discover relationships for entry
                let relationships = try await discoverRelationships(for: entry)

                // Link relationships to entry and mark as discovered
                await MainActor.run {
                    entry.relationships.append(contentsOf: relationships)
                    entry.isRelationshipsDiscovered = true
                    entry.relationshipsDiscoveredAt = Date()
                    entry.relationshipsDiscoveryModel = discoveryModel

                    // Explicitly save the context
                    try? dataService.modelContext.save()
                }

                processedCount += 1

                // Small delay to avoid rate limiting
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            } catch let error as OpenRouterService.OpenRouterError {
                print("❌ DISCOVERY ERROR for entry \(entry.id): \(error)")

                // Check if it's a rate limit error
                if case .rateLimitExceeded = error {
                    print("⚠️ Rate limit exceeded - stopping discovery")
                    await MainActor.run {
                        isDiscovering = false
                        onProgress(progress, "Rate limit exceeded - you can resume later")
                    }
                    throw DiscoveryError.networkError(error)
                }

                // For other errors, continue with next entry
                processedCount += 1
                await MainActor.run {
                    progress = Double(processedCount) / Double(totalEntries)
                    onProgress(progress, "Error: \(error.localizedDescription)")
                }

            } catch {
                print("Failed to discover relationships for entry \(entry.id): \(error)")
                // Continue with next entry
                processedCount += 1
                await MainActor.run {
                    progress = Double(processedCount) / Double(totalEntries)
                    onProgress(progress, "Error")
                }
            }
        }

        await MainActor.run {
            isDiscovering = false
            progress = 1.0
            currentEntry = nil
            onProgress(1.0, "Completed")
        }
    }

    // MARK: - Private Methods

    private func parseRelationshipsResponse(_ response: String, sourceEntry: Entry) throws -> [EntityRelationship] {
        // Clean response - remove markdown code blocks if present
        var jsonString = response
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "```json", with: "")
            .replacingOccurrences(of: "```", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        // Extract JSON array if embedded in text
        if let startIndex = jsonString.firstIndex(of: "["),
           let endIndex = jsonString.lastIndex(of: "]") {
            jsonString = String(jsonString[startIndex...endIndex])
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw DiscoveryError.parsingError("Cannot convert response to data")
        }

        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw DiscoveryError.parsingError("Response is not a JSON array")
            }

            var relationships: [EntityRelationship] = []

            for relationshipDict in jsonArray {
                guard let fromEntityValue = relationshipDict["fromEntity"] as? String,
                      let toEntityValue = relationshipDict["toEntity"] as? String,
                      let typeString = relationshipDict["type"] as? String,
                      let confidence = relationshipDict["confidence"] as? Double,
                      let evidence = relationshipDict["evidence"] as? String else {
                    print("⚠️ Skipping malformed relationship: \(relationshipDict)")
                    continue
                }

                // Parse relationship type
                guard let type = RelationshipType(rawValue: typeString.lowercased()) else {
                    print("⚠️ Unknown relationship type: \(typeString)")
                    continue
                }

                // Find entities from source entry (temporary placeholders)
                // These will be linked to actual database entities later
                guard let fromEntity = sourceEntry.entities.first(where: { $0.value.lowercased() == fromEntityValue.lowercased() }),
                      let toEntity = sourceEntry.entities.first(where: { $0.value.lowercased() == toEntityValue.lowercased() }) else {
                    print("⚠️ Entity not found in entry: \(fromEntityValue) → \(toEntityValue)")
                    continue
                }

                let relationship = EntityRelationship(
                    from: fromEntity,
                    to: toEntity,
                    type: type,
                    confidence: confidence,
                    evidence: evidence,
                    sourceEntry: sourceEntry
                )

                relationships.append(relationship)
            }

            return relationships

        } catch {
            throw DiscoveryError.parsingError("JSON parsing failed: \(error.localizedDescription)")
        }
    }

    private func linkToDatabaseEntities(_ relationships: [EntityRelationship], sourceEntry: Entry) async throws -> [EntityRelationship] {
        // The relationships are already linked to the database entities from the entry
        // Just need to insert them into the context
        await MainActor.run {
            for relationship in relationships {
                dataService.modelContext.insert(relationship)
            }
        }

        return relationships
    }

    // MARK: - Utility Methods

    /// Gets relationship discovery statistics
    public func getDiscoveryStats() -> (totalRelationships: Int, byType: [RelationshipType: Int]) {
        let allRelationships = dataService.fetchAllRelationships()
        var byType: [RelationshipType: Int] = [:]

        for type in RelationshipType.allCases {
            byType[type] = allRelationships.filter { $0.type == type }.count
        }

        return (allRelationships.count, byType)
    }
}
