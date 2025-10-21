import Foundation
import SwiftData

// MARK: - Import Errors

public enum ImportError: Error, LocalizedError {
    case unsupportedVersion(String)
    case invalidFormat(String)
    case missingRequiredField(String)
    case invalidUUID(String)
    case duplicateEntry(UUID)
    case referentialIntegrityViolation(String)
    case decryptionFailed(String)

    public var errorDescription: String? {
        switch self {
        case .unsupportedVersion(let version): return "Unsupported version: \(version)"
        case .invalidFormat(let msg): return "Invalid format: \(msg)"
        case .missingRequiredField(let field): return "Missing required field: \(field)"
        case .invalidUUID(let uuid): return "Invalid UUID: \(uuid)"
        case .duplicateEntry(let id): return "Duplicate entry: \(id)"
        case .referentialIntegrityViolation(let msg): return "Referential integrity violation: \(msg)"
        case .decryptionFailed(let msg): return "Decryption failed: \(msg)"
        }
    }
}

// MARK: - Conflict Resolution

public enum ConflictStrategy {
    case skipDuplicates // Skip if ID exists
    case merge // Merge by comparing updated_at
    case replace // Replace existing with imported
}

// MARK: - Import Results

public struct ImportValidationResult: Sendable {
    public let isValid: Bool
    public let errors: [ImportError]
    public let warnings: [String]
    public let summary: ImportSummary
}

public struct ImportSummary: Sendable {
    public let entryCount: Int
    public let entityCount: Int
    public let relationshipCount: Int
    public let insightCount: Int
    public let conversationCount: Int
}

public struct ImportResult: Sendable {
    public let success: Bool
    public let summary: ImportSummary
    public let skipped: Int
    public let errors: [ImportError]
}

// MARK: - Import Service

@Observable
public class ImportService {
    private let dataService: DataService
    private let encryptionService: EncryptionService

    public init(dataService: DataService, encryptionService: EncryptionService) {
        self.dataService = dataService
        self.encryptionService = encryptionService
    }

    // MARK: - Validation

    public func validateImport(data: Data) throws -> ImportValidationResult {
        var errors: [ImportError] = []
        var warnings: [String] = []

        // Parse JSON
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        let exportData: ExportData
        do {
            exportData = try decoder.decode(ExportData.self, from: data)
        } catch {
            throw ImportError.invalidFormat("Failed to parse JSON: \(error.localizedDescription)")
        }

        // Version check
        guard exportData.version == "1.0" else {
            errors.append(.unsupportedVersion(exportData.version))
            return ImportValidationResult(
                isValid: false,
                errors: errors,
                warnings: warnings,
                summary: ImportSummary(
                    entryCount: 0,
                    entityCount: 0,
                    relationshipCount: 0,
                    insightCount: 0,
                    conversationCount: 0
                )
            )
        }

        // Data integrity checks
        let entityIds = Set(exportData.entities.map { $0.id })
        let entryIds = Set(exportData.entries.map { $0.id })

        // Check entity references in entries
        for entry in exportData.entries {
            for entityId in entry.entityIds {
                if !entityIds.contains(entityId) {
                    warnings.append("Entry \(entry.id) references missing entity \(entityId)")
                }
            }
        }

        // Check relationships reference valid entities
        for relationship in exportData.relationships {
            if !entityIds.contains(relationship.fromEntityId) {
                errors.append(.referentialIntegrityViolation("Relationship \(relationship.id) references missing fromEntity \(relationship.fromEntityId)"))
            }
            if !entityIds.contains(relationship.toEntityId) {
                errors.append(.referentialIntegrityViolation("Relationship \(relationship.id) references missing toEntity \(relationship.toEntityId)"))
            }
            if let sourceEntryId = relationship.sourceEntryId, !entryIds.contains(sourceEntryId) {
                warnings.append("Relationship \(relationship.id) references missing sourceEntry \(sourceEntryId)")
            }
        }

        // Check insights reference valid entities/entries
        for insight in exportData.insights {
            for entityId in insight.relatedEntityIds {
                if !entityIds.contains(entityId) {
                    warnings.append("Insight \(insight.id) references missing entity \(entityId)")
                }
            }
            for entryId in insight.relatedEntryIds {
                if !entryIds.contains(entryId) {
                    warnings.append("Insight \(insight.id) references missing entry \(entryId)")
                }
            }
        }

        // Check conversations reference valid entities
        for conversation in exportData.conversations {
            for entityId in conversation.entityIds {
                if !entityIds.contains(entityId) {
                    warnings.append("Conversation \(conversation.id) references missing entity \(entityId)")
                }
            }
        }

        let summary = ImportSummary(
            entryCount: exportData.entries.count,
            entityCount: exportData.entities.count,
            relationshipCount: exportData.relationships.count,
            insightCount: exportData.insights.count,
            conversationCount: exportData.conversations.count
        )

        return ImportValidationResult(
            isValid: errors.isEmpty,
            errors: errors,
            warnings: warnings,
            summary: summary
        )
    }

