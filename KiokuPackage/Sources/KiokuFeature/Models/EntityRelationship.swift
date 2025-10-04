import SwiftData
import Foundation

/// Represents a relationship between two entities
/// Can be Temporal, Causal, Emotional, or Topical
@Model
public final class EntityRelationship: @unchecked Sendable {
    public var id: UUID
    public var type: RelationshipType
    public var confidence: Double // 0.0-1.0
    public var evidence: String // Text excerpt supporting this relationship
    public var createdAt: Date

    // MARK: - Relationships
    public var fromEntity: Entity
    public var toEntity: Entity

    @Relationship(inverse: \Entry.relationships)
    public var sourceEntry: Entry? // Entry where this relationship was discovered

    public init(
        from: Entity,
        to: Entity,
        type: RelationshipType,
        confidence: Double,
        evidence: String,
        sourceEntry: Entry? = nil
    ) {
        self.id = UUID()
        self.fromEntity = from
        self.toEntity = to
        self.type = type
        self.confidence = confidence
        self.evidence = evidence
        self.sourceEntry = sourceEntry
        self.createdAt = Date()
    }

    // MARK: - Convenience Methods

    /// Get a human-readable description of this relationship
    public var description: String {
        return "\(fromEntity.value) → \(toEntity.value) (\(type.displayName))"
    }

    /// Check if this relationship connects two specific entities
    public func connects(_ entity1: Entity, _ entity2: Entity) -> Bool {
        return (fromEntity.id == entity1.id && toEntity.id == entity2.id) ||
               (fromEntity.id == entity2.id && toEntity.id == entity1.id)
    }

    /// Get the other entity in this relationship
    public func otherEntity(from entity: Entity) -> Entity? {
        if fromEntity.id == entity.id {
            return toEntity
        } else if toEntity.id == entity.id {
            return fromEntity
        }
        return nil
    }

    /// Get evidence excerpt (truncated if needed)
    public func truncatedEvidence(maxLength: Int = 100) -> String {
        if evidence.count <= maxLength {
            return evidence
        }
        let endIndex = evidence.index(evidence.startIndex, offsetBy: maxLength)
        return String(evidence[..<endIndex]) + "..."
    }
}

/// Types of relationships between entities
public enum RelationshipType: String, Codable, CaseIterable {
    case temporal   // Time-based: A happened before/after B
    case causal     // Cause-effect: A led to B
    case emotional  // Emotion-entity: Person/Event → Emotion
    case topical    // Shared topics: A and B related by topic

    public var displayName: String {
        switch self {
        case .temporal: return "Temporal"
        case .causal: return "Causal"
        case .emotional: return "Emotional"
        case .topical: return "Topical"
        }
    }

    public var color: String {
        switch self {
        case .temporal: return "blue"
        case .causal: return "orange"
        case .emotional: return "pink"
        case .topical: return "green"
        }
    }

    public var icon: String {
        switch self {
        case .temporal: return "clock.fill"
        case .causal: return "arrow.triangle.branch"
        case .emotional: return "heart.fill"
        case .topical: return "tag.fill"
        }
    }
}

// MARK: - Preview Support
extension EntityRelationship {
    nonisolated(unsafe) static let previewTemporal = EntityRelationship(
        from: Entity.previewPeople,
        to: Entity.previewPlace,
        type: .temporal,
        confidence: 0.85,
        evidence: "Met Sarah on Monday. On Tuesday, went to Paris."
    )

    nonisolated(unsafe) static let previewCausal = EntityRelationship(
        from: Entity.previewEvent,
        to: Entity.previewEmotion,
        type: .causal,
        confidence: 0.9,
        evidence: "The product launch made me feel happy and accomplished."
    )
}
