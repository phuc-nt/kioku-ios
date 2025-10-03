import SwiftData
import Foundation

/// Represents an entity extracted from journal entries
/// Entities can be People, Places, Events, Emotions, or Topics
@Model
public final class Entity: @unchecked Sendable {
    public var id: UUID
    public var type: EntityType
    public var value: String // The entity name/value
    public var confidence: Double // 0.0-1.0
    public var aliases: [String] // Alternative names for deduplication
    public var metadata: String? // JSON-encoded additional data
    public var createdAt: Date
    public var updatedAt: Date

    // MARK: - Relationships
    @Relationship(inverse: \Entry.entities)
    public var entries: [Entry] = []

    @Relationship(inverse: \Conversation.extractedEntities)
    public var conversations: [Conversation] = []

    // Relationships where this entity is the source
    @Relationship(deleteRule: .cascade)
    public var outgoingRelationships: [EntityRelationship] = []

    // Relationships where this entity is the target
    @Relationship(inverse: \EntityRelationship.toEntity)
    public var incomingRelationships: [EntityRelationship] = []

    public init(
        type: EntityType,
        value: String,
        confidence: Double,
        aliases: [String] = [],
        metadata: String? = nil
    ) {
        self.id = UUID()
        self.type = type
        self.value = value
        self.confidence = confidence
        self.aliases = aliases
        self.metadata = metadata
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Convenience Methods

    /// Check if this entity matches a search query (case-insensitive)
    public func matches(query: String) -> Bool {
        let lowercaseQuery = query.lowercased()
        if value.lowercased().contains(lowercaseQuery) {
            return true
        }
        return aliases.contains { $0.lowercased().contains(lowercaseQuery) }
    }

    /// Get all related entities through relationships
    public var relatedEntities: [Entity] {
        let outgoing = outgoingRelationships.map { $0.toEntity }
        let incoming = incomingRelationships.map { $0.fromEntity }
        return Array(Set(outgoing + incoming))
    }

    /// Get count of all relationships (for node sizing)
    public var relationshipCount: Int {
        return outgoingRelationships.count + incomingRelationships.count
    }

    /// Get count of entries mentioning this entity
    public var mentionCount: Int {
        return entries.count
    }

    /// Update metadata from a dictionary
    public func updateMetadata(_ dict: [String: Any]) throws {
        let jsonData = try JSONSerialization.data(withJSONObject: dict)
        self.metadata = String(data: jsonData, encoding: .utf8)
        self.updatedAt = Date()
    }

    /// Get metadata as dictionary
    public func getMetadata() -> [String: Any]? {
        guard let metadata = metadata,
              let data = metadata.data(using: .utf8),
              let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        return dict
    }
}

/// Entity types that can be extracted
public enum EntityType: String, Codable, CaseIterable {
    case people
    case places
    case events
    case emotions
    case topics

    public var displayName: String {
        switch self {
        case .people: return "People"
        case .places: return "Places"
        case .events: return "Events"
        case .emotions: return "Emotions"
        case .topics: return "Topics"
        }
    }

    public var icon: String {
        switch self {
        case .people: return "person.fill"
        case .places: return "map.fill"
        case .events: return "calendar"
        case .emotions: return "heart.fill"
        case .topics: return "tag.fill"
        }
    }
}

// MARK: - Preview Support
extension Entity {
    nonisolated(unsafe) static let previewPeople = Entity(
        type: .people,
        value: "Sarah",
        confidence: 0.9,
        aliases: ["Sarah", "sarah"]
    )

    nonisolated(unsafe) static let previewPlace = Entity(
        type: .places,
        value: "Paris",
        confidence: 0.95,
        aliases: ["Paris", "paris"]
    )

    nonisolated(unsafe) static let previewEvent = Entity(
        type: .events,
        value: "Product Launch",
        confidence: 0.85
    )

    nonisolated(unsafe) static let previewEmotion = Entity(
        type: .emotions,
        value: "happy",
        confidence: 0.9
    )

    nonisolated(unsafe) static let previewTopic = Entity(
        type: .topics,
        value: "machine learning",
        confidence: 0.95
    )
}