    // MARK: - Import

    public func importFromJSON(
        data: Data,
        conflictStrategy: ConflictStrategy = .skipDuplicates,
        progress: @escaping @Sendable (Double, String) -> Void = { _, _ in }
    ) async throws -> ImportResult {
        progress(0.0, "Validating import...")

        // Validate first
        let validation = try validateImport(data: data)
        guard validation.isValid else {
            throw validation.errors.first ?? ImportError.invalidFormat("Validation failed")
        }

        // Parse JSON
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let exportData = try decoder.decode(ExportData.self, from: data)

        var skippedCount = 0
        var errors: [ImportError] = []

        // Import in order: Entities → Entries → Relationships → Insights → Conversations
        progress(0.1, "Importing entities...")
        let (importedEntities, skippedEntities) = try await importEntities(
            exportData.entities,
            strategy: conflictStrategy
        )
        skippedCount += skippedEntities

        progress(0.3, "Importing entries...")
        let (importedEntries, skippedEntries) = try await importEntries(
            exportData.entries,
            entities: importedEntities,
            strategy: conflictStrategy
        )
        skippedCount += skippedEntries

        progress(0.5, "Importing relationships...")
        let (importedRelationships, skippedRelationships) = try await importRelationships(
            exportData.relationships,
            entities: importedEntities,
            entries: importedEntries,
            strategy: conflictStrategy
        )
        skippedCount += skippedRelationships

        progress(0.7, "Importing insights...")
        let (importedInsights, skippedInsights) = try await importInsights(
            exportData.insights,
            strategy: conflictStrategy
        )
        skippedCount += skippedInsights

        progress(0.9, "Importing conversations...")
        let (importedConversations, skippedConversations) = try await importConversations(
            exportData.conversations,
            entities: importedEntities,
            strategy: conflictStrategy
        )
        skippedCount += skippedConversations

        // Save context
        try dataService.modelContext.save()

        progress(1.0, "Import complete!")

        return ImportResult(
            success: true,
            summary: ImportSummary(
                entryCount: importedEntries,
                entityCount: importedEntities,
                relationshipCount: importedRelationships,
                insightCount: importedInsights,
                conversationCount: importedConversations
            ),
            skipped: skippedCount,
            errors: errors
        )
    }

    // MARK: - Private Import Methods

