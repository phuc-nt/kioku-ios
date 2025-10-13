import SwiftData
import Foundation

@Observable
public final class DataService: @unchecked Sendable {
    private let modelContainer: ModelContainer
    private let _modelContext: ModelContext
    private let encryptionService = EncryptionService.shared
    
    public init() {
        do {
            // Configure SwiftData model container
            let schema = Schema([
                Entry.self,
                AIAnalysis.self,
                Conversation.self,
                ChatMessage.self,
                Entity.self,
                EntityRelationship.self,
                Insight.self
            ])
            let modelConfiguration = ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false
            )

            self.modelContainer = try ModelContainer(
                for: schema,
                configurations: [modelConfiguration]
            )

            self._modelContext = ModelContext(modelContainer)

            // Validate encryption service
            try encryptionService.validateEncryption()

            print("DataService initialized with encryption support")

        } catch {
            fatalError("Failed to initialize SwiftData container: \(error)")
        }
    }
    
    // MARK: - Entry Operations
    
    func createEntry(content: String, date: Date = Date()) -> Entry {
        let entry = Entry(content: content, date: date)
        _modelContext.insert(entry)
        saveContext()
        return entry
    }
    
    func updateEntry(_ entry: Entry, content: String) {
        entry.updateContent(content)
        saveContext()
    }
    
    func deleteEntry(_ entry: Entry) {
        _modelContext.delete(entry)
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
    
    func fetchEntry(by id: UUID) throws -> Entry? {
        let predicate = #Predicate<Entry> { entry in
            entry.id == id
        }
        
        let descriptor = FetchDescriptor<Entry>(
            predicate: predicate
        )
        
        let results = try modelContext.fetch(descriptor)
        return results.first
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
    
    // MARK: - Analysis Operations
    
    /// Save analysis results for an entry
    func saveAnalysis(for entry: Entry, analysisResult: AIAnalysisService.EntryAnalysis) -> AIAnalysis {
        let analysis = AIAnalysis(entryId: entry.id, analysis: analysisResult)
        analysis.entry = entry
        _modelContext.insert(analysis)
        saveContext()
        return analysis
    }
    
    /// Get all analyses for a specific entry
    func getAnalyses(for entry: Entry) -> [AIAnalysis] {
        let entryId = entry.id
        let predicate = #Predicate<AIAnalysis> { analysis in
            analysis.entryId == entryId
        }
        
        let descriptor = FetchDescriptor<AIAnalysis>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.processingDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch analyses for entry \(entry.id): \(error)")
            return []
        }
    }
    
    /// Get latest analysis for an entry
    func getLatestAnalysis(for entry: Entry) -> AIAnalysis? {
        return getAnalyses(for: entry).first
    }
    
    /// Get analyses by sentiment type
    func getAnalyses(bySentiment sentiment: String) -> [AIAnalysis] {
        let predicate = #Predicate<AIAnalysis> { analysis in
            analysis.overallSentiment == sentiment
        }
        
        let descriptor = FetchDescriptor<AIAnalysis>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.processingDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch analyses by sentiment: \(error)")
            return []
        }
    }
    
    /// Get analyses by model
    func getAnalyses(byModel model: String) -> [AIAnalysis] {
        let predicate = #Predicate<AIAnalysis> { analysis in
            analysis.modelUsed == model
        }
        
        let descriptor = FetchDescriptor<AIAnalysis>(
            predicate: predicate,
            sortBy: [SortDescriptor(\.processingDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch analyses by model: \(error)")
            return []
        }
    }
    
    /// Get all analyses (for pattern discovery and knowledge graph)
    func getAllAnalyses() -> [AIAnalysis] {
        let descriptor = FetchDescriptor<AIAnalysis>(
            sortBy: [SortDescriptor(\.processingDate, order: .reverse)]
        )
        
        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch all analyses: \(error)")
            return []
        }
    }
    
    /// Delete an analysis
    func deleteAnalysis(_ analysis: AIAnalysis) {
        _modelContext.delete(analysis)
        saveContext()
    }
    
    /// Delete all analyses for an entry (called automatically via cascade delete)
    func deleteAnalyses(for entry: Entry) {
        let analyses = getAnalyses(for: entry)
        for analysis in analyses {
            _modelContext.delete(analysis)
        }
        saveContext()
    }
    
    /// Get analysis statistics
    func getAnalysisStatistics() -> (total: Int, byModel: [String: Int], bySentiment: [String: Int]) {
        let allAnalyses = getAllAnalyses()

        var byModel: [String: Int] = [:]
        var bySentiment: [String: Int] = [:]

        for analysis in allAnalyses {
            byModel[analysis.modelUsed, default: 0] += 1
            bySentiment[analysis.overallSentiment, default: 0] += 1
        }

        return (total: allAnalyses.count, byModel: byModel, bySentiment: bySentiment)
    }

    // MARK: - Conversation Operations

    func createConversation(title: String = "New Conversation", associatedDate: Date? = nil) -> Conversation {
        let conversation = Conversation(title: title, associatedDate: associatedDate)
        _modelContext.insert(conversation)
        saveContext()
        return conversation
    }

    func fetchAllConversations() -> [Conversation] {
        let descriptor = FetchDescriptor<Conversation>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch conversations: \(error)")
            return []
        }
    }

    func fetchConversation(by id: UUID) throws -> Conversation? {
        let predicate = #Predicate<Conversation> { conversation in
            conversation.id == id
        }

        let descriptor = FetchDescriptor<Conversation>(predicate: predicate)
        let results = try modelContext.fetch(descriptor)
        return results.first
    }

    func fetchConversation(forDate date: Date) -> Conversation? {
        // Normalize date to start of day for comparison
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return nil
        }

        // Fetch all conversations with associatedDate, then filter in-memory
        // SwiftData predicates don't support captured variable comparisons well
        let descriptor = FetchDescriptor<Conversation>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )

        do {
            let allConversations = try modelContext.fetch(descriptor)

            // Filter to conversations with associatedDate in the target day
            let matchingConversations = allConversations.filter { conversation in
                guard let assocDate = conversation.associatedDate else { return false }
                return assocDate >= startOfDay && assocDate < endOfDay
            }

            return matchingConversations.first
        } catch {
            print("Failed to fetch conversation for date: \(error)")
            return nil
        }
    }

    func updateConversationTitle(_ conversation: Conversation, title: String) {
        conversation.title = title
        conversation.updatedAt = Date()
        saveContext()
    }

    func deleteConversation(_ conversation: Conversation) {
        _modelContext.delete(conversation)
        saveContext()
    }

    // MARK: - Chat Message Operations

    func addMessage(to conversation: Conversation, content: String, isFromUser: Bool, contextData: String? = nil) -> ChatMessage {
        let message = ChatMessage(
            content: content,
            isFromUser: isFromUser,
            contextData: contextData
        )
        message.conversation = conversation
        conversation.messages.append(message)
        conversation.updatedAt = Date()
        _modelContext.insert(message)
        saveContext()
        return message
    }

    func updateMessageContent(_ message: ChatMessage, content: String) {
        message.content = content
        message.conversation?.updatedAt = Date()
        saveContext()
    }

    func updateMessageStreamingState(_ message: ChatMessage, isStreaming: Bool) {
        message.isStreaming = isStreaming
        saveContext()
    }

    func deleteMessage(_ message: ChatMessage) {
        message.conversation?.updatedAt = Date()
        _modelContext.delete(message)
        saveContext()
    }

    // MARK: - Entity Operations

    public func fetchAllEntities() -> [Entity] {
        let descriptor = FetchDescriptor<Entity>(
            sortBy: [SortDescriptor(\.updatedAt, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    public func fetchEntities(type: EntityType) -> [Entity] {
        let descriptor = FetchDescriptor<Entity>(
            predicate: #Predicate<Entity> { entity in
                entity.type == type
            },
            sortBy: [SortDescriptor(\.confidence, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    public func fetchEntities(type: EntityType, searchText: String) -> [Entity] {
        // Fetch all entities of this type first, then filter with exact match
        // This ensures proper deduplication during entity extraction
        let descriptor = FetchDescriptor<Entity>(
            predicate: #Predicate<Entity> { entity in
                entity.type == type
            },
            sortBy: [SortDescriptor(\.confidence, order: .reverse)]
        )

        let allEntities = (try? modelContext.fetch(descriptor)) ?? []

        print("      🔎 fetchEntities: type=\(type.rawValue), search='\(searchText)', total in DB=\(allEntities.count)")
        if !allEntities.isEmpty {
            print("         Entities in DB: \(allEntities.map { $0.value }.joined(separator: ", "))")
        }

        // Filter using the entity's matches() method which does exact matching
        let matches = allEntities.filter { $0.matches(query: searchText) }
        print("         Matches: \(matches.count)")
        return matches
    }

    public func fetchEntity(by id: UUID) -> Entity? {
        let descriptor = FetchDescriptor<Entity>(
            predicate: #Predicate<Entity> { entity in
                entity.id == id
            }
        )
        return try? modelContext.fetch(descriptor).first
    }

    public func deleteEntity(_ entity: Entity) {
        modelContext.delete(entity)
        saveContext()
    }

    // MARK: - Entity Relationship Operations

    public func fetchRelationships(for entity: Entity) -> [EntityRelationship] {
        // Get both outgoing and incoming relationships
        var relationships = entity.outgoingRelationships
        relationships.append(contentsOf: entity.incomingRelationships)
        return relationships.sorted { $0.confidence > $1.confidence }
    }

    public func fetchRelationships(type: RelationshipType) -> [EntityRelationship] {
        let descriptor = FetchDescriptor<EntityRelationship>(
            predicate: #Predicate<EntityRelationship> { relationship in
                relationship.type == type
            },
            sortBy: [SortDescriptor(\.confidence, order: .reverse)]
        )
        return (try? modelContext.fetch(descriptor)) ?? []
    }

    public func deleteRelationship(_ relationship: EntityRelationship) {
        modelContext.delete(relationship)
        saveContext()
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
    
    public var modelContext: ModelContext {
        _modelContext
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

        // Add sample insights (Sprint 15)
        let dailyInsight = Insight(
            type: .emotional,
            title: "Positive day with family",
            description: "Your entries show gratitude and positive emotions when spending time with family members.",
            confidence: 0.85,
            timeframe: .daily
        )
        service.modelContext.insert(dailyInsight)

        let weeklyInsight = Insight(
            type: .frequency,
            title: "Work-life balance focus",
            description: "This week you mentioned 'work from home' and 'family time' frequently, showing good balance.",
            confidence: 0.78,
            timeframe: .weekly
        )
        service.modelContext.insert(weeklyInsight)

        let suggestionInsight = Insight(
            type: .suggestion,
            title: "Health tracking opportunity",
            description: "You wrote about health concerns. Consider tracking symptoms and doctor visits for better health management.",
            confidence: 0.72,
            timeframe: .daily
        )
        service.modelContext.insert(suggestionInsight)

        try? service.modelContext.save()

        return service
    }()
}