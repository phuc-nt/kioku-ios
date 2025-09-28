import SwiftUI
import SwiftData

struct HistoricalNotesView: View {
    let selectedDate: Date
    let onNoteSelected: (Entry) -> Void
    let onDismiss: () -> Void
    
    @Query(sort: \Entry.createdAt, order: .reverse) private var allEntries: [Entry]
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Historical Notes List
            if historicalNotes.isEmpty {
                emptyStateView
            } else {
                notesListView
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // Title
            Text("Same day in previous months")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            // Found entries counter
            Text("Found \(historicalNotes.count) \(historicalNotes.count == 1 ? "entry" : "entries")")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
            
            // Close button
            HStack {
                Spacer()
                Button("Close") {
                    onDismiss()
                }
                .foregroundColor(.accentColor)
                .padding(.horizontal, 20)
            }
        }
        .padding(.bottom, 20)
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No entries found")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("You haven't written any entries on \(selectedDate.formatted(.dateTime.month(.wide).day())) in previous months")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding(.vertical, 40)
    }
    
    private var notesListView: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(historicalNotes, id: \.id) { entry in
                    HistoricalNoteCard(
                        entry: entry,
                        dateFormatter: dateFormatter,
                        onTap: {
                            onNoteSelected(entry)
                            onDismiss()
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34) // Safe area padding
        }
    }
    
    // MARK: - Helper Methods
    
    private var historicalNotes: [Entry] {
        let selectedDay = calendar.component(.day, from: selectedDate)
        let currentMonth = calendar.startOfMonth(for: selectedDate)
        
        var historicalEntries: [Entry] = []
        
        // Look back 12 months (excluding current month)
        for monthsBack in 1...12 {
            if let targetMonth = calendar.date(byAdding: .month, value: -monthsBack, to: currentMonth) {
                let targetDate = getTargetDate(for: targetMonth, day: selectedDay)
                
                if let matchingEntry = allEntries.first(where: { entry in
                    if let entryDate = entry.date {
                        return calendar.isDate(entryDate, inSameDayAs: targetDate)
                    } else {
                        return calendar.isDate(entry.createdAt, inSameDayAs: targetDate)
                    }
                }) {
                    historicalEntries.append(matchingEntry)
                }
            }
        }
        
        // Sort by date, newest first (most recent past month first)
        return historicalEntries.sorted { entry1, entry2 in
            let date1 = entry1.date ?? entry1.createdAt
            let date2 = entry2.date ?? entry2.createdAt
            return date1 > date2
        }
    }
    
    private func getTargetDate(for month: Date, day: Int) -> Date {
        let targetYear = calendar.component(.year, from: month)
        let targetMonth = calendar.component(.month, from: month)
        
        var components = DateComponents()
        components.year = targetYear
        components.month = targetMonth
        components.day = day
        
        // Handle edge case where target day doesn't exist in target month (e.g., Feb 30)
        if let targetDate = calendar.date(from: components) {
            return targetDate
        } else {
            // Fallback to last day of target month
            components.day = nil
            let firstOfMonth = calendar.date(from: components) ?? month
            return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstOfMonth) ?? month
        }
    }
}

// MARK: - Historical Note Card Component

struct HistoricalNoteCard: View {
    let entry: Entry
    let dateFormatter: DateFormatter
    let onTap: () -> Void
    
    private var previewContent: String {
        let content = entry.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.count > 120 {
            return String(content.prefix(120)) + "..."
        }
        return content
    }
    
    private var displayDate: String {
        return dateFormatter.string(from: entry.date ?? entry.createdAt)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date
            Text(displayDate)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
            
            // Content preview
            Text(previewContent)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color(.systemGray4), lineWidth: 0.5)
                )
        )
        .onTapGesture {
            onTap()
        }
    }
}


// MARK: - View Extension for Corner Radius

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    HistoricalNotesView(
        selectedDate: Date(),
        onNoteSelected: { _ in },
        onDismiss: { }
    )
    .environment(DataService.preview)
}