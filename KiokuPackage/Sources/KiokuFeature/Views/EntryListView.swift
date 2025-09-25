import SwiftUI
import SwiftData

public struct EntryListView: View {
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]
    @Environment(DataService.self) private var dataService
    @State private var selectedEntry: Entry?
    
    public var body: some View {
        NavigationView {
            Group {
                if entries.isEmpty {
                    emptyStateView
                } else {
                    entryListContent
                }
            }
            .navigationTitle("All Entries")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.closed")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No entries yet")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Your journal entries will appear here")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    private var entryListContent: some View {
        List {
            ForEach(entries) { entry in
                EntryRowView(entry: entry)
                    .onTapGesture {
                        selectedEntry = entry
                    }
            }
            .onDelete(perform: deleteEntries)
        }
        .sheet(item: $selectedEntry) { entry in
            EntryDetailView(entry: entry)
        }
    }
    
    private func deleteEntries(offsets: IndexSet) {
        for index in offsets {
            dataService.deleteEntry(entries[index])
        }
    }
    
    public init() {}
}

struct EntryRowView: View {
    let entry: Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date and time
            HStack {
                Text(entry.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(entry.createdAt, style: .time)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Content preview
            Text(entry.content)
                .font(.body)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            // Word count
            HStack {
                Spacer()
                Text("\(wordCount(entry.content)) words")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func wordCount(_ text: String) -> Int {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
}

// MARK: - Previews

#Preview {
    EntryListView()
        .environment(DataService.preview)
}