import Foundation
import SwiftData

// MARK: - Export Options

public enum ExportFormat: Sendable {
    case json
    case markdown
}

public struct ExportDateRange: Sendable {
    let start: Date?
    let end: Date?
}

public struct ExportOptions: Sendable {
    let format: ExportFormat
    let includeEncrypted: Bool // Encrypt content in export (JSON only)
    let includeLegacyAnalysis: Bool // Include AIAnalysis models
    let includeConversations: Bool // Include chat conversations
    let dateRange: ExportDateRange? // Filter entries by date range

    public static let `default` = ExportOptions(
        format: .json,
        includeEncrypted: true,
        includeLegacyAnalysis: false,
        includeConversations: true,
        dateRange: nil
    )
}

// MARK: - Export Errors

public enum ExportError: Error, LocalizedError {
    case encryptionFailed(String)
    case diskSpaceInsufficient
    case serializationFailed(String)
    case partialExportFailed([String])

    public var errorDescription: String? {
        switch self {
        case .encryptionFailed(let msg): return "Encryption failed: \(msg)"
        case .diskSpaceInsufficient: return "Insufficient disk space"
        case .serializationFailed(let msg): return "Serialization failed: \(msg)"
        case .partialExportFailed(let items): return "Partial export failed: \(items.joined(separator: ", "))"
        }
    }
}

// MARK: - Export Service

@Observable
public class ExportService {
    private let dataService: DataService
    private let encryptionService: EncryptionService

    public init(dataService: DataService, encryptionService: EncryptionService) {
        self.dataService = dataService
        self.encryptionService = encryptionService
    }

    // MARK: - Export Methods

    @MainActor
    public func exportToJSON(
        options: ExportOptions = .default,
        progress: @escaping @Sendable (Double, String) -> Void = { _, _ in }
    ) async throws -> Data {
        progress(0.0, "Starting export...")

        // Fetch all data
        progress(0.1, "Fetching entries...")
        let entries = try await fetchEntries(dateRange: options.dateRange)

        progress(0.3, "Fetching entities...")
        let entities = try await fetchEntities()

        progress(0.5, "Fetching relationships...")
        let relationships = try await fetchRelationships()

        progress(0.6, "Fetching insights...")
        let insights = try await fetchInsights()

        var conversations: [Conversation] = []
        if options.includeConversations {
            progress(0.7, "Fetching conversations...")
            conversations = try await fetchConversations()
        }

        // Build export structure
        progress(0.8, "Building export structure...")
        let exportData = try buildJSONExport(
            entries: entries,
            entities: entities,
            relationships: relationships,
            insights: insights,
            conversations: conversations,
            options: options
        )

        // Serialize to JSON
        progress(0.9, "Serializing to JSON...")
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        do {
            let data = try encoder.encode(exportData)
            progress(1.0, "Export complete!")
            return data
        } catch {
            throw ExportError.serializationFailed(error.localizedDescription)
        }
    }

    @MainActor
    public func exportToMarkdown(
        options: ExportOptions = .default,
        progress: @escaping @Sendable (Double, String) -> Void = { _, _ in }
    ) async throws -> String {
        progress(0.0, "Starting Markdown export...")

        progress(0.2, "Fetching entries...")
        let entries = try await fetchEntries(dateRange: options.dateRange)

        progress(0.4, "Fetching entities...")
        let entities = try await fetchEntities()

        progress(0.6, "Fetching insights...")
        let insights = try await fetchInsights()

        progress(0.8, "Formatting Markdown...")
        let markdown = try buildMarkdownExport(
            entries: entries,
            entities: entities,
            insights: insights
        )

        progress(1.0, "Markdown export complete!")
        return markdown
    }

