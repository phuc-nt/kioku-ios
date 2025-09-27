import SwiftUI
import SwiftData

public struct MigrationFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataService.self) private var dataService
    @State private var migrationService = MigrationService.shared
    @State private var currentStep: MigrationStep = .analysis
    @State private var analysisResult: MigrationAnalysis?
    @State private var migrationResult: MigrationResult?
    @State private var errorMessage: String?
    @State private var showingConflictResolution = false
    @State private var conflicts: [DateConflict] = []
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                MigrationProgressView(currentStep: currentStep)
                
                // Content based on current step
                switch currentStep {
                case .analysis:
                    AnalysisView(
                        analysis: analysisResult,
                        onStart: startMigration,
                        onAnalyze: performAnalysis
                    )
                    
                case .conflictResolution:
                    ConflictResolutionStepView(
                        conflicts: conflicts,
                        onResolve: { resolvedConflicts in
                            self.conflicts = resolvedConflicts
                            executeMigration()
                        }
                    )
                    
                case .migration:
                    MigrationProgressStepView(migrationService: migrationService)
                    
                case .complete:
                    CompletionView(
                        result: migrationResult,
                        onDismiss: { dismiss() }
                    )
                    
                case .error:
                    ErrorView(
                        message: errorMessage ?? "Unknown error occurred",
                        onRetry: performAnalysis,
                        onDismiss: { dismiss() }
                    )
                }
            }
            .navigationTitle("Data Migration")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if currentStep == .analysis {
                        Button("Cancel") {
                            dismiss()
                        }
                    }
                }
            }
        }
        .onAppear {
            migrationService.setModelContext(dataService.modelContext)
            performAnalysis()
        }
    }
    
    private func performAnalysis() {
        currentStep = .analysis
        
        Task {
            do {
                let analysis = try migrationService.analyzeMigrationComplexity()
                await MainActor.run {
                    self.analysisResult = analysis
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.currentStep = .error
                }
            }
        }
    }
    
    private func startMigration() {
        guard let analysis = analysisResult else { return }
        
        if analysis.hasConflicts {
            conflicts = analysis.conflicts
            currentStep = .conflictResolution
        } else {
            executeMigration()
        }
    }
    
    private func executeMigration() {
        currentStep = .migration
        
        Task {
            do {
                let result = try await migrationService.executeMigration(conflictResolutions: conflicts)
                await MainActor.run {
                    self.migrationResult = result
                    self.currentStep = .complete
                }
            } catch {
                await MainActor.run {
                    self.errorMessage = error.localizedDescription
                    self.currentStep = .error
                }
            }
        }
    }
}

enum MigrationStep {
    case analysis
    case conflictResolution
    case migration
    case complete
    case error
}

struct MigrationProgressView: View {
    let currentStep: MigrationStep
    
    private var steps: [(String, MigrationStep)] {
        [
            ("Analysis", .analysis),
            ("Conflicts", .conflictResolution),
            ("Migration", .migration),
            ("Complete", .complete)
        ]
    }
    
