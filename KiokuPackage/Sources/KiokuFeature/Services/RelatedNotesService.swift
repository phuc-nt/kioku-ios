import Foundation
import SwiftData

/// Service for finding related notes (placeholder for future Sprint 16 implementation)
@Observable
public final class RelatedNotesService: @unchecked Sendable {

    private let dataService: DataService

    public init(dataService: DataService) {
        self.dataService = dataService
    }

    // TODO: Implement for Sprint 16 - Knowledge Graph Context Loading
}
