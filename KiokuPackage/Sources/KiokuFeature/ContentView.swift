import SwiftUI
import SwiftData

public struct ContentView: View {
    @Environment(DataService.self) private var dataService
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]
    @State private var showingEntryCreation = false
    @State private var showingEntryList = false
    @State private var showingBatchProcessing = false
    @State private var showingMigration = false
    @State private var migrationNeeded = false
    
    public var body: some View {
        NavigationView {
            if migrationNeeded {
                MigrationBannerView(onStartMigration: {
                    showingMigration = true
                })
            } else {
                mainContentView
            }
        }
        .onAppear {
            checkMigrationStatus()
        }
        .sheet(isPresented: $showingEntryCreation) {
            EntryCreationView()
        }
        .sheet(isPresented: $showingEntryList) {
            EntryListView()
        }
        .sheet(isPresented: $showingBatchProcessing) {
            BatchProcessingView()
        }
        .fullScreenCover(isPresented: $showingMigration) {
            MigrationFlowView()
        }
    }
    
    private var mainContentView: some View {
        CalendarView()
    }
    
    private func checkMigrationStatus() {
        let entriesNeedingMigration = entries.filter { $0.needsMigration }
        migrationNeeded = !entriesNeedingMigration.isEmpty
    }
    
    public init() {}
}

struct MigrationBannerView: View {
    let onStartMigration: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.system(size: 60))
                    .foregroundColor(.orange)
                
                Text("Migration Required")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Text("Your journal needs to be updated to the new calendar-based format for the best experience.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                Button("Start Migration") {
                    onStartMigration()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                
                Text("This process is safe and reversible")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct EntryStatsView: View {
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]
    
    var body: some View {
        VStack(spacing: 8) {
            Text("\(entries.count)")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(entries.count == 1 ? "Entry" : "Entries")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}

// MARK: - Previews

#Preview {
    ContentView()
        .environment(DataService.preview)
}