    var body: some View {
        HStack {
            ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                HStack {
                    Circle()
                        .fill(stepColor(for: step.1))
                        .frame(width: 12, height: 12)
                    
                    Text(step.0)
                        .font(.caption)
                        .foregroundColor(stepColor(for: step.1))
                    
                    if index < steps.count - 1 {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(height: 1)
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private func stepColor(for step: MigrationStep) -> Color {
        switch (currentStep, step) {
        case (.analysis, .analysis), (.conflictResolution, .conflictResolution), 
             (.migration, .migration), (.complete, .complete):
            return .blue
        case (.conflictResolution, .analysis), (.migration, .analysis), (.migration, .conflictResolution),
             (.complete, .analysis), (.complete, .conflictResolution), (.complete, .migration):
            return .green
        default:
            return .gray
        }
    }
}

struct AnalysisView: View {
    let analysis: MigrationAnalysis?
    let onStart: () -> Void
    let onAnalyze: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header
                VStack(spacing: 8) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 50))
                        .foregroundColor(.blue)
                    
                    Text("Migration Analysis")
                        .font(.title2)
                        .fontWeight(.semibold)
                    
                    Text("Analyzing your data for migration to calendar-based architecture")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                if let analysis = analysis {
                    // Analysis results
                    VStack(spacing: 16) {
                        AnalysisCard(
                            title: "Total Entries",
                            value: "\(analysis.totalEntries)",
                            description: "entries to migrate",
                            color: .blue
                        )
                        
                        AnalysisCard(
                            title: "Date Conflicts",
                            value: "\(analysis.conflictDates)",
                            description: analysis.conflictDates == 0 ? "no conflicts found" : "dates with multiple entries",
                            color: analysis.hasConflicts ? .orange : .green
                        )
                        
                        AnalysisCard(
                            title: "Estimated Time",
                            value: formatTime(analysis.estimatedTime),
                            description: "migration duration",
                            color: .purple
                        )
                    }
                    
                    if analysis.hasConflicts {
                        ConflictWarningView(conflictDates: analysis.conflictDates)
                    }
                    
                    // Action button
                    Button {
                        onStart()
                    } label: {
                        HStack {
                            Image(systemName: "play.fill")
                            Text("Start Migration")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.top)
                    
                } else {
                    // Loading state
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Analyzing your data...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(height: 100)
                }
            }
            .padding()
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        if seconds < 60 {
            return "\(Int(seconds))s"
        } else {
            let minutes = Int(seconds / 60)
            return "\(minutes)m"
        }
    }
}

struct AnalysisCard: View {
    let title: String
    let value: String
    let description: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
            
            Text(description)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

struct ConflictWarningView: View {
    let conflictDates: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundColor(.orange)
                
                Text("Conflicts Detected")
                    .font(.headline)
                    .foregroundColor(.orange)
            }
            
            Text("Found \(conflictDates) dates with multiple entries. You'll need to choose how to resolve these conflicts during migration.")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Resolution options:")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("• Smart merge: Combine entries with timestamps")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("• Keep latest: Only preserve the most recent entry")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                
                Text("• Keep longest: Preserve the entry with most content")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

struct ConflictResolutionStepView: View {
    let conflicts: [DateConflict]
    let onResolve: ([DateConflict]) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Resolve Conflicts")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Choose how to handle dates with multiple entries")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("Start Conflict Resolution") {
                // This will be handled by showing the MigrationConflictView
                onResolve(conflicts)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

struct MigrationProgressStepView: View {
    @State var migrationService: MigrationService
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Migrating Data")
                .font(.title2)
                .fontWeight(.semibold)
            
            ProgressView(value: migrationService.migrationProgress)
                .scaleEffect(1.2)
            
            Text(migrationService.currentStep)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text("\(Int(migrationService.migrationProgress * 100))% Complete")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

struct CompletionView: View {
    let result: MigrationResult?
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            if let result = result, result.success {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.green)
                
                Text("Migration Complete!")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                VStack(spacing: 8) {
                    Text("Successfully migrated \(result.migratedEntries) entries")
                        .font(.subheadline)
                    
                    if result.conflictsResolved > 0 {
                        Text("Resolved \(result.conflictsResolved) conflicts")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                Button("Continue") {
                    onDismiss()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)
                
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.red)
                
                Text("Migration Failed")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                if let result = result, !result.errors.isEmpty {
                    Text(result.errors.first?.localizedDescription ?? "Unknown error")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Button("Close") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
                .padding(.top)
            }
        }
        .padding()
    }
}

struct ErrorView: View {
    let message: String
    let onRetry: () -> Void
    let onDismiss: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 60))
                .foregroundColor(.red)
            
            Text("Migration Error")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button("Retry") {
                    onRetry()
                }
                .buttonStyle(.borderedProminent)
                
                Button("Cancel") {
                    onDismiss()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}