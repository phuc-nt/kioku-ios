import Foundation
import SwiftData

struct ChatContext {
    let selectedDate: Date
    let currentNote: Entry?
    let historicalNotes: [Entry]
    let recentNotes: [Entry]

    // Knowledge Graph Context (Sprint 15)
    let entities: [Entity]
    let insights: [Insight]

    // Sprint 16: KG-Enhanced Related Entries
    let relatedEntries: [RelatedEntry]

    init(
        selectedDate: Date,
        currentNote: Entry? = nil,
        historicalNotes: [Entry] = [],
        recentNotes: [Entry] = [],
        entities: [Entity] = [],
        insights: [Insight] = [],
        relatedEntries: [RelatedEntry] = []
    ) {
        self.selectedDate = selectedDate
        self.currentNote = currentNote
        self.historicalNotes = historicalNotes
        self.recentNotes = recentNotes
        self.entities = entities
        self.insights = insights
        self.relatedEntries = relatedEntries
    }
    
    /// Generate context summary for AI prompting
    var contextSummary: String {
        var summary = "Journal Entry for \(selectedDate.formatted(date: .abbreviated, time: .omitted)):\n\n"

        if let currentNote = currentNote {
            summary += "\(currentNote.content)\n\n"
        } else {
            summary += "(No journal entry for this date)\n\n"
        }

        // Sprint 16: KG-Enhanced Related Entries
        if !relatedEntries.isEmpty {
            summary += "--- Related Entries from Your Journal History ---\n"
            summary += "(These entries are connected through people, events, or themes you've written about)\n\n"

            for relatedEntry in relatedEntries.prefix(5) {
                let dateStr = relatedEntry.entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                summary += "[\(dateStr)] (\(relatedEntry.relevanceLevel) Relevance - \(relatedEntry.reason))\n"
                summary += "\(relatedEntry.entry.content)\n\n"
            }
        }

        // Historical context from same day in previous months
        if !historicalNotes.isEmpty {
            summary += "--- Past Entries (Same Day in Previous Months) ---\n"
            for note in historicalNotes.prefix(3) {
                let dateStr = note.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                summary += "\n[\(dateStr)]\n\(note.content)\n"
            }
            summary += "\n"
        }

        // Recent context from past week
        if !recentNotes.isEmpty {
            summary += "--- Recent Entries (Past Week) ---\n"
            for note in recentNotes.prefix(2) {
                let dateStr = note.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                summary += "\n[\(dateStr)]\n\(note.content)\n"
            }
        }

        return summary
    }
}