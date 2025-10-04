import Foundation
import SwiftData

@Observable
public final class ConversationEntityService: @unchecked Sendable {

    public enum ExtractionError: Error, LocalizedError {
        case invalidAPIKey
        case networkError(Error)
        case invalidResponse
        case parsingError(String)
        case noMessages

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
            case .noMessages:
                return "No messages in conversation"
            }
        }
    }

    // MARK: - Properties

    private let openRouterService: OpenRouterService
    private let dataService: DataService

    public var extractionModel = "google/gemini-2.0-flash-exp:free"
    public var minConfidence: Double = 0.5

    // MARK: - Init

    public init(
        openRouterService: OpenRouterService = .shared,
        dataService: DataService
    ) {
        self.openRouterService = openRouterService
        self.dataService = dataService
    }

    // MARK: - Extraction Methods

    /// Extracts entities from a conversation's messages
    public func extractEntities(from conversation: Conversation) async throws -> [Entity] {
        guard openRouterService.hasAPIKey else {
            throw ExtractionError.invalidAPIKey
        }

        guard !conversation.messages.isEmpty else {
            throw ExtractionError.noMessages
        }

        // Combine all user messages
        let userMessages = conversation.messages
            .filter { $0.isFromUser }
            .map { $0.content }
            .joined(separator: "\n\n")

        guard !userMessages.isEmpty else {
            throw ExtractionError.noMessages
        }

        let systemPrompt = """
        You are an expert entity extraction system for chat conversations.
        Extract meaningful entities from the user's messages and classify them.

        Entity Types:
        - PEOPLE: Names of people, relationships (mom, dad, friend), groups
        - PLACES: Locations, cities, countries, buildings, venues
        - EVENTS: Specific events, meetings, activities, projects
        - EMOTIONS: Feelings and emotional states (happy, sad, anxious, excited)
        - TOPICS: Subjects, themes, interests, work areas

        For each entity, provide:
        1. type: One of (people, places, events, emotions, topics)
        2. value: The entity name/value (normalized)
        3. confidence: 0.0-1.0 score
        4. aliases: Alternative names/spellings

        Return ONLY a JSON array of entities:
        [
          {"type": "people", "value": "Sarah", "confidence": 0.95, "aliases": []},
          {"type": "topics", "value": "machine learning", "confidence": 0.9, "aliases": ["ML", "AI"]}
        ]

        If no entities found, return empty array: []
        """

        let userPrompt = "Extract entities from these chat messages:\n\n\(userMessages)"

        do {
            let response = try await openRouterService.completeText(
                prompt: userPrompt,
                systemMessage: systemPrompt,
                model: extractionModel
            )

            let entities = try parseEntitiesResponse(response)

            // Filter by confidence
            let filteredEntities = entities.filter { $0.confidence >= minConfidence }

            // Deduplicate and merge with existing entities
            let mergedEntities = try await deduplicateAndMerge(filteredEntities, conversation: conversation)

            return mergedEntities

        } catch let error as OpenRouterService.OpenRouterError {
            throw ExtractionError.networkError(error)
        } catch {
            throw error
        }
    }

    // MARK: - Private Methods

    private func parseEntitiesResponse(_ response: String) throws -> [Entity] {
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

    private func deduplicateAndMerge(_ newEntities: [Entity], conversation: Conversation) async throws -> [Entity] {
        var mergedEntities: [Entity] = []

        for newEntity in newEntities {
            // Search for existing entity
            let existingEntities = dataService.fetchEntities(
                type: newEntity.type,
                searchText: newEntity.value
            )

            if let existing = existingEntities.first(where: { $0.matches(query: newEntity.value) }) {
                // Update confidence if higher
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
}

// MARK: - Preview Support

extension ConversationEntityService {
    public static let preview: ConversationEntityService = {
        let service = ConversationEntityService(dataService: DataService.preview)
        return service
    }()
}
