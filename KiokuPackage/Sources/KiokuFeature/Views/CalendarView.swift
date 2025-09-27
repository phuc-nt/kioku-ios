import SwiftUI
import SwiftData

enum SearchPeriod: String, CaseIterable {
    case allTime = "All Time"
    case thisMonth = "This Month"
    case lastThreeMonths = "Last 3 Months"
    case thisYear = "This Year"
    case lastYear = "Last Year"
    
    var dateRange: (start: Date?, end: Date?) {
        let calendar = Calendar.current
        let now = Date()
        
        switch self {
        case .allTime:
            return (nil, nil)
        case .thisMonth:
            let startOfMonth = calendar.dateInterval(of: .month, for: now)?.start
            return (startOfMonth, now)
        case .lastThreeMonths:
            let threeMonthsAgo = calendar.date(byAdding: .month, value: -3, to: now)
            return (threeMonthsAgo, now)
        case .thisYear:
            let startOfYear = calendar.dateInterval(of: .year, for: now)?.start
            return (startOfYear, now)
        case .lastYear:
            let startOfLastYear = calendar.date(byAdding: .year, value: -1, to: calendar.dateInterval(of: .year, for: now)?.start ?? now)
            let endOfLastYear = calendar.date(byAdding: .day, value: -1, to: calendar.dateInterval(of: .year, for: now)?.start ?? now)
            return (startOfLastYear, endOfLastYear)
        }
    }
}

