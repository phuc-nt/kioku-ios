import SwiftData
import Foundation

@Model
public final class Entry: @unchecked Sendable {
    public var id: UUID
    private var encryptedContent: Data?
    private var _plaintextContent: String? // Legacy unencrypted content
    public var createdAt: Date
    public var updatedAt: Date
    
    // MARK: - Calendar Architecture Fields
    public var date: Date? // Normalized date (start of day) for calendar navigation
    
    // Version tracking for future use
    public var dataVersion: Int = 2 // Current calendar-based architecture
    
    // MARK: - Relationships
    @Relationship(deleteRule: .cascade, inverse: \AIAnalysis.entry)
    public var analyses: [AIAnalysis] = []
    
    // Computed property for transparent encryption/decryption
    public var content: String {
        get {
            // Try encrypted content first
            if let encryptedData = encryptedContent {
                do {
                    return try EncryptionService.shared.decrypt(encryptedData)
                } catch {
                    print("Failed to decrypt content: \(error)")
                    // Fallback to plaintext if decryption fails
                    return _plaintextContent ?? ""
                }
            }
            
            // Fallback to legacy plaintext content
            return _plaintextContent ?? ""
        }
        set {
            do {
                // Encrypt and store the new content
                encryptedContent = try EncryptionService.shared.encrypt(newValue)
                // Clear legacy plaintext content
                _plaintextContent = nil
            } catch {
                print("Failed to encrypt content: \(error)")
                // Fallback to storing as plaintext (for development/debugging)
                _plaintextContent = newValue
                encryptedContent = nil
            }
        }
    }
    
    // Check if this entry is encrypted
    public var isEncrypted: Bool {
        return encryptedContent != nil
    }
    
    public init(content: String, date: Date? = nil) {
        self.id = UUID()
        self.createdAt = Date()
        self.updatedAt = Date()
        self.encryptedContent = nil
        self._plaintextContent = nil
        
        // Set date to normalized start of day (for calendar architecture)
        self.date = Calendar.current.startOfDay(for: date ?? Date())
        self.dataVersion = 2
        
        // Use computed property to handle encryption
        self.content = content
    }
    
    
    public func updateContent(_ newContent: String) {
        content = newContent
        updatedAt = Date()
    }
    
    // Migration method to encrypt existing plaintext entries
    public func migrateToEncrypted() throws {
        guard let plaintextContent = _plaintextContent, encryptedContent == nil else {
            return // Already encrypted or no content to migrate
        }
        
        do {
            encryptedContent = try EncryptionService.shared.encrypt(plaintextContent)
            _plaintextContent = nil
            print("Successfully migrated entry \(id) to encrypted storage")
        } catch {
            print("Failed to migrate entry \(id) to encrypted storage: \(error)")
            throw error
        }
    }
    
    // MARK: - Analysis Convenience Methods
    
    /// Get the most recent analysis for this entry
    public var latestAnalysis: AIAnalysis? {
        return analyses.max(by: { $0.processingDate < $1.processingDate })
    }
    
    /// Get analyses by a specific model
    public func analyses(byModel model: String) -> [AIAnalysis] {
        return analyses.filter { $0.modelUsed == model }
    }
    
    /// Check if this entry has any AI analysis
    public var hasAnalysis: Bool {
        return !analyses.isEmpty
    }
    
    /// Get the latest analysis summary for display
    public var latestAnalysisSummary: String? {
        return latestAnalysis?.displaySummary
    }
    
    // MARK: - Calendar Architecture Methods
    
    /// Check if this entry is for a specific date
    public func isForDate(_ checkDate: Date) -> Bool {
        guard let date = date else { return false }
        return Calendar.current.isDate(date, inSameDayAs: checkDate)
    }
    
    /// Get formatted date string for display
    public var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date ?? createdAt)
    }
    
    /// Get day component for calendar display
    public var dayOfMonth: Int {
        return Calendar.current.component(.day, from: date ?? createdAt)
    }
    
}

// MARK: - Preview Support
extension Entry {
    nonisolated(unsafe) static let preview = Entry(content: "This is a sample journal entry for previews. It contains some thoughts about the day and reflects on personal experiences.")
    
    nonisolated(unsafe) static let previewEntries: [Entry] = [
        Entry(content: "Today was a productive day. I managed to complete most of my tasks and felt really accomplished."),
        Entry(content: "Reflecting on this week, I notice I've been more mindful about my daily habits."),
        Entry(content: "Had an interesting conversation with a friend about life goals and aspirations.")
    ]
}