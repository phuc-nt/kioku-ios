import SwiftUI
import SwiftData

struct TimeTravelView: View {
    let selectedDate: Date
    let onDateSelected: (Date) -> Void
    let onDismiss: () -> Void
    
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Month Cards
            monthCardsView
        }
        .background(Color(.systemBackground))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: -5)
    }
    
    private var headerView: some View {
        VStack(spacing: 12) {
            // Drag indicator
            RoundedRectangle(cornerRadius: 2.5)
                .fill(Color(.systemGray3))
                .frame(width: 36, height: 5)
                .padding(.top, 8)
            
            // Title
            Text("Time Travel to \(selectedDate.formatted(.dateTime.month(.wide).day()))")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            Text("Select a month to jump to the same day")
                .font(.caption)
                .foregroundColor(.secondary)
                .padding(.horizontal, 20)
        }
        .padding(.bottom, 20)
    }
    
    private var monthCardsView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(previousMonths, id: \.self) { date in
                    monthCard(for: date)
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 34) // Safe area padding
        }
    }
    
    private func monthCard(for date: Date) -> some View {
        let hasEntries = hasEntriesForSameDay(in: date)
        let targetDate = getTargetDate(for: date)
        
        return VStack(spacing: 8) {
            // Month/Year
            Text(dateFormatter.string(from: date))
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(hasEntries ? .primary : .secondary)
            
            // Day number
            Text("\(calendar.component(.day, from: selectedDate))")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(hasEntries ? .accentColor : .secondary)
            
            // Content indicator
            if hasEntries {
                Circle()
                    .fill(Color.accentColor)
                    .frame(width: 6, height: 6)
            } else {
                Circle()
                    .fill(Color.clear)
                    .frame(width: 6, height: 6)
            }
        }
        .frame(width: 80, height: 90)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(hasEntries ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(hasEntries ? Color.accentColor.opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
        .onTapGesture {
            onDateSelected(targetDate)
            onDismiss()
        }
    }
    
    // MARK: - Helper Methods
    
    private var previousMonths: [Date] {
        var months: [Date] = []
        let currentMonth = calendar.startOfMonth(for: selectedDate)
        
        // Get 6 previous months
        for i in 1...6 {
            if let previousMonth = calendar.date(byAdding: .month, value: -i, to: currentMonth) {
                months.append(previousMonth)
            }
        }
        
        return months
    }
    
    private func hasEntriesForSameDay(in month: Date) -> Bool {
        let targetDate = getTargetDate(for: month)
        let startOfDay = calendar.startOfDay(for: targetDate)
        
        return entries.contains { entry in
            if let entryDate = entry.date {
                return calendar.isDate(entryDate, inSameDayAs: startOfDay)
            } else {
                return calendar.isDate(entry.createdAt, inSameDayAs: startOfDay)
            }
        }
    }
    
    private func getTargetDate(for month: Date) -> Date {
        let targetDay = calendar.component(.day, from: selectedDate)
        let targetYear = calendar.component(.year, from: month)
        let targetMonth = calendar.component(.month, from: month)
        
        var components = DateComponents()
        components.year = targetYear
        components.month = targetMonth
        components.day = targetDay
        
        // Handle edge case where target day doesn't exist in target month (e.g., Feb 30)
        if let targetDate = calendar.date(from: components) {
            return targetDate
        } else {
            // Fallback to last day of target month
            components.day = nil
            let firstOfMonth = calendar.date(from: components) ?? month
            return calendar.date(byAdding: DateComponents(month: 1, day: -1), to: firstOfMonth) ?? month
        }
    }
}

// MARK: - Calendar Extension

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}

// MARK: - View Extension for Corner Radius

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Preview

#Preview {
    TimeTravelView(
        selectedDate: Date(),
        onDateSelected: { _ in },
        onDismiss: { }
    )
    .environment(DataService.preview)
}