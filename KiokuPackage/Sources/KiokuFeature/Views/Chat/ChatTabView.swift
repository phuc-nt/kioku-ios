import SwiftUI

struct ChatTabView: View {
    @Environment(DataService.self) private var dataService
    @State private var dateContextService: DateContextService?
    @State private var chatContextService: ChatContextService?
    @State private var showAPIKeySetup = false
    @State private var initialContext: ChatContext?
    @State private var chatViewID = UUID()
    @State private var lastLoadedDate: Date?
    @State private var showModelConfig = false // Sprint 17: Model configuration sheet
    @State private var currentConversation: Conversation? // Sprint 17: Track current conversation

    @Binding var selectedDate: Date

    init(selectedDate: Binding<Date>) {
        self._selectedDate = selectedDate
    }

    var body: some View {
        NavigationStack {
            Group {
                if let chatContextService = chatContextService {
                    AIChatView(
                        chatContextService: chatContextService,
                        initialContext: initialContext,
                        modelIdentifier: currentConversation?.modelIdentifier
                    )
                    .id(chatViewID)
                    .environment(OpenRouterService.shared)
                    .onAppear {
                        // Sprint 17: Periodically check for conversation creation
                        startConversationPolling()
                    }
                    .onDisappear {
                        stopConversationPolling()
                    }
                } else {
                    ProgressView("Loading chat...")
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        // Sprint 17: Create conversation if doesn't exist
                        Task {
                            await ensureConversationExists()
                            showModelConfig = true
                        }
                    } label: {
                        Image(systemName: "cpu")
                    }
                }
            }
            .sheet(isPresented: $showModelConfig) {
                if let conversation = currentConversation {
                    ModelConfigurationView(conversation: conversation)
                }
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

            let chatService = ChatContextService(
                dateContextService: dateService,
                dataService: dataService
            )

            self.dateContextService = dateService
            self.chatContextService = chatService

            // Generate initial context for the selected date (async)
            Task {
                self.initialContext = await chatService.generateContext()
                self.lastLoadedDate = selectedDate

                // Sprint 17: Load conversation for model configuration
                self.currentConversation = await dataService.fetchConversation(forDate: selectedDate)
            }
        } else if !Calendar.current.isDate(selectedDate, inSameDayAs: lastLoadedDate ?? Date.distantPast) {
            // Date changed while chat is visible - update context
            dateContextService?.updateSelectedDate(selectedDate)
            if let chatContextService = chatContextService {
                Task {
                    self.initialContext = await chatContextService.generateContext()
                    self.lastLoadedDate = selectedDate

                    // Sprint 17: Reload conversation for new date
                    self.currentConversation = await dataService.fetchConversation(forDate: selectedDate)

                    // Force recreate AIChatView with new date context
                    chatViewID = UUID()
                }
            }
        }
    }
    
    private func updateSelectedDateAndContext() {
        // Only recreate chat if date changed to a different day
        guard !Calendar.current.isDate(selectedDate, inSameDayAs: lastLoadedDate ?? Date.distantPast) else {
            return
        }

        dateContextService?.updateSelectedDate(selectedDate)

        // Regenerate context when date changes (async)
        if let chatContextService = chatContextService {
            Task {
                self.initialContext = await chatContextService.generateContext()
                self.lastLoadedDate = selectedDate

                // Sprint 17: Reload conversation for new date
                self.currentConversation = await dataService.fetchConversation(forDate: selectedDate)

                // Force recreate AIChatView with new context
                chatViewID = UUID()
            }
        }
    }

    // Sprint 17: Ensure conversation exists before showing model config
    @MainActor
    private func ensureConversationExists() async {
        if currentConversation == nil {
            // Create new conversation with default model
            let newConversation = Conversation(
                title: "Chat for \(selectedDate.formatted(date: .abbreviated, time: .omitted))",
                associatedDate: selectedDate
            )
            newConversation.modelIdentifier = ModelValidationService.defaultModel

            dataService.modelContext.insert(newConversation)
            try? dataService.modelContext.save()

            // Update current conversation reference
            currentConversation = newConversation
        }
    }

    // Sprint 17: Polling for conversation creation
    @State private var conversationPollTimer: Timer?

    private func startConversationPolling() {
        // Poll every 2 seconds to check if conversation was created
        conversationPollTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true) { _ in
            Task { @MainActor in
                let conversation = await self.dataService.fetchConversation(forDate: self.selectedDate)
                if conversation != nil && self.currentConversation == nil {
                    // Conversation was just created
                    self.currentConversation = conversation
                } else if conversation != nil {
                    // Update existing conversation reference
                    self.currentConversation = conversation
                }
            }
        }
    }

    private func stopConversationPolling() {
        conversationPollTimer?.invalidate()
        conversationPollTimer = nil
    }
}

#Preview {
    ChatTabView(selectedDate: .constant(Date()))
        .environment(DataService.preview)
        .environment(OpenRouterService.shared)
}