import SwiftUI

struct ChatTabView: View {
    @Environment(DataService.self) private var dataService
    @State private var dateContextService: DateContextService?
    @State private var chatContextService: ChatContextService?
    @State private var showAPIKeySetup = false
    @State private var initialContext: ChatContext?
    @State private var chatViewID = UUID()
    @State private var lastLoadedDate: Date?

    @Binding var selectedDate: Date
    
    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if let chatContextService = chatContextService {
                    StreamingChatView(
                        dataService: dataService,
                        chatContextService: chatContextService,
                        initialContext: initialContext
                    )
                    .id(chatViewID)
                } else {
                    ProgressView("Loading chat...")
                }
            }
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("API Key") {
                        showAPIKeySetup = true
                    }
                }
            }
            .sheet(isPresented: $showAPIKeySetup) {
                APIKeySetupView()
            }
        }
        .onAppear {
            setupServicesIfNeeded()
        }
        .onChange(of: selectedDate) {
            updateSelectedDateAndContext()
        }
    }
    
    private func setupServicesIfNeeded() {
        // Only setup once or when date changes significantly
        if dateContextService == nil || chatContextService == nil {
            let dateService = DateContextService(dataService: dataService)
            dateService.updateSelectedDate(selectedDate)
            
            let chatService = ChatContextService(dateContextService: dateService)
            
            self.dateContextService = dateService
            self.chatContextService = chatService
            
            // Generate initial context for the selected date
            self.initialContext = chatService.generateContext()
            self.lastLoadedDate = selectedDate
        } else if !Calendar.current.isDate(selectedDate, inSameDayAs: lastLoadedDate ?? Date.distantPast) {
            // Date changed while chat is visible - update context
            dateContextService?.updateSelectedDate(selectedDate)
            if let chatContextService = chatContextService {
                self.initialContext = chatContextService.generateContext()
                self.lastLoadedDate = selectedDate
                
                // Force recreate StreamingChatView with new date context
                chatViewID = UUID()
            }
        }
    }
    
    private func updateSelectedDateAndContext() {
        // Only recreate chat if date changed to a different day
        guard !Calendar.current.isDate(selectedDate, inSameDayAs: lastLoadedDate ?? Date.distantPast) else {
            return
        }
        
        dateContextService?.updateSelectedDate(selectedDate)
        
        // Regenerate context when date changes
        if let chatContextService = chatContextService {
            self.initialContext = chatContextService.generateContext()
            self.lastLoadedDate = selectedDate
            
            // Force recreate StreamingChatView with new context
            chatViewID = UUID()
        }
    }
}

#Preview {
    ChatTabView(selectedDate: .constant(Date()))
        .environment(DataService.preview)
        .environment(OpenRouterService.shared)
}