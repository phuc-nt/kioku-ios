import SwiftUI
import SwiftData
import Foundation

// MARK: - Animation Constants
extension Animation {
    static let calendarTransition = Animation.easeInOut(duration: 0.3)
    static let quickFeedback = Animation.easeOut(duration: 0.15)
    static let smoothTransition = Animation.interpolatingSpring(stiffness: 300, damping: 30)
}

// MARK: - Design System
struct CalendarDesign {
    // Typography
    static let headerFont = Font.system(.title2, design: .default, weight: .semibold)
    static let dayFont = Font.system(.body, design: .default, weight: .medium)
    static let weekdayFont = Font.system(.caption, design: .default, weight: .medium)
    static let titleFont = Font.system(.title, design: .default, weight: .bold)
    
    // Colors
    static let accentColor = Color.accentColor
    static let primaryText = Color.primary
    static let secondaryText = Color.secondary
    static let cardBackground = Color(.systemBackground)
    static let groupedBackground = Color(.systemGroupedBackground)
    
    // Calendar Day Colors
    static let primaryTextColor = Color.primary
    static let secondaryTextColor = Color.secondary
    static let selectedTextColor = Color.accentColor
    static let selectedBackgroundColor = Color.accentColor.opacity(0.15)
    static let todayBackgroundColor = Color.accentColor.opacity(0.08)
    static let entryBackgroundColor = Color.accentColor.opacity(0.05)
    static let selectedBorderColor = Color.accentColor
    static let todayBorderColor = Color.accentColor.opacity(0.6)
    
    // Indicator Colors
    static let entryIndicatorColor = Color.accentColor
    static let todayIndicatorColor = Color.secondary.opacity(0.6)
    
    // Spacing & Sizing
    static let cardPadding: CGFloat = 16
    static let itemSpacing: CGFloat = 12
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 1
    
    // Calendar Day Specific
    static let dayViewHeight: CGFloat = 44
    static let dayCornerRadius: CGFloat = 8
    static let dayBorderWidth: CGFloat = 2
    static let dayIndicatorSpacing: CGFloat = 4
    
