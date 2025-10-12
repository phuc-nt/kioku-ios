import Foundation
import SwiftData

@Model
public class Conversation: @unchecked Sendable {
    public var id: UUID
    public var title: String
    public var createdAt: Date
    public var updatedAt: Date
    public var hasKnowledgeGraph: Bool
    public var associatedDate: Date?
    public var contextNoteIds: String? // JSON array of note IDs

    // Sprint 17: Flexible model configuration for chat
    public var modelIdentifier: String? // OpenRouter model ID (e.g., "openai/gpt-4o-mini")

    @Relationship(deleteRule: .cascade)
    public var messages: [ChatMessage] = []

    // Knowledge Graph relationships
    @Relationship(deleteRule: .cascade)
    public var extractedEntities: [Entity] = []

    public init(
        title: String = "New Conversation",
        associatedDate: Date? = nil
    ) {
        self.id = UUID()
        self.title = title
        self.createdAt = Date()
        self.updatedAt = Date()
        self.hasKnowledgeGraph = false
        self.associatedDate = associatedDate
        self.contextNoteIds = nil
    }

    public var messageCount: Int {
        messages.count
    }

    public var lastMessageDate: Date? {
        messages.last?.timestamp
    }
}
