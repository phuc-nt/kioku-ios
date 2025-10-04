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

    /// Discovers relationships from multiple entries in batch
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
            // Skip entries without enough entities
            guard entry.entities.count >= 2 else {
                processedCount += 1
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

                // Link relationships to entry
                await MainActor.run {
                    entry.relationships.append(contentsOf: relationships)
                }

                processedCount += 1

                // Small delay to avoid rate limiting
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            } catch {
                print("Failed to discover relationships for entry \(entry.id): \(error)")
                // Continue with next entry
                processedCount += 1
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

            for relDict in jsonArray {
                guard let fromEntityValue = relDict["fromEntity"] as? String,
                      let toEntityValue = relDict["toEntity"] as? String,
                      let typeString = relDict["type"] as? String,
                      let type = RelationshipType(rawValue: typeString.lowercased()),
                      let confidence = relDict["confidence"] as? Double,
                      let evidence = relDict["evidence"] as? String else {
                    print("Skipping invalid relationship: \(relDict)")
                    continue
                }

                // Find matching entities in entry
                guard let fromEntity = sourceEntry.entities.first(where: { $0.value == fromEntityValue }),
                      let toEntity = sourceEntry.entities.first(where: { $0.value == toEntityValue }) else {
                    print("Entities not found for relationship: \(fromEntityValue) -> \(toEntityValue)")
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
            throw DiscoveryError.parsingError(error.localizedDescription)
        }
    }

    private func linkToDatabaseEntities(_ relationships: [EntityRelationship], sourceEntry: Entry) async throws -> [EntityRelationship] {
        var linkedRelationships: [EntityRelationship] = []

        for relationship in relationships {
            // Insert into database
            await MainActor.run {
                dataService.modelContext.insert(relationship)
            }

            linkedRelationships.append(relationship)
        }

        return linkedRelationships
    }

    // MARK: - Utility Methods

    /// Gets relationship discovery statistics
    public func getDiscoveryStats() -> (totalRelationships: Int, byType: [RelationshipType: Int]) {
        let allRelationships = getAllRelationships()
        var byType: [RelationshipType: Int] = [:]

        for type in RelationshipType.allCases {
            byType[type] = allRelationships.filter { $0.type == type }.count
        }

        return (allRelationships.count, byType)
    }

    private func getAllRelationships() -> [EntityRelationship] {
        let descriptor = FetchDescriptor<EntityRelationship>(
            sortBy: [SortDescriptor(\.confidence, order: .reverse)]
        )
        return (try? dataService.modelContext.fetch(descriptor)) ?? []
    }

    /// Cancels current discovery batch
    public func cancelDiscovery() {
        isDiscovering = false
        progress = 0.0
        currentEntry = nil
    }
}

// MARK: - Preview Support

extension RelationshipDiscoveryService {
    public static let preview: RelationshipDiscoveryService = {
        let service = RelationshipDiscoveryService(dataService: DataService.preview)
        return service
    }()
}
