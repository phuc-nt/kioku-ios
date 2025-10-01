import Foundation
import SwiftData

@Model
public class ChatMessage {
    public var id: UUID
    public var content: String
    public var isFromUser: Bool
    public var timestamp: Date
    public var contextData: String? // JSON string of context used for this message
    public var isStreaming: Bool // True while streaming is in progress
    public var isError: Bool // True if message is an error

    @Relationship(inverse: \Conversation.messages)
    public var conversation: Conversation?

    public init(
        content: String,
        isFromUser: Bool,
        contextData: String? = nil,
        isStreaming: Bool = false,
        isError: Bool = false
    ) {
        self.id = UUID()
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.contextData = contextData
        self.isStreaming = isStreaming
        self.isError = isError
    }
}

// Alias for backward compatibility
typealias AIChatMessage = ChatMessage