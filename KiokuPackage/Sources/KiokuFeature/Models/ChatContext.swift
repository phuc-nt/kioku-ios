import Foundation

struct ChatContext {
    let selectedDate: Date
    let currentNote: Entry?
    let historicalNotes: [Entry]
    let recentNotes: [Entry]

    // Knowledge Graph Context (Sprint 15)
    let entities: [Entity]
    let insights: [Insight]

    init(
        selectedDate: Date,
        currentNote: Entry? = nil,
        historicalNotes: [Entry] = [],
        recentNotes: [Entry] = [],
        entities: [Entity] = [],
        insights: [Insight] = []
    ) {
        self.selectedDate = selectedDate
        self.currentNote = currentNote
        self.historicalNotes = historicalNotes
        self.recentNotes = recentNotes
        self.entities = entities
        self.insights = insights
    }
    
    /// Generate context summary for AI prompting
    var contextSummary: String {
        var summary = "Context for \(selectedDate.formatted(date: .abbreviated, time: .omitted)):\n\n"

        if let currentNote = currentNote {
            summary += "Today's Note:\n\(currentNote.content)\n\n"
        } else {
            summary += "No note for today yet.\n\n"
        }

        // Sprint 15: Entity & Relationship Context
        if !entities.isEmpty {
            summary += "## Entities & Relationships\n"

            // Group entities by type
            let groupedEntities = Dictionary(grouping: entities, by: { $0.type })

            for type in EntityType.allCases {
                if let typeEntities = groupedEntities[type], !typeEntities.isEmpty {
                    summary += "**\(type.displayName)**: "
                    let names = typeEntities.prefix(10).map { entity in
                        let confidence = String(format: "%.0f%%", entity.confidence * 100)
                        return "\(entity.value) (\(confidence))"
                    }
                    summary += names.joined(separator: ", ") + "\n"
                }
            }

            // Show key relationships
            let entitiesWithRelationships = entities.filter { $0.relationshipCount > 0 }
            if !entitiesWithRelationships.isEmpty {
                summary += "\n**Relationships**:\n"
                for entity in entitiesWithRelationships.prefix(5) {
                    let related = entity.relatedEntities.prefix(3).map { $0.value }
                    if !related.isEmpty {
                        summary += "• \(entity.value) connected to: \(related.joined(separator: ", "))\n"
                    }
                }
            }
            summary += "\n"
        }

        // Sprint 15: Insight Context
        if !insights.isEmpty {
            summary += "## Insights\n"
            for insight in insights.prefix(5) {
                let timeframe = insight.timeframe.displayName
                let confidence = String(format: "%.0f%%", insight.confidence * 100)
                summary += "• **\(timeframe)** (\(confidence) confidence): \(insight.title)\n"
                summary += "  \(insight.insightDescription)\n"
            }
            summary += "\n"
        }

        if !historicalNotes.isEmpty {
            summary += "## Historical Context\n"
            summary += "Notes from same day in previous months:\n"
            for note in historicalNotes.prefix(5) {
                let dateStr = note.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                summary += "• \(dateStr): \(String(note.content.prefix(100)))\n"
            }
            summary += "\n"
        }

        if !recentNotes.isEmpty {
            summary += "## Recent Context\n"
            summary += "Notes from past week:\n"
            for note in recentNotes.prefix(3) {
                let dateStr = note.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                summary += "• \(dateStr): \(String(note.content.prefix(100)))\n"
            }
        }

        return summary
    }
}