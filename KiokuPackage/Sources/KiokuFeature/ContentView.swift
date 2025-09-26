import SwiftUI
import SwiftData

public struct ContentView: View {
    @Environment(DataService.self) private var dataService
    @Query(sort: \Entry.createdAt, order: .reverse) private var entries: [Entry]
    @State private var showingEntryCreation = false
    @State private var showingEntryList = false
    @State private var showingBatchProcessing = false
    
    public var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Welcome message
                VStack(spacing: 8) {
                    Text("Kioku")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Your AI-Powered Personal Journal")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Quick entry button
                VStack(spacing: 12) {
                    Button {
                        showingEntryCreation = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("New Entry")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(Color.accentColor)
                        .cornerRadius(10)
                    }
                    
                    Text("Tap to capture your thoughts")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Entry count and browse button
                VStack(spacing: 12) {
                    EntryStatsView()
                    
                    // Browse entries button
                    Button {
                        showingEntryList = true
                    } label: {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("Browse Entries")
                        }
                        .font(.subheadline)
                        .foregroundColor(.accentColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(8)
                    }
                    .padding(.horizontal, 32)
                    
                    // AI Tools section
                    if entries.count > 1 {
                        HStack(spacing: 12) {
                            Button {
                                showingBatchProcessing = true
                            } label: {
                                VStack(spacing: 4) {
                                    Image(systemName: "brain.head.profile")
                                        .font(.title3)
                                    Text("AI Tools")
                                        .font(.caption)
                                }
                                .foregroundColor(.purple)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 60)
                            .background(Color.purple.opacity(0.1))
                            .cornerRadius(8)
                        }
                        .padding(.horizontal, 32)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Journal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingBatchProcessing = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                }
            }
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
    }
    
    public init() {}
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