    @MainActor
    public func estimateExportSize(format: ExportFormat) async -> Int {
        // Rough estimation based on data count
        let entryCount = (try? await fetchEntries(dateRange: nil).count) ?? 0
        let entityCount = (try? await fetchEntities().count) ?? 0

        switch format {
        case .json:
            // ~10KB per entry with full KG data
            return entryCount * 10_000 + entityCount * 500
        case .markdown:
            // ~2KB per entry (text only)
            return entryCount * 2_000
        }
    }

    // MARK: - Private Fetch Methods

    @MainActor
    private func fetchEntries(dateRange: ExportDateRange?) async throws -> [Entry] {
        let descriptor = FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.date, order: .reverse)])
        let allEntries = try dataService.modelContext.fetch(descriptor)

        guard let range = dateRange else { return allEntries }

        return allEntries.filter { entry in
            guard let entryDate = entry.date else { return false }
            if let start = range.start, entryDate < start { return false }
            if let end = range.end, entryDate > end { return false }
            return true
        }
    }

    @MainActor
    private func fetchEntities() async throws -> [Entity] {
        let descriptor = FetchDescriptor<Entity>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try dataService.modelContext.fetch(descriptor)
    }

    @MainActor
    private func fetchRelationships() async throws -> [EntityRelationship] {
        let descriptor = FetchDescriptor<EntityRelationship>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try dataService.modelContext.fetch(descriptor)
    }

    @MainActor
    private func fetchInsights() async throws -> [Insight] {
        let descriptor = FetchDescriptor<Insight>(sortBy: [SortDescriptor(\.generatedAt, order: .reverse)])
        return try dataService.modelContext.fetch(descriptor)
    }

    @MainActor
    private func fetchConversations() async throws -> [Conversation] {
        let descriptor = FetchDescriptor<Conversation>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        return try dataService.modelContext.fetch(descriptor)
    }

    // MARK: - JSON Export Builder

    private func buildJSONExport(
        entries: [Entry],
        entities: [Entity],
        relationships: [EntityRelationship],
        insights: [Insight],
        conversations: [Conversation],
        options: ExportOptions
    ) throws -> ExportData {
        let metadata = ExportMetadata(
            appVersion: "1.0.0", // TODO: Get from bundle
            dataVersion: 2,
            entryCount: entries.count,
            entityCount: entities.count,
            relationshipCount: relationships.count,
            insightCount: insights.count,
            conversationCount: conversations.count,
            encryptionEnabled: options.includeEncrypted
        )

        let exportedEntries = try entries.map { entry in
            try exportEntry(entry, includeEncrypted: options.includeEncrypted)
        }

        let exportedEntities = entities.map { exportEntity($0) }
        let exportedRelationships = relationships.map { exportRelationship($0) }
        let exportedInsights = insights.map { exportInsight($0) }
        let exportedConversations = conversations.map { exportConversation($0) }

        return ExportData(
            version: "1.0",
            exportedAt: Date(),
            exportMetadata: metadata,
            entries: exportedEntries,
            entities: exportedEntities,
            relationships: exportedRelationships,
            insights: exportedInsights,
            conversations: exportedConversations
        )
    }

    private func exportEntry(_ entry: Entry, includeEncrypted: Bool) throws -> ExportedEntry {
        let content: String
        let isEncrypted: Bool

        if includeEncrypted && entry.isEncrypted {
            // Export encrypted content (the computed property decrypts automatically, so we need to re-encrypt)
            let encryptedData = try encryptionService.encrypt(entry.content)
            content = encryptedData.base64EncodedString()
            isEncrypted = true
        } else {
            // Export as plaintext (computed property handles decryption automatically)
            content = entry.content
            isEncrypted = false
        }

        return ExportedEntry(
            id: entry.id,
            content: content,
            isEncrypted: isEncrypted,
            date: entry.date,
            createdAt: entry.createdAt,
            updatedAt: entry.updatedAt,
            dataVersion: entry.dataVersion,
            kgTracking: ExportedKGTracking(
                isEntitiesExtracted: entry.isEntitiesExtracted,
                entitiesExtractedAt: entry.entitiesExtractedAt,
                entitiesExtractionModel: entry.entitiesExtractionModel,
                isRelationshipsDiscovered: entry.isRelationshipsDiscovered,
                relationshipsDiscoveredAt: entry.relationshipsDiscoveredAt,
                relationshipsDiscoveryModel: entry.relationshipsDiscoveryModel
            ),
            entityIds: entry.entities.map { $0.id },
            relationshipIds: entry.relationships.map { $0.id },
            analysisIds: entry.analyses.map { $0.id }
        )
    }

    private func exportEntity(_ entity: Entity) -> ExportedEntity {
        // Convert metadata [String: Any]? to [String: String]?
        let metadata: [String: String]? = entity.getMetadata()?.compactMapValues { value in
            return String(describing: value)
        }

        return ExportedEntity(
            id: entity.id,
            type: entity.type.rawValue,
            value: entity.value,
            confidence: entity.confidence,
            aliases: entity.aliases,
            metadata: metadata,
            createdAt: entity.createdAt,
            updatedAt: entity.updatedAt,
            entryIds: entity.entries.map { $0.id },
            conversationIds: entity.conversations.map { $0.id }
        )
    }

    private func exportRelationship(_ relationship: EntityRelationship) -> ExportedRelationship {
        ExportedRelationship(
            id: relationship.id,
            type: relationship.type.rawValue,
            fromEntityId: relationship.fromEntity.id,
            toEntityId: relationship.toEntity.id,
            confidence: relationship.confidence,
            evidence: relationship.evidence,
            createdAt: relationship.createdAt,
            sourceEntryId: relationship.sourceEntry?.id
        )
    }

    private func exportInsight(_ insight: Insight) -> ExportedInsight {
        ExportedInsight(
            id: insight.id,
            type: insight.type.rawValue,
            title: insight.title,
            description: insight.insightDescription,
            confidence: insight.confidence,
            generatedAt: insight.generatedAt,
            timeframe: insight.timeframe.rawValue,
            relatedEntityIds: insight.relatedEntityIds,
            relatedEntryIds: insight.relatedEntryIds,
            evidence: insight.evidence,
            isRead: insight.isRead,
            isStarred: insight.isStarred
        )
    }

    private func exportConversation(_ conversation: Conversation) -> ExportedConversation {
        let contextNoteIds: [UUID]
        if let contextJson = conversation.contextNoteIds,
           let data = contextJson.data(using: .utf8),
           let ids = try? JSONDecoder().decode([UUID].self, from: data) {
            contextNoteIds = ids
        } else {
            contextNoteIds = []
        }

        return ExportedConversation(
            id: conversation.id,
            title: conversation.title,
            createdAt: conversation.createdAt,
            updatedAt: conversation.updatedAt,
            hasKnowledgeGraph: conversation.hasKnowledgeGraph,
            associatedDate: conversation.associatedDate,
            contextNoteIds: contextNoteIds,
            modelIdentifier: conversation.modelIdentifier,
            messages: conversation.messages.map { exportMessage($0) },
            entityIds: conversation.extractedEntities.map { $0.id }
        )
    }

    private func exportMessage(_ message: ChatMessage) -> ExportedMessage {
        ExportedMessage(
            id: message.id,
            content: message.content,
            isFromUser: message.isFromUser,
            timestamp: message.timestamp,
            contextData: message.contextData,
            isStreaming: message.isStreaming,
            isError: message.isError
        )
    }

    // MARK: - Markdown Export Builder

    private func buildMarkdownExport(
        entries: [Entry],
        entities: [Entity],
        insights: [Insight]
    ) throws -> String {
        var markdown = "# Kioku Journal Export\n\n"

        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short

        markdown += "**Exported**: \(dateFormatter.string(from: Date()))\n"
        markdown += "**Entries**: \(entries.count) | **Entities**: \(entities.count) | **Insights**: \(insights.count)\n\n"
        markdown += "---\n\n"

        // Group entries by month
        let groupedByMonth = Dictionary(grouping: entries) { entry -> String in
            guard let date = entry.date else { return "Unknown" }
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            return formatter.string(from: date)
        }

        let sortedMonths = groupedByMonth.keys.sorted { month1, month2 in
            let formatter = DateFormatter()
            formatter.dateFormat = "MMMM yyyy"
            guard let date1 = formatter.date(from: month1),
                  let date2 = formatter.date(from: month2) else { return false }
            return date1 > date2
        }

        for month in sortedMonths {
            markdown += "## \(month)\n\n"

            let monthEntries = groupedByMonth[month]?.sorted {
                guard let date1 = $0.date, let date2 = $1.date else { return false }
                return date1 > date2
            } ?? []

            for entry in monthEntries {
                markdown += try formatEntryMarkdown(entry, entities: entities, insights: insights)
                markdown += "\n---\n\n"
            }
        }

        return markdown
    }

    private func formatEntryMarkdown(
        _ entry: Entry,
        entities: [Entity],
        insights: [Insight]
    ) throws -> String {
        var markdown = ""

        // Date heading
        if let date = entry.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMMM d, yyyy"
            markdown += "### \(formatter.string(from: date))\n\n"
        }

        // Content (automatically decrypted by Entry's computed property)
        markdown += "\(entry.content)\n\n"

        // Entities
        if !entry.entities.isEmpty {
            let entityGroups = Dictionary(grouping: entry.entities) { $0.type }
            let entityStrings = entityGroups.map { type, entities in
                entities.sorted { $0.confidence > $1.confidence }
                    .prefix(5)
                    .map { $0.value }
                    .joined(separator: ", ")
            }
            markdown += "**Entities**: \(entityStrings.joined(separator: " | "))\n\n"
        }

        // Top insights
        let relatedInsights = insights.filter { insight in
            insight.relatedEntryIds.contains(entry.id)
        }.sorted { $0.confidence > $1.confidence }.prefix(3)

        if !relatedInsights.isEmpty {
            markdown += "**Insights**:\n"
            for insight in relatedInsights {
                markdown += "- \(insight.title) (\(insight.type.rawValue.capitalized), Confidence: \(Int(insight.confidence * 100))%)\n"
            }
            markdown += "\n"
        }

        return markdown
    }
}

