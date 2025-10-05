import SwiftUI
import SwiftData

@Observable
public final class SearchService: @unchecked Sendable {
    private let dataService: DataService

    // Search state
    public var searchText: String = ""
    public var selectedEntityTypes: Set<EntityType> = []
    public var dateRange: DateRange?
    public var isSearching: Bool = false

    // Results
    public var searchResults: [Entry] = []

    public init(dataService: DataService) {
        self.dataService = dataService
    }

    // MARK: - Search Methods

    /// Performs a search with current filters
    @MainActor
    public func performSearch() async {
        guard !searchText.isEmpty || !selectedEntityTypes.isEmpty || dateRange != nil else {
            searchResults = []
            return
        }

        isSearching = true
        defer { isSearching = false }

        do {
            var descriptor = FetchDescriptor<Entry>(
                sortBy: [SortDescriptor(\.date, order: .reverse)]
            )

            let allEntries = try dataService.modelContext.fetch(descriptor)

            // Apply filters
            var filteredEntries = allEntries

            // Text search filter
            if !searchText.isEmpty {
                let searchLower = searchText.lowercased()
                filteredEntries = filteredEntries.filter { entry in
                    entry.content.lowercased().contains(searchLower)
                }
            }

            // Entity type filter
            if !selectedEntityTypes.isEmpty {
                filteredEntries = filteredEntries.filter { entry in
                    let entryEntityTypes = Set(entry.entities.map { $0.type })
                    return !entryEntityTypes.isDisjoint(with: selectedEntityTypes)
                }
            }

            // Date range filter
            if let range = dateRange {
                filteredEntries = filteredEntries.filter { entry in
                    guard let entryDate = entry.date else { return false }
                    return entryDate >= range.start && entryDate <= range.end
                }
            }

            searchResults = filteredEntries

        } catch {
            print("Search error: \(error)")
            searchResults = []
        }
    }

    /// Clears all search filters and results
    @MainActor
    public func clearSearch() {
        searchText = ""
        selectedEntityTypes = []
        dateRange = nil
        searchResults = []
    }

    /// Toggle entity type filter
    @MainActor
    public func toggleEntityType(_ type: EntityType) {
        if selectedEntityTypes.contains(type) {
            selectedEntityTypes.remove(type)
        } else {
            selectedEntityTypes.insert(type)
        }
    }

    /// Get all available entity types from data
    public func getAvailableEntityTypes() -> [EntityType] {
        do {
            let descriptor = FetchDescriptor<Entity>()
            let entities = try dataService.modelContext.fetch(descriptor)
            let types = Set(entities.map { $0.type })
            return Array(types).sorted { $0.rawValue < $1.rawValue }
        } catch {
            print("Error fetching entity types: \(error)")
            return []
        }
    }
}

// MARK: - Date Range

public struct DateRange: Equatable {
    public let start: Date
    public let end: Date

    public init(start: Date, end: Date) {
        self.start = start
        self.end = end
    }

    // Convenience constructors
    public static func lastWeek() -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .day, value: -7, to: end)!
        return DateRange(start: start, end: end)
    }

    public static func lastMonth() -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .month, value: -1, to: end)!
        return DateRange(start: start, end: end)
    }

    public static func last3Months() -> DateRange {
        let end = Date()
        let start = Calendar.current.date(byAdding: .month, value: -3, to: end)!
        return DateRange(start: start, end: end)
    }

    public static func thisYear() -> DateRange {
        let calendar = Calendar.current
        let now = Date()
        let year = calendar.component(.year, from: now)
        let start = calendar.date(from: DateComponents(year: year, month: 1, day: 1))!
        let end = now
        return DateRange(start: start, end: end)
    }
}
