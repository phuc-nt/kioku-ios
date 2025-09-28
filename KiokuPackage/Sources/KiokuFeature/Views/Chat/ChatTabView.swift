import SwiftUI

struct ChatTabView: View {
    @Environment(DataService.self) private var dataService
    @State private var dateContextService: DateContextService?
    @State private var chatContextService: ChatContextService?
    
    let selectedDate: Date
    
    init(selectedDate: Date) {
        self.selectedDate = selectedDate
    }
    
    var body: some View {
        NavigationView {
            Group {
                if let chatContextService = chatContextService {
                    AIChatView(chatContextService: chatContextService)
                } else {
                    ProgressView("Loading chat...")
                }
            }
            .navigationTitle("AI Chat")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            setupServices()
        }
        .onChange(of: selectedDate) {
            updateSelectedDate()
        }
    }
    
    private func setupServices() {
        let dateService = DateContextService(dataService: dataService)
        dateService.updateSelectedDate(selectedDate)
        
        let chatService = ChatContextService(dateContextService: dateService)
        
        self.dateContextService = dateService
        self.chatContextService = chatService
    }
    
    private func updateSelectedDate() {
        dateContextService?.updateSelectedDate(selectedDate)
    }
}

#Preview {
    ChatTabView(selectedDate: Date())
        .environment(DataService.preview)
        .environment(OpenRouterService.shared)
}