// MARK: - Export Data Structures

struct ExportData: Codable {
    let version: String
    let exportedAt: Date
    let exportMetadata: ExportMetadata
    let entries: [ExportedEntry]
    let entities: [ExportedEntity]
    let relationships: [ExportedRelationship]
    let insights: [ExportedInsight]
    let conversations: [ExportedConversation]

    enum CodingKeys: String, CodingKey {
        case version
        case exportedAt = "exported_at"
        case exportMetadata = "export_metadata"
        case entries, entities, relationships, insights, conversations
    }
}

struct ExportMetadata: Codable {
    let appVersion: String
    let dataVersion: Int
    let entryCount: Int
    let entityCount: Int
    let relationshipCount: Int
    let insightCount: Int
    let conversationCount: Int
    let encryptionEnabled: Bool

    enum CodingKeys: String, CodingKey {
        case appVersion = "app_version"
        case dataVersion = "data_version"
        case entryCount = "entry_count"
        case entityCount = "entity_count"
        case relationshipCount = "relationship_count"
        case insightCount = "insight_count"
        case conversationCount = "conversation_count"
        case encryptionEnabled = "encryption_enabled"
    }
}

struct ExportedEntry: Codable {
    let id: UUID
    let content: String
    let isEncrypted: Bool
    let date: Date?
    let createdAt: Date
    let updatedAt: Date
    let dataVersion: Int
    let kgTracking: ExportedKGTracking
    let entityIds: [UUID]
    let relationshipIds: [UUID]
    let analysisIds: [UUID]