public struct CalendarView: View {
    @Environment(DataService.self) private var dataService
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]
    
    @State private var selectedDate = Date()
    @State private var currentMonth = Date()
    @State private var showingDateEntry = false
    @State private var showingYearView = false
    @State private var showingTimeTravelControls = false
    @State private var showingDatePicker = false
    @State private var datePickerSelection = Date()
    @State private var showingTemporalSearch = false
    @State private var searchText = ""
    @State private var searchResults: [Entry] = []
    @State private var selectedSearchPeriod: SearchPeriod = .allTime
    
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
                if showingYearView {
                    yearView
                } else {
                    // Month header with navigation
                    monthHeaderView
                    
                    // Days of week header
                    daysOfWeekHeader
                    
                    // Calendar grid
                    calendarGrid
                    
                    // Time travel controls
                    if showingTimeTravelControls {
                        timeTravelControlsView
                    }
                    
                    Spacer()
                }
            }
            .navigationTitle("Calendar")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        showingTemporalSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        datePickerSelection = currentMonth
                        showingDatePicker = true
                    }) {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingDateEntry) {
                DateEntryView(selectedDate: selectedDate)
            }
            .sheet(isPresented: $showingDatePicker) {
                datePickerView
            }
            .sheet(isPresented: $showingTemporalSearch) {
                temporalSearchView
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
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingYearView = true
                }
            }) {
                Text(dateFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
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
                    } onLongPress: {
                        selectedDate = date
                        showingTimeTravelControls = true
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
    
    // MARK: - Year View
    
    private var yearView: some View {
        VStack(spacing: 0) {
            yearHeaderView
            yearGrid
            Spacer()
        }
    }
    
    private var yearHeaderView: some View {
        HStack {
            Button(action: previousYear) {
                Image(systemName: "chevron.left")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
            
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingYearView = false
                }
            }) {
                Text(yearFormatter.string(from: currentMonth))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            Spacer()
            
            Button(action: nextYear) {
                Image(systemName: "chevron.right")
                    .font(.title2)
                    .foregroundColor(.accentColor)
            }
        }
        .padding()
        .background(Color(.systemGray6))
    }
    
    private var yearGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
            ForEach(monthsInYear, id: \.self) { month in
                YearMonthView(
                    month: month,
                    isCurrentMonth: calendar.isDate(month, equalTo: currentMonth, toGranularity: .month),
                    hasEntries: hasEntries(for: month)
                ) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        currentMonth = month
                        showingYearView = false
                    }
                }
            }
        }
        .padding()
    }
    
    private var monthsInYear: [Date] {
        let year = calendar.component(.year, from: currentMonth)
        return (1...12).compactMap { month in
            calendar.date(from: DateComponents(year: year, month: month))
        }
    }
    
    private var yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    private func hasEntries(for month: Date) -> Bool {
        guard let monthInterval = calendar.dateInterval(of: .month, for: month) else { return false }
        
        return entries.contains { entry in
            let entryDate = entry.date ?? entry.createdAt
            return monthInterval.contains(entryDate)
        }
    }
    
    private func previousYear() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .year, value: -1, to: currentMonth) ?? currentMonth
        }
    }
    
    private func nextYear() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = calendar.date(byAdding: .year, value: 1, to: currentMonth) ?? currentMonth
        }
    }
    
    // MARK: - Time Travel Controls
    
    private var timeTravelControlsView: some View {
        VStack(spacing: 16) {
            // Header
            HStack {
                Text("Time Travel to \(dayFormatter.string(from: selectedDate))")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Button("Done") {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingTimeTravelControls = false
                    }
                }
                .foregroundColor(.accentColor)
            }
            .padding(.horizontal)
            
            // Same day navigation options
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(sameDayPreviousMonths, id: \.self) { date in
                        SameDayMonthCard(
                            date: date,
                            hasEntry: hasEntry(for: date),
                            isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month)
                        ) {
                            navigateToSameDay(date)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
        .background(Color(.systemGray6))
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private var dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter
    }()
    
    private var sameDayPreviousMonths: [Date] {
        let targetDay = calendar.component(.day, from: selectedDate)
        let targetMonth = calendar.component(.month, from: selectedDate)
        let targetYear = calendar.component(.year, from: selectedDate)
        
        var dates: [Date] = []
        
        // Get same day for the last 12 months (excluding current month)
        for monthOffset in 1...12 {
            if let previousMonth = calendar.date(byAdding: .month, value: -monthOffset, to: selectedDate) {
                let previousYear = calendar.component(.year, from: previousMonth)
                let previousMonthNumber = calendar.component(.month, from: previousMonth)
                
                // Create date for same day in previous month
                if let sameDay = calendar.date(from: DateComponents(year: previousYear, month: previousMonthNumber, day: targetDay)) {
                    dates.append(sameDay)
                }
            }
        }
        
        return dates
    }
    
    private func navigateToSameDay(_ date: Date) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = date
            selectedDate = date
            showingTimeTravelControls = false
        }
    }
    
    // MARK: - Date Picker View
    
    private var datePickerView: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Jump to Date")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Select any date to quickly navigate")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Date Picker
                DatePicker(
                    "Select Date",
                    selection: $datePickerSelection,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .padding(.horizontal)
                
                // Recent Dates Section
                if !recentDates.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Recent Dates")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 12) {
                            ForEach(recentDates, id: \.self) { date in
                                Button(action: {
                                    datePickerSelection = date
                                    jumpToDate(date)
                                }) {
                                    VStack(spacing: 4) {
                                        Text(dateFormatter.string(from: date))
                                            .font(.subheadline)
                                            .fontWeight(.medium)
                                        
                                        if hasEntryOnDate(date) {
                                            Circle()
                                                .fill(Color.blue)
                                                .frame(width: 6, height: 6)
                                        }
                                    }
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Jump Button
                Button(action: {
                    jumpToDate(datePickerSelection)
                }) {
                    Text("Jump to Date")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingDatePicker = false
                    }
                }
            }
        }
    }
    
    private var temporalSearchView: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 8) {
                    Text("Temporal Search")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Search entries based on time periods")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top)
                
                // Search Text Field
                VStack(alignment: .leading, spacing: 8) {
                    Text("Search Content")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    TextField("Enter search terms...", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            performTemporalSearch()
                        }
                }
                .padding(.horizontal)
                
                // Time Period Filters
                VStack(alignment: .leading, spacing: 12) {
                    Text("Time Period")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 12) {
                        ForEach(SearchPeriod.allCases, id: \.self) { period in
                            Button(action: {
                                selectedSearchPeriod = period
                                performTemporalSearch()
                            }) {
                                Text(period.rawValue)
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundColor(selectedSearchPeriod == period ? .white : .primary)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(selectedSearchPeriod == period ? Color.blue : Color(.systemGray6))
                                    .cornerRadius(8)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                }
                .padding(.horizontal)
                
                // Search Results
                if !searchResults.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Search Results (\(searchResults.count))")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        ScrollView {
                            LazyVStack(spacing: 8) {
                                ForEach(searchResults, id: \.id) { entry in
                                    SearchResultRow(entry: entry) {
                                        // Navigate to entry date
                                        jumpToEntryDate(entry)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                } else if !searchText.isEmpty {
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 40))
                            .foregroundColor(.secondary)
                        
                        Text("No results found")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Try adjusting your search terms or time period")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                
                Spacer()
                
                // Clear Search Button
                if !searchText.isEmpty || !searchResults.isEmpty {
                    Button(action: {
                        clearSearch()
                    }) {
                        Text("Clear Search")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                }
            }
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingTemporalSearch = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Search") {
                        performTemporalSearch()
                    }
                    .disabled(searchText.isEmpty)
                }
            }
        }
    }
    
    // MARK: - Date Picker Helper Functions
    
    private var recentDates: [Date] {
        // Get dates with entries from the last 30 days
        let thirtyDaysAgo = calendar.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let datesWithEntries = entries
            .compactMap { entry in
                calendar.dateInterval(of: .day, for: entry.createdAt)?.start
            }
            .filter { $0 >= thirtyDaysAgo }
            .sorted(by: { $0 > $1 })
        
        // Remove duplicates and take first 6
        let uniqueDates = Array(Set(datesWithEntries)).sorted(by: { $0 > $1 })
        return Array(uniqueDates.prefix(6))
    }
    
    private func hasEntryOnDate(_ date: Date) -> Bool {
        let dayStart = calendar.startOfDay(for: date)
        let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
        
        return entries.contains { entry in
            entry.createdAt >= dayStart && entry.createdAt < dayEnd
        }
    }
    
    private func jumpToDate(_ date: Date) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = date
            selectedDate = date
        }
        showingDatePicker = false
    }
    
    // MARK: - Temporal Search Helper Functions
    
    private func performTemporalSearch() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        let dateRange = selectedSearchPeriod.dateRange
        
        // Filter entries based on search text and time period
        let filteredEntries = entries.filter { entry in
            // Check if entry content contains search text (case insensitive)
            let contentMatches = entry.content.localizedCaseInsensitiveContains(searchText)
            
            // Check if entry falls within selected time period
            let dateMatches: Bool
            if let startDate = dateRange.start, let endDate = dateRange.end {
                dateMatches = entry.createdAt >= startDate && entry.createdAt <= endDate
            } else if let startDate = dateRange.start {
                dateMatches = entry.createdAt >= startDate
            } else if let endDate = dateRange.end {
                dateMatches = entry.createdAt <= endDate
            } else {
                dateMatches = true // All time
            }
            
            return contentMatches && dateMatches
        }
        
        searchResults = filteredEntries.sorted { $0.createdAt > $1.createdAt }
    }
    
    private func jumpToEntryDate(_ entry: Entry) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentMonth = entry.createdAt
            selectedDate = entry.createdAt
        }
        showingTemporalSearch = false
    }
    
    private func clearSearch() {
        searchText = ""
        searchResults = []
        selectedSearchPeriod = .allTime
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let isCurrentMonth: Bool
    let hasEntry: Bool
    let onTap: () -> Void
    let onLongPress: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        VStack(spacing: 4) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16, weight: isToday ? .bold : .medium))
                .foregroundColor(textColor)
            
            // Enhanced content indicator
            contentIndicator
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
        .onLongPressGesture {
            onLongPress()
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
    
    private var contentIndicator: some View {
        Group {
            if hasEntry {
                // Entry exists - blue dot
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 6, height: 6)
                    .accessibilityLabel("Has journal entry")
            } else if isToday {
                // Today but no entry - subtle gray dot
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 4, height: 4)
                    .accessibilityLabel("Today - no entry yet")
            } else {
                // No entry, not today - invisible spacer
                Circle()
                    .fill(Color.clear)
                    .frame(width: 4, height: 4)
                    .accessibilityHidden(true)
            }
        }
    }
}

