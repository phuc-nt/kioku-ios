import SwiftUI
import SwiftData
import KiokuFeature

@main
struct KiokuApp: App {
    let dataService = DataService()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(dataService)
                .modelContainer(dataService.container)
        }
    }
}