    // Indicator Sizing
    static let entryIndicatorSize: CGFloat = 6
    static let todayIndicatorSize: CGFloat = 4
}

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
    @State private var showingEntryDetail = false
    @State private var selectedEntry: Entry?
    @State private var showingYearView = false
    @State private var showingTimeTravelControls = false
    @State private var showingDatePicker = false
    @State private var datePickerSelection = Date()
    @State private var showingTemporalSearch = false
    @State private var searchText = ""
    @State private var searchResults: [Entry] = []
    @State private var selectedSearchPeriod: SearchPeriod = .allTime
    
    // Enhanced search features for US-006
    @State private var searchSuggestions: [String] = []
    @State private var recentSearches: [String] = []
    @State private var isSearching = false
    @State private var showingSuggestions = false
    @State private var searchTask: Task<Void, Never>?
    
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
                    
                    Spacer()
                }
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    // Temporal Search button
                    Button(action: {
                        showingTemporalSearch = true
                    }) {
                        Image(systemName: "magnifyingglass")
                            .font(.headline)
                    }
                    .accessibilityLabel("Search entries")
                }
                
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    // Date Picker button
                    Button(action: {
                        datePickerSelection = currentMonth
                        showingDatePicker = true
                    }) {
                        Image(systemName: "calendar")
                            .font(.headline)
                    }
                    .accessibilityLabel("Jump to date")
                }
            }
            .sheet(isPresented: $showingDateEntry) {
                EntryCreationView(selectedDate: selectedDate)
            }
            .sheet(isPresented: $showingEntryDetail) {
                if let selectedEntry = selectedEntry {
                    EntryDetailView(entry: selectedEntry)
                }
            }
            .sheet(isPresented: $showingDatePicker) {
                datePickerView
            }
            .sheet(isPresented: $showingTemporalSearch) {
                temporalSearchView
            }
        }
    }
    
    // MARK: - Month Header View
    private var monthHeaderView: some View {
        HStack(spacing: 0) {
            Button(action: {
                withAnimation(.calendarTransition) {
                    previousMonth()
                }
            }) {
                Image(systemName: "chevron.left")
                    .font(.headline)
                    .foregroundColor(CalendarDesign.accentColor)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Previous month")
            
            Spacer()
            
            Button(action: {
                withAnimation(.calendarTransition) {
                    showingYearView = true
                }
            }) {
                Text(dateFormatter.string(from: currentMonth))
                    .font(CalendarDesign.headerFont)
                    .foregroundColor(CalendarDesign.primaryText)
            }
            .accessibilityLabel("Show year view")
            
            Spacer()
            
            Button(action: {
                withAnimation(.calendarTransition) {
                    nextMonth()
                }
            }) {
                Image(systemName: "chevron.right")
                    .font(.headline)
                    .foregroundColor(CalendarDesign.accentColor)
                    .frame(width: 44, height: 44)
            }
            .accessibilityLabel("Next month")
        }
        .padding(.horizontal, CalendarDesign.itemSpacing)
        .padding(.vertical, 8)
    }
    
    // MARK: - Days of Week Header
    private var daysOfWeekHeader: some View {
        HStack(spacing: 0) {
            ForEach(calendar.shortWeekdaySymbols, id: \.self) { daySymbol in
                Text(daySymbol)
                    .font(CalendarDesign.weekdayFont)
                    .foregroundColor(CalendarDesign.secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, CalendarDesign.itemSpacing)
        .padding(.bottom, 8)
    }
    
    // MARK: - Calendar Grid
    private var calendarGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 4) {
            ForEach(daysInMonth.indices, id: \.self) { index in
                if let date = daysInMonth[index] {
                    CalendarDayView(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        isToday: calendar.isDateInToday(date),
                        isCurrentMonth: calendar.isDate(date, equalTo: currentMonth, toGranularity: .month),
                        hasEntry: hasEntry(for: date)
                    ) {
                        selectedDate = date
                        if let existingEntry = getEntry(for: date) {
                            selectedEntry = existingEntry
                            showingEntryDetail = true
                        } else {
                            showingDateEntry = true
                        }
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
        .padding(CalendarDesign.cardPadding)
        .background(
            RoundedRectangle(cornerRadius: CalendarDesign.cornerRadius)
                .fill(CalendarDesign.cardBackground)
                .shadow(color: .black.opacity(0.05), radius: CalendarDesign.shadowRadius, x: 0, y: 1)
        )
        .padding(.horizontal, CalendarDesign.itemSpacing)
    }
    
    // MARK: - Year View
    private var yearView: some View {
        Text("Year View - Coming Soon")
            .font(.title)
            .padding()
    }
    
    // MARK: - Date Picker View
    private var datePickerView: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Jump to Date")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                DatePicker(
                    "Select Date",
                    selection: $datePickerSelection,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                
                Spacer()
            }
            .navigationTitle("Jump to Date")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingDatePicker = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Jump to Date") {
                        withAnimation(.calendarTransition) {
                            currentMonth = datePickerSelection
                        }
                        showingDatePicker = false
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
    
    // MARK: - Temporal Search View
    private var temporalSearchView: some View {
        NavigationView {
            VStack(spacing: 24) {
                Text("Temporal Search")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.top)
                
                TextField("Search content...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 12) {
                    ForEach(SearchPeriod.allCases, id: \.self) { period in
                        Button(action: {
                            selectedSearchPeriod = period
                            performSearch()
                        }) {
                            Text(period.rawValue)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(selectedSearchPeriod == period ? Color.accentColor : Color(.systemGray6))
                                )
                                .foregroundColor(selectedSearchPeriod == period ? .white : .primary)
                        }
                    }
                }
                .padding(.horizontal)
                
                if !searchResults.isEmpty {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(searchResults, id: \.id) { entry in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(entry.createdAt, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    
                                    Text(entry.content)
                                        .font(.body)
                                        .lineLimit(3)
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // Navigate to entry date
                                    withAnimation(.calendarTransition) {
                                        currentMonth = entry.createdAt
                                        selectedDate = entry.createdAt
                                    }
                                    showingTemporalSearch = false
                                }
                            }
                        }
                        .padding()
                    }
                } else if !searchText.isEmpty {
                    Text("No results found")
                        .foregroundColor(.secondary)
                        .padding()
                }
                
                Spacer()
            }
            .navigationTitle("Temporal Search")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        showingTemporalSearch = false
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
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
    
    private func getEntry(for date: Date) -> Entry? {
        let startOfDay = calendar.startOfDay(for: date)
        return entries.first { entry in
            if let entryDate = entry.date {
                return calendar.isDate(entryDate, inSameDayAs: startOfDay)
            } else {
                return calendar.isDate(entry.createdAt, inSameDayAs: startOfDay)
            }
        }
    }
    
    private func previousMonth() {
        currentMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth) ?? currentMonth
    }
    
    private func nextMonth() {
        currentMonth = calendar.date(byAdding: .month, value: 1, to: currentMonth) ?? currentMonth
    }
    
    private func performSearch() {
        let (startDate, endDate) = selectedSearchPeriod.dateRange
        
        searchResults = entries.filter { entry in
            // Filter by content
            guard entry.content.lowercased().contains(searchText.lowercased()) else {
                return false
            }
            
            // Filter by date range
            if let startDate = startDate {
                guard entry.createdAt >= startDate else { return false }
            }
            
            if let endDate = endDate {
                guard entry.createdAt <= endDate else { return false }
            }
            
            return true
        }
    }
}

