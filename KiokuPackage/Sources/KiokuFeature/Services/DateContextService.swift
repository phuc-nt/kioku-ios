import Foundation
import SwiftData

@Observable
class DateContextService {
    private let dataService: DataService
    private var calendar: Calendar = {
        var cal = Calendar.current
        cal.timeZone = TimeZone.current
        return cal
    }()
    
    // Current selected date for context
    var selectedDate: Date = Date()
    
    init(dataService: DataService) {
        self.dataService = dataService
    }
    
    /// Get current note for the selected date
    func getCurrentNote() -> Entry? {
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        // Get all entries and filter using same logic as CalendarView
        let allEntriesDescriptor = FetchDescriptor<Entry>(sortBy: [SortDescriptor(\.updatedAt, order: .reverse)])
        guard let allEntries = try? dataService.modelContext.fetch(allEntriesDescriptor) else {
            return nil
        }
        
        // Use same logic as CalendarView.hasEntry()
        return allEntries.first { entry in
            if let entryDate = entry.date {
                return calendar.isDate(entryDate, inSameDayAs: startOfDay)
            } else {
                return calendar.isDate(entry.createdAt, inSameDayAs: startOfDay)
            }
        }
    }
    
    /// Get historical notes from same day in previous months (excluding current month)
    func getHistoricalNotes() -> [Entry] {
        // Use normalized start of day to avoid timezone issues
        let normalizedDate = calendar.startOfDay(for: selectedDate)
        let selectedDay = calendar.component(.day, from: normalizedDate)
        let currentMonth = calendar.startOfMonth(for: normalizedDate)
        
        
        var historicalEntries: [Entry] = []
        
        // Look back 12 months (excluding current month)
        for monthsBack in 1...12 {
            if let targetMonth = calendar.date(byAdding: .month, value: -monthsBack, to: currentMonth) {
                let targetDate = getTargetDate(for: targetMonth, day: selectedDay)
                let entries = getEntriesForDate(targetDate)
                historicalEntries.append(contentsOf: entries)
            }
        }
        
        return historicalEntries.sorted { 
            guard let date1 = $0.date, let date2 = $1.date else { return false }
            return date1 > date2 
        }
    }
    
    /// Get recent notes from past week
    func getRecentNotes() -> [Entry] {
        let oneWeekAgo = calendar.date(byAdding: .weekOfYear, value: -1, to: selectedDate) ?? selectedDate
        let startOfDay = calendar.startOfDay(for: selectedDate)
        
        let predicate = #Predicate<Entry> { entry in
            entry.date != nil && entry.date! >= oneWeekAgo && entry.date! < startOfDay
        }
        
        let descriptor = FetchDescriptor<Entry>(predicate: predicate, sortBy: [SortDescriptor(\.date, order: .reverse)])
        return (try? dataService.modelContext.fetch(descriptor)) ?? []
    }
    
    /// Update selected date and notify observers
    func updateSelectedDate(_ date: Date) {
        selectedDate = date
    }
    
    // MARK: - Helper Methods
    
    private func getTargetDate(for targetMonth: Date, day: Int) -> Date {
        let components = calendar.dateComponents([.year, .month], from: targetMonth)
        var targetComponents = DateComponents()
        targetComponents.year = components.year
        targetComponents.month = components.month
        targetComponents.day = day
        
        // Handle invalid dates (e.g., Feb 31 -> Feb 28/29)
        return calendar.date(from: targetComponents) ?? targetMonth
    }
    
    private func getEntriesForDate(_ date: Date) -> [Entry] {
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        // Try to find by date field first
        let datePredicate = #Predicate<Entry> { entry in
            entry.date != nil && entry.date! >= startOfDay && entry.date! < endOfDay
        }
        
        let dateDescriptor = FetchDescriptor<Entry>(predicate: datePredicate)
        var entries = (try? dataService.modelContext.fetch(dateDescriptor)) ?? []
        
        // If no entries found with date field, try createdAt field
        if entries.isEmpty {
            let createdAtPredicate = #Predicate<Entry> { entry in
                entry.createdAt >= startOfDay && entry.createdAt < endOfDay
            }
            
            let createdAtDescriptor = FetchDescriptor<Entry>(predicate: createdAtPredicate)
            entries = (try? dataService.modelContext.fetch(createdAtDescriptor)) ?? []
        }
        
        return entries
    }
}

// Note: Calendar.startOfMonth extension already exists in CalendarView.swift