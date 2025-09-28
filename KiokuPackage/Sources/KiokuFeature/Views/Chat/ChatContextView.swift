import SwiftUI

struct ChatContextView: View {
    let context: ChatContext
    @State private var isExpanded = false
    
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
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color(.systemGray6).opacity(0.5))
                    .cornerRadius(8)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(.horizontal)
    }
    
    private var contextDetails: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let currentNote = context.currentNote {
                contextSection(
                    title: "Today's Note",
                    icon: "note.text",
                    content: String(currentNote.content.prefix(100)) + (currentNote.content.count > 100 ? "..." : "")
                )
            } else {
                contextSection(
                    title: "Today's Note",
                    icon: "note.text",
                    content: "No note for today yet"
                )
            }
            
            if !context.historicalNotes.isEmpty {
                contextSection(
                    title: "Historical Notes (\(context.historicalNotes.count))",
                    icon: "clock.arrow.circlepath",
                    content: context.historicalNotes.prefix(3).map { entry in
                        let dateStr = entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                        return "\(dateStr): \(String(entry.content.prefix(50)))..."
                    }.joined(separator: "\n")
                )
            }
            
            if !context.recentNotes.isEmpty {
                contextSection(
                    title: "Recent Notes (\(context.recentNotes.count))",
                    icon: "calendar",
                    content: context.recentNotes.prefix(2).map { entry in
                        let dateStr = entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                        return "\(dateStr): \(String(entry.content.prefix(50)))..."
                    }.joined(separator: "\n")
                )
            }
        }
    }
    
    private func contextSection(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(.accentColor)
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            
            Text(content)
                .font(.caption2)
                .foregroundColor(.secondary)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
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