import Foundation
import SwiftData

@Observable
public final class EntityExtractionService: @unchecked Sendable {

    public enum ExtractionError: Error, LocalizedError {
        case invalidAPIKey
        case networkError(Error)
        case invalidResponse
        case parsingError(String)
        case noEntitiesFound

        public var errorDescription: String? {
            switch self {
            case .invalidAPIKey:
                return "Invalid OpenRouter API key"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from AI service"
            case .parsingError(let details):
                return "Failed to parse entities: \(details)"
            case .noEntitiesFound:
                return "No entities found in text"
            }
        }
    }

    // MARK: - Properties

    private let openRouterService: OpenRouterService
    private let dataService: DataService

    // Extraction configuration
    public var extractionModel = "google/gemini-2.0-flash-exp:free" // Cost-effective for extraction
    public var minConfidence: Double = 0.5 // Minimum confidence to accept entity
    public var batchSize = 10 // Process N entries at a time

    // Progress tracking
    public private(set) var isExtracting = false
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

    // MARK: - Extraction Methods

    /// Extracts entities from a single entry
    public func extractEntities(from entry: Entry) async throws -> [Entity] {
        guard openRouterService.hasAPIKey else {
            throw ExtractionError.invalidAPIKey
        }

        let systemPrompt = """
        You are an expert entity extraction system for personal journal entries.
        Extract meaningful entities from the text and classify them into these types:

        - PEOPLE: Names of people, relationships (mom, dad, friend), groups
        - PLACES: Locations, cities, countries, buildings, venues
        - EVENTS: Specific events, meetings, activities, projects
        - EMOTIONS: Feelings and emotional states (happy, sad, anxious, excited)
        - TOPICS: Subjects, themes, interests, work areas

        For each entity, provide:
        1. type: One of (people, places, events, emotions, topics)
        2. value: The entity name/value (normalized, e.g., "San Francisco" not "SF")
        3. confidence: 0.0-1.0 score based on clarity and importance
        4. aliases: Alternative names/spellings (e.g., ["SF", "San Fran"] for "San Francisco")

        Return ONLY a JSON array of entities, no other text:
        [
          {"type": "people", "value": "Sarah", "confidence": 0.95, "aliases": []},
          {"type": "places", "value": "Paris", "confidence": 0.9, "aliases": ["Paris, France"]},
          {"type": "emotions", "value": "happy", "confidence": 0.85, "aliases": ["happiness", "joy"]}
        ]

        If no entities found, return empty array: []
        """

        let userPrompt = "Extract entities from this journal entry:\n\n\(entry.content)"

        do {
            let response = try await openRouterService.completeText(
                prompt: userPrompt,
                systemMessage: systemPrompt,
                model: extractionModel
            )

            let entities = try parseEntitiesResponse(response, sourceEntry: entry)

            // Filter by confidence
            let filteredEntities = entities.filter { $0.confidence >= minConfidence }

            // Deduplicate and merge with existing entities
            let mergedEntities = try await deduplicateAndMerge(filteredEntities, sourceEntry: entry)

            return mergedEntities

        } catch let error as OpenRouterService.OpenRouterError {
            throw ExtractionError.networkError(error)
        } catch {
            throw error
        }
    }

    /// Extracts entities from multiple entries in batch
    public func extractEntitiesFromBatch(
        entries: [Entry],
        onProgress: @escaping @MainActor @Sendable (Double, String) -> Void
    ) async throws {
        guard !isExtracting else {
            throw ExtractionError.networkError(NSError(
                domain: "EntityExtractionService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Extraction already in progress"]
            ))
        }

        await MainActor.run {
            isExtracting = true
            progress = 0.0
        }

        let totalEntries = entries.count
        var processedCount = 0

        for entry in entries {
            // Update progress
            await MainActor.run {
                currentEntry = String(entry.content.prefix(50))
                progress = Double(processedCount) / Double(totalEntries)
                onProgress(progress, currentEntry ?? "")
            }

            do {
                // Extract entities from entry
                let entities = try await extractEntities(from: entry)

                // Link entities to entry and mark as extracted
                await MainActor.run {
                    entry.entities.append(contentsOf: entities)
                    entry.isEntitiesExtracted = true
                    entry.entitiesExtractedAt = Date()
                    entry.entitiesExtractionModel = extractionModel
                }

                processedCount += 1

                // Small delay to avoid rate limiting
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds

            } catch {
                print("Failed to extract entities from entry \(entry.id): \(error)")
                // Continue with next entry
                processedCount += 1
            }
        }

        await MainActor.run {
            isExtracting = false
            progress = 1.0
            currentEntry = nil
            onProgress(1.0, "Completed")
        }
    }

    // MARK: - Private Methods

    private func parseEntitiesResponse(_ response: String, sourceEntry: Entry) throws -> [Entity] {
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
            throw ExtractionError.parsingError("Cannot convert response to data")
        }

        do {
            guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
                throw ExtractionError.parsingError("Response is not a JSON array")
            }

            var entities: [Entity] = []

            for entityDict in jsonArray {
                guard let typeString = entityDict["type"] as? String,
                      let type = EntityType(rawValue: typeString.lowercased()),
                      let value = entityDict["value"] as? String,
                      let confidence = entityDict["confidence"] as? Double else {
                    print("Skipping invalid entity: \(entityDict)")
                    continue
                }

                let aliases = (entityDict["aliases"] as? [String]) ?? []

                let entity = Entity(
                    type: type,
                    value: value,
                    confidence: confidence,
                    aliases: aliases
                )

                entities.append(entity)
            }

            return entities

        } catch {
            throw ExtractionError.parsingError(error.localizedDescription)
        }
    }

    /// Deduplicates extracted entities with existing entities in database
    private func deduplicateAndMerge(_ newEntities: [Entity], sourceEntry: Entry) async throws -> [Entity] {
        var mergedEntities: [Entity] = []

        for newEntity in newEntities {
            // Search for existing entity with same value or alias
            let existingEntities = dataService.fetchEntities(
                type: newEntity.type,
                searchText: newEntity.value
            )

            if let existing = existingEntities.first(where: { $0.matches(query: newEntity.value) }) {
                // Merge: update confidence if higher, add new aliases
                if newEntity.confidence > existing.confidence {
                    await MainActor.run {
                        existing.confidence = newEntity.confidence
                    }
                }

                // Add new aliases
                let newAliases = newEntity.aliases.filter { !existing.aliases.contains($0) }
                if !newAliases.isEmpty {
                    await MainActor.run {
                        existing.aliases.append(contentsOf: newAliases)
                    }
                }

                // Update timestamp
                await MainActor.run {
                    existing.updatedAt = Date()
                }

                mergedEntities.append(existing)
            } else {
                // New entity - insert into database
                await MainActor.run {
                    dataService.modelContext.insert(newEntity)
                }
                mergedEntities.append(newEntity)
            }
        }

        return mergedEntities
    }

    // MARK: - Utility Methods

    /// Gets extraction statistics
    public func getExtractionStats() -> (totalEntities: Int, byType: [EntityType: Int]) {
        let allEntities = dataService.fetchAllEntities()
        var byType: [EntityType: Int] = [:]

        for type in EntityType.allCases {
            byType[type] = allEntities.filter { $0.type == type }.count
        }

        return (allEntities.count, byType)
    }

    /// Cancels current extraction batch
    public func cancelExtraction() {
        isExtracting = false
        progress = 0.0
        currentEntry = nil
    }
}

// MARK: - Preview Support

extension EntityExtractionService {
    public static let preview: EntityExtractionService = {
        let service = EntityExtractionService(dataService: DataService.preview)
        return service
    }()
}
