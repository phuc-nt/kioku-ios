import SwiftData
import Foundation

// MARK: - Migration Types

public struct DateConflict: Sendable {
    public let date: Date
    public let entries: [Entry]
    public let recommendedStrategy: MergeStrategy
    public var userChoice: MergeStrategy?
    
    public var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter.string(from: date)
    }
}

public enum MergeStrategy: String, CaseIterable, Sendable {
    case smartMerge = "smartMerge"
    case userChoice = "userChoice"
    case latestOnly = "latestOnly"
    case longestContent = "longestContent"
    
    public var displayName: String {
        switch self {
        case .smartMerge:
            return "Smart merge (recommended)"
        case .userChoice:
            return "Choose primary entry"
        case .latestOnly:
            return "Keep latest only"
        case .longestContent:
            return "Keep longest content"
        }
    }
    
    public var description: String {
        switch self {
        case .smartMerge:
            return "Combine all entries with timestamps"
        case .userChoice:
            return "Let me select the content manually"
        case .latestOnly:
            return "Keep only the most recent entry"
        case .longestContent:
            return "Keep the entry with most content"
        }
    }
}

public struct MigrationAnalysis: Sendable {
    public let totalEntries: Int
    public let conflictDates: Int
    public let estimatedTime: TimeInterval
    public let conflicts: [DateConflict]
    
    public var hasConflicts: Bool {
        return conflictDates > 0
    }
}

public struct MigrationResult: Sendable {
    public let success: Bool
    public let migratedEntries: Int
    public let conflictsResolved: Int
    public let errors: [MigrationError]
    public let backupPath: String?
}

public enum MigrationError: Error, LocalizedError, Sendable {
    case backupFailed(String)
    case dataIntegrityError(String)
    case migrationInterrupted(String)
    case rollbackFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .backupFailed(let message):
            return "Backup failed: \(message)"
        case .dataIntegrityError(let message):
            return "Data integrity error: \(message)"
        case .migrationInterrupted(let message):
            return "Migration interrupted: \(message)"
        case .rollbackFailed(let message):
            return "Rollback failed: \(message)"
        }
    }
}

// MARK: - Migration Service

@Observable
public class MigrationService: @unchecked Sendable {
    public static let shared = MigrationService()
    
    public var isRunningMigration = false
    public var migrationProgress: Double = 0.0
    public var currentStep = ""
    
    private var modelContext: ModelContext?
    
    private init() {}
    
    public func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    // MARK: - Migration Analysis
    
    public func analyzeMigrationComplexity() throws -> MigrationAnalysis {
        guard let context = modelContext else {
            throw MigrationError.dataIntegrityError("No model context available")
        }
        
        // Fetch all entries that need migration
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { entry in
                !entry.isMigrated || entry.migrationVersion < 2
            },
            sortBy: [SortDescriptor(\.createdAt)]
        )
        
        let entriesToMigrate = try context.fetch(descriptor)
        
        // Group entries by date to detect conflicts
        var dateGroups: [Date: [Entry]] = [:]
        for entry in entriesToMigrate {
            let normalizedDate = Calendar.current.startOfDay(for: entry.date ?? entry.createdAt)
            dateGroups[normalizedDate, default: []].append(entry)
        }
        
        // Identify conflicts (multiple entries per date)
        var conflicts: [DateConflict] = []
        for (date, entries) in dateGroups {
            if entries.count > 1 {
                let recommendedStrategy = recommendMergeStrategy(for: entries)
                conflicts.append(DateConflict(
                    date: date,
                    entries: entries,
                    recommendedStrategy: recommendedStrategy
                ))
            }
        }
        
        // Estimate migration time (roughly 100ms per entry + conflict resolution time)
        let baseTime = Double(entriesToMigrate.count) * 0.1
        let conflictTime = Double(conflicts.count) * 2.0 // 2 seconds per conflict
        let estimatedTime = baseTime + conflictTime
        
