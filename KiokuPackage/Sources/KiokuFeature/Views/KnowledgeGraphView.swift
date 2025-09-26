import SwiftUI
import SwiftData

public struct KnowledgeGraphView: View {
    let entry: Entry
    @Environment(\.dismiss) private var dismiss
    @Environment(DataService.self) private var dataService
    @State private var connections: [KnowledgeGraphService.EntryConnection] = []
    @State private var isLoading = true
    @State private var statistics: ConnectionStatistics?
    
    private let knowledgeGraphService: KnowledgeGraphService
    
    public init(entry: Entry) {
        self.entry = entry
        self.knowledgeGraphService = KnowledgeGraphService(
            dataService: DataService(),
            analysisService: AIAnalysisService.shared
        )
    }
    
    public var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Header section
                    headerSection
                    
                    if isLoading {
                        loadingSection
                    } else if connections.isEmpty {
                        emptyStateSection
                    } else {
                        // Statistics section
                        if let stats = statistics {
                            statisticsSection(stats)
                        }
                        
                        Divider()
                        
                        // Connections section
                        connectionsSection
                    }
                }
                .padding()
            }
            .navigationTitle("Knowledge Graph")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        refreshConnections()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(isLoading)
                }
            }
        }
        .task {
            await loadConnections()
        }
    }
    
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Connected Insights")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Discover patterns and connections between this entry and others in your journal")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            // Entry preview
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(entry.content.prefix(100) + (entry.content.count > 100 ? "..." : ""))
                        .font(.caption)
                        .lineLimit(2)
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                Image(systemName: "link.circle.fill")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
    }
    
    private var loadingSection: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            
            Text("Analyzing connections...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private var emptyStateSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "link.badge.plus")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No Connections Found")
                .font(.headline)
                .foregroundColor(.primary)
            
            Text("This entry doesn't have strong connections to other analyzed entries yet. As you analyze more entries, patterns will emerge.")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 40)
    }
    
    private func statisticsSection(_ stats: ConnectionStatistics) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connection Overview")
                .font(.headline)
            
            HStack(spacing: 16) {
                StatCard(
                    title: "Total",
                    value: "\(stats.totalConnections)",
                    icon: "link",
                    color: .blue
                )
                
                StatCard(
                    title: "Avg Strength",
                    value: String(format: "%.1f%%", stats.averageStrength * 100),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
            }
            
            // Connection types breakdown
            if !stats.byType.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Connection Types")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 8) {
                        ForEach(Array(stats.byType.keys), id: \.self) { type in
                            HStack {
                                connectionTypeIcon(type)
                                Text("\(stats.byType[type] ?? 0)")
                                    .font(.caption)
                                    .fontWeight(.medium)
                                Spacer()
                            }
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                        }
                    }
                }
            }
        }
    }
    
    private var connectionsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Connected Entries")
                .font(.headline)
            
            LazyVStack(spacing: 8) {
                ForEach(connections, id: \.id) { connection in
                    ConnectionCard(
                        connection: connection,
                        dataService: dataService,
                        sourceEntry: entry
                    )
                }
            }
        }
    }
    
    private func connectionTypeIcon(_ type: KnowledgeGraphService.EntryConnection.ConnectionType) -> some View {
        Group {
            switch type {
            case .entityMatch:
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
            case .themeSimilarity:
                Image(systemName: "tag.fill")
                    .foregroundColor(.purple)
            case .sentimentAlignment:
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
            case .temporalProximity:
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
            case .contentSimilarity:
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.green)
            }
        }
        .font(.caption)
    }
    
    private func loadConnections() async {
        let currentEntry = entry // Capture before async boundary
        
        await MainActor.run {
            isLoading = true
        }
        
        // Load connections for this entry
        let entryConnections = await knowledgeGraphService.getConnections(for: currentEntry)
        
        // Load overall statistics
        let stats = await knowledgeGraphService.getConnectionStatistics()
        
        await MainActor.run {
            self.connections = entryConnections
            self.statistics = stats
            self.isLoading = false
        }
    }
    
    private func refreshConnections() {
        Task {
            knowledgeGraphService.clearCache()
            await loadConnections()
        }
    }
}

// MARK: - Supporting Views

private struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                
                Text(title)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

