import SwiftUI
import SwiftData

public struct MigrationConflictView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var conflicts: [DateConflict]
    @State private var currentConflictIndex = 0
    @State private var showingPreview = false
    @State private var previewContent = ""
    
    let onResolutionComplete: ([DateConflict]) -> Void
    
    public init(conflicts: [DateConflict], onResolutionComplete: @escaping ([DateConflict]) -> Void) {
        self._conflicts = State(initialValue: conflicts)
        self.onResolutionComplete = onResolutionComplete
    }
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Progress indicator
                ProgressView(value: Double(currentConflictIndex), total: Double(conflicts.count))
                    .padding()
                
                if currentConflictIndex < conflicts.count {
                    ConflictResolutionView(
                        conflict: $conflicts[currentConflictIndex],
                        onNext: nextConflict,
                        onPreview: showPreview
                    )
                } else {
                    // All conflicts resolved
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.green)
                        
                        Text("All Conflicts Resolved")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Ready to complete migration with your choices.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button("Complete Migration") {
                            onResolutionComplete(conflicts)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top)
                    }
                    .padding()
                }
            }
            .navigationTitle("Migration Conflicts")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
        .sheet(isPresented: $showingPreview) {
            PreviewView(content: previewContent) {
                showingPreview = false
            }
        }
    }
    
    private func nextConflict() {
        if currentConflictIndex < conflicts.count - 1 {
            currentConflictIndex += 1
        } else {
            currentConflictIndex = conflicts.count
        }
    }
    
    private func showPreview(content: String) {
        previewContent = content
        showingPreview = true
    }
}

struct ConflictResolutionView: View {
    @Binding var conflict: DateConflict
    let onNext: () -> Void
    let onPreview: (String) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Date header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Multiple entries found for:")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Text(conflict.displayDate)
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
                
                // Entries preview
                VStack(alignment: .leading, spacing: 12) {
                    Text("Conflicting Entries (\(conflict.entries.count))")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(Array(conflict.entries.enumerated()), id: \.offset) { index, entry in
                        EntryPreviewCard(entry: entry, index: index + 1)
                    }
                }
                
                // Strategy selection
                VStack(alignment: .leading, spacing: 16) {
                    Text("Resolution Strategy")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(MergeStrategy.allCases, id: \.self) { strategy in
                        StrategySelectionCard(
                            strategy: strategy,
                            isSelected: conflict.userChoice == strategy,
                            isRecommended: strategy == conflict.recommendedStrategy
                        ) {
                            conflict.userChoice = strategy
                        } onPreview: {
                            let previewContent = generatePreview(for: strategy)
                            onPreview(previewContent)
                        }
                    }
                }
                .padding(.horizontal)
                
                // Action buttons
                HStack {
                    Spacer()
                    
                    Button("Preview Result") {
                        let strategy = conflict.userChoice ?? conflict.recommendedStrategy
                        let previewContent = generatePreview(for: strategy)
                        onPreview(previewContent)
                    }
                    .buttonStyle(.bordered)
                    .disabled(conflict.userChoice == nil)
                    
                    Button("Next") {
                        if conflict.userChoice == nil {
                            conflict.userChoice = conflict.recommendedStrategy
                        }
                        onNext()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
        }
    }
    
    private func generatePreview(for strategy: MergeStrategy) -> String {
        let sortedEntries = conflict.entries.sorted { $0.createdAt < $1.createdAt }
        
        switch strategy {
        case .smartMerge:
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
            return mergedContent
            
        case .latestOnly:
            return sortedEntries.last?.content ?? ""
            
        case .longestContent:
            return sortedEntries.max { $0.content.count < $1.content.count }?.content ?? ""
            
        case .userChoice:
            return sortedEntries.first?.content ?? ""
        }
    }
}

struct EntryPreviewCard: View {
    let entry: Entry
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Entry \(index)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                
                Text(DateFormatter.timeFormatter.string(from: entry.createdAt))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.content)
                .font(.body)
                .lineLimit(3)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .padding(.horizontal)
    }
}

struct StrategySelectionCard: View {
    let strategy: MergeStrategy
    let isSelected: Bool
    let isRecommended: Bool
    let onSelect: () -> Void
    let onPreview: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(strategy.displayName)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if isRecommended {
                            Text("RECOMMENDED")
                                .font(.caption2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.green)
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(strategy.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Button("Preview") {
                    onPreview()
                }
                .buttonStyle(.bordered)
                .controlSize(.mini)
            }
        }
        .padding()
        .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .cornerRadius(8)
        .onTapGesture {
            onSelect()
        }
    }
}

struct PreviewView: View {
    let content: String
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationView {
            ScrollView {
                Text(content)
                    .font(.body)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .navigationTitle("Preview")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        onDismiss()
                    }
                }
            }
        }
    }
}

extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}