    private func importEntities(
        _ exportedEntities: [ExportedEntity],
        strategy: ConflictStrategy
    ) async throws -> (imported: Int, skipped: Int) {
        var imported = 0
        var skipped = 0

        for exported in exportedEntities {
            // Check if exists
            let descriptor = FetchDescriptor<Entity>(
                predicate: #Predicate { $0.id == exported.id }
            )
            let existing = try dataService.modelContext.fetch(descriptor).first

            if let existing = existing {
                switch strategy {
                case .skipDuplicates:
                    skipped += 1
                    continue
                case .merge:
                    // Keep newer version
                    if exported.updatedAt > existing.updatedAt {
                        updateEntity(existing, with: exported)
                        imported += 1
                    } else {
                        skipped += 1
                    }
                case .replace:
                    dataService.modelContext.delete(existing)
                    createEntity(from: exported)
                    imported += 1
                }
            } else {
                createEntity(from: exported)
                imported += 1
            }
        }

        return (imported, skipped)
    }

    private func createEntity(from exported: ExportedEntity) {
        let entity = Entity(
            type: EntityType(rawValue: exported.type) ?? .topics, // Default to topics if unknown
            value: exported.value,
            confidence: exported.confidence
        )
        entity.id = exported.id
        entity.aliases = exported.aliases
        if let metadata = exported.metadata {
            // Convert [String: String] to [String: Any] for updateMetadata
            try? entity.updateMetadata(metadata as [String: Any])
        }
        entity.createdAt = exported.createdAt
        entity.updatedAt = exported.updatedAt

        dataService.modelContext.insert(entity)
    }

    private func updateEntity(_ entity: Entity, with exported: ExportedEntity) {
        entity.type = EntityType(rawValue: exported.type) ?? .topics
        entity.value = exported.value
        entity.confidence = exported.confidence
        entity.aliases = exported.aliases
        if let metadata = exported.metadata {
            try? entity.updateMetadata(metadata as [String: Any])
        }
        entity.updatedAt = exported.updatedAt
    }

    private func importEntries(
        _ exportedEntries: [ExportedEntry],
        entities: Int,
        strategy: ConflictStrategy
    ) async throws -> (imported: Int, skipped: Int) {
        var imported = 0
        var skipped = 0

        for exported in exportedEntries {
            // Check if exists
            let descriptor = FetchDescriptor<Entry>(
                predicate: #Predicate { $0.id == exported.id }
            )
            let existing = try dataService.modelContext.fetch(descriptor).first

            if let existing = existing {
                switch strategy {
                case .skipDuplicates:
                    skipped += 1
                    continue
                case .merge:
                    if exported.updatedAt > existing.updatedAt {
                        try updateEntry(existing, with: exported)
                        imported += 1
                    } else {
                        skipped += 1
                    }
                case .replace:
                    dataService.modelContext.delete(existing)
                    try createEntry(from: exported)
                    imported += 1
                }
            } else {
                try createEntry(from: exported)
                imported += 1
            }
        }

        return (imported, skipped)
    }

    private func createEntry(from exported: ExportedEntry) throws {
        // Handle encrypted content import
        let content: String
        if exported.isEncrypted {
            // Decode base64 encrypted content and decrypt
            guard let encryptedData = Data(base64Encoded: exported.content) else {
                throw ImportError.invalidFormat("Invalid base64 encrypted content")
            }
            content = try encryptionService.decrypt(encryptedData)
        } else {
            content = exported.content
        }

        let entry = Entry(content: content, date: exported.date)
        entry.id = exported.id
        entry.createdAt = exported.createdAt
        entry.updatedAt = exported.updatedAt
        entry.dataVersion = exported.dataVersion

        // KG tracking
        entry.isEntitiesExtracted = exported.kgTracking.isEntitiesExtracted
        entry.entitiesExtractedAt = exported.kgTracking.entitiesExtractedAt
        entry.entitiesExtractionModel = exported.kgTracking.entitiesExtractionModel
        entry.isRelationshipsDiscovered = exported.kgTracking.isRelationshipsDiscovered
        entry.relationshipsDiscoveredAt = exported.kgTracking.relationshipsDiscoveredAt
        entry.relationshipsDiscoveryModel = exported.kgTracking.relationshipsDiscoveryModel

        dataService.modelContext.insert(entry)

        // Link entities (after all entities are imported)
        linkEntryEntities(entry, entityIds: exported.entityIds)
    }

