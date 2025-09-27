import SwiftUI
import SwiftData

public struct CalendarView: View {
    @Environment(DataService.self) private var dataService
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingDateEntry = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    public init() {}
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Month header with navigation
                monthHeaderView
                
                // Days of week header
                daysOfWeekHeader
                
                // Calendar grid
                calendarGrid
                
                Spacer()
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingDateEntry) {
                DateEntryView(selectedDate: selectedDate)
            }
        }
    }
    
    private var monthHeaderView: some View {
        HStack {
            Button(action: previousMonth) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
            
            Text(dateFormatter.string(from: currentMonth))
                .font(.title2)
                .fontWeight(.semibold)
            
            Spacer()
            
            Button(action: nextMonth) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var daysOfWeekHeader: some View {
        HStack {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }
    
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 1) {
            ForEach(daysInMonth, id: \.self) { date in
                if let date = date {
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        hasEntry: hasEntry(for: date)
                    ) {
                        selectedDate = date
                        showingDateEntry = true
                    }
                } else {
                    Rectangle()
                        .fill(Color.clear)
                        .aspectRatio(1, contentMode: .fit)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var daysInMonth: [Date?] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: currentMonth),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfYear, for: monthInterval.end - 1)
        else { return [] }
        
        var days: [Date?] = []
        var date = monthFirstWeek.start
        
        while date < monthLastWeek.end {
            if calendar.isDate(date, equalTo: currentMonth, toGranularity: .month) {
                days.append(date)
            } else {
                days.append(nil)
            }
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        
        return days
    }
    
    private func hasEntry(for date: Date) -> Bool {
        let startOfDay = calendar.startOfDay(for: date)
        return entries.contains { entry in
            if let entryDate = entry.date {
                return calendar.isDate(entryDate, inSameDayAs: startOfDay)
            } else {
                return calendar.isDate(entry.createdAt, inSameDayAs: startOfDay)
            }
        }
    }
    
    private func previousMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextMonth() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let hasEntry: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isToday ? .bold : .medium))
                .foregroundColor(textColor)
            
            // Content indicator dot
            Circle()
                .fill(hasEntry ? Color.accentColor : Color.clear)
                .frame(width: 6, height: 6)
        }
        .frame(height: 44)
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            onTap()
        }
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return .secondary
        } else if isToday {
            return .primary
        } else {
            return .primary
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return Color.accentColor.opacity(0.1)
        } else if isToday {
            return Color.accentColor.opacity(0.05)
        } else {
            return Color.clear
        }
    }
}

// MARK: - Date Entry View

struct DateEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(DataService.self) private var dataService
    @Query private var allEntries: [Entry]
    
    let selectedDate: Date
    @State private var content = ""
    @State private var existingEntry: Entry?
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Date header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Entry for")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(dateFormatter.string(from: selectedDate))
                        .font(.title2)
                        .fontWeight(.semibold)
                }
                .padding(.horizontal)
                
                // Content editor
                VStack(alignment: .leading, spacing: 8) {
                    Text("Content")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    TextEditor(text: $content)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle(existingEntry != nil ? "Edit Entry" : "New Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveEntry()
                        dismiss()
                    }
                    .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            loadExistingEntry()
        }
    }
    
    private func loadExistingEntry() {
        // Find existing entry for this date
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        
        existingEntry = allEntries.first { entry in
            if let entryDate = entry.date {
                return Calendar.current.isDate(entryDate, inSameDayAs: startOfDay)
            } else {
                return Calendar.current.isDate(entry.createdAt, inSameDayAs: startOfDay)
            }
        }
        
        content = existingEntry?.content ?? ""
    }
    
    private func saveEntry() {
        if let existingEntry = existingEntry {
            // Update existing entry
            dataService.updateEntry(existingEntry, content: content)
        } else {
            // Create new entry with specific date
            let entry = Entry(content: content, date: selectedDate)
            dataService.modelContext.insert(entry)
            try? dataService.modelContext.save()
        }
    }
}

// MARK: - Preview

#Preview {
    CalendarView()
        .environment(DataService.preview)
}