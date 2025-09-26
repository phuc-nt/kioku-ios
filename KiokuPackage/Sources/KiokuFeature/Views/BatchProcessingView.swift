import SwiftUI
import SwiftData

public struct BatchProcessingView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataService.self) private var dataService
    @StateObject private var batchService: BatchProcessingService
    
    @State private var selectedEntries: Set<Entry> = []
    @State private var selectedModel: String = "openai/gpt-4o-mini"
    @State private var showingEntrySelection = false
    @State private var availableEntries: [Entry] = []
    
    // Available models for selection
    private let availableModels = [
        "openai/gpt-4o-mini",
        "anthropic/claude-3-haiku",
        "anthropic/claude-3-sonnet",
        "meta-llama/llama-3.1-8b-instruct"
    ]
    
    public init() {
        let dataService = DataService()
        let analysisService = AIAnalysisService.shared
        let knowledgeGraphService = KnowledgeGraphService(
            dataService: dataService,
            analysisService: analysisService
        )
        
        self._batchService = StateObject(wrappedValue: BatchProcessingService(
            dataService: dataService,
            analysisService: analysisService,
            knowledgeGraphService: knowledgeGraphService
        ))
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    headerSection
                    
                    Divider()
                    
                    // Quick Actions
                    quickActionsSection
                    
                    Divider()
                    
                    // Active Operations
                    if !batchService.activeOperations.isEmpty {
                        activeOperationsSection
                        
                        Divider()
                    }
                    
                    // Statistics
                    statisticsSection
                }
                .padding()
            }
            .navigationTitle("Batch Processing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        batchService.clearCompletedOperations()
                    } label: {
                        Text("Clear")
                    }
                    .disabled(batchService.activeOperations.allSatisfy { 
                        $0.status == .running || $0.status == .pending 
                    })
                }
            }
        }
        .task {
            loadAvailableEntries()
        }
        .sheet(isPresented: $showingEntrySelection) {
            entrySelectionSheet
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Batch Operations")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Process multiple journal entries efficiently with AI analysis and connection generation")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
    
    private var quickActionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 280))], spacing: 12) {
                // Reanalyze All Entries
                QuickActionCard(
                    title: "Reanalyze All Entries",
                    description: "Re-process all journal entries with the latest AI models",
                    icon: "arrow.clockwise.circle.fill",
                    color: .blue,
                    action: {
                        startBatchReanalysis(entries: availableEntries)
                    }
                )
                
                // Reanalyze Selected Entries
                QuickActionCard(
                    title: "Reanalyze Selected",
                    description: "Choose specific entries to reprocess",
                    icon: "checkmark.circle.fill",
                    color: .green,
                    action: {
                        showingEntrySelection = true
                    }
                )
                
                // Generate Knowledge Graph
                QuickActionCard(
                    title: "Generate Connections",
                    description: "Discover relationships between all analyzed entries",
                    icon: "link.circle.fill",
                    color: .purple,
                    action: {
                        startConnectionGeneration()
                    }
                )
            }
            
            // Model Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Default AI Model")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Picker("Model", selection: $selectedModel) {
                    ForEach(availableModels, id: \.self) { model in
                        Text(model.components(separatedBy: "/").last ?? model)
                            .tag(model)
                    }
                }
                .pickerStyle(.menu)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
        }
    }
    
    private var activeOperationsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Active Operations")
                .font(.headline)
            
            LazyVStack(spacing: 12) {
                ForEach(batchService.activeOperations, id: \.id) { operation in
                    BatchOperationCard(
                        operation: operation,
                        onCancel: {
                            batchService.cancelOperation(operation.id)
                        },
                        onPause: {
                            if operation.status == .running {
                                batchService.pauseOperation(operation.id)
                            } else if operation.status == .paused {
                                batchService.resumeOperation(operation.id)
                            }
                        }
                    )
                }
            }
        }
    }
    
    private var statisticsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Processing Statistics")
                .font(.headline)
            
            let stats = batchService.getProcessingStatistics()
            
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 140))], spacing: 12) {
                StatCard(
                    title: "Total Ops",
                    value: "\(stats.totalOperations)",
                    icon: "gearshape.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Completed",
                    value: "\(stats.completedOperations)",
                    icon: "checkmark.circle.fill",
                    color: .green
                )
                
                StatCard(
                    title: "Running",
                    value: "\(stats.runningOperations)",
                    icon: "arrow.clockwise",
                    color: .orange
                )
                
                StatCard(
                    title: "Failed",
                    value: "\(stats.failedOperations)",
                    icon: "xmark.circle.fill",
                    color: .red
                )
                
                StatCard(
                    title: "Entries Processed",
                    value: "\(stats.totalEntriesProcessed)",
                    icon: "doc.text.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "Avg Time",
                    value: String(format: "%.1fs", stats.averageProcessingTime),
                    icon: "timer",
                    color: .teal
                )
            }
        }
    }
    
    private var entrySelectionSheet: some View {
        NavigationView {
            List(availableEntries, id: \.id, selection: $selectedEntries) { entry in
                BatchEntryRowView(entry: entry)
            }
            .navigationTitle("Select Entries")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingEntrySelection = false
                        selectedEntries.removeAll()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Process") {
                        let entries = Array(selectedEntries)
                        startBatchReanalysis(entries: entries)
                        showingEntrySelection = false
                        selectedEntries.removeAll()
                    }
                    .disabled(selectedEntries.isEmpty)
                }
            }
        }
    }
    
    private func loadAvailableEntries() {
        availableEntries = dataService.fetchAllEntries()
    }
    
    private func startBatchReanalysis(entries: [Entry]) {
        guard !entries.isEmpty else { return }
        let _ = batchService.startBatchReanalysis(entries: entries, model: selectedModel)
    }
    
    private func startConnectionGeneration() {
        let _ = batchService.startBatchConnectionGeneration()
    }
}

