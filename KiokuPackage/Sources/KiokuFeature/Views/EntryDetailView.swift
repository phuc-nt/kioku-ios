import SwiftUI
import SwiftData

public struct EntryDetailView: View {
    let entry: Entry
    @Environment(\.dismiss) private var dismiss
    @Environment(DataService.self) private var dataService
    @State private var isEditing = false
    @State private var editedContent = ""
    @State private var showingDeleteAlert = false
    @State private var analysisResult: AIAnalysisService.EntryAnalysis?
    @State private var isAnalyzing = false
    @State private var storedAnalyses: [AIAnalysis] = []
    @State private var showingAnalysisHistory = false
    @State private var selectedHistoricalEntry: Entry?
    @State private var showingHistoricalDetail = false
    @State private var showingAIChat = false
    
    @Query(sort: \Entry.createdAt, order: .reverse) private var allEntries: [Entry]
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Date information
                    dateSection
                    
                    Divider()
                    
                    // Content
                    contentSection
                    
                    if !isEditing {
                        Divider()
                        
                        // AI Analysis section
                        aiAnalysisSection
                        
                        // Historical Notes section
                        historicalNotesSection
                    }
                    
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
                        
                        Button {
                            analyzeEntry()
                        } label: {
                            Label("AI Analysis", systemImage: "brain.head.profile")
                        }
                        
