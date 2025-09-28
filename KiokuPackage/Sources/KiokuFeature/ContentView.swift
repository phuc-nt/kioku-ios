import SwiftUI
import SwiftData

public struct ContentView: View {
    @Environment(DataService.self) private var dataService
    
    public var body: some View {
        NavigationView {
            CalendarView()
        }
    }
    
    public init() {}
}

// MARK: - Previews

#Preview {
    ContentView()
        .environment(DataService.preview)
}
