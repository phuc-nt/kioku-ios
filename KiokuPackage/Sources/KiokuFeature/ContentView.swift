import SwiftUI
import SwiftData

public struct ContentView: View {
    @Environment(DataService.self) private var dataService
    @State private var selectedDate = Date()
    @State private var selectedTab = 0
    
    public var body: some View {
        TabView(selection: $selectedTab) {
            CalendarTabView(selectedDate: $selectedDate)
                .tabItem {
                    Image(systemName: "calendar")
                    Text("Calendar")
                }
                .tag(0)

            InsightsView()
                .tabItem {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                    Text("Insights")
                }
                .tag(1)

            KnowledgeGraphView()
                .tabItem {
                    Image(systemName: "network")
                    Text("Graph")
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(3)
        }
    }
    
    public init() {}
}

// MARK: - Previews

#Preview {
    ContentView()
        .environment(DataService.preview)
}
