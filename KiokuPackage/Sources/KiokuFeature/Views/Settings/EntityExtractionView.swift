import SwiftUI

struct EntityExtractionView: View {
    @Environment(DataService.self) private var dataService
    @Environment(\.dismiss) private var dismiss

    @State private var extractionService: EntityExtractionService
    @State private var relationshipService: RelationshipDiscoveryService
    @State private var isProcessing = false
    @State private var progress: Double = 0.0
    @State private var currentEntryText: String = ""
    @State private var showError: String?
    @State private var showSuccess = false
    @State private var extractionStats: (total: Int, byType: [EntityType: Int])?
    @State private var relationshipStats: (total: Int, byType: [RelationshipType: Int])?
    @State private var isDiscoveringRelationships = false
    @State private var discoveryProgress: Double = 0.0
    @State private var showRelationshipSuccess = false

    init(dataService: DataService) {
        self._extractionService = State(initialValue: EntityExtractionService(dataService: dataService))
        self._relationshipService = State(initialValue: RelationshipDiscoveryService(dataService: dataService))
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    headerSection

                    // Statistics
                    if let stats = extractionStats {
                        statisticsSection(stats: stats)
                    }

                    // Extraction controls
                    extractionSection

                    // Progress
                    if isProcessing {
                        progressSection
                    }

                    // Relationship discovery section
                    if let stats = extractionStats, stats.total >= 2 {
                        relationshipDiscoverySection
                    }

                    // Relationship stats
                    if let relStats = relationshipStats, relStats.total > 0 {
                        relationshipStatsSection(stats: relStats)
                    }

                    // Discovery progress
                    if isDiscoveringRelationships {
                        discoveryProgressSection
                    }
                }
                .padding()
            }
            .navigationTitle("Entity Extraction")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .alert("Error", isPresented: .init(
                get: { showError != nil },
                set: { if !$0 { showError = nil } }
            )) {
                Button("OK") { showError = nil }
            } message: {
                Text(showError ?? "")
            }
            .alert("Extraction Complete", isPresented: $showSuccess) {
                Button("OK") {
                    showSuccess = false
                    loadStats()
                }
            } message: {
                Text("Successfully extracted entities from your journal entries!")
            }
            .alert("Discovery Complete", isPresented: $showRelationshipSuccess) {
                Button("OK") {
                    showRelationshipSuccess = false
                    loadStats()
                }
            } message: {
                Text("Successfully discovered relationships between entities!")
            }
            .onAppear {
                loadStats()
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.accentColor.opacity(0.6))

            Text("AI-Powered Entity Extraction")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Extract people, places, events, emotions, and topics from your journal entries to build your knowledge graph.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Statistics Section

    private func statisticsSection(stats: (total: Int, byType: [EntityType: Int])) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Current Knowledge Graph")
                .font(.headline)

            VStack(spacing: 8) {
                // Total
                HStack {
                    Image(systemName: "circle.grid.3x3.fill")
                        .foregroundColor(.accentColor)
                    Text("Total Entities")
                    Spacer()
                    Text("\(stats.total)")
                        .fontWeight(.semibold)
                }

                Divider()

                // By type
                ForEach(EntityType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.icon)
                            .foregroundColor(.secondary)
                        Text(type.displayName)
                        Spacer()
                        Text("\(stats.byType[type] ?? 0)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    // MARK: - Extraction Section

    private var extractionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Batch Processing")
                .font(.headline)

            Text("Process all journal entries to extract entities. This may take several minutes depending on the number of entries.")
                .font(.caption)
                .foregroundColor(.secondary)

            // Show extraction status
            let allEntries = dataService.fetchAllEntries()
            let extractedCount = allEntries.filter { $0.isEntitiesExtracted }.count
            let totalCount = allEntries.count

            if totalCount > 0 {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(extractedCount == totalCount ? .green : .orange)
                    Text("\(extractedCount) of \(totalCount) entries extracted")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Button(action: startExtraction) {
                HStack {
                    Image(systemName: isProcessing ? "stop.circle.fill" : "play.circle.fill")
                    Text(isProcessing ? "Stop Extraction" : "Start Extraction")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isProcessing ? .red : .accentColor)
            .disabled(!hasAPIKey)

            if !hasAPIKey {
                Text("⚠️ API key required. Please set up your OpenRouter API key in Settings first.")
                    .font(.caption)
                    .foregroundColor(.orange)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Processing...")
                .font(.headline)

            ProgressView(value: progress, total: 1.0) {
                HStack {
                    Text("Progress")
                    Spacer()
                    Text("\(Int(progress * 100))%")
                }
                .font(.caption)
            }

            if !currentEntryText.isEmpty {
                Text("Extracting from: \(currentEntryText)...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Relationship Discovery Section

    private var relationshipDiscoverySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Relationship Discovery")
                .font(.headline)

            Text("Discover relationships between extracted entities. Requires at least 2 entities.")
                .font(.caption)
                .foregroundColor(.secondary)

            Button(action: startRelationshipDiscovery) {
                HStack {
                    Image(systemName: isDiscoveringRelationships ? "stop.circle.fill" : "arrow.triangle.branch")
                    Text(isDiscoveringRelationships ? "Stop Discovery" : "Discover Relationships")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
            .tint(isDiscoveringRelationships ? .red : .orange)
            .disabled(!hasAPIKey || isProcessing)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    private func relationshipStatsSection(stats: (total: Int, byType: [RelationshipType: Int])) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Discovered Relationships")
                .font(.headline)

            VStack(spacing: 8) {
                HStack {
                    Image(systemName: "link.circle.fill")
                        .foregroundColor(.orange)
                    Text("Total Relationships")
                    Spacer()
                    Text("\(stats.total)")
                        .fontWeight(.semibold)
                }

                Divider()

                ForEach(RelationshipType.allCases, id: \.self) { type in
                    HStack {
                        Image(systemName: type.icon)
                            .foregroundColor(.secondary)
                        Text(type.displayName)
                        Spacer()
                        Text("\(stats.byType[type] ?? 0)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }

    private var discoveryProgressSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Discovering...")
                .font(.headline)

            ProgressView(value: discoveryProgress, total: 1.0) {
                HStack {
                    Text("Progress")
                    Spacer()
                    Text("\(Int(discoveryProgress * 100))%")
                }
                .font(.caption)
            }

            if !currentEntryText.isEmpty {
                Text("Analyzing: \(currentEntryText)...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }

    // MARK: - Methods

    private var hasAPIKey: Bool {
        OpenRouterService.shared.hasAPIKey
    }

    private func loadStats() {
        let stats = extractionService.getExtractionStats()
        extractionStats = (total: stats.totalEntities, byType: stats.byType)

        let relStats = relationshipService.getDiscoveryStats()
        relationshipStats = (total: relStats.totalRelationships, byType: relStats.byType)
    }

    private func startExtraction() {
        if isProcessing {
            // Stop extraction
            extractionService.cancelExtraction()
            isProcessing = false
            progress = 0.0
            currentEntryText = ""
            return
        }

        // Start extraction - only process entries that haven't been extracted yet
        let allEntries = dataService.fetchAllEntries()
        let unextractedEntries = allEntries.filter { !$0.isEntitiesExtracted }

        guard !unextractedEntries.isEmpty else {
            showError = "No unextracted journal entries found. All entries have already been processed."
            return
        }

        isProcessing = true
        progress = 0.0
        currentEntryText = ""

        Task {
            do {
                try await extractionService.extractEntitiesFromBatch(
                    entries: unextractedEntries,
                    onProgress: { @MainActor newProgress, entryText in
                        progress = newProgress
                        currentEntryText = entryText
                    }
                )

                await MainActor.run {
                    isProcessing = false
                    progress = 1.0
                    currentEntryText = ""
                    showSuccess = true
                }

            } catch {
                await MainActor.run {
                    isProcessing = false
                    progress = 0.0
                    currentEntryText = ""
                    showError = error.localizedDescription
                }
            }
        }
    }

    private func startRelationshipDiscovery() {
        if isDiscoveringRelationships {
            // Stop discovery
            relationshipService.cancelDiscovery()
            isDiscoveringRelationships = false
            discoveryProgress = 0.0
            currentEntryText = ""
            return
        }

        // Start discovery - only process entries that have entities
        let allEntries = dataService.fetchAllEntries().filter { $0.entities.count >= 2 }

        guard !allEntries.isEmpty else {
            showError = "No entries with entities found. Extract entities first."
            return
        }

        isDiscoveringRelationships = true
        discoveryProgress = 0.0
        currentEntryText = ""

        Task {
            do {
                try await relationshipService.discoverRelationshipsFromBatch(
                    entries: allEntries,
                    onProgress: { @MainActor newProgress, entryText in
                        discoveryProgress = newProgress
                        currentEntryText = entryText
                    }
                )

                await MainActor.run {
                    isDiscoveringRelationships = false
                    discoveryProgress = 1.0
                    currentEntryText = ""
                    showRelationshipSuccess = true
                }

            } catch {
                await MainActor.run {
                    isDiscoveringRelationships = false
                    discoveryProgress = 0.0
                    currentEntryText = ""
                    showError = error.localizedDescription
                }
            }
        }
    }
}

#Preview {
    EntityExtractionView(dataService: DataService.preview)
        .environment(DataService.preview)
}
