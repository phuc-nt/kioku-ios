import SwiftUI

struct ChatTabView: View {
    @Environment(DataService.self) private var dataService
    @State private var dateContextService: DateContextService?
    @State private var chatContextService: ChatContextService?
    @State private var showAPIKeySetup = false

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
                        chatContextService: chatContextService
                    )
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
    ChatTabView(selectedDate: .constant(Date()))
        .environment(DataService.preview)
        .environment(OpenRouterService.shared)
}