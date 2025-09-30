import SwiftUI

struct CalendarTabView: View {
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationStack {
            CalendarView(selectedDate: $selectedDate)
        }
    }
}

#Preview {
    CalendarTabView(selectedDate: .constant(Date()))
        .environment(DataService.preview)
}