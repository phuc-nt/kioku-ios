import SwiftUI
import SwiftData

public struct EntryDetailView: View {
    let entry: Entry
    @Environment(\.dismiss) private var dismiss
    @Environment(DataService.self) private var dataService
    @State private var isEditing = false
    @State private var editedContent = ""
    @State private var showingDeleteAlert = false
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Date information
                    dateSection
                    
                    Divider()
                    
                    // Content
                    contentSection
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Entry Detail")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        if isEditing {
                            saveChanges()
                        }
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        if !isEditing {
                            Button {
                                startEditing()
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                        
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        
                        Button {
                            shareEntry()
                        } label: {
                            Label("Share", systemImage: "square.and.arrow.up")
                        }
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    private var dateSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Created")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
                Text(entry.createdAt, format: .dateTime.weekday().month().day().hour().minute())
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if entry.updatedAt != entry.createdAt {
                HStack {
                    Text("Last modified")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(entry.updatedAt, format: .dateTime.weekday().month().day().hour().minute())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // Word and character count
            HStack {
                Text("\(wordCount) words, \(characterCount) characters")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Content")
                .font(.headline)
            
            if isEditing {
                TextEditor(text: $editedContent)
                    .font(.body)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .frame(minHeight: 200)
                    .toolbar {
                        ToolbarItemGroup(placement: .keyboard) {
                            Spacer()
                            Button("Save") {
                                saveChanges()
                            }
                            .fontWeight(.semibold)
                        }
                    }
            } else {
                Text(entry.content)
                    .font(.body)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
    
    private var wordCount: Int {
        let content = isEditing ? editedContent : entry.content
        let words = content.components(separatedBy: .whitespacesAndNewlines)
        return words.filter { !$0.isEmpty }.count
    }
    
    private var characterCount: Int {
        let content = isEditing ? editedContent : entry.content
        return content.count
    }
    
    private func startEditing() {
        editedContent = entry.content
        isEditing = true
    }
    
    private func saveChanges() {
        guard editedContent != entry.content else {
            isEditing = false
            return
        }
        
        dataService.updateEntry(entry, content: editedContent)
        isEditing = false
    }
    
    private func deleteEntry() {
        dataService.deleteEntry(entry)
        dismiss()
    }
    
    private func shareEntry() {
        let shareText = """
        Journal Entry - \(entry.createdAt.formatted(date: .abbreviated, time: .omitted))
        
        \(entry.content)
        """
        
        // Find the root view controller to present the share sheet
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        
        let activityController = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        // Configure for iPad
        if let popover = activityController.popoverPresentationController {
            popover.sourceView = rootViewController.view
            popover.sourceRect = CGRect(x: rootViewController.view.bounds.midX, 
                                      y: rootViewController.view.bounds.midY, 
                                      width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        rootViewController.present(activityController, animated: true)
    }
    
    public init(entry: Entry) {
        self.entry = entry
    }
}

// MARK: - Previews

#Preview {
    EntryDetailView(entry: Entry.preview)
        .environment(DataService.preview)
}