                        Button {
                            openChatWithAI()
                        } label: {
                            Label("Chat with AI", systemImage: "message")
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
        .sheet(isPresented: $showingHistoricalDetail) {
            if let selectedHistoricalEntry = selectedHistoricalEntry {
                EntryDetailView(entry: selectedHistoricalEntry)
            }
        }
        .sheet(isPresented: $showingAIChat) {
            NavigationView {
                if let entryDate = entry.date {
                    AIChatView_OLD(chatContextService: createChatContextService(for: entryDate))
                        .navigationTitle("Chat with AI (Legacy)")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .navigationBarTrailing) {
                                Button("Done") {
                                    showingAIChat = false
                                }
                            }
                        }
                } else {
                    Text("Unable to load chat context")
                        .foregroundColor(.secondary)
                }
            }
        }
        .task {
            loadStoredAnalyses()
        }
    }
    
    private var aiAnalysisSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Analysis")
                    .font(.headline)
                
                Spacer()
                
                if !storedAnalyses.isEmpty {
                    Button("History (\(storedAnalyses.count))") {
                        showingAnalysisHistory.toggle()
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
                
                if isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Button("Analyze") {
                        analyzeEntry()
                    }
                    .font(.caption)
                    .foregroundColor(.accentColor)
                }
            }
            
            // Show current analysis result or latest stored analysis
            if let analysis = analysisResult ?? storedAnalyses.first?.analysis {
                // Analysis results
                VStack(alignment: .leading, spacing: 8) {
                    // Sentiment
                    HStack {
                        sentimentIcon(analysis.sentiment.overall)
                        Text(analysis.sentiment.overall.rawValue.capitalized)
                            .font(.subheadline)
                            .fontWeight(.medium)
                        
                        if !analysis.sentiment.emotions.isEmpty {
                            Text("• \(analysis.sentiment.emotions.prefix(3).joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Themes
                    if !analysis.themes.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Themes:")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 4) {
                                ForEach(analysis.themes.prefix(4), id: \.name) { theme in
                                    HStack {
                                        Text(theme.name)
                                            .font(.caption2)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                                }
                            }
                        }
                    }
                    
                    // Key entities
                    if !analysis.entities.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Key Elements:")
                                .font(.caption)
                                .fontWeight(.medium)
                                .foregroundColor(.secondary)
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: 4) {
                                ForEach(analysis.entities.filter { $0.confidence > 0.6 }.prefix(6), id: \.name) { entity in
                                    HStack {
                                        entityIcon(entity.type)
                                        Text(entity.name)
                                            .font(.caption2)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(6)
                                }
                            }
                        }
                    }
                    
                    // Summary
                    if !analysis.summary.isEmpty {
                        Text(analysis.summary)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(.top, 4)
                    }
                    
                    // Analysis metadata
                    HStack {
                        Text("Analyzed with \(analysis.modelUsed.components(separatedBy: "/").last ?? "AI")")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        
                        Spacer()
                        
                        Text(analysis.processingDate, style: .relative)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 4)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Quick actions for analyzed entries
                if !storedAnalyses.isEmpty && storedAnalyses.count > 1 {
                    HStack {
                        Spacer()
                        
                        Button("Analysis History") {
                            showingAnalysisHistory.toggle()
                        }
                        .font(.caption)
                        .foregroundColor(.accentColor)
                    }
                    .padding(.top, 8)
                }
                
                // Analysis history section
                if showingAnalysisHistory && storedAnalyses.count > 1 {
                    analysisHistorySection
                }
                
            } else if !isAnalyzing && storedAnalyses.isEmpty {
                Text("Tap 'Analyze' to get AI insights about this entry")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            } else if !isAnalyzing && !storedAnalyses.isEmpty {
                Text("Previous analyses available. Tap 'History' to view or 'Analyze' for a new analysis.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
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
    
    private var analysisHistorySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Analysis History")
                .font(.subheadline)
                .fontWeight(.medium)
            
            LazyVStack(spacing: 8) {
                ForEach(storedAnalyses.dropFirst(), id: \.id) { storedAnalysis in
                    if let analysis = storedAnalysis.analysis {
                        analysisHistoryCard(analysis, storedAnalysis: storedAnalysis)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray5))
        .cornerRadius(10)
    }
    
    private func analysisHistoryCard(_ analysis: AIAnalysisService.EntryAnalysis, storedAnalysis: AIAnalysis) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                // Sentiment
                HStack(spacing: 4) {
                    sentimentIcon(analysis.sentiment.overall)
                    Text(analysis.sentiment.overall.rawValue.capitalized)
                        .font(.caption)
                        .fontWeight(.medium)
                }
                
                Spacer()
                
                // Date and model
                VStack(alignment: .trailing, spacing: 2) {
                    Text(analysis.processingDate, style: .date)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                    
                    Text(analysis.modelUsed.components(separatedBy: "/").last ?? "AI")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            
            // Themes (compact view)
            if !analysis.themes.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(analysis.themes.prefix(3), id: \.name) { theme in
                            Text(theme.name)
                                .font(.caption2)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray4))
                                .cornerRadius(4)
                        }
                        
                        if analysis.themes.count > 3 {
                            Text("+\(analysis.themes.count - 3)")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            // Summary (truncated)
            if !analysis.summary.isEmpty {
                Text(analysis.summary)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(8)
        .background(Color(.systemBackground))
        .cornerRadius(6)
    }
    
    private func sentimentIcon(_ sentiment: AIAnalysisService.EntryAnalysis.Sentiment.SentimentType) -> some View {
        Group {
            switch sentiment {
            case .positive:
                Image(systemName: "face.smiling")
                    .foregroundColor(.green)
            case .negative:
                Image(systemName: "face.dashed")
                    .foregroundColor(.red)
            case .neutral:
                Image(systemName: "face.expressionless")
                    .foregroundColor(.gray)
            case .mixed:
                Image(systemName: "face.smiling.inverse")
                    .foregroundColor(.orange)
            }
        }
        .font(.caption)
    }
    
    private func entityIcon(_ entityType: AIAnalysisService.EntryAnalysis.Entity.EntityType) -> some View {
        Group {
            switch entityType {
            case .person:
                Image(systemName: "person.fill")
                    .foregroundColor(.blue)
            case .place:
                Image(systemName: "location.fill")
                    .foregroundColor(.green)
            case .event:
                Image(systemName: "calendar")
                    .foregroundColor(.orange)
            case .emotion:
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
            case .concept:
                Image(systemName: "lightbulb.fill")
                    .foregroundColor(.yellow)
            case .activity:
                Image(systemName: "figure.walk")
                    .foregroundColor(.purple)
            }
        }
        .font(.caption2)
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
    
    private func loadStoredAnalyses() {
        storedAnalyses = AIAnalysisService.shared.getStoredAnalyses(for: entry)
        
        // If we have stored analyses, show the latest one
        if let latestAnalysis = storedAnalyses.first?.analysis {
            analysisResult = latestAnalysis
        }
    }
    
    private func analyzeEntry() {
        guard !isAnalyzing else { return }
        
        isAnalyzing = true
        let entryId = entry.id
        let entryContent = entry.content
        
        Task {
            do {
                // This will now persist the analysis automatically, but we need to use entry ID and content
                let analysis = try await AIAnalysisService.shared.analyzeEntry(entryId: entryId, content: entryContent, persist: true)
                
                await MainActor.run {
                    analysisResult = analysis
                    isAnalyzing = false
                    // Reload stored analyses to include the new one
                    loadStoredAnalyses()
                }
            } catch {
                await MainActor.run {
                    isAnalyzing = false
                    print("Analysis failed: \(error)")
                    // In a real app, we'd show an error alert here
                }
            }
        }
    }
    
    private func openChatWithAI() {
        showingAIChat = true
    }
    
    private func createChatContextService(for date: Date) -> ChatContextService {
        let dateContextService = DateContextService(dataService: dataService)
        dateContextService.updateSelectedDate(date)
        return ChatContextService(dateContextService: dateContextService)
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
    
    public init(entry: Entry) {
        self.entry = entry
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