import SwiftUI

public struct SearchView: View {
    @Environment(DataService.self) private var dataService
    @State private var searchService: SearchService?
    @State private var showFilters = false

    public init() {}

    public var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Search Bar
                SearchBar(
                    text: Binding(
                        get: { searchService?.searchText ?? "" },
                        set: { newValue in
                            searchService?.searchText = newValue
                            Task {
                                await searchService?.performSearch()
                            }
                        }
                    ),
                    onClear: {
                        Task {
                            await searchService?.clearSearch()
                        }
                    }
                )
                .padding()

                // Active Filters
                if let service = searchService, (!service.selectedEntityTypes.isEmpty || service.dateRange != nil) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(Array(service.selectedEntityTypes), id: \.self) { type in
                                FilterChip(
                                    title: type.rawValue.capitalized,
                                    color: .blue,
                                    onRemove: {
                                        Task { @MainActor in
                                            service.toggleEntityType(type)
                                            await service.performSearch()
                                        }
                                    }
                                )
                            }

                            if let range = service.dateRange {
                                FilterChip(
                                    title: formatDateRange(range),
                                    color: .purple,
                                    onRemove: {
                                        Task { @MainActor in
                                            service.dateRange = nil
                                            await service.performSearch()
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.bottom, 8)
                }

                Divider()

                // Results
                if let service = searchService {
                    if service.isSearching {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if service.searchResults.isEmpty {
                        if service.searchText.isEmpty && service.selectedEntityTypes.isEmpty && service.dateRange == nil {
                            EmptySearchView()
                        } else {
                            NoResultsView()
                        }
                    } else {
                        SearchResultsList(results: service.searchResults, searchText: service.searchText)
                    }
                }
            }
            .navigationTitle("Search")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showFilters = true
                    } label: {
                        Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                    }
                }
            }
            .sheet(isPresented: $showFilters) {
                if let service = searchService {
                    FilterSheet(searchService: service)
                }
            }
        }
        .onAppear {
            if searchService == nil {
                searchService = SearchService(dataService: dataService)
            }
        }
    }

    private func formatDateRange(_ range: DateRange) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return "\(formatter.string(from: range.start)) - \(formatter.string(from: range.end))"
    }
}

// MARK: - Search Bar

struct SearchBar: View {
    @Binding var text: String
    let onClear: () -> Void

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField("Search entries...", text: $text)
                .textFieldStyle(.plain)

            if !text.isEmpty {
                Button(action: onClear) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(10)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - Filter Chip

struct FilterChip: View {
    let title: String
    let color: Color
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)

            Button(action: onRemove) {
                Image(systemName: "xmark")
                    .font(.caption2)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(color.opacity(0.15))
        .foregroundStyle(color)
        .clipShape(Capsule())
    }
}

// MARK: - Search Results List

struct SearchResultsList: View {
    let results: [Entry]
    let searchText: String

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(results) { entry in
                    SearchResultCard(entry: entry, searchText: searchText)
                }
            }
            .padding()
        }
    }
}

// MARK: - Search Result Card

struct SearchResultCard: View {
    let entry: Entry
    let searchText: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date
            HStack {
                Text(entry.displayDate)
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                if !entry.entities.isEmpty {
                    HStack(spacing: 4) {
                        ForEach(Array(entry.entities.prefix(3))) { entity in
                            Text(entity.value)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.blue.opacity(0.1))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            // Content preview with highlighting
            Text(highlightedContent)
                .font(.subheadline)
                .lineLimit(4)
                .foregroundStyle(.primary)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }

    private var highlightedContent: AttributedString {
        var attributed = AttributedString(entry.content)

        if !searchText.isEmpty {
            let searchLower = searchText.lowercased()
            let contentLower = entry.content.lowercased()

            var searchRange = contentLower.startIndex..<contentLower.endIndex

            while let range = contentLower.range(of: searchLower, range: searchRange) {
                let attributedRange = Range(range, in: attributed)!
                attributed[attributedRange].backgroundColor = .yellow.opacity(0.3)
                attributed[attributedRange].foregroundColor = .primary

                searchRange = range.upperBound..<contentLower.endIndex
            }
        }

        return attributed
    }
}

// MARK: - Empty States

struct EmptySearchView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Search Your Journal")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Find entries by text, entities, or date range")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct NoResultsView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text.magnifyingglass")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("No Results")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Try different keywords or filters")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Filter Sheet

struct FilterSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var searchService: SearchService
    @State private var selectedDateRangeType: DateRangeType = .none

    enum DateRangeType: String, CaseIterable {
        case none = "None"
        case lastWeek = "Last Week"
        case lastMonth = "Last Month"
        case last3Months = "Last 3 Months"
        case thisYear = "This Year"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Entity Types") {
                    let availableTypes = searchService.getAvailableEntityTypes()

                    if availableTypes.isEmpty {
                        Text("No entities found")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(availableTypes, id: \.self) { type in
                            Toggle(type.rawValue.capitalized, isOn: Binding(
                                get: { searchService.selectedEntityTypes.contains(type) },
                                set: { isOn in
                                    if isOn {
                                        searchService.selectedEntityTypes.insert(type)
                                    } else {
                                        searchService.selectedEntityTypes.remove(type)
                                    }
                                }
                            ))
                        }
                    }
                }

                Section("Date Range") {
                    Picker("Range", selection: $selectedDateRangeType) {
                        ForEach(DateRangeType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.menu)
                    .onChange(of: selectedDateRangeType) {
                        updateDateRange()
                    }
                }
            }
            .navigationTitle("Filters")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Clear All") {
                        Task { @MainActor in
                            await searchService.clearSearch()
                            selectedDateRangeType = .none
                        }
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        Task { @MainActor in
                            await searchService.performSearch()
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            // Set initial date range type based on current range
            if searchService.dateRange == nil {
                selectedDateRangeType = .none
            }
        }
    }

    private func updateDateRange() {
        switch selectedDateRangeType {
        case .none:
            searchService.dateRange = nil
        case .lastWeek:
            searchService.dateRange = .lastWeek()
        case .lastMonth:
            searchService.dateRange = .lastMonth()
        case .last3Months:
            searchService.dateRange = .last3Months()
        case .thisYear:
            searchService.dateRange = .thisYear()
        }
    }
}

#Preview {
    SearchView()
        .environment(DataService.preview)
}