struct SearchResultRow: View {
    let entry: Entry
    let onTap: () -> Void
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(dateFormatter.string(from: entry.createdAt))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(entry.content)
                    .font(.body)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct YearMonthView: View {
    let month: Date
    let isCurrentMonth: Bool
    let hasEntries: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            Text(monthFormatter.string(from: month))
                .font(.headline)
                .fontWeight(isCurrentMonth ? .bold : .medium)
                .foregroundColor(isCurrentMonth ? .accentColor : .primary)
            
            // Enhanced content indicator for year view
            yearContentIndicator
        }
        .frame(width: 80, height: 60)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(isCurrentMonth ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(isCurrentMonth ? Color.accentColor : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onTap()
        }
    }
    
    private var yearContentIndicator: some View {
        Group {
            if hasEntries {
                // Month has entries - blue dot
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 8, height: 8)
                    .accessibilityLabel("Month has journal entries")
            } else if isCurrentMonth {
                // Current month but no entries - subtle gray dot
                Circle()
                    .fill(Color.gray.opacity(0.4))
                    .frame(width: 6, height: 6)
                    .accessibilityLabel("Current month - no entries yet")
            } else {
                // No entries, not current month - very subtle placeholder
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 4, height: 4)
                    .accessibilityLabel("No entries this month")
            }
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
    @State private var showingTimeTravelView = false
    
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
                
