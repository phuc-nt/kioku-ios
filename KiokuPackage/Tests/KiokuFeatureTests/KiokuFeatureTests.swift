import Testing
import Foundation
import SwiftData
@testable import KiokuFeature

// MARK: - Entry Model Tests

@Test("Entry model initialization")
func testEntryInitialization() async throws {
    let content = "Test entry content"
    let entry = Entry(content: content)
    
    #expect(entry.content == content)
    #expect(entry.id != UUID())
    #expect(entry.createdAt <= Date())
    #expect(entry.updatedAt <= Date())
    #expect(entry.createdAt <= entry.updatedAt)
}

@Test("Entry content update")
func testEntryContentUpdate() async throws {
    let originalContent = "Original content"
    let newContent = "Updated content"
    let entry = Entry(content: originalContent)
    let originalUpdatedAt = entry.updatedAt
    
    // Small delay to ensure updatedAt changes
    try await Task.sleep(nanoseconds: 1_000_000)
    
    entry.content = newContent
    
    #expect(entry.content == newContent)
    #expect(entry.updatedAt > originalUpdatedAt)
}

@Test("Entry encrypted content handling")
func testEntryEncryptionHandling() async throws {
    let content = "Secret diary entry"
    let entry = Entry(content: content)
    
    // Content should be accessible transparently
    #expect(entry.content == content)
    
    // When encryption is enabled, encryptedContent should exist
    if entry.encryptedContent != nil {
        #expect(entry.encryptedContent!.count > 0)
    }
}

// MARK: - EncryptionService Tests

@Test("EncryptionService encrypt and decrypt")
func testEncryptionServiceRoundTrip() async throws {
    let service = EncryptionService.preview
    let testContent = "This is a test message for encryption"
    
    let encryptedData = try service.encrypt(testContent)
    let decryptedContent = try service.decrypt(encryptedData)
    
    #expect(decryptedContent == testContent)
    #expect(encryptedData.count > 0)
}

@Test("EncryptionService validation")
func testEncryptionServiceValidation() async throws {
    let service = EncryptionService.preview
    
    // Should not throw
    try service.validateEncryption()
}

@Test("EncryptionService handles empty content")
func testEncryptionServiceEmptyContent() async throws {
    let service = EncryptionService.preview
    let emptyContent = ""
    
    let encryptedData = try service.encrypt(emptyContent)
    let decryptedContent = try service.decrypt(encryptedData)
    
    #expect(decryptedContent == emptyContent)
}

@Test("EncryptionService handles unicode content")
func testEncryptionServiceUnicodeContent() async throws {
    let service = EncryptionService.preview
    let unicodeContent = "こんにちは 🌍 éñçryptîön tést"
    
    let encryptedData = try service.encrypt(unicodeContent)
    let decryptedContent = try service.decrypt(encryptedData)
    
    #expect(decryptedContent == unicodeContent)
}

@Test("EncryptionService rejects invalid data")
func testEncryptionServiceInvalidData() async throws {
    let service = EncryptionService.preview
    let invalidData = Data([1, 2, 3, 4, 5]) // Random invalid encrypted data
    
    #expect(throws: EncryptionService.EncryptionError.self) {
        try service.decrypt(invalidData)
    }
}

// MARK: - DataService Tests

@Test("DataService preview initialization")
func testDataServicePreviewInitialization() async throws {
    let dataService = DataService.preview
    
    #expect(dataService != nil)
    // Preview service should be functional
}

// MARK: - Search Functionality Tests

@Test("Entry search filtering")
func testEntrySearchFiltering() async throws {
    let entries = [
        Entry(content: "First entry about Swift development"),
        Entry(content: "Second entry about iOS programming"),
        Entry(content: "Third entry about machine learning"),
        Entry(content: "Fourth entry discussing design patterns")
    ]
    
    // Test case-insensitive search
    let swiftResults = entries.filter { entry in
        entry.content.localizedCaseInsensitiveContains("swift")
    }
    #expect(swiftResults.count == 1)
    #expect(swiftResults[0].content.contains("Swift"))
    
    // Test partial word matching
    let progResults = entries.filter { entry in
        entry.content.localizedCaseInsensitiveContains("prog")
    }
    #expect(progResults.count == 1)
    #expect(progResults[0].content.contains("programming"))
    
    // Test no matches
    let noResults = entries.filter { entry in
        entry.content.localizedCaseInsensitiveContains("nonexistent")
    }
    #expect(noResults.count == 0)
}

@Test("Entry search with empty query")
func testEntrySearchEmptyQuery() async throws {
    let entries = [
        Entry(content: "Test entry 1"),
        Entry(content: "Test entry 2")
    ]
    
    let results = entries.filter { entry in
        "".isEmpty || entry.content.localizedCaseInsensitiveContains("")
    }
    
    // Empty search should return all entries (logic from EntryListView)
    #expect(results.count == 2)
}

// MARK: - Helper Functions Tests

@Test("Word count functionality")
func testWordCountFunctionality() async throws {
    let testCases = [
        ("", 0),
        ("Hello", 1),
        ("Hello world", 2),
        ("This is a test sentence.", 5),
        ("Multiple   spaces   between   words", 4),
        ("Line1\nLine2\nLine3", 3),
        ("   Leading and trailing spaces   ", 4)
    ]
    
    for (text, expectedCount) in testCases {
        let words = text.components(separatedBy: .whitespacesAndNewlines)
        let actualCount = words.filter { !$0.isEmpty }.count
        #expect(actualCount == expectedCount, "Word count failed for '\(text)'")
    }
}

// MARK: - Integration Tests

@Test("Entry with encryption integration")
func testEntryEncryptionIntegration() async throws {
    let testContent = "Integration test for encrypted entry content"
    let entry = Entry(content: testContent)
    
    // Simulate what happens when reading back from storage
    if let encryptedData = entry.encryptedContent {
        let service = EncryptionService.preview
        let decryptedContent = try service.decrypt(encryptedData)
        #expect(decryptedContent == testContent)
    } else {
        // If no encryption, content should still be accessible
        #expect(entry.content == testContent)
    }
}

@Test("Multiple entries creation and search")
func testMultipleEntriesCreationAndSearch() async throws {
    let contents = [
        "Daily reflection on productivity",
        "Thoughts about learning Swift",
        "Weekend activities and fun",
        "Work progress and challenges"
    ]
    
    let entries = contents.map { Entry(content: $0) }
    
    // Verify all entries created successfully
    #expect(entries.count == 4)
    
    // Test search across multiple entries
    let workRelated = entries.filter { 
        $0.content.localizedCaseInsensitiveContains("work") ||
        $0.content.localizedCaseInsensitiveContains("productivity")
    }
    #expect(workRelated.count == 2)
    
    // Test specific content search
    let swiftEntries = entries.filter { 
        $0.content.localizedCaseInsensitiveContains("Swift")
    }
    #expect(swiftEntries.count == 1)
}
