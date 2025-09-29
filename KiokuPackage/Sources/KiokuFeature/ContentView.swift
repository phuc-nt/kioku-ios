import SwiftUI
import SwiftData

public struct ContentView: View {
    @Environment(DataService.self) private var dataService
    @State private var selectedDate = Calendar.current.date(from: DateComponents(year: 2025, month: 9, day: 11)) ?? Date()
    @State private var selectedTab = 1
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            CalendarTabView(selectedDate: $selectedDate)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(0)
            
            ChatTabView(selectedDate: $selectedDate)
                .tabItem {
                    Image(systemName: "message")
                    Text("Chat")
                }
                .tag(1)
        }
        .accentColor(.primary)
    }
    
    public init() {}
}

// MARK: - Previews

#Preview {
    ContentView()
        .environment(DataService.preview)
}