    private func updateEntry(_ entry: Entry, with exported: ExportedEntry) throws {
        // Handle encrypted content import
        if exported.isEncrypted {
            guard let encryptedData = Data(base64Encoded: exported.content) else {
                throw ImportError.invalidFormat("Invalid base64 encrypted content")
            }
            entry.content = try encryptionService.decrypt(encryptedData)
        } else {
            entry.content = exported.content
        }
        entry.date = exported.date
        entry.updatedAt = exported.updatedAt
        entry.dataVersion = exported.dataVersion

        entry.isEntitiesExtracted = exported.kgTracking.isEntitiesExtracted
        entry.entitiesExtractedAt = exported.kgTracking.entitiesExtractedAt
        entry.entitiesExtractionModel = exported.kgTracking.entitiesExtractionModel
        entry.isRelationshipsDiscovered = exported.kgTracking.isRelationshipsDiscovered
        entry.relationshipsDiscoveredAt = exported.kgTracking.relationshipsDiscoveredAt
        entry.relationshipsDiscoveryModel = exported.kgTracking.relationshipsDiscoveryModel

        linkEntryEntities(entry, entityIds: exported.entityIds)
    }

    private func linkEntryEntities(_ entry: Entry, entityIds: [UUID]) {
        for entityId in entityIds {
            let descriptor = FetchDescriptor<Entity>(
                predicate: #Predicate { $0.id == entityId }
            )
            if let entity = try? dataService.modelContext.fetch(descriptor).first {
                entry.entities.append(entity)
            }
        }
    }

    private func importRelationships(
        _ exportedRelationships: [ExportedRelationship],
        entities: Int,
        entries: Int,
        strategy: ConflictStrategy
    ) async throws -> (imported: Int, skipped: Int) {
        var imported = 0
        var skipped = 0

        for exported in exportedRelationships {
            // Check if exists
            let descriptor = FetchDescriptor<EntityRelationship>(
                predicate: #Predicate { $0.id == exported.id }
            )
            let existing = try dataService.modelContext.fetch(descriptor).first

            if let existing = existing {
                switch strategy {
                case .skipDuplicates:
                    skipped += 1
                    continue
                case .merge, .replace:
                    dataService.modelContext.delete(existing)
                    try createRelationship(from: exported)
                    imported += 1
                }
            } else {
                try createRelationship(from: exported)
                imported += 1
            }
        }

        return (imported, skipped)
    }

    private func createRelationship(from exported: ExportedRelationship) throws {
        // Fetch entities
        let fromDescriptor = FetchDescriptor<Entity>(
            predicate: #Predicate { $0.id == exported.fromEntityId }
        )
        guard let fromEntity = try dataService.modelContext.fetch(fromDescriptor).first else {
            throw ImportError.referentialIntegrityViolation("Missing fromEntity \(exported.fromEntityId)")
        }

        let toDescriptor = FetchDescriptor<Entity>(
            predicate: #Predicate { $0.id == exported.toEntityId }
        )
        guard let toEntity = try dataService.modelContext.fetch(toDescriptor).first else {
            throw ImportError.referentialIntegrityViolation("Missing toEntity \(exported.toEntityId)")
        }

        let relationship = EntityRelationship(
            from: fromEntity,
            to: toEntity,
            type: RelationshipType(rawValue: exported.type) ?? .topical, // Default to topical if unknown
            confidence: exported.confidence,
            evidence: exported.evidence ?? ""
        )
        relationship.id = exported.id
        relationship.createdAt = exported.createdAt

        if let sourceEntryId = exported.sourceEntryId {
            let entryDescriptor = FetchDescriptor<Entry>(
                predicate: #Predicate { $0.id == sourceEntryId }
            )
            relationship.sourceEntry = try? dataService.modelContext.fetch(entryDescriptor).first
        }

        dataService.modelContext.insert(relationship)
    }

