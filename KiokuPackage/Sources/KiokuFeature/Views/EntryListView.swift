import SwiftUI
import SwiftData

public struct EntryListView: View {
    @Environment(DataService.self) private var dataService
    @State private var selectedEntry: Entry?
    @State private var searchText = ""
    @State private var isSearching = false
    
    // Dynamic query based on search text
    private var entries: [Entry] {
        if searchText.isEmpty {
            return allEntries
        } else {
            return allEntries.filter { entry in
                entry.content.localizedCaseInsensitiveContains(searchText)
            }
        }
    }
    
    @Query(sort: \Entry.createdAt, order: .reverse) private var allEntries: [Entry]
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                
                // Content
                Group {
                    if entries.isEmpty {
                        if searchText.isEmpty {
                            emptyStateView
                        } else {
                            searchEmptyStateView
                        }
                    } else {
                        entryListContent
                    }
                }
            }
            .navigationTitle(searchText.isEmpty ? "All Entries" : "Search Results")
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
    
    private var searchBar: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                
                TextField("Search entries...", text: $searchText)
                    .textFieldStyle(PlainTextFieldStyle())
                    .onTapGesture {
                        isSearching = true
                    }
                
                if !searchText.isEmpty {
                    Button("Clear") {
                        searchText = ""
                    }
                    .foregroundColor(.accentColor)
                    .font(.caption)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))
            .cornerRadius(10)
            
            if isSearching {
                Button("Cancel") {
                    searchText = ""
                    isSearching = false
                    hideKeyboard()
                }
                .foregroundColor(.accentColor)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var searchEmptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No results found")
                .font(.title2)
                .fontWeight(.medium)
            
            Text("Try different keywords or check spelling")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Clear Search") {
                searchText = ""
            }
            .foregroundColor(.accentColor)
            .padding(.top, 8)
        }
        .padding()
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), 
                                       to: nil, from: nil, for: nil)
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
            
            // Content preview with search highlighting
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