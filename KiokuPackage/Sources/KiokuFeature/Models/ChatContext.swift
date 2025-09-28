import Foundation

struct ChatContext {
    let selectedDate: Date
    let currentNote: Entry?
    let historicalNotes: [Entry]
    let recentNotes: [Entry]
    
    init(
        selectedDate: Date,
        currentNote: Entry? = nil,
        historicalNotes: [Entry] = [],
        recentNotes: [Entry] = []
    ) {
        self.selectedDate = selectedDate
        self.currentNote = currentNote
        self.historicalNotes = historicalNotes
        self.recentNotes = recentNotes
    }
    
    /// Generate context summary for AI prompting
    var contextSummary: String {
        var summary = "Context for \(selectedDate.formatted(date: .abbreviated, time: .omitted)):\n\n"
        
        if let currentNote = currentNote {
            summary += "Today's Note:\n\(currentNote.content)\n\n"
        } else {
            summary += "No note for today yet.\n\n"
        }
        
        if !historicalNotes.isEmpty {
            summary += "Historical notes from same day in previous months:\n"
            for note in historicalNotes.prefix(5) {
                let dateStr = note.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                summary += "• \(dateStr): \(String(note.content.prefix(100)))\n"
            }
            summary += "\n"
        }
        
        if !recentNotes.isEmpty {
            summary += "Recent notes from past week:\n"
            for note in recentNotes.prefix(3) {
                let dateStr = note.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                summary += "• \(dateStr): \(String(note.content.prefix(100)))\n"
            }
        }
        
        return summary
    }
}