// MARK: - Calendar Day View
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
        Button(action: onTap) {
            VStack(spacing: CalendarDesign.dayIndicatorSpacing) {
                Text("\(calendar.component(.day, from: date))")
                    .font(CalendarDesign.dayFont)
                    .foregroundColor(textColor)
                
                // Entry indicator
                if hasEntry {
                    Circle()
                        .fill(CalendarDesign.entryIndicatorColor)
                        .frame(width: CalendarDesign.entryIndicatorSize, height: CalendarDesign.entryIndicatorSize)
                } else if isToday {
                    Circle()
                        .fill(CalendarDesign.todayIndicatorColor)
                        .frame(width: CalendarDesign.todayIndicatorSize, height: CalendarDesign.todayIndicatorSize)
                } else {
                    Spacer()
                        .frame(width: CalendarDesign.entryIndicatorSize, height: CalendarDesign.entryIndicatorSize)
                }
            }
            .frame(height: CalendarDesign.dayViewHeight)
            .frame(maxWidth: .infinity)
            .background(backgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: CalendarDesign.dayCornerRadius)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
            .clipShape(RoundedRectangle(cornerRadius: CalendarDesign.dayCornerRadius))
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture {
            onLongPress()
        }
    }
    
    private var textColor: Color {
        if !isCurrentMonth {
            return CalendarDesign.secondaryText.opacity(0.5)
        } else if isSelected {
            return CalendarDesign.selectedTextColor
        } else {
            return CalendarDesign.primaryTextColor
        }
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return CalendarDesign.selectedBackgroundColor
        } else if isToday {
            return CalendarDesign.todayBackgroundColor
        } else if hasEntry {
            return CalendarDesign.entryBackgroundColor
        } else {
            return Color.clear
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return CalendarDesign.selectedBorderColor
        } else if isToday {
            return CalendarDesign.todayBorderColor
        } else {
            return Color.clear
        }
    }
    
    private var borderWidth: CGFloat {
        if isSelected || isToday {
            return CalendarDesign.dayBorderWidth
        } else {
            return 0
        }
    }
}

#Preview {
    CalendarView()
        .environment(DataService.preview)
}