    private func importInsights(
        _ exportedInsights: [ExportedInsight],
        strategy: ConflictStrategy
    ) async throws -> (imported: Int, skipped: Int) {
        var imported = 0
        var skipped = 0

        for exported in exportedInsights {
            let descriptor = FetchDescriptor<Insight>(
                predicate: #Predicate { $0.id == exported.id }
            )
            let existing = try dataService.modelContext.fetch(descriptor).first

            if let existing = existing {
                switch strategy {
                case .skipDuplicates:
                    skipped += 1
                    continue
                case .merge, .replace:
                    dataService.modelContext.delete(existing)
                    createInsight(from: exported)
                    imported += 1
                }
            } else {
                createInsight(from: exported)
                imported += 1
            }
        }

        return (imported, skipped)
    }

    private func createInsight(from exported: ExportedInsight) {
        let insight = Insight(
            type: InsightType(rawValue: exported.type) ?? .frequency,
            title: exported.title,
            description: exported.description,
            confidence: exported.confidence,
            timeframe: TimeframeType(rawValue: exported.timeframe) ?? .weekly,
            relatedEntityIds: exported.relatedEntityIds,
            relatedEntryIds: exported.relatedEntryIds
        )
        insight.id = exported.id
        insight.generatedAt = exported.generatedAt
        insight.evidence = exported.evidence ?? ""
        insight.isRead = exported.isRead
        insight.isStarred = exported.isStarred

        dataService.modelContext.insert(insight)
    }

    private func importConversations(
        _ exportedConversations: [ExportedConversation],
        entities: Int,
        strategy: ConflictStrategy
    ) async throws -> (imported: Int, skipped: Int) {
        var imported = 0
        var skipped = 0

        for exported in exportedConversations {
            let descriptor = FetchDescriptor<Conversation>(
                predicate: #Predicate { $0.id == exported.id }
            )
            let existing = try dataService.modelContext.fetch(descriptor).first

            if let existing = existing {
                switch strategy {
                case .skipDuplicates:
                    skipped += 1
                    continue
                case .merge, .replace:
                    dataService.modelContext.delete(existing)
                    try createConversation(from: exported)
                    imported += 1
                }
            } else {
                try createConversation(from: exported)
                imported += 1
            }
        }

        return (imported, skipped)
    }

    private func createConversation(from exported: ExportedConversation) throws {
        let conversation = Conversation(
            title: exported.title,
            associatedDate: exported.associatedDate
        )
        conversation.id = exported.id
        conversation.createdAt = exported.createdAt
        conversation.updatedAt = exported.updatedAt
        conversation.hasKnowledgeGraph = exported.hasKnowledgeGraph
        conversation.modelIdentifier = exported.modelIdentifier

        // Context note IDs
        if !exported.contextNoteIds.isEmpty {
            let encoder = JSONEncoder()
            if let data = try? encoder.encode(exported.contextNoteIds),
               let json = String(data: data, encoding: .utf8) {
                conversation.contextNoteIds = json
            }
        }

        dataService.modelContext.insert(conversation)

        // Import messages
        for exportedMessage in exported.messages {
            let message = ChatMessage(
                content: exportedMessage.content,
                isFromUser: exportedMessage.isFromUser
            )
            message.id = exportedMessage.id
            message.timestamp = exportedMessage.timestamp
            message.contextData = exportedMessage.contextData
            message.isStreaming = exportedMessage.isStreaming
            message.isError = exportedMessage.isError
            message.conversation = conversation

            dataService.modelContext.insert(message)
        }

        // Link entities
        for entityId in exported.entityIds {
            let entityDescriptor = FetchDescriptor<Entity>(
                predicate: #Predicate { $0.id == entityId }
            )
            if let entity = try? dataService.modelContext.fetch(entityDescriptor).first {
                conversation.extractedEntities.append(entity)
            }
        }
    }
}
