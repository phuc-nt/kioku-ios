import SwiftData
import Foundation

@Model
public final class Entry {
    public var id: UUID
    public var content: String
    public var createdAt: Date
    public var updatedAt: Date
    
    public init(content: String) {
        self.id = UUID()
        self.content = content
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    public func updateContent(_ newContent: String) {
        content = newContent
        updatedAt = Date()
    }
}

// MARK: - Preview Support
extension Entry {
    nonisolated(unsafe) static let preview = Entry(content: "This is a sample journal entry for previews. It contains some thoughts about the day and reflects on personal experiences.")
    
    nonisolated(unsafe) static let previewEntries: [Entry] = [
        Entry(content: "Today was a productive day. I managed to complete most of my tasks and felt really accomplished."),
        Entry(content: "Reflecting on this week, I notice I've been more mindful about my daily habits."),
        Entry(content: "Had an interesting conversation with a friend about life goals and aspirations.")
    ]
}