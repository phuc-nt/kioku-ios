import Foundation
import SwiftData

@Observable
public final class AIAnalysisService: @unchecked Sendable {
    
    public enum AnalysisError: Error, LocalizedError {
        case openRouterNotConfigured
        case analysisParsingFailed
        case entryTooShort
        case networkError(Error)
        case analysisTimeout
        
        public var errorDescription: String? {
            switch self {
            case .openRouterNotConfigured:
                return "OpenRouter API not configured. Please add your API key."
            case .analysisParsingFailed:
                return "Failed to parse AI analysis results"
            case .entryTooShort:
                return "Entry is too short for meaningful analysis"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .analysisTimeout:
                return "Analysis request timed out"
            }
        }
    }
    
    // MARK: - Analysis Data Models
    
    public struct EntryAnalysis: Sendable {
        public let entryId: UUID
        public let entities: [Entity]
        public let themes: [Theme] 
        public let sentiment: Sentiment
        public let summary: String
        public let processingDate: Date
        public let modelUsed: String
        
        public struct Entity: Sendable {
            public let type: EntityType
            public let name: String
            public let confidence: Double // 0.0 - 1.0
            
            public enum EntityType: String, CaseIterable, Sendable {
                case person = "person"
                case place = "place"
                case event = "event"
                case emotion = "emotion"
                case concept = "concept"
                case activity = "activity"
            }
        }
        
        public struct Theme: Sendable {
            public let name: String
            public let confidence: Double // 0.0 - 1.0
            public let description: String
        }
        
        public struct Sentiment: Sendable {
            public let overall: SentimentType
            public let confidence: Double // 0.0 - 1.0
            public let emotions: [String] // ["joy", "gratitude", "anxiety", etc.]
            
            public enum SentimentType: String, CaseIterable, Sendable {
                case positive = "positive"
                case negative = "negative"
                case neutral = "neutral"
                case mixed = "mixed"
            }
        }
    }
    
    // MARK: - Properties
    
    private let openRouter = OpenRouterService.shared
    private let analysisTimeout: TimeInterval = 30.0
    
    // Analysis prompt templates
    private let systemPrompt = """
    You are an expert personal journal analyst. Your task is to analyze journal entries and extract meaningful insights that help with self-reflection and personal growth.
    
    For each journal entry, provide analysis in the following JSON format:
    {
        "entities": [
            {
                "type": "person|place|event|emotion|concept|activity",
                "name": "entity name",
                "confidence": 0.0-1.0
            }
        ],
        "themes": [
            {
                "name": "theme name",
                "confidence": 0.0-1.0,
                "description": "brief theme description"
            }
        ],
        "sentiment": {
            "overall": "positive|negative|neutral|mixed",
            "confidence": 0.0-1.0,
            "emotions": ["emotion1", "emotion2"]
        },
        "summary": "Brief 1-2 sentence summary of the entry"
    }
    
    Guidelines:
    - Focus on meaningful entities and themes, not trivial ones
    - Confidence should reflect how certain you are about each extraction
    - Emotions should be specific and nuanced
    - Summary should capture the essence without being too verbose
    - Be respectful of personal content and maintain privacy focus
    """
    
    // MARK: - Singleton
    
    public static let shared = AIAnalysisService()
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Analyzes a single journal entry and extracts insights
    public func analyzeEntry(_ entry: Entry, model: String? = nil) async throws -> EntryAnalysis {
        return try await analyzeEntry(entryId: entry.id, content: entry.content, model: model)
    }
    
    /// Analyzes journal entry content directly
    public func analyzeEntry(entryId: UUID, content: String, model: String? = nil) async throws -> EntryAnalysis {
        
        // Validate entry content
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw AnalysisError.entryTooShort
        }
        
        guard content.count >= 10 else {
            throw AnalysisError.entryTooShort
        }
        
        // Check OpenRouter configuration
        guard openRouter.hasAPIKey else {
            throw AnalysisError.openRouterNotConfigured
        }
        
