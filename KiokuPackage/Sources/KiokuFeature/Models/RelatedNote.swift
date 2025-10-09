import Foundation
import SwiftData

/// A note related to another note via Knowledge Graph connections
public struct RelatedNote: Sendable {
    public let entry: Entry
    public let relevanceScore: Double
    public let reason: String

    public init(entry: Entry, relevanceScore: Double, reason: String) {
        self.entry = entry
        self.relevanceScore = relevanceScore
        self.reason = reason
    }
}
