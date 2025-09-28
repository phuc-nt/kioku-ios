import Foundation
import SwiftData

@Model
class AIChatMessage {
    var id: UUID
    var content: String
    var isFromUser: Bool
    var timestamp: Date
    var contextData: String? // JSON string of context used for this message
    
    init(
        content: String,
        isFromUser: Bool,
        contextData: String? = nil
    ) {
        self.id = UUID()
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = Date()
        self.contextData = contextData
    }
}