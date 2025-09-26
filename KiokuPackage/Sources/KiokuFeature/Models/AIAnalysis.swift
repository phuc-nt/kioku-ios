import SwiftData
import Foundation

@Model
public final class AIAnalysis: @unchecked Sendable {
    // MARK: - Primary Properties
    public var id: UUID
    public var entryId: UUID // Foreign key to Entry
    public var modelUsed: String // "openai/gpt-4o-mini", "anthropic/claude-3-haiku", etc.
    public var processingDate: Date
    public var analysisVersion: Int // Schema version for future migrations
    
    // MARK: - Queryable Summary Fields (for fast filtering)
    public var overallSentiment: String // "positive", "negative", "neutral", "mixed"
    public var sentimentConfidence: Double
    public var entityCount: Int
    public var themeCount: Int
    
    // MARK: - Detailed Results as JSON (for full structure)
    private var analysisData: Data // Encoded EntryAnalysis struct
    
    // MARK: - Relationships
    public var entry: Entry?
    
    // MARK: - Computed Properties
    
    /// Computed property for structured access to analysis results
    public var analysis: AIAnalysisService.EntryAnalysis? {
        get {
            guard !analysisData.isEmpty else { return nil }
            do {
                return try JSONDecoder().decode(AIAnalysisService.EntryAnalysis.self, from: analysisData)
            } catch {
                print("Failed to decode analysis data for \(id): \(error)")
                return nil
            }
        }
        set {
            if let newValue = newValue {
                do {
                    analysisData = try JSONEncoder().encode(newValue)
                    
                    // Update queryable fields for fast access
                    overallSentiment = newValue.sentiment.overall.rawValue
                    sentimentConfidence = newValue.sentiment.confidence
                    entityCount = newValue.entities.count
                    themeCount = newValue.themes.count
                } catch {
                    print("Failed to encode analysis data: \(error)")
                    analysisData = Data()
                }
            } else {
                analysisData = Data()
                overallSentiment = "neutral"
                sentimentConfidence = 0.0
                entityCount = 0
                themeCount = 0
            }
        }
    }
    
    // MARK: - Initializers
    
    public init(entryId: UUID, analysis: AIAnalysisService.EntryAnalysis) {
        self.id = UUID()
        self.entryId = entryId
        self.modelUsed = analysis.modelUsed
        self.processingDate = analysis.processingDate
        self.analysisVersion = 1 // Current schema version
        
        // Initialize queryable fields
        self.overallSentiment = analysis.sentiment.overall.rawValue
        self.sentimentConfidence = analysis.sentiment.confidence
        self.entityCount = analysis.entities.count
        self.themeCount = analysis.themes.count
        
        // Store detailed analysis data as JSON
        self.analysisData = Data()
        
        // Use computed property to set the analysis data
        self.analysis = analysis
    }
    
    // MARK: - Public Methods
    
    /// Get a summary string for display purposes
    public var displaySummary: String {
        guard let analysis = analysis else {
            return "Analysis unavailable"
        }
        
        var parts: [String] = []
        
        // Sentiment with icon
        let sentimentIcon: String
        switch analysis.sentiment.overall {
        case .positive: sentimentIcon = "😊"
        case .negative: sentimentIcon = "😔"
        case .neutral: sentimentIcon = "😐"
        case .mixed: sentimentIcon = "🤔"
        }
        parts.append("\(sentimentIcon) \(analysis.sentiment.overall.rawValue.capitalized)")
        
        // Top themes (limit to 2)
        let topThemes = analysis.themes
            .sorted { $0.confidence > $1.confidence }
            .prefix(2)
            .map { $0.name }
        
        if !topThemes.isEmpty {
            parts.append("Themes: \(topThemes.joined(separator: ", "))")
        }
        
        return parts.joined(separator: " • ")
    }
    
    /// Check if this analysis is recent (within last 24 hours)
    public var isRecent: Bool {
        return Date().timeIntervalSince(processingDate) < 86400 // 24 hours
    }
    
    /// Get entities of a specific type
    public func entities(ofType type: AIAnalysisService.EntryAnalysis.Entity.EntityType) -> [AIAnalysisService.EntryAnalysis.Entity] {
        return analysis?.entities.filter { $0.type == type } ?? []
    }
    
