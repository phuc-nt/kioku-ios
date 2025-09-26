import Foundation
import SwiftData

@Observable
public final class KnowledgeGraphService: @unchecked Sendable {
    
    // MARK: - Connection Data Models
    
    public struct EntryConnection: Sendable, Identifiable {
        public let id = UUID()
        public let sourceEntryId: UUID
        public let targetEntryId: UUID
        public let connectionType: ConnectionType
        public let strength: Double // 0.0 - 1.0
        public let commonElements: [CommonElement]
        public let discoveredAt: Date
        
        public enum ConnectionType: String, CaseIterable, Sendable {
            case entityMatch = "entity_match"
            case themeSimilarity = "theme_similarity"
            case sentimentAlignment = "sentiment_alignment"
            case temporalProximity = "temporal_proximity"
            case contentSimilarity = "content_similarity"
        }
        
        public struct CommonElement: Sendable {
            public let type: ElementType
            public let name: String
            public let confidence: Double
            
            public enum ElementType: String, Sendable {
                case entity = "entity"
                case theme = "theme"
                case sentiment = "sentiment"
                case keyword = "keyword"
            }
        }
    }
    
    // MARK: - Properties
    
    private let dataService: DataService
    private let analysisService: AIAnalysisService
    
    // Connection caching
    private var connectionCache: [String: [EntryConnection]] = [:]
    private var lastCacheUpdate: Date?
    private let cacheValidityDuration: TimeInterval = 300 // 5 minutes
    
    // MARK: - Initialization
    
    public init(dataService: DataService, analysisService: AIAnalysisService) {
        self.dataService = dataService
        self.analysisService = analysisService
    }
    
    // MARK: - Public Methods
    
    /// Generate connections between all analyzed entries
    public func generateKnowledgeGraph() async -> [EntryConnection] {
        let allAnalyses = dataService.getAllAnalyses()
        
        guard allAnalyses.count > 1 else {
            print("Knowledge graph requires at least 2 analyzed entries")
            return []
        }
        
        var connections: [EntryConnection] = []
        
        // Compare each pair of entries
        for i in 0..<allAnalyses.count {
            for j in (i + 1)..<allAnalyses.count {
                let analysis1 = allAnalyses[i]
                let analysis2 = allAnalyses[j]
                
                if let connection = await findConnection(between: analysis1, and: analysis2) {
                    connections.append(connection)
                }
            }
        }
        
        // Sort by connection strength (descending)
        connections.sort { $0.strength > $1.strength }
        
        print("Generated \(connections.count) connections in knowledge graph")
        return connections
    }
    
    /// Get connections for a specific entry
    public func getConnections(for entry: Entry) async -> [EntryConnection] {
        let cacheKey = entry.id.uuidString
        
        // Check cache first
        if let cached = connectionCache[cacheKey],
           let lastUpdate = lastCacheUpdate,
           Date().timeIntervalSince(lastUpdate) < cacheValidityDuration {
            return cached
        }
        
        let allConnections = await generateKnowledgeGraph()
        let entryConnections = allConnections.filter { connection in
            connection.sourceEntryId == entry.id || connection.targetEntryId == entry.id
        }
        
        // Update cache
        connectionCache[cacheKey] = entryConnections
        lastCacheUpdate = Date()
        
        return entryConnections
    }
    
    /// Find the strongest connections for a specific entry
    public func getStrongestConnections(for entry: Entry, limit: Int = 5) async -> [EntryConnection] {
        let connections = await getConnections(for: entry)
        return Array(connections.prefix(limit))
    }
    
    /// Get connection statistics
    public func getConnectionStatistics() async -> ConnectionStatistics {
        let allConnections = await generateKnowledgeGraph()
        
        var byType: [EntryConnection.ConnectionType: Int] = [:]
        var strengthDistribution = ConnectionStrengthDistribution()
        
        for connection in allConnections {
            byType[connection.connectionType, default: 0] += 1
            
            switch connection.strength {
            case 0.8...1.0:
                strengthDistribution.strong += 1
            case 0.6..<0.8:
                strengthDistribution.moderate += 1
            case 0.4..<0.6:
                strengthDistribution.weak += 1
            default:
                strengthDistribution.veryWeak += 1
            }
        }
        
        return ConnectionStatistics(
            totalConnections: allConnections.count,
            byType: byType,
            strengthDistribution: strengthDistribution,
            averageStrength: allConnections.map(\.strength).reduce(0, +) / Double(max(allConnections.count, 1))
        )
    }
    
