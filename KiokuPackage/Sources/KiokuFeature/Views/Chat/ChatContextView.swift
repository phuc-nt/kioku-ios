import SwiftUI

enum DiscoveryMethod {
    case today
    case sameDay
    case recent
    case knowledgeGraph(relevance: String) // Sprint 16: KG-based discovery

    var label: String {
        switch self {
        case .today: return "Today"
        case .sameDay: return "Same day"
        case .recent: return "Related"
        case .knowledgeGraph(let relevance): return "KG: \(relevance)"
        }
    }

    var icon: String {
        switch self {
        case .today: return "calendar.badge.clock"
        case .sameDay: return "arrow.clockwise"
        case .recent: return "link"
        case .knowledgeGraph: return "brain.head.profile"
        }
    }

    var color: Color {
        switch self {
        case .today: return .blue
        case .sameDay: return .green
        case .recent: return .purple
        case .knowledgeGraph: return .orange
        }
    }
}

struct ChatContextView: View {
    let context: ChatContext
    @State private var isExpanded = false
    @State private var selectedEntry: Entry?

    private var totalNotesCount: Int {
        var count = 0
        if context.currentNote != nil { count += 1 }
        count += context.relatedNotes.count // Sprint 16: Include KG-related notes
        count += context.historicalNotes.count
        count += context.recentNotes.count
        return count
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.accentColor)

                    Text("Context for \(context.selectedDate.formatted(date: .abbreviated, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if totalNotesCount > 0 {
                        Text("(\(totalNotesCount) notes)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(8)

            if isExpanded {
                ScrollView {
                    contextDetails
                        .padding(.vertical, 8)
                }
                .frame(maxHeight: 400)
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(.horizontal)
        .sheet(item: $selectedEntry) { entry in
            EntryDetailSheet(entry: entry)
        }
    }
    
    private var contextDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            if totalNotesCount == 0 {
                emptyStateView
            } else {
                // Today's note
                if let currentNote = context.currentNote {
                    NoteContextCard(
                        entry: currentNote,
                        discoveryMethod: .today,
                        onTap: { selectedEntry = currentNote }
                    )
                }

                // Sprint 16: Related notes via Knowledge Graph (highest priority)
                if !context.relatedNotes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "brain.head.profile")
                                .font(.caption)
                                .foregroundColor(.orange)
                            Text("Related via Knowledge Graph")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .padding(.bottom, 4)

                        ForEach(context.relatedNotes.prefix(5), id: \.entry.id) { relatedNote in
                            KGRelatedNoteCard(
                                relatedNote: relatedNote,
                                onTap: { selectedEntry = relatedNote.entry }
                            )
                        }
                    }
                    .padding(12)
                    .background(Color.orange.opacity(0.05))
                    .cornerRadius(8)
                }

                // Historical notes (same day in past)
                ForEach(context.historicalNotes.prefix(5), id: \.id) { entry in
                    NoteContextCard(
                        entry: entry,
                        discoveryMethod: .sameDay,
                        onTap: { selectedEntry = entry }
                    )
                }

                // Recent notes
                ForEach(context.recentNotes.prefix(5), id: \.id) { entry in
                    NoteContextCard(
                        entry: entry,
                        discoveryMethod: .recent,
                        onTap: { selectedEntry = entry }
                    )
                }
            }

            // Sprint 15: Entities & Relationships
            if !context.entities.isEmpty {
                entitiesSection
            }

            // Sprint 15: Insights
            if !context.insights.isEmpty {
                insightsSection
            }
        }
        .padding(.horizontal, 16)
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.title2)
                .foregroundColor(.secondary)

            Text("No notes for this date yet")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24)
    }

    // MARK: - Sprint 15: Entities Section

    private var entitiesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "brain")
                    .font(.caption)
                    .foregroundColor(.orange)
                Text("Entities & Relationships")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 4)

            // Group entities by type
            let groupedEntities = Dictionary(grouping: context.entities, by: { $0.type })

            ForEach(EntityType.allCases, id: \.self) { type in
                if let typeEntities = groupedEntities[type], !typeEntities.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(type.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)

                        FlowLayout(spacing: 6) {
                            ForEach(typeEntities.prefix(10), id: \.id) { entity in
                                EntityBadge(entity: entity)
                            }
                        }
                    }
                }
            }

            // Show key relationships
            let entitiesWithRelationships = context.entities.filter { $0.relationshipCount > 0 }
            if !entitiesWithRelationships.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Key Relationships")
                        .font(.caption2)
                        .fontWeight(.medium)
                        .foregroundColor(.secondary)
                        .padding(.top, 4)

                    ForEach(entitiesWithRelationships.prefix(3), id: \.id) { entity in
                        let related = entity.relatedEntities.prefix(2).map { $0.value }
                        if !related.isEmpty {
                            HStack(spacing: 4) {
                                Text("•")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text("\(entity.value)")
                                    .font(.caption2)
                                    .fontWeight(.medium)
                                Text("→")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                Text(related.joined(separator: ", "))
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .background(Color.orange.opacity(0.05))
        .cornerRadius(8)
    }

    // MARK: - Sprint 15: Insights Section

    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "lightbulb.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                Text("Insights")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 4)

            ForEach(context.insights.prefix(3), id: \.id) { insight in
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(insight.timeframe.displayName)
                            .font(.caption2)
                            .fontWeight(.medium)
                            .foregroundColor(.yellow.opacity(0.8))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.yellow.opacity(0.2))
                            .cornerRadius(4)

                        Text(String(format: "%.0f%%", insight.confidence * 100))
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }

                    Text(insight.title)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Text(insight.insightDescription)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }
                .padding(8)
                .background(Color(.systemBackground))
                .cornerRadius(6)
            }
        }
        .padding(12)
        .background(Color.yellow.opacity(0.05))
        .cornerRadius(8)
    }
}