    /// Get high-confidence entities (confidence > 0.7)
    public var highConfidenceEntities: [AIAnalysisService.EntryAnalysis.Entity] {
        return analysis?.entities.filter { $0.confidence > 0.7 } ?? []
    }
    
    /// Get primary themes (confidence > 0.6)
    public var primaryThemes: [AIAnalysisService.EntryAnalysis.Theme] {
        return analysis?.themes.filter { $0.confidence > 0.6 } ?? []
    }
    
    // MARK: - Migration Support
    
    /// Migrate analysis data to a newer version if needed
    public func migrateToVersion(_ version: Int) {
        guard analysisVersion < version else { return }
        
        switch (analysisVersion, version) {
        case (1, 2):
            // Future migration logic would go here
            // For example, add new fields or transform existing data
            print("Migrating AIAnalysis \(id) from version 1 to 2")
            break
        default:
            print("No migration path available from version \(analysisVersion) to \(version)")
            return
        }
        
        analysisVersion = version
    }
}

// MARK: - Preview Support
extension AIAnalysis {
    /// Sample analysis for previews and testing
    nonisolated(unsafe) public static let preview: AIAnalysis = {
        let sampleAnalysis = AIAnalysisService.EntryAnalysis(
            entryId: UUID(),
            entities: [
                AIAnalysisService.EntryAnalysis.Entity(type: .emotion, name: "gratitude", confidence: 0.9),
                AIAnalysisService.EntryAnalysis.Entity(type: .activity, name: "morning walk", confidence: 0.8),
                AIAnalysisService.EntryAnalysis.Entity(type: .person, name: "family", confidence: 0.7)
            ],
            themes: [
                AIAnalysisService.EntryAnalysis.Theme(
                    name: "Personal Growth",
                    confidence: 0.85,
                    description: "Reflection on self-improvement and mindfulness"
                ),
                AIAnalysisService.EntryAnalysis.Theme(
                    name: "Gratitude Practice",
                    confidence: 0.75,
                    description: "Recognition of positive aspects in daily life"
                )
            ],
            sentiment: AIAnalysisService.EntryAnalysis.Sentiment(
                overall: .positive,
                confidence: 0.82,
                emotions: ["gratitude", "contentment", "peace"]
            ),
            summary: "A reflective entry about morning mindfulness and appreciation for family time.",
            processingDate: Date(),
            modelUsed: "openai/gpt-4o-mini"
        )
        
        return AIAnalysis(entryId: UUID(), analysis: sampleAnalysis)
    }()
    
    nonisolated(unsafe) public static let previewAnalyses: [AIAnalysis] = {
        let entries = [
            (sentiment: AIAnalysisService.EntryAnalysis.Sentiment.SentimentType.positive, summary: "Great day with productive work and quality time with friends"),
            (sentiment: AIAnalysisService.EntryAnalysis.Sentiment.SentimentType.neutral, summary: "Routine day with some reflection on recent life changes"),
            (sentiment: AIAnalysisService.EntryAnalysis.Sentiment.SentimentType.mixed, summary: "Challenging day but with moments of gratitude and learning")
        ]
        
        return entries.enumerated().map { index, data in
            let analysis = AIAnalysisService.EntryAnalysis(
                entryId: UUID(),
                entities: [
                    AIAnalysisService.EntryAnalysis.Entity(type: .emotion, name: "reflection", confidence: 0.8),
                    AIAnalysisService.EntryAnalysis.Entity(type: .activity, name: "work", confidence: 0.7)
                ],
                themes: [
                    AIAnalysisService.EntryAnalysis.Theme(
                        name: "Daily Life",
                        confidence: 0.8,
                        description: "Routine activities and experiences"
                    )
                ],
                sentiment: AIAnalysisService.EntryAnalysis.Sentiment(
                    overall: data.sentiment,
                    confidence: 0.75,
                    emotions: ["reflection", "awareness"]
                ),
                summary: data.summary,
                processingDate: Date().addingTimeInterval(-Double(index) * 86400), // Different days
                modelUsed: "openai/gpt-4o-mini"
            )
            
            return AIAnalysis(entryId: UUID(), analysis: analysis)
        }
    }()
}