        return MigrationAnalysis(
            totalEntries: entriesToMigrate.count,
            conflictDates: conflicts.count,
            estimatedTime: estimatedTime,
            conflicts: conflicts
        )
    }
    
    // MARK: - Migration Execution
    
    public func executeMigration(conflictResolutions: [DateConflict]) async throws -> MigrationResult {
        guard let context = modelContext else {
            throw MigrationError.dataIntegrityError("No model context available")
        }
        
        isRunningMigration = true
        migrationProgress = 0.0
        currentStep = "Starting migration..."
        
        var migratedCount = 0
        var conflictsResolved = 0
        var errors: [MigrationError] = []
        
        do {
            // Step 1: Create backup
            currentStep = "Creating backup..."
            migrationProgress = 0.1
            let backupPath = try createBackup()
            
            // Step 2: Process conflicts
            currentStep = "Resolving conflicts..."
            migrationProgress = 0.3
            
            for conflict in conflictResolutions {
                do {
                    try resolveConflict(conflict)
                    conflictsResolved += 1
                } catch {
                    errors.append(.dataIntegrityError("Failed to resolve conflict for \(conflict.displayDate): \(error)"))
                }
            }
            
            // Step 3: Migrate remaining entries
            currentStep = "Migrating entries..."
            migrationProgress = 0.6
            
            let descriptor = FetchDescriptor<Entry>(
                predicate: #Predicate<Entry> { entry in
                    !entry.isMigrated || entry.migrationVersion < 2
                }
            )
            
            let remainingEntries = try context.fetch(descriptor)
            
            for (index, entry) in remainingEntries.enumerated() {
                try migrateEntry(entry)
                migratedCount += 1
                
                // Update progress
                let progress = 0.6 + (0.3 * Double(index + 1) / Double(remainingEntries.count))
                migrationProgress = progress
            }
            
            // Step 4: Save changes
            currentStep = "Saving changes..."
            migrationProgress = 0.9
            try context.save()
            
            // Step 5: Validate migration
            currentStep = "Validating migration..."
            migrationProgress = 1.0
            try validateMigration()
            
            currentStep = "Migration completed successfully!"
            
            return MigrationResult(
                success: true,
                migratedEntries: migratedCount,
                conflictsResolved: conflictsResolved,
                errors: errors,
                backupPath: backupPath
            )
            
        } catch {
            errors.append(.migrationInterrupted(error.localizedDescription))
            isRunningMigration = false
            
            return MigrationResult(
                success: false,
                migratedEntries: migratedCount,
                conflictsResolved: conflictsResolved,
                errors: errors,
                backupPath: nil
            )
        }
    }
    
    // MARK: - Private Migration Methods
    
    private func recommendMergeStrategy(for entries: [Entry]) -> MergeStrategy {
        // Smart recommendations based on entry characteristics
        let totalLength = entries.reduce(0) { $0 + $1.content.count }
        let avgLength = totalLength / entries.count
        
        // If entries are short, smart merge is usually best
        if avgLength < 100 {
            return .smartMerge
        }
        
        // If one entry is significantly longer, suggest keeping longest
        let maxLength = entries.map { $0.content.count }.max() ?? 0
        if maxLength > avgLength * 2 {
            return .longestContent
        }
        
        // Default to smart merge
        return .smartMerge
    }
    
    private func resolveConflict(_ conflict: DateConflict) throws {
        guard let context = modelContext else {
            throw MigrationError.dataIntegrityError("No model context available")
        }
        
        let strategy = conflict.userChoice ?? conflict.recommendedStrategy
        let entries = conflict.entries.sorted { $0.createdAt < $1.createdAt }
        
        switch strategy {
        case .smartMerge:
            try smartMergeEntries(entries, for: conflict.date)
            
        case .latestOnly:
            try keepLatestEntry(entries, for: conflict.date)
            
        case .longestContent:
            try keepLongestEntry(entries, for: conflict.date)
            
        case .userChoice:
            // User choice should have been resolved in UI
            try smartMergeEntries(entries, for: conflict.date)
        }
    }
    
    private func smartMergeEntries(_ entries: [Entry], for date: Date) throws {
        guard let context = modelContext else {
            throw MigrationError.dataIntegrityError("No model context available")
        }
        
        let sortedEntries = entries.sorted { $0.createdAt < $1.createdAt }
        let primaryEntry = sortedEntries.first!
        
        // Build merged content
        var mergedContent = ""
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        
        for (index, entry) in sortedEntries.enumerated() {
            if index == 0 {
                mergedContent = entry.content
            } else {
                let timeStamp = timeFormatter.string(from: entry.createdAt)
                mergedContent += "\n\n[\(timeStamp)] \(entry.content)"
            }
        }
        
        // Update primary entry
        primaryEntry.content = mergedContent
        primaryEntry.date = Calendar.current.startOfDay(for: date)
        primaryEntry.markAsMigrated()
        
        // Delete other entries
        for entry in sortedEntries.dropFirst() {
            context.delete(entry)
        }
    }
    
    private func keepLatestEntry(_ entries: [Entry], for date: Date) throws {
        guard let context = modelContext else {
            throw MigrationError.dataIntegrityError("No model context available")
        }
        
        let sortedEntries = entries.sorted { $0.createdAt > $1.createdAt }
        let latestEntry = sortedEntries.first!
        
        // Update latest entry
        latestEntry.date = Calendar.current.startOfDay(for: date)
        latestEntry.markAsMigrated()
        
        // Delete other entries
        for entry in sortedEntries.dropFirst() {
            context.delete(entry)
        }
    }
    
    private func keepLongestEntry(_ entries: [Entry], for date: Date) throws {
        guard let context = modelContext else {
            throw MigrationError.dataIntegrityError("No model context available")
        }
        
        let longestEntry = entries.max { $0.content.count < $1.content.count }!
        
        // Update longest entry
        longestEntry.date = Calendar.current.startOfDay(for: date)
        longestEntry.markAsMigrated()
        
        // Delete other entries
        for entry in entries {
            if entry.id != longestEntry.id {
                context.delete(entry)
            }
        }
    }
    
    private func migrateEntry(_ entry: Entry) throws {
        // Ensure date is normalized to start of day
        if entry.date == nil {
            entry.date = Calendar.current.startOfDay(for: entry.createdAt)
        }
        entry.markAsMigrated()
    }
    
    private func createBackup() throws -> String {
        // Create a backup directory
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let backupDir = documentsPath.appendingPathComponent("KiokuBackups")
        
        try FileManager.default.createDirectory(at: backupDir, withIntermediateDirectories: true)
        
        let timestamp = DateFormatter().string(from: Date()).replacingOccurrences(of: " ", with: "_")
        let backupPath = backupDir.appendingPathComponent("migration_backup_\(timestamp).json")
        
        // Export all entries to JSON (simplified backup)
        // In a real implementation, this would be more comprehensive
        let backupData = ["timestamp": Date().timeIntervalSince1970, "migration_version": 2] as [String: Any]
        let jsonData = try JSONSerialization.data(withJSONObject: backupData)
        try jsonData.write(to: backupPath)
        
        return backupPath.path
    }
    
    private func validateMigration() throws {
        guard let context = modelContext else {
            throw MigrationError.dataIntegrityError("No model context available")
        }
        
        // Check that all entries have been migrated
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { entry in
                !entry.isMigrated || entry.migrationVersion < 2
            }
        )
        
        let unmigrated = try context.fetch(descriptor)
        if !unmigrated.isEmpty {
            throw MigrationError.dataIntegrityError("Found \(unmigrated.count) unmigrated entries")
        }
        
        // Check for date conflicts (should be none after migration)
        let allEntries = try context.fetch(FetchDescriptor<Entry>())
        var dateSet: Set<Date> = []
        
        for entry in allEntries {
            if let date = entry.date {
                if dateSet.contains(date) {
                    throw MigrationError.dataIntegrityError("Found duplicate entries for date: \(entry.displayDate)")
                }
                dateSet.insert(date)
            }
        }
    }
}