import Foundation
import SwiftData

@Model
public class Conversation {
    public var id: UUID
    public var title: String
    public var createdAt: Date
    public var updatedAt: Date
    public var hasKnowledgeGraph: Bool
    public var associatedDate: Date?
    public var contextNoteIds: String? // JSON array of note IDs

    @Relationship(deleteRule: .cascade)
    public var messages: [ChatMessage] = []

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
