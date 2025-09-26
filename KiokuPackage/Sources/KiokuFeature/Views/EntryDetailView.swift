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
    @State private var showingKnowledgeGraph = false
    
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
                            showingKnowledgeGraph = true
                        } label: {
                            Label("Knowledge Graph", systemImage: "link.circle")
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
        .task {
            loadStoredAnalyses()
        }
        .sheet(isPresented: $showingKnowledgeGraph) {
            KnowledgeGraphView(entry: entry)
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
                if !storedAnalyses.isEmpty {
                    HStack {
                        Button {
                            showingKnowledgeGraph = true
                        } label: {
                            HStack {
                                Image(systemName: "link.circle")
                                Text("View Connections")
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        }
                        
                        Spacer()
                        
                        if storedAnalyses.count > 1 {
                            Button("Analysis History") {
                                showingAnalysisHistory.toggle()
                            }
                            .font(.caption)
                            .foregroundColor(.accentColor)
                        }
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
    
    public init(entry: Entry) {
        self.entry = entry
    }
}

// MARK: - Previews

#Preview {
    EntryDetailView(entry: Entry.preview)
        .environment(DataService.preview)
}