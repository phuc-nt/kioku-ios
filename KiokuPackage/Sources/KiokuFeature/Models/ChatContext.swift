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
        var summary = ""

        // Count total context entries
        let totalContextEntries = 1 + relatedNotes.count + historicalNotes.count + recentNotes.count

        // Add context overview header
        summary += "=== JOURNAL CONTEXT SUMMARY ===\n"
        summary += "You have access to \(totalContextEntries) journal entries from different dates:\n"

        // List all dates available in context
        var availableDates: [String] = []
        availableDates.append(selectedDate.formatted(date: .abbreviated, time: .omitted))
        for relatedNote in relatedNotes {
            if let date = relatedNote.entry.date {
                availableDates.append(date.formatted(date: .abbreviated, time: .omitted))
            }
        }
        for note in historicalNotes {
            if let date = note.date {
                availableDates.append(date.formatted(date: .abbreviated, time: .omitted))
            }
        }
        for note in recentNotes {
            if let date = note.date {
                availableDates.append(date.formatted(date: .abbreviated, time: .omitted))
            }
        }
        summary += "Available dates: \(availableDates.joined(separator: ", "))\n\n"

        // Current entry (primary context)
        summary += "=== PRIMARY ENTRY ===\n"
        summary += "📅 Date: \(selectedDate.formatted(date: .abbreviated, time: .omitted))\n\n"

        if let currentNote = currentNote {
            summary += "\(currentNote.content)\n\n"
        } else {
            summary += "(No journal entry for this date)\n\n"
        }

        // Sprint 16: Related entries via Knowledge Graph (highest priority)
        if !relatedNotes.isEmpty {
            summary += "=== RELATED ENTRIES (via Knowledge Graph) ===\n"
            summary += "Found \(relatedNotes.count) related entries based on shared entities, emotions, and topics:\n\n"

            for relatedNote in relatedNotes {
                let entry = relatedNote.entry
                let dateStr = entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                let relevanceBadge = relevanceBadge(for: relatedNote.relevanceScore)

                summary += "📅 Date: \(dateStr) | Relevance: \(relevanceBadge)\n"
                summary += "🔗 Connection: \(relatedNote.reason)\n"
                summary += "📝 Content:\n\(entry.content)\n\n"
            }
        }

        // Historical context from same day in previous months
        if !historicalNotes.isEmpty {
            summary += "=== HISTORICAL ENTRIES (Same Day in Previous Months) ===\n"
            summary += "Found \(historicalNotes.count) entries from the same day in previous months:\n\n"

            for note in historicalNotes.prefix(3) {
                let dateStr = note.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                summary += "📅 Date: \(dateStr)\n"
                summary += "📝 Content:\n\(note.content)\n\n"
            }
        }

        // Recent context from past week
        if !recentNotes.isEmpty {
            summary += "=== RECENT ENTRIES (Past Week) ===\n"
            summary += "Found \(recentNotes.count) entries from the past week:\n\n"

            for note in recentNotes.prefix(2) {
                let dateStr = note.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                summary += "📅 Date: \(dateStr)\n"
                summary += "📝 Content:\n\(note.content)\n\n"
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