// MARK: - Sprint 16: KG Related Note Card

struct KGRelatedNoteCard: View {
    let relatedNote: RelatedNoteInfo
    let onTap: () -> Void

    private var excerpt: String {
        let maxLength = 100
        if relatedNote.entry.content.count <= maxLength {
            return relatedNote.entry.content
        }
        return String(relatedNote.entry.content.prefix(maxLength)) + "..."
    }

    private var dateString: String {
        if let date = relatedNote.entry.date {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
        return relatedNote.entry.createdAt.formatted(date: .abbreviated, time: .omitted)
    }

    private var relevanceBadge: String {
        if relatedNote.relevanceScore >= 3.0 {
            return "High"
        } else if relatedNote.relevanceScore >= 1.0 {
            return "Medium"
        } else {
            return "Low"
        }
    }

    private var relevanceColor: Color {
        if relatedNote.relevanceScore >= 3.0 {
            return .green
        } else if relatedNote.relevanceScore >= 1.0 {
            return .orange
        } else {
            return .gray
        }
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Relevance badge
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                        Text(relevanceBadge)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(relevanceColor)
                    .cornerRadius(4)

                    Spacer()

                    Text(dateString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                // Relevance reason
                Text(relatedNote.reason)
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .lineLimit(2)
                    .italic()

                // Entry excerpt
                Text(excerpt)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.orange.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Note Context Card

struct NoteContextCard: View {
    let entry: Entry
    let discoveryMethod: DiscoveryMethod
    let onTap: () -> Void

    private var excerpt: String {
        let maxLength = 100
        if entry.content.count <= maxLength {
            return entry.content
        }
        return String(entry.content.prefix(maxLength)) + "..."
    }

    private var dateString: String {
        if let date = entry.date {
            return date.formatted(date: .abbreviated, time: .omitted)
        }
        return entry.createdAt.formatted(date: .abbreviated, time: .omitted)
    }

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    // Discovery method badge
                    HStack(spacing: 4) {
                        Image(systemName: discoveryMethod.icon)
                            .font(.caption2)
                        Text(discoveryMethod.label)
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(discoveryMethod.color)
                    .cornerRadius(4)

                    Spacer()

                    Text(dateString)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Text(excerpt)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .italic()
                    .lineLimit(3)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(8)
            .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Entry Detail Sheet

struct EntryDetailSheet: View {
    let entry: Entry
    @Environment(\.dismiss) private var dismiss

    private var dateString: String {
        if let date = entry.date {
            return date.formatted(date: .long, time: .omitted)
        }
        return entry.createdAt.formatted(date: .long, time: .omitted)
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(entry.content)
                        .font(.body)
                        .foregroundColor(.primary)
                        .textSelection(.enabled)
                }
                .padding()
            }
            .navigationTitle(dateString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Entity Badge

struct EntityBadge: View {
    let entity: Entity

    var body: some View {
        HStack(spacing: 4) {
            Text(entity.value)
                .font(.caption2)
                .fontWeight(.medium)

            Text(String(format: "%.0f%%", entity.confidence * 100))
                .font(.system(size: 9))
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(entity.type.color.opacity(0.15))
        .cornerRadius(4)
    }
}

// MARK: - Flow Layout

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.replacingUnspecifiedDimensions().width, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.frames[index].minX, y: bounds.minY + result.frames[index].minY), proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize
        var frames: [CGRect]

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var frames: [CGRect] = []
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if currentX + size.width > maxWidth && currentX > 0 {
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }

                frames.append(CGRect(x: currentX, y: currentY, width: size.width, height: size.height))
                lineHeight = max(lineHeight, size.height)
                currentX += size.width + spacing
            }

            self.frames = frames
            self.size = CGSize(width: maxWidth, height: currentY + lineHeight)
        }
    }
}

#Preview {
    ChatContextView(
        context: ChatContext(
            selectedDate: Date(),
            currentNote: Entry(content: "Today I feel grateful for the small moments of joy that came my way. The morning coffee tasted especially good."),
            historicalNotes: [
                Entry(content: "Last month was challenging but I learned a lot about resilience."),
                Entry(content: "Two months ago I set some goals that I'm still working towards.")
            ],
            recentNotes: [
                Entry(content: "Yesterday was productive and fulfilling."),
                Entry(content: "Day before yesterday I had an interesting conversation with a friend.")
            ]
        )
    )
    .padding()
}