    enum CodingKeys: String, CodingKey {
        case id, content
        case isEncrypted = "is_encrypted"
        case date
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case dataVersion = "data_version"
        case kgTracking = "kg_tracking"
        case entityIds = "entity_ids"
        case relationshipIds = "relationship_ids"
        case analysisIds = "analysis_ids"
    }
}

struct ExportedKGTracking: Codable {
    let isEntitiesExtracted: Bool
    let entitiesExtractedAt: Date?
    let entitiesExtractionModel: String?
    let isRelationshipsDiscovered: Bool
    let relationshipsDiscoveredAt: Date?
    let relationshipsDiscoveryModel: String?

    enum CodingKeys: String, CodingKey {
        case isEntitiesExtracted = "is_entities_extracted"
        case entitiesExtractedAt = "entities_extracted_at"
        case entitiesExtractionModel = "entities_extraction_model"
        case isRelationshipsDiscovered = "is_relationships_discovered"
        case relationshipsDiscoveredAt = "relationships_discovered_at"
        case relationshipsDiscoveryModel = "relationships_discovery_model"
    }
}

struct ExportedEntity: Codable {
    let id: UUID
    let type: String
    let value: String
    let confidence: Double
    let aliases: [String]
    let metadata: [String: String]?
    let createdAt: Date
    let updatedAt: Date
    let entryIds: [UUID]
    let conversationIds: [UUID]

