import SwiftData
import Foundation

@Observable
public final class DataService {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    
    public init() {
        do {
            // Configure SwiftData model container
            let schema = Schema([Entry.self])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )
            
            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )
            
            self.modelContext = ModelContext(modelContainer)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }
    
    // MARK: - Entry Operations
    
    func createEntry(content: String) -> Entry {
        let entry = Entry(content: content)
        modelContext.insert(entry)
        saveContext()
        return entry
    }
    
    func updateEntry(_ entry: Entry, content: String) {
        entry.updateContent(content)
        saveContext()
    }
    
    func deleteEntry(_ entry: Entry) {
        modelContext.delete(entry)
        saveContext()
    }
    
    func fetchAllEntries() -> [Entry] {
        let descriptor = FetchDescriptor<Entry>(
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch entries: \(error)")
            return []
        }
    }
    
    func fetchEntriesForDate(_ date: Date) -> [Entry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? date
        
        let predicate = #Predicate<Entry> { entry in
            entry.createdAt >= startOfDay && entry.createdAt < endOfDay
        }
        
        let descriptor = FetchDescriptor<Entry>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.createdAt, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch entries for date: \(error)")
            return []
        }
    }
    
    // MARK: - Private Methods
    
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save context: \(error)")
        }
    }
    
    // MARK: - Container Access
    
    public var container: ModelContainer {
        modelContainer
    }
}

// MARK: - Preview Support
extension DataService {
    nonisolated(unsafe) static let preview: DataService = {
        let service = DataService()
        
        // Add sample data for previews
        _ = service.createEntry(content: "This is a sample entry for previews")
        _ = service.createEntry(content: "Another sample entry with different content")
        
        return service
    }()
}