                // Time travel section
                if !previousYearEntries.isEmpty {
                    timeTravelSection
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
    
    // MARK: - Time Travel Support
    
    private var previousYearEntries: [(Date, Entry)] {
        let calendar = Calendar.current
        let currentYear = calendar.component(.year, from: selectedDate)
        let currentMonth = calendar.component(.month, from: selectedDate)
        let currentDay = calendar.component(.day, from: selectedDate)
        
        return allEntries.compactMap { entry in
            let entryDate = entry.date ?? entry.createdAt
            let entryYear = calendar.component(.year, from: entryDate)
            let entryMonth = calendar.component(.month, from: entryDate)
            let entryDay = calendar.component(.day, from: entryDate)
            
            // Same month and day, but different (previous) year
            if entryMonth == currentMonth && entryDay == currentDay && entryYear < currentYear {
                return (entryDate, entry)
            }
            return nil
        }.sorted { $0.0 > $1.0 } // Most recent years first
    }
    
    private var timeTravelSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "clock.arrow.circlepath")
                    .foregroundColor(.accentColor)
                Text("Same Day in Previous Years")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Button(action: {
                    showingTimeTravelView = true
                }) {
                    Text("View All")
                        .font(.caption)
                        .foregroundColor(.accentColor)
                }
            }
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(previousYearEntries.prefix(3)), id: \.1.id) { (date, entry) in
                        TimeTravelCardView(date: date, entry: entry)
                    }
                }
                .padding(.horizontal)
            }
        }
        .sheet(isPresented: $showingTimeTravelView) {
            TimeTravelDetailView(
                selectedDate: selectedDate,
                previousYearEntries: previousYearEntries
            )
        }
    }
}

struct SameDayMonthCard: View {
    let date: Date
    let hasEntry: Bool
    let isCurrentMonth: Bool
    let onTap: () -> Void
    
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 8) {
            Text(monthFormatter.string(from: date))
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(isCurrentMonth ? .accentColor : .primary)
            
            Circle()
                .fill(hasEntry ? Color.accentColor : Color.gray.opacity(0.3))
                .frame(width: 8, height: 8)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isCurrentMonth ? Color.accentColor.opacity(0.1) : Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isCurrentMonth ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 1)
        )
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - Time Travel Components

struct TimeTravelCardView: View {
    let date: Date
    let entry: Entry
    
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(yearFormatter.string(from: date))
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.accentColor)
                
                Spacer()
                
                Text("\(Calendar.current.component(.year, from: Date()) - Calendar.current.component(.year, from: date)) years ago")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Text(entry.content)
                .font(.caption)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
        }
        .padding(12)
        .frame(width: 200)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

struct TimeTravelDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedDate: Date
    let previousYearEntries: [(Date, Entry)]
    
    private let fullDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()
    
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Time Travel")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Entries from \(fullDateFormatter.string(from: selectedDate))")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                
                if previousYearEntries.isEmpty {
                    // Empty state
                    VStack(spacing: 16) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 48))
                            .foregroundColor(.secondary)
                        
                        Text("No entries from previous years")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text("Create more entries to see your journey through time!")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                } else {
                    // Timeline view
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(previousYearEntries, id: \.1.id) { (date, entry) in
                                TimeTravelTimelineItemView(date: date, entry: entry, selectedDate: selectedDate)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("Same Day History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct TimeTravelTimelineItemView: View {
    let date: Date
    let entry: Entry
    let selectedDate: Date
    
    private let yearFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 4) {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(Color.accentColor.opacity(0.3))
                    .frame(width: 2)
                    .frame(minHeight: 60)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(yearFormatter.string(from: date))
                        .font(.headline)
                        .foregroundColor(.accentColor)
                    
                    Spacer()
                    
                    Text("\(Calendar.current.component(.year, from: selectedDate) - Calendar.current.component(.year, from: date)) years ago")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(entry.content)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(16)
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

// MARK: - Preview

#Preview {
    CalendarView()
        .environment(DataService.preview)
}