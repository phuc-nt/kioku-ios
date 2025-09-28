import SwiftUI
import SwiftData

public struct EntryCreationView: View {
    @Environment(DataService.self) private var dataService
    @Environment(\.dismiss) private var dismiss
    @State private var content: String = ""
    @State private var isAutoSaving: Bool = false
    @State private var lastSavedContent: String = ""
    @State private var currentEntry: Entry?
    
    // Auto-save timer
    @State private var autoSaveTimer: Timer?
    
    private let autoSaveDelay: TimeInterval = 2.0
    private let selectedDate: Date
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Content Editor
                TextEditor(text: $content)
                    .font(.body)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .onChange(of: content) { _, newValue in
                        scheduleAutoSave()
                    }
                
                // Status Bar
                HStack {
                    Text(statusMessage)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("\(content.count) characters")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
            }
            .navigationTitle("New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        finalSave()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        cancelEntry()
                    }
                }
            }
        }
        .onAppear {
            // Auto-focus on the text editor when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                // TextEditor auto-focuses by default in SwiftUI
            }
        }
        .onDisappear {
            cancelAutoSaveTimer()
            
            // Auto-save when view disappears (if there's unsaved content)
            if hasUnsavedChanges {
                performAutoSave()
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var statusMessage: String {
        if isAutoSaving {
            return "Saving..."
        } else if hasUnsavedChanges {
            return "Unsaved changes"
        } else if !content.isEmpty {
            return "Saved"
        } else {
            return "Start typing to create your entry"
        }
    }
    
    private var hasUnsavedChanges: Bool {
        content != lastSavedContent && !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Auto-Save Logic
    
    private func scheduleAutoSave() {
        cancelAutoSaveTimer()
        
        guard hasUnsavedChanges else { return }
        
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: autoSaveDelay, repeats: false) { _ in
            Task { @MainActor in
                performAutoSave()
            }
        }
    }
    
    private func performAutoSave() {
        guard hasUnsavedChanges else { return }
        
        isAutoSaving = true
        
        // Simulate async save operation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if let existingEntry = currentEntry {
                // Update existing entry
                dataService.updateEntry(existingEntry, content: content)
            } else {
                // Create new entry with selected date
                currentEntry = dataService.createEntry(content: content, date: selectedDate)
            }
            
            lastSavedContent = content
            isAutoSaving = false
        }
    }
    
    private func cancelAutoSaveTimer() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = nil
    }
    
    // MARK: - Actions
    
    private func finalSave() {
        if hasUnsavedChanges {
            performAutoSave()
        }
        dismiss()
    }
    
    private func cancelEntry() {
        // If we have an auto-saved entry but user cancels, we might want to delete it
        // For now, we'll keep it as the user might have intended to save it
        cancelAutoSaveTimer()
        dismiss()
    }
    
    public init(selectedDate: Date = Date()) {
        self.selectedDate = selectedDate
    }
}

// MARK: - Previews

#Preview("Empty Entry") {
    EntryCreationView()
        .environment(DataService.preview)
}

#Preview("With Content") {
    @Previewable @State var content = "This is a sample entry with some initial content to test the auto-save functionality and character count display."
    
    EntryCreationView()
        .environment(DataService.preview)
}