    /// Clear connection cache (useful after new analyses are added)
    public func clearCache() {
        connectionCache.removeAll()
        lastCacheUpdate = nil
    }
    
    // MARK: - Private Methods
    
    private func findConnection(between analysis1: AIAnalysis, and analysis2: AIAnalysis) async -> EntryConnection? {
        guard let data1 = analysis1.analysis, let data2 = analysis2.analysis else {
            return nil
        }
        
        var connections: [EntryConnection] = []
        var commonElements: [EntryConnection.CommonElement] = []
        
        // 1. Entity matching
        let entityConnections = findEntityConnections(data1, data2)
        connections.append(contentsOf: entityConnections.connections)
        commonElements.append(contentsOf: entityConnections.elements)
        
        // 2. Theme similarity
        let themeConnections = findThemeConnections(data1, data2)
        connections.append(contentsOf: themeConnections.connections)
        commonElements.append(contentsOf: themeConnections.elements)
        
        // 3. Sentiment alignment
        let sentimentConnections = findSentimentConnections(data1, data2)
        connections.append(contentsOf: sentimentConnections.connections)
        commonElements.append(contentsOf: sentimentConnections.elements)
        
        // Calculate overall connection strength
        let overallStrength = connections.map(\.strength).reduce(0, +) / Double(max(connections.count, 1))
        
        // Only create connection if strength is meaningful (> 0.3)
        guard overallStrength > 0.3 else { return nil }
        
        // Determine primary connection type (strongest)
        let primaryType = connections.max(by: { $0.strength < $1.strength })?.connectionType ?? .entityMatch
        
        return EntryConnection(
            sourceEntryId: analysis1.entryId,
            targetEntryId: analysis2.entryId,
            connectionType: primaryType,
            strength: overallStrength,
            commonElements: commonElements,
            discoveredAt: Date()
        )
    }
    
    private func findEntityConnections(_ analysis1: AIAnalysisService.EntryAnalysis, _ analysis2: AIAnalysisService.EntryAnalysis) -> (connections: [EntryConnection], elements: [EntryConnection.CommonElement]) {
        var connections: [EntryConnection] = []
        var commonElements: [EntryConnection.CommonElement] = []
        
        for entity1 in analysis1.entities {
            for entity2 in analysis2.entities {
                if entity1.type == entity2.type && entitySimilarity(entity1.name, entity2.name) > 0.8 {
                    let strength = min(entity1.confidence, entity2.confidence) * entitySimilarity(entity1.name, entity2.name)
                    
                    connections.append(EntryConnection(
                        sourceEntryId: analysis1.entryId,
                        targetEntryId: analysis2.entryId,
                        connectionType: .entityMatch,
                        strength: strength,
                        commonElements: [],
                        discoveredAt: Date()
                    ))
                    
                    commonElements.append(EntryConnection.CommonElement(
                        type: .entity,
                        name: entity1.name,
                        confidence: strength
                    ))
                }
            }
        }
        
        return (connections, commonElements)
    }
    
    private func findThemeConnections(_ analysis1: AIAnalysisService.EntryAnalysis, _ analysis2: AIAnalysisService.EntryAnalysis) -> (connections: [EntryConnection], elements: [EntryConnection.CommonElement]) {
        var connections: [EntryConnection] = []
        var commonElements: [EntryConnection.CommonElement] = []
        
        for theme1 in analysis1.themes {
            for theme2 in analysis2.themes {
                let similarity = themeSimilarity(theme1, theme2)
                if similarity > 0.6 {
                    let strength = min(theme1.confidence, theme2.confidence) * similarity
                    
                    connections.append(EntryConnection(
                        sourceEntryId: analysis1.entryId,
                        targetEntryId: analysis2.entryId,
                        connectionType: .themeSimilarity,
                        strength: strength,
                        commonElements: [],
                        discoveredAt: Date()
                    ))
                    
                    commonElements.append(EntryConnection.CommonElement(
                        type: .theme,
                        name: theme1.name,
                        confidence: strength
                    ))
                }
            }
        }
        
        return (connections, commonElements)
    }
    