        let selectedModel = model ?? openRouter.currentModel
        
        // Create analysis prompt
        let userPrompt = """
        Please analyze the following journal entry:
        
        "\(content)"
        
        Provide your analysis in the specified JSON format.
        """
        
        do {
            // Send request to OpenRouter
            let response = try await withTimeout(seconds: analysisTimeout) {
                try await self.openRouter.completeText(
                    prompt: userPrompt,
                    systemMessage: self.systemPrompt,
                    model: selectedModel
                )
            }
            
            // Parse the response
            let analysis = try parseAnalysisResponse(response, entryId: entryId, modelUsed: selectedModel)
            
            print("Analysis completed for entry \(entryId): \(analysis.entities.count) entities, \(analysis.themes.count) themes")
            
            return analysis
            
        } catch let error as AnalysisError {
            throw error
        } catch {
            throw AnalysisError.networkError(error)
        }
    }
    
    /// Batch analyze multiple entries
    public func analyzeEntries(_ entries: [Entry], model: String? = nil) async throws -> [EntryAnalysis] {
        var results: [EntryAnalysis] = []
        var errors: [Error] = []
        
        for entry in entries {
            do {
                let analysis = try await analyzeEntry(entry, model: model)
                results.append(analysis)
                
                // Add small delay to respect rate limits
                try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                
            } catch {
                print("Failed to analyze entry \(entry.id): \(error)")
                errors.append(error)
            }
        }
        
        // If too many errors, throw the first one
        if errors.count > entries.count / 2 {
            throw errors.first!
        }
        
        return results
    }
    
    /// Get analysis summary for display purposes
    public func getAnalysisSummary(_ analysis: EntryAnalysis) -> String {
        var summaryParts: [String] = []
        
        // Sentiment
        let sentimentIcon = analysis.sentiment.overall == .positive ? "😊" : 
                           analysis.sentiment.overall == .negative ? "😔" : "😐"
        summaryParts.append("\(sentimentIcon) \(analysis.sentiment.overall.rawValue.capitalized)")
        
        // Top themes
        let topThemes = analysis.themes.prefix(2).map { $0.name }
        if !topThemes.isEmpty {
            summaryParts.append("Themes: \(topThemes.joined(separator: ", "))")
        }
        
        // Key entities
        let keyEntities = analysis.entities
            .filter { $0.confidence > 0.7 }
            .prefix(3)
            .map { $0.name }
        
        if !keyEntities.isEmpty {
            summaryParts.append("Key: \(keyEntities.joined(separator: ", "))")
        }
        
        return summaryParts.joined(separator: " • ")
    }
    
    // MARK: - Private Methods
    
    private func parseAnalysisResponse(_ response: String, entryId: UUID, modelUsed: String) throws -> EntryAnalysis {
        do {
            // Find JSON in response (handle cases where AI adds explanation around JSON)
            let jsonString = extractJSON(from: response)
            
            guard let jsonData = jsonString.data(using: .utf8) else {
                throw AnalysisError.analysisParsingFailed
            }
            
            guard let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                throw AnalysisError.analysisParsingFailed
            }
            
            // Parse entities
            let entities = try parseEntities(json["entities"] as? [[String: Any]] ?? [])
            
            // Parse themes
            let themes = try parseThemes(json["themes"] as? [[String: Any]] ?? [])
            
            // Parse sentiment
            let sentiment = try parseSentiment(json["sentiment"] as? [String: Any] ?? [:])
            
            // Get summary
            let summary = json["summary"] as? String ?? "Analysis completed"
            
            return EntryAnalysis(
                entryId: entryId,
                entities: entities,
                themes: themes,
                sentiment: sentiment,
                summary: summary,
                processingDate: Date(),
                modelUsed: modelUsed
            )
            
        } catch {
            print("Failed to parse analysis response: \(error)")
            print("Raw response: \(response)")
            throw AnalysisError.analysisParsingFailed
        }
    }
    
    private func extractJSON(from response: String) -> String {
        // Look for JSON block between ```json and ``` or just find { ... }
        let patterns = [
            "```json\\n?([\\s\\S]*?)```",
            "```([\\s\\S]*?)```",
            "(\\{[\\s\\S]*\\})"
        ]
        
        for pattern in patterns {
            if let regex = try? NSRegularExpression(pattern: pattern, options: []),
               let match = regex.firstMatch(in: response, options: [], range: NSRange(response.startIndex..., in: response)),
               let range = Range(match.range(at: 1), in: response) {
                return String(response[range]).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        return response.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func parseEntities(_ entitiesArray: [[String: Any]]) throws -> [EntryAnalysis.Entity] {
        return entitiesArray.compactMap { entityDict in
            guard let typeString = entityDict["type"] as? String,
                  let type = EntryAnalysis.Entity.EntityType(rawValue: typeString),
                  let name = entityDict["name"] as? String,
                  let confidence = entityDict["confidence"] as? Double else {
                return nil
            }
            
            return EntryAnalysis.Entity(type: type, name: name, confidence: confidence)
        }
    }
    
    private func parseThemes(_ themesArray: [[String: Any]]) throws -> [EntryAnalysis.Theme] {
        return themesArray.compactMap { themeDict in
            guard let name = themeDict["name"] as? String,
                  let confidence = themeDict["confidence"] as? Double else {
                return nil
            }
            
            let description = themeDict["description"] as? String ?? ""
            
            return EntryAnalysis.Theme(name: name, confidence: confidence, description: description)
        }
    }
    
    private func parseSentiment(_ sentimentDict: [String: Any]) throws -> EntryAnalysis.Sentiment {
        guard let overallString = sentimentDict["overall"] as? String,
              let overall = EntryAnalysis.Sentiment.SentimentType(rawValue: overallString),
              let confidence = sentimentDict["confidence"] as? Double else {
            
            // Fallback to neutral sentiment
            return EntryAnalysis.Sentiment(
                overall: .neutral,
                confidence: 0.5,
                emotions: []
            )
        }
        
        let emotions = sentimentDict["emotions"] as? [String] ?? []
        
        return EntryAnalysis.Sentiment(
            overall: overall,
            confidence: confidence,
            emotions: emotions
        )
    }
    
    // Helper function to add timeout to async operations
    private func withTimeout<T: Sendable>(seconds: TimeInterval, operation: @escaping @Sendable () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            // Add the main operation
            group.addTask {
                try await operation()
            }
            
            // Add timeout task
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw AnalysisError.analysisTimeout
            }
            
            // Return first completed result
            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }
}

// MARK: - Preview Support

extension AIAnalysisService {
    public static let preview: AIAnalysisService = {
        let service = AIAnalysisService()
        return service
    }()
    
    /// Creates a sample analysis for previews
    public static let sampleAnalysis = EntryAnalysis(
        entryId: UUID(),
        entities: [
            EntryAnalysis.Entity(type: .emotion, name: "gratitude", confidence: 0.9),
            EntryAnalysis.Entity(type: .activity, name: "morning routine", confidence: 0.8),
            EntryAnalysis.Entity(type: .person, name: "family", confidence: 0.7)
        ],
        themes: [
            EntryAnalysis.Theme(name: "Personal Growth", confidence: 0.85, description: "Reflection on self-improvement"),
            EntryAnalysis.Theme(name: "Mindfulness", confidence: 0.75, description: "Present moment awareness")
        ],
        sentiment: EntryAnalysis.Sentiment(
            overall: .positive,
            confidence: 0.8,
            emotions: ["gratitude", "contentment", "motivation"]
        ),
        summary: "Reflective entry about personal growth and morning mindfulness practices.",
        processingDate: Date(),
        modelUsed: "openai/gpt-4o-mini"
    )
}