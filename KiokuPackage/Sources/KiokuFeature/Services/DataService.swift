import SwiftData
import Foundation

@Observable
public final class DataService: @unchecked Sendable {
    private let modelContainer: ModelContainer
    private let modelContext: ModelContext
    private let encryptionService = EncryptionService.shared
    
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
            
            // Validate encryption service
            try encryptionService.validateEncryption()
            
            print("DataService initialized with encryption support")
            
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
    
    // MARK: - Migration
    
    /// Migrates existing unencrypted entries to encrypted storage
    public func migrateExistingEntriesToEncryption() {
        let descriptor = FetchDescriptor<Entry>()
        
        do {
            let allEntries = try modelContext.fetch(descriptor)
            var migratedCount = 0
            var alreadyEncryptedCount = 0
            
            for entry in allEntries {
                if entry.isEncrypted {
                    alreadyEncryptedCount += 1
                    continue
                }
                
                // Attempt to migrate this entry
                do {
                    try entry.migrateToEncrypted()
                    migratedCount += 1
                } catch {
                    print("Failed to migrate entry \(entry.id): \(error)")
                }
            }
            
            // Save changes if any entries were migrated
            if migratedCount > 0 {
                saveContext()
                print("Migration completed: \(migratedCount) entries migrated, \(alreadyEncryptedCount) already encrypted")
            } else if alreadyEncryptedCount > 0 {
                print("All \(alreadyEncryptedCount) entries are already encrypted")
            } else {
                print("No entries found to migrate")
            }
            
        } catch {
            print("Failed to fetch entries for migration: \(error)")
        }
    }
    
    /// Gets encryption status for all entries (for debugging/validation)
    public func getEncryptionStatus() -> (encrypted: Int, unencrypted: Int) {
        let descriptor = FetchDescriptor<Entry>()
        
        do {
            let allEntries = try modelContext.fetch(descriptor)
            let encryptedCount = allEntries.filter { $0.isEncrypted }.count
            let unencryptedCount = allEntries.count - encryptedCount
            return (encrypted: encryptedCount, unencrypted: unencryptedCount)
        } catch {
            print("Failed to fetch encryption status: \(error)")
            return (encrypted: 0, unencrypted: 0)
        }
    }
}

// MARK: - Preview Support
extension DataService {
    static let preview: DataService = {
        let service = DataService()
        
        // Add sample data for previews
        _ = service.createEntry(content: "This is a sample entry for previews")
        _ = service.createEntry(content: "Another sample entry with different content")
        
        return service
    }()
}