private struct ConnectionCard: View {
    let connection: KnowledgeGraphService.EntryConnection
    let dataService: DataService
    let sourceEntry: Entry
    @State private var connectedEntry: Entry?
    @State private var isLoading = true
    @State private var showingEntryDetail = false
    
    var body: some View {
        Button {
            showingEntryDetail = true
        } label: {
            VStack(alignment: .leading, spacing: 8) {
            HStack {
                connectionTypeIcon(connection.connectionType)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(connectionTypeName(connection.connectionType))
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text("Strength: \(Int(connection.strength * 100))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                strengthIndicator
            }
            
            if let entry = connectedEntry {
                Divider()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.createdAt, style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(entry.content.prefix(150) + (entry.content.count > 150 ? "..." : ""))
                        .font(.caption)
                        .lineLimit(3)
                }
                
                // Common elements
                if !connection.commonElements.isEmpty {
                    commonElementsSection
                }
            } else if isLoading {
                HStack {
                    ProgressView()
                        .scaleEffect(0.7)
                    Text("Loading...")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .task {
            await loadConnectedEntry()
        }
        .sheet(isPresented: $showingEntryDetail) {
            if let entry = connectedEntry {
                EntryDetailView(entry: entry)
            }
        }
    }
    
    private var strengthIndicator: some View {
        HStack(spacing: 2) {
            ForEach(0..<5, id: \.self) { index in
                Circle()
                    .fill(index < Int(connection.strength * 5) ? Color.accentColor : Color(.systemGray4))
                    .frame(width: 6, height: 6)
            }
        }
    }
    
    private var commonElementsSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Common Elements:")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 6) {
                    ForEach(connection.commonElements.prefix(5), id: \.name) { element in
                        HStack(spacing: 4) {
                            elementIcon(element.type)
                            Text(element.name)
                                .font(.caption2)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(.systemGray4))
                        .cornerRadius(4)
                    }
                    
                    if connection.commonElements.count > 5 {
                        Text("+\(connection.commonElements.count - 5)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
    }
    
    private func connectionTypeIcon(_ type: KnowledgeGraphService.EntryConnection.ConnectionType) -> some View {
        Group {
            switch type {
            case .entityMatch:
                Image(systemName: "person.2.fill")
                    .foregroundColor(.blue)
            case .themeSimilarity:
                Image(systemName: "tag.fill")
                    .foregroundColor(.purple)
            case .sentimentAlignment:
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
            case .temporalProximity:
                Image(systemName: "clock.fill")
                    .foregroundColor(.orange)
            case .contentSimilarity:
                Image(systemName: "doc.text.fill")
                    .foregroundColor(.green)
            }
        }
    }
    
    private func elementIcon(_ type: KnowledgeGraphService.EntryConnection.CommonElement.ElementType) -> some View {
        Group {
            switch type {
            case .entity:
                Image(systemName: "circle.fill")
                    .foregroundColor(.blue)
            case .theme:
                Image(systemName: "tag.fill")
                    .foregroundColor(.purple)
            case .sentiment:
                Image(systemName: "heart.fill")
                    .foregroundColor(.pink)
            case .keyword:
                Image(systemName: "textformat")
                    .foregroundColor(.green)
            }
        }
        .font(.caption2)
    }
    
    private func connectionTypeName(_ type: KnowledgeGraphService.EntryConnection.ConnectionType) -> String {
        switch type {
        case .entityMatch:
            return "Entity Match"
        case .themeSimilarity:
            return "Theme Similarity"
        case .sentimentAlignment:
            return "Sentiment Alignment"
        case .temporalProximity:
            return "Temporal Proximity"
        case .contentSimilarity:
            return "Content Similarity"
        }
    }
    
    private func loadConnectedEntry() async {
        let targetId = connection.targetEntryId == sourceEntry.id ? connection.sourceEntryId : connection.targetEntryId
        
        do {
            if let entry = try dataService.fetchEntry(by: targetId) {
                await MainActor.run {
                    self.connectedEntry = entry
                    self.isLoading = false
                }
            }
        } catch {
            await MainActor.run {
                self.isLoading = false
            }
            print("Failed to load connected entry: \(error)")
        }
    }
}

// MARK: - Previews

#Preview {
    KnowledgeGraphView(entry: Entry.preview)
        .environment(DataService.preview)
}