// MARK: - Supporting Views

private struct QuickActionCard: View {
    let title: String
    let description: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                    
                    Spacer()
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

private struct BatchOperationCard: View {
    let operation: BatchProcessingService.BatchOperation
    let onCancel: () -> Void
    let onPause: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                operationIcon
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(operationTitle)
                        .font(.headline)
                    
                    Text(operation.createdAt, style: .time)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                statusBadge
            }
            
            // Progress
            if operation.status == .running || operation.status == .paused {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Progress: \(operation.progress.completed)/\(operation.progress.total)")
                            .font(.subheadline)
                        
                        Spacer()
                        
                        Text(String(format: "%.0f%%", operation.progress.percentage * 100))
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    
                    ProgressView(value: operation.progress.percentage)
                        .tint(operation.status == .paused ? .orange : .blue)
                    
                    if let currentItem = operation.progress.currentItem {
                        Text(currentItem)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    if let eta = operation.progress.estimatedTimeRemaining {
                        Text("ETA: \(formatTimeRemaining(eta))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            
            // Results summary
            if !operation.results.isEmpty {
                let successCount = operation.results.filter(\.success).count
                let totalCount = operation.results.count
                
                HStack {
                    Label("\(successCount)/\(totalCount) successful", systemImage: "checkmark.circle")
                        .font(.caption)
                        .foregroundColor(.green)
                    
                    Spacer()
                    
                    if let error = operation.error {
                        Label("Error", systemImage: "exclamationmark.triangle")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            
            // Controls
            if operation.status == .running || operation.status == .paused {
                HStack {
                    Button {
                        onPause()
                    } label: {
                        Label(operation.status == .paused ? "Resume" : "Pause", 
                              systemImage: operation.status == .paused ? "play.fill" : "pause.fill")
                    }
                    .font(.caption)
                    
                    Spacer()
                    
                    Button {
                        onCancel()
                    } label: {
                        Label("Cancel", systemImage: "xmark.circle")
                    }
                    .font(.caption)
                    .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private var operationIcon: some View {
        Group {
            switch operation.type {
            case .reanalyze:
                Image(systemName: "brain.head.profile")
                    .foregroundColor(.blue)
            case .generateConnections:
                Image(systemName: "link.circle")
                    .foregroundColor(.purple)
            case .updateAnalyses:
                Image(systemName: "arrow.up.circle")
                    .foregroundColor(.green)
            case .cleanupAnalyses:
                Image(systemName: "trash.circle")
                    .foregroundColor(.orange)
            }
        }
        .font(.title2)
    }
    
    private var operationTitle: String {
        switch operation.type {
        case .reanalyze:
            return "Reanalyze Entries"
        case .generateConnections:
            return "Generate Connections"
        case .updateAnalyses:
            return "Update Analyses"
        case .cleanupAnalyses:
            return "Cleanup Analyses"
        }
    }
    
    private var statusBadge: some View {
        Text(operation.status.rawValue.capitalized)
            .font(.caption)
            .fontWeight(.medium)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(statusColor)
            .cornerRadius(8)
    }
    
    private var statusColor: Color {
        switch operation.status {
        case .pending:
            return .gray
        case .running:
            return .blue
        case .paused:
            return .orange
        case .completed:
            return .green
        case .cancelled:
            return .secondary
        case .failed:
            return .red
        }
    }
    
    private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
}

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private struct BatchEntryRowView: View {
    let entry: Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.createdAt, style: .date)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(entry.content.prefix(100) + (entry.content.count > 100 ? "..." : ""))
                .font(.subheadline)
                .lineLimit(2)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview {
    BatchProcessingView()
        .environment(DataService.preview)
}