    enum CodingKeys: String, CodingKey {
        case id, type, value, confidence, aliases, metadata
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case entryIds = "entry_ids"
        case conversationIds = "conversation_ids"
    }
}

struct ExportedRelationship: Codable {
    let id: UUID
    let type: String
    let fromEntityId: UUID
    let toEntityId: UUID
    let confidence: Double
    let evidence: String?
    let createdAt: Date
    let sourceEntryId: UUID?

    enum CodingKeys: String, CodingKey {
        case id, type
        case fromEntityId = "from_entity_id"
        case toEntityId = "to_entity_id"
        case confidence, evidence
        case createdAt = "created_at"
        case sourceEntryId = "source_entry_id"
    }
}

struct ExportedInsight: Codable {
    let id: UUID
    let type: String
    let title: String
    let description: String
    let confidence: Double
    let generatedAt: Date
    let timeframe: String
    let relatedEntityIds: [UUID]
    let relatedEntryIds: [UUID]
    let evidence: String?
    let isRead: Bool
    let isStarred: Bool

    enum CodingKeys: String, CodingKey {
        case id, type, title, description, confidence
        case generatedAt = "generated_at"
        case timeframe
        case relatedEntityIds = "related_entity_ids"
        case relatedEntryIds = "related_entry_ids"
        case evidence
        case isRead = "is_read"
        case isStarred = "is_starred"
    }
}

struct ExportedConversation: Codable {
    let id: UUID
    let title: String
    let createdAt: Date
    let updatedAt: Date
    let hasKnowledgeGraph: Bool
    let associatedDate: Date?
    let contextNoteIds: [UUID]
    let modelIdentifier: String?
    let messages: [ExportedMessage]
    let entityIds: [UUID]

    enum CodingKeys: String, CodingKey {
        case id, title
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case hasKnowledgeGraph = "has_knowledge_graph"
        case associatedDate = "associated_date"
        case contextNoteIds = "context_note_ids"
        case modelIdentifier = "model_identifier"
        case messages
        case entityIds = "entity_ids"
    }
}

struct ExportedMessage: Codable {
    let id: UUID
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let contextData: String?
    let isStreaming: Bool
    let isError: Bool

    enum CodingKeys: String, CodingKey {
        case id, content
        case isFromUser = "is_from_user"
        case timestamp
        case contextData = "context_data"
        case isStreaming = "is_streaming"
        case isError = "is_error"
    }
}
