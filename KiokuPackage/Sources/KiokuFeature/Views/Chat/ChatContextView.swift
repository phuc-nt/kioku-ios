import SwiftUI

enum DiscoveryMethod {
    case today
    case sameDay
    case recent

    var label: String {
        switch self {
        case .today: return "Today"
        case .sameDay: return "Same day"
        case .recent: return "Related"
        }
    }

    var icon: String {
        switch self {
        case .today: return "calendar.badge.clock"
        case .sameDay: return "arrow.clockwise"
        case .recent: return "link"
        }
    }

    var color: Color {
        switch self {
        case .today: return .blue
        case .sameDay: return .green
        case .recent: return .purple
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
                contextDetails
                    .padding(.vertical, 8)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(.horizontal)
        .sheet(item: $selectedEntry) { entry in
            EntryDetailSheet(entry: entry)
        }
    }
    
    private var contextDetails: some View {
        VStack(alignment: .leading, spacing: 8) {
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