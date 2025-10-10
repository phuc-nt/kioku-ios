import Foundation
import SwiftData

/// A note related to another note via Knowledge Graph connections
public struct RelatedNoteInfo: Sendable {
    public let entry: Entry
    public let relevanceScore: Double
    public let reason: String

    public init(entry: Entry, relevanceScore: Double, reason: String) {
        self.entry = entry
        self.relevanceScore = relevanceScore
        self.reason = reason
    }
}

struct ChatContext {
    let selectedDate: Date
    let currentNote: Entry?
    let historicalNotes: [Entry]
    let recentNotes: [Entry]

    // Knowledge Graph Context (Sprint 15)
    let entities: [Entity]
    let insights: [Insight]

    // Related Notes via Knowledge Graph (Sprint 16)
    let relatedNotes: [RelatedNoteInfo]

    init(
        selectedDate: Date,
        currentNote: Entry? = nil,
        historicalNotes: [Entry] = [],
        recentNotes: [Entry] = [],
        entities: [Entity] = [],
        insights: [Insight] = [],
        relatedNotes: [RelatedNoteInfo] = []
    ) {
        self.selectedDate = selectedDate
        self.currentNote = currentNote
        self.historicalNotes = historicalNotes
        self.recentNotes = recentNotes
        self.entities = entities
        self.insights = insights
        self.relatedNotes = relatedNotes
    }
    
    /// Generate context summary for AI prompting
    var contextSummary: String {
        var summary = "Journal Entry for \(selectedDate.formatted(date: .abbreviated, time: .omitted)):\n\n"

        if let currentNote = currentNote {
            summary += "\(currentNote.content)\n\n"
        } else {
            summary += "(No journal entry for this date)\n\n"
        }

        // Sprint 16: Related entries via Knowledge Graph (highest priority)
        if !relatedNotes.isEmpty {
            summary += "--- Related Journal Entries (via Knowledge Graph) ---\n"
            for relatedNote in relatedNotes {
                let entry = relatedNote.entry
                let dateStr = entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                let relevanceBadge = relevanceBadge(for: relatedNote.relevanceScore)

                summary += "\n[\(dateStr)] - Relevance: \(relevanceBadge)\n"
                summary += "Reason: \(relatedNote.reason)\n"
                summary += "\(entry.content)\n"
            }
            summary += "\n"
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

    /// Convert relevance score to badge (High/Medium/Low)
    private func relevanceBadge(for score: Double) -> String {
        if score >= 0.7 {
            return "High"
        } else if score >= 0.4 {
            return "Medium"
        } else {
            return "Low"
        }
    }
}