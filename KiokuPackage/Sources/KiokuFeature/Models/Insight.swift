import Foundation
import SwiftData

@Model
public class Insight: @unchecked Sendable {

    public var id: UUID
    public var type: InsightType
    public var title: String
    public var insightDescription: String // 'description' conflicts with NSObject.description
    public var confidence: Double // 0.0-1.0
    public var generatedAt: Date
    public var timeframe: TimeframeType

    // Evidence
    public var relatedEntityIds: [UUID] // Links to entities
    public var relatedEntryIds: [UUID] // Links to journal entries
    public var evidence: String // Supporting data as JSON string

    // User interaction
    public var isRead: Bool
    public var isStarred: Bool

    public init(
        type: InsightType,
        title: String,
        description: String,
        confidence: Double,
        timeframe: TimeframeType,
        relatedEntityIds: [UUID] = [],
        relatedEntryIds: [UUID] = [],
        evidence: String = ""
    ) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.insightDescription = description
        self.confidence = confidence
        self.generatedAt = Date()
        self.timeframe = timeframe
        self.relatedEntityIds = relatedEntityIds
        self.relatedEntryIds = relatedEntryIds
        self.evidence = evidence
        self.isRead = false
        self.isStarred = false
    }
}

// MARK: - Enums

public enum InsightType: String, Codable, CaseIterable {
    case frequency // Entity mention patterns
    case temporal // Time-based patterns
    case emotional // Mood/emotion patterns
    case social // People/relationship patterns
    case topical // Theme/topic trends
    case suggestion // Proactive suggestions

    public var icon: String {
        switch self {
        case .frequency: return "chart.bar.fill"
        case .temporal: return "clock.fill"
        case .emotional: return "heart.fill"
        case .social: return "person.2.fill"
        case .topical: return "books.vertical.fill"
        case .suggestion: return "lightbulb.fill"
        }
    }

    public var displayName: String {
        switch self {
        case .frequency: return "Frequency Pattern"
        case .temporal: return "Time Pattern"
        case .emotional: return "Emotional Pattern"
        case .social: return "Social Pattern"
        case .topical: return "Topic Trend"
        case .suggestion: return "Suggestion"
        }
    }

    public var color: String {
        switch self {
        case .frequency: return "blue"
        case .temporal: return "purple"
        case .emotional: return "pink"
        case .social: return "green"
        case .topical: return "orange"
        case .suggestion: return "yellow"
        }
    }
}

public enum TimeframeType: String, Codable, CaseIterable {
    case daily
    case weekly
    case monthly

    public var displayName: String {
        switch self {
        case .daily: return "Today"
        case .weekly: return "This Week"
        case .monthly: return "This Month"
        }
    }
}

// MARK: - Preview Support

extension Insight {
    public static let preview: Insight = {
        Insight(
            type: .frequency,
            title: "Work mentioned frequently",
            description: "You've mentioned 'work' 5 times today, suggesting it's on your mind",
            confidence: 0.85,
            timeframe: .daily,
            relatedEntityIds: [],
            relatedEntryIds: [],
            evidence: #"{"mentions": 5, "context": "work stress, deadline, project"}"#
        )
    }()

    public static let previewWeekly: Insight = {
        Insight(
            type: .emotional,
            title: "Mood improves after exercise",
            description: "Your journal entries show a pattern: entries written after exercise have 30% more positive emotions",
            confidence: 0.78,
            timeframe: .weekly,
            relatedEntityIds: [],
            relatedEntryIds: [],
            evidence: #"{"correlation": 0.78, "entries_analyzed": 7}"#
        )
    }()
}
