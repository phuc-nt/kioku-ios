import SwiftUI

struct EntityExtractionView: View {
    @Environment(DataService.self) private var dataService
    @Environment(\.dismiss) private var dismiss

    @State private var extractionService: EntityExtractionService
    @State private var isProcessing = false
    @State private var progress: Double = 0.0
    @State private var currentEntryText: String = ""
    @State private var showError: String?
    @State private var showSuccess = false
    @State private var extractionStats: (total: Int, byType: [EntityType: Int])?

    init(dataService: DataService) {
        self._extractionService = State(initialValue: EntityExtractionService(dataService: dataService))
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

    // MARK: - Methods

    private var hasAPIKey: Bool {
        OpenRouterService.shared.hasAPIKey
    }

    private func loadStats() {
        let stats = extractionService.getExtractionStats()
        extractionStats = (total: stats.totalEntities, byType: stats.byType)
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

        // Start extraction
        let allEntries = dataService.fetchAllEntries()

        guard !allEntries.isEmpty else {
            showError = "No journal entries found"
            return
        }

        isProcessing = true
        progress = 0.0
        currentEntryText = ""

        Task {
            do {
                try await extractionService.extractEntitiesFromBatch(
                    entries: allEntries,
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
}

#Preview {
    EntityExtractionView(dataService: DataService.preview)
        .environment(DataService.preview)
}
