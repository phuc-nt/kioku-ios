import Testing
import Foundation
import SwiftData
@testable import KiokuFeature

// MARK: - Relationship Discovery Tracking Tests

@Suite("Relationship Discovery Tracking")
struct RelationshipTrackingTests {

    // MARK: - Test Setup

    private func createTestContainer() throws -> ModelContainer {
        let schema = Schema([
            Entry.self,
            Entity.self,
            EntityRelationship.self,
            Insight.self,
            Conversation.self
        ])

        let configuration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true
        )

        return try ModelContainer(for: schema, configurations: [configuration])
    }

    // MARK: - Entry Model Tests

    @Test("Entry has relationship tracking fields")
    func testEntryTrackingFields() async throws {
        let entry = Entry(content: "Test entry", date: Date())

        // Verify default values
        #expect(entry.isRelationshipsDiscovered == false)
        #expect(entry.relationshipsDiscoveredAt == nil)
        #expect(entry.relationshipsDiscoveryModel == nil)
    }

    @Test("Entry can be marked as relationships discovered")
    @MainActor
    func testMarkEntryAsDiscovered() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let entry = Entry(content: "Test entry with entities", date: Date())
        context.insert(entry)
        try context.save()

        // Mark as discovered
        entry.isRelationshipsDiscovered = true
        entry.relationshipsDiscoveredAt = Date()
        entry.relationshipsDiscoveryModel = "openai/gpt-4o-mini"
        try context.save()

        // Verify tracking fields
        #expect(entry.isRelationshipsDiscovered == true)
        #expect(entry.relationshipsDiscoveredAt != nil)
        #expect(entry.relationshipsDiscoveryModel == "openai/gpt-4o-mini")
    }

    @Test("Entry tracking persists across fetches")
    @MainActor
    func testTrackingPersistence() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        // Create and mark entry
        let entry = Entry(content: "Test entry", date: Date())
        let entryId = entry.id
        context.insert(entry)

        entry.isRelationshipsDiscovered = true
        entry.relationshipsDiscoveredAt = Date()
        entry.relationshipsDiscoveryModel = "test-model"
        try context.save()

        // Fetch entry again
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { $0.id == entryId }
        )
        let fetchedEntries = try context.fetch(descriptor)

        #expect(fetchedEntries.count == 1)
        let fetchedEntry = fetchedEntries[0]

        // Verify tracking fields persisted
        #expect(fetchedEntry.isRelationshipsDiscovered == true)
        #expect(fetchedEntry.relationshipsDiscoveredAt != nil)
        #expect(fetchedEntry.relationshipsDiscoveryModel == "test-model")
    }

    // MARK: - Batch Processing Tests

    @Test("Batch processing skips already discovered entries")
    @MainActor
    func testBatchSkipsDiscoveredEntries() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        // Create entries: one discovered, one not
        let entry1 = Entry(content: "Entry 1", date: Date())
        entry1.isRelationshipsDiscovered = true
        entry1.relationshipsDiscoveredAt = Date()

        let entry2 = Entry(content: "Entry 2", date: Date())
        entry2.isRelationshipsDiscovered = false

        context.insert(entry1)
        context.insert(entry2)
        try context.save()

        // In real batch processing, entry1 would be skipped
        // This test validates the data model supports the pattern

        let entriesToProcess = [entry1, entry2].filter { !$0.isRelationshipsDiscovered }
        #expect(entriesToProcess.count == 1)
        #expect(entriesToProcess[0].id == entry2.id)
    }

    @Test("Tracking enables incremental processing")
    @MainActor
    func testIncrementalProcessing() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        // Simulate batch 1: process 2 entries
        let entry1 = Entry(content: "Entry 1", date: Date())
        let entry2 = Entry(content: "Entry 2", date: Date())
        let entry3 = Entry(content: "Entry 3", date: Date())

        context.insert(entry1)
        context.insert(entry2)
        context.insert(entry3)
        try context.save()

        // Batch 1: Process first 2 entries
        entry1.isRelationshipsDiscovered = true
        entry1.relationshipsDiscoveredAt = Date()
        entry2.isRelationshipsDiscovered = true
        entry2.relationshipsDiscoveredAt = Date()
        try context.save()

        // Batch 2: Only entry3 should be processed
        let allEntries = [entry1, entry2, entry3]
        let remainingEntries = allEntries.filter { !$0.isRelationshipsDiscovered }

        #expect(remainingEntries.count == 1)
        #expect(remainingEntries[0].id == entry3.id)
    }

    @Test("Tracking works with entity extraction tracking")
    @MainActor
    func testCombinedTracking() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let entry = Entry(content: "Test entry", date: Date())
        context.insert(entry)

        // Mark entity extraction as done
        entry.isEntitiesExtracted = true
        entry.entitiesExtractedAt = Date()
        entry.entitiesExtractionModel = "extraction-model"

        // Mark relationship discovery as done
        entry.isRelationshipsDiscovered = true
        entry.relationshipsDiscoveredAt = Date()
        entry.relationshipsDiscoveryModel = "discovery-model"

        try context.save()

        // Verify both tracking mechanisms work together
        #expect(entry.isEntitiesExtracted == true)
        #expect(entry.isRelationshipsDiscovered == true)
        #expect(entry.entitiesExtractionModel != entry.relationshipsDiscoveryModel)
    }

    // MARK: - Query Tests

    @Test("Can query undiscovered entries efficiently")
    @MainActor
    func testQueryUndiscoveredEntries() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        // Create mixed entries
        for i in 0..<5 {
            let entry = Entry(content: "Entry \(i)", date: Date())
            entry.isRelationshipsDiscovered = (i % 2 == 0) // Even numbers discovered
            context.insert(entry)
        }
        try context.save()

        // Query undiscovered entries
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> { !$0.isRelationshipsDiscovered }
        )
        let undiscovered = try context.fetch(descriptor)

        #expect(undiscovered.count == 2) // Entries 1 and 3
    }

    @Test("Can query entries ready for relationship discovery")
    @MainActor
    func testQueryReadyForDiscovery() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        // Create entries with different states
        let entry1 = Entry(content: "Entry 1", date: Date())
        entry1.isEntitiesExtracted = true
        entry1.isRelationshipsDiscovered = false

        let entry2 = Entry(content: "Entry 2", date: Date())
        entry2.isEntitiesExtracted = false
        entry2.isRelationshipsDiscovered = false

        let entry3 = Entry(content: "Entry 3", date: Date())
        entry3.isEntitiesExtracted = true
        entry3.isRelationshipsDiscovered = true

        context.insert(entry1)
        context.insert(entry2)
        context.insert(entry3)
        try context.save()

        // Query entries ready for discovery: entities extracted but relationships not discovered
        let descriptor = FetchDescriptor<Entry>(
            predicate: #Predicate<Entry> {
                $0.isEntitiesExtracted && !$0.isRelationshipsDiscovered
            }
        )
        let ready = try context.fetch(descriptor)

        #expect(ready.count == 1)
        #expect(ready[0].id == entry1.id)
    }

    // MARK: - Model Update Tests

    @Test("Can update discovery model when re-processing")
    @MainActor
    func testModelUpdate() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let entry = Entry(content: "Test entry", date: Date())
        context.insert(entry)

        // First discovery with model A
        entry.isRelationshipsDiscovered = true
        entry.relationshipsDiscoveredAt = Date()
        entry.relationshipsDiscoveryModel = "model-v1"
        try context.save()

        // Re-process with model B
        let firstDate = entry.relationshipsDiscoveredAt!
        try await Task.sleep(nanoseconds: 100_000_000) // 0.1s delay

        entry.relationshipsDiscoveredAt = Date()
        entry.relationshipsDiscoveryModel = "model-v2"
        try context.save()

        #expect(entry.relationshipsDiscoveryModel == "model-v2")
        #expect(entry.relationshipsDiscoveredAt! > firstDate)
    }

    // MARK: - Edge Cases

    @Test("Tracking fields optional for backward compatibility")
    @MainActor
    func testBackwardCompatibility() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        // Old entries might not have tracking fields set
        let entry = Entry(content: "Old entry", date: Date())
        context.insert(entry)
        try context.save()

        // Should default to false/nil
        #expect(entry.isRelationshipsDiscovered == false)
        #expect(entry.relationshipsDiscoveredAt == nil)
        #expect(entry.relationshipsDiscoveryModel == nil)
    }

    @Test("Can reset tracking to reprocess entry")
    @MainActor
    func testResetTracking() async throws {
        let container = try createTestContainer()
        let context = container.mainContext

        let entry = Entry(content: "Test entry", date: Date())
        context.insert(entry)

        // Mark as discovered
        entry.isRelationshipsDiscovered = true
        entry.relationshipsDiscoveredAt = Date()
        entry.relationshipsDiscoveryModel = "old-model"
        try context.save()

        // Reset tracking
        entry.isRelationshipsDiscovered = false
        entry.relationshipsDiscoveredAt = nil
        entry.relationshipsDiscoveryModel = nil
        try context.save()

        // Verify reset
        #expect(entry.isRelationshipsDiscovered == false)
        #expect(entry.relationshipsDiscoveredAt == nil)
        #expect(entry.relationshipsDiscoveryModel == nil)
    }
}
