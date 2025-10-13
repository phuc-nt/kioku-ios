import SwiftUI
import SwiftData

public struct EntryDetailView: View {
    let entry: Entry
    var isPresentedInSheet: Bool = false
    @Environment(\.dismiss) private var dismiss
    @Environment(DataService.self) private var dataService
    @State private var isEditing = false
    @State private var editedContent = ""
    @State private var showingDeleteAlert = false
    @State private var selectedHistoricalEntry: Entry?
    @State private var showingHistoricalDetail = false
    @State private var showingAIChat = false
    @State private var allEntries: [Entry] = []
    @State private var showModelConfig = false // Sprint 17: Model configuration sheet
    @State private var chatConversation: Conversation? // Sprint 17: Track conversation for model config
    
    public var body: some View {
        ZStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Date information
                    dateSection

                    Divider()

                    // Content
                    contentSection

                    if !isEditing {
                        Divider()

                        // Historical Notes section
                        historicalNotesSection
                    }

                    Spacer()
                }
                .padding()
                .padding(.bottom, 80) // Space for floating button
            }

            // Floating Chat with AI button
            if !isEditing {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            openChatWithAI()
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "message.fill")
                                    .font(.system(size: 18))
                                Text("Chat with AI")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color.accentColor)
                            .cornerRadius(30)
                            .shadow(color: Color.black.opacity(0.2), radius: 8, x: 0, y: 4)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
        }
        .navigationTitle(entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "Entry Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
                if !isPresentedInSheet {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Done") {
                            if isEditing {
                                saveChanges()
                            }
                            dismiss()
                        }
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
        .alert("Delete Entry", isPresented: $showingDeleteAlert) {
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This action cannot be undone.")
        }
        .sheet(isPresented: $showingHistoricalDetail) {
            if let selectedHistoricalEntry = selectedHistoricalEntry {
                NavigationView {
                    EntryDetailView(entry: selectedHistoricalEntry, isPresentedInSheet: true)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarLeading) {
                                Button("Done") {
                                    showingHistoricalDetail = false
                                }
                            }
                        }
                }
            }
        }
        .sheet(isPresented: $showingAIChat) {
            NavigationView {
                if let entryDate = entry.date {
                    // Sprint 16: Pass entry to AIChatView for related notes discovery
                    AIChatView(
                        chatContextService: createChatContextService(for: entryDate),
                        entry: entry,
                        modelIdentifier: chatConversation?.modelIdentifier
                    )
                    .navigationTitle("Chat with AI")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        // Sprint 17: CPU button for model configuration
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button {
                                Task {
                                    await ensureChatConversationExists(for: entryDate)
                                    showModelConfig = true
                                }
                            } label: {
                                Image(systemName: "cpu")
                            }
                        }

                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingAIChat = false
                            }
                        }
                    }
                    .environment(OpenRouterService.shared)
                    .onAppear {
                        Task {
                            chatConversation = await dataService.fetchConversation(forDate: entryDate)
                        }
                    }
                } else {
                    Text("Unable to load chat context")
                        .foregroundColor(.secondary)
                }
            }
            .sheet(isPresented: $showModelConfig) {
                if let conversation = chatConversation {
                    ModelConfigurationView(conversation: conversation)
                }
            }
        }
        .onAppear {
            loadAllEntries()
        }
    }

    private func loadAllEntries() {
        let descriptor = FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.createdAt, order: .reverse)])
        do {
            allEntries = try dataService.modelContext.fetch(descriptor)
        } catch {
            print("Failed to load entries: \(error)")
            allEntries = []
        }
    }

    @ViewBuilder
    private var historicalNotesSection: some View {
        if !historicalNotes.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                Divider()
                
                Text("Same day in previous months")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Text("Found \(historicalNotes.count) \(historicalNotes.count == 1 ? "entry" : "entries")")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                LazyVStack(spacing: 8) {
                    ForEach(historicalNotes, id: \.id) { historicalEntry in
                        CompactHistoricalNoteCard(
                            entry: historicalEntry,
                            onTap: {
                                selectedHistoricalEntry = historicalEntry
                                showingHistoricalDetail = true
                            }
                        )
                    }
                }
            }
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
    
    private func openChatWithAI() {
        showingAIChat = true
    }
    
    private func createChatContextService(for date: Date) -> ChatContextService {
        let dateContextService = DateContextService(dataService: dataService)
        dateContextService.updateSelectedDate(date)
        return ChatContextService(
            dateContextService: dateContextService,
            dataService: dataService
        )
    }

    // Sprint 17: Ensure conversation exists for model configuration
    @MainActor
    private func ensureChatConversationExists(for date: Date) async {
        if chatConversation == nil {
            // Create new conversation with default model
            let newConversation = Conversation(
                title: "Chat for \(date.formatted(date: .abbreviated, time: .omitted))",
                associatedDate: date
            )
            newConversation.modelIdentifier = ModelValidationService.defaultModel

            dataService.modelContext.insert(newConversation)
            try? dataService.modelContext.save()

            chatConversation = newConversation
        }
    }
    
    // MARK: - Historical Notes Logic
    
    private var historicalNotes: [Entry] {
        guard let entryDate = entry.date else { return [] }
        
        let calendar = Calendar.current
        let selectedDay = calendar.component(.day, from: entryDate)
        let currentMonth = calendar.startOfMonth(for: entryDate)
        
        var historicalEntries: [Entry] = []
        
        // Look back 12 months (excluding current month)
        for monthsBack in 1...12 {
            if let targetMonth = calendar.date(byAdding: .month, value: -monthsBack, to: currentMonth) {
                let targetDate = getTargetDate(for: targetMonth, day: selectedDay, calendar: calendar)
                
                if let matchingEntry = allEntries.first(where: { historicalEntry in
                    if let historicalEntryDate = historicalEntry.date {
                        return calendar.isDate(historicalEntryDate, inSameDayAs: targetDate)
                    } else {
                        return calendar.isDate(historicalEntry.createdAt, inSameDayAs: targetDate)
                    }
                }) {
                    historicalEntries.append(matchingEntry)
                }
            }
        }
        
        // Sort by date, newest first (most recent past month first)
        return historicalEntries.sorted { entry1, entry2 in
            let date1 = entry1.date ?? entry1.createdAt
            let date2 = entry2.date ?? entry2.createdAt
            return date1 > date2
        }
    }
    
    private func getTargetDate(for month: Date, day: Int, calendar: Calendar) -> Date {
        let targetYear = calendar.component(.year, from: month)
        let targetMonth = calendar.component(.month, from: month)
        
        var components = DateComponents()
        components.year = targetYear
        components.month = targetMonth
        components.day = day
        
        // Handle edge case where target day doesn't exist in target month (e.g., Feb 30)
        if let targetDate = calendar.date(from: components) {
            return targetDate
        } else {
            // Fallback to last day of target month
            components.day = nil
            let firstOfMonth = calendar.date(from: components) ?? month
            return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstOfMonth) ?? month
        }
    }
    
    public init(entry: Entry, isPresentedInSheet: Bool = false) {
        self.entry = entry
        self.isPresentedInSheet = isPresentedInSheet
        print("DEBUG EntryDetailView: Init with entry content: \(entry.content)")
    }
}

// MARK: - Compact Historical Note Card Component

struct CompactHistoricalNoteCard: View {
    let entry: Entry
    let onTap: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM yyyy"
        return formatter
    }()
    
    private var previewContent: String {
        let content = entry.content.trimmingCharacters(in: .whitespacesAndNewlines)
        if content.count > 80 {
            return String(content.prefix(80)) + "..."
        }
        return content
    }
    
    private var displayDate: String {
        return dateFormatter.string(from: entry.date ?? entry.createdAt)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(displayDate)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.accentColor)
                
                Text(previewContent)
                    .font(.caption)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color(.systemGray5), lineWidth: 0.5)
                )
        )
        .onTapGesture {
            onTap()
        }
    }
}


// MARK: - Previews

#Preview {
    EntryDetailView(entry: Entry.preview)
        .environment(DataService.preview)
}