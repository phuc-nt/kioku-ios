import Foundation

@Observable
class ChatContextService {
    private let dateContextService: DateContextService
    
    init(dateContextService: DateContextService) {
        self.dateContextService = dateContextService
    }
    
    /// Generate comprehensive chat context for the current selected date
    func generateContext() -> ChatContext {
        let currentNote = dateContextService.getCurrentNote()
        let historicalNotes = dateContextService.getHistoricalNotes()
        let recentNotes = dateContextService.getRecentNotes()
        
        return ChatContext(
            selectedDate: dateContextService.selectedDate,
            currentNote: currentNote,
            historicalNotes: historicalNotes,
            recentNotes: recentNotes
        )
    }
    
    /// Generate context specifically for a note detail chat
    func generateContextForNote(_ entry: Entry) -> ChatContext {
        // Use entry date or current date as fallback
        let entryDate = entry.date ?? Date()
        
        // Update date context to match the entry
        dateContextService.updateSelectedDate(entryDate)
        
        // Get historical notes for this specific date
        let historicalNotes = dateContextService.getHistoricalNotes()
        let recentNotes = dateContextService.getRecentNotes()
        
        return ChatContext(
            selectedDate: entryDate,
            currentNote: entry,
            historicalNotes: historicalNotes,
            recentNotes: recentNotes
        )
    }
    
    /// Create AI prompt with context injection
    func createAIPrompt(userMessage: String, context: ChatContext) -> String {
        return """
        You are a personal AI assistant helping with journal reflection and insights.
        
        \(context.contextSummary)
        
        User Question: \(userMessage)
        
        Please provide thoughtful, personalized insights based on the journal context above. Be empathetic, supportive, and help the user reflect on patterns or connections in their writing.
        """
    }
}