    private func findSentimentConnections(_ analysis1: AIAnalysisService.EntryAnalysis, _ analysis2: AIAnalysisService.EntryAnalysis) -> (connections: [EntryConnection], elements: [EntryConnection.CommonElement]) {
        var connections: [EntryConnection] = []
        var commonElements: [EntryConnection.CommonElement] = []
        
        // Check overall sentiment alignment
        if analysis1.sentiment.overall == analysis2.sentiment.overall {
            let strength = min(analysis1.sentiment.confidence, analysis2.sentiment.confidence) * 0.7 // Moderate weight for sentiment
            
            connections.append(EntryConnection(
                sourceEntryId: analysis1.entryId,
                targetEntryId: analysis2.entryId,
                connectionType: .sentimentAlignment,
                strength: strength,
                commonElements: [],
                discoveredAt: Date()
            ))
            
            commonElements.append(EntryConnection.CommonElement(
                type: .sentiment,
                name: analysis1.sentiment.overall.rawValue,
                confidence: strength
            ))
        }
        
        // Check common emotions
        let commonEmotions = Set(analysis1.sentiment.emotions).intersection(Set(analysis2.sentiment.emotions))
        if !commonEmotions.isEmpty {
            let emotionStrength = Double(commonEmotions.count) / Double(max(analysis1.sentiment.emotions.count, analysis2.sentiment.emotions.count))
            
            for emotion in commonEmotions {
                commonElements.append(EntryConnection.CommonElement(
                    type: .sentiment,
                    name: emotion,
                    confidence: emotionStrength
                ))
            }
        }
        
        return (connections, commonElements)
    }
    
    // MARK: - Similarity Algorithms
    
    private func entitySimilarity(_ name1: String, _ name2: String) -> Double {
        let normalized1 = name1.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let normalized2 = name2.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Exact match
        if normalized1 == normalized2 {
            return 1.0
        }
        
        // Levenshtein distance based similarity
        let distance = levenshteinDistance(normalized1, normalized2)
        let maxLength = max(normalized1.count, normalized2.count)
        
        guard maxLength > 0 else { return 0.0 }
        
        let similarity = 1.0 - (Double(distance) / Double(maxLength))
        return max(0.0, similarity)
    }
    
    private func themeSimilarity(_ theme1: AIAnalysisService.EntryAnalysis.Theme, _ theme2: AIAnalysisService.EntryAnalysis.Theme) -> Double {
        // Simple keyword matching for now
        let keywords1 = Set(theme1.name.lowercased().components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)).filter { !$0.isEmpty })
        let keywords2 = Set(theme2.name.lowercased().components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters)).filter { !$0.isEmpty })
        
        let intersection = keywords1.intersection(keywords2)
        let union = keywords1.union(keywords2)
        
        guard !union.isEmpty else { return 0.0 }
        
        return Double(intersection.count) / Double(union.count)
    }
    
    private func levenshteinDistance(_ str1: String, _ str2: String) -> Int {
        let a = Array(str1)
        let b = Array(str2)
        let m = a.count
        let n = b.count
        
        var dp = Array(repeating: Array(repeating: 0, count: n + 1), count: m + 1)
        
        for i in 0...m {
            dp[i][0] = i
        }
        
        for j in 0...n {
            dp[0][j] = j
        }
        
        for i in 1...m {
            for j in 1...n {
                if a[i - 1] == b[j - 1] {
                    dp[i][j] = dp[i - 1][j - 1]
                } else {
                    dp[i][j] = 1 + min(dp[i - 1][j], dp[i][j - 1], dp[i - 1][j - 1])
                }
            }
        }
        
        return dp[m][n]
    }
}

// MARK: - Supporting Types

public struct ConnectionStatistics: Sendable {
    public let totalConnections: Int
    public let byType: [KnowledgeGraphService.EntryConnection.ConnectionType: Int]
    public let strengthDistribution: ConnectionStrengthDistribution
    public let averageStrength: Double
}

public struct ConnectionStrengthDistribution: Sendable {
    public var strong: Int = 0      // 0.8 - 1.0
    public var moderate: Int = 0    // 0.6 - 0.8
    public var weak: Int = 0        // 0.4 - 0.6
    public var veryWeak: Int = 0    // 0.0 - 0.4
}

// MARK: - Preview Support

extension KnowledgeGraphService {
    public static let preview: KnowledgeGraphService = {
        return KnowledgeGraphService(
            dataService: DataService.preview,
            analysisService: AIAnalysisService.preview
        )
    }()
}