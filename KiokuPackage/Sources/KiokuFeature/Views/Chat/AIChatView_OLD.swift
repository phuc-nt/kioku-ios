import SwiftUI
import SwiftData

struct AIChatView_OLD: View {
    @Environment(DataService.self) private var dataService
    @Environment(OpenRouterService.self) private var openRouterService
    
    private let chatContextService: ChatContextService
    private let initialContext: ChatContext?
    
    @State private var messages: [AIChatMessage] = []
    @State private var currentMessage = ""
    @State private var isLoading = false
    @State private var currentContext: ChatContext?
    
    init(
        chatContextService: ChatContextService,
        initialContext: ChatContext? = nil
    ) {
        self.chatContextService = chatContextService
        self.initialContext = initialContext
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Context display
            if let context = currentContext {
                ChatContextView(context: context)
                    .padding(.top)
            }
            
            // Messages list
            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 8) {
                        if messages.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(messages, id: \.id) { message in
                                ChatMessageView(message: message)
                                    .id(message.id)
                            }
                        }
                        
                        if isLoading {
                            loadingIndicator
                        }
                    }
                    .padding(.vertical)
                }
                .onChange(of: messages.count) {
                    if let lastMessage = messages.last {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            proxy.scrollTo(lastMessage.id, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Message input
            messageInputView
        }
        .onAppear {
            setupInitialContext()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "brain.head.profile")
                .font(.system(size: 48))
                .foregroundColor(.accentColor.opacity(0.6))
            
            Text("AI Assistant")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Ask me anything about your journal patterns, get insights, or just have a conversation about your thoughts.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            if let context = currentContext {
                if context.currentNote != nil || !context.historicalNotes.isEmpty {
                    VStack(spacing: 8) {
                        Text("💡 Try asking:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.accentColor)
                        
                        suggestedQuestions
                    }
                    .padding(.top, 8)
                }
            }
        }
        .padding(.vertical, 32)
    }
    
    private var suggestedQuestions: some View {
        VStack(spacing: 6) {
            ForEach(getSuggestedQuestions(), id: \.self) { question in
                Button(action: {
                    currentMessage = question
                    sendMessage()
                }) {
                    Text(question)
                        .font(.caption)
                        .foregroundColor(.accentColor)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.accentColor.opacity(0.1))
                        .cornerRadius(12)
                }
            }
        }
    }
    
    private var loadingIndicator: some View {
        HStack {
            Circle()
                .fill(Color.accentColor.opacity(0.2))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "brain.head.profile")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.accentColor)
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    ForEach(0..<3) { index in
                        Circle()
                            .fill(Color.accentColor.opacity(0.6))
                            .frame(width: 6, height: 6)
                            .scaleEffect(isLoading ? 1.0 : 0.5)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: isLoading
                            )
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(.systemGray6))
                .cornerRadius(18)
                
                Text("AI is thinking...")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 16)
            }
            
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                TextField("Ask me anything...", text: $currentMessage, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .accentColor)
                }
                .disabled(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isLoading)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }
    
    // MARK: - Methods
    
    private func setupInitialContext() {
        if let initialContext = initialContext {
            currentContext = initialContext
        } else {
            currentContext = chatContextService.generateContext()
        }
        
        // Add context as initial messages so user can see what AI has access to
        addContextAsMessages()
    }
    
    private func addContextAsMessages() {
        guard let context = currentContext else { return }
        
        var contextMessages: [AIChatMessage] = []
        
        // Add current note context
        if let currentNote = context.currentNote {
            let noteMessage = AIChatMessage(
                content: "📖 Today's Note (\(context.selectedDate.formatted(date: .abbreviated, time: .omitted))):\n\n\(currentNote.content)",
                isFromUser: true,
                contextData: "current_note"
            )
            contextMessages.append(noteMessage)
        } else {
            let noNoteMessage = AIChatMessage(
                content: "📝 No note found for \(context.selectedDate.formatted(date: .abbreviated, time: .omitted))",
                isFromUser: true,
                contextData: "no_current_note"
            )
            contextMessages.append(noNoteMessage)
        }
        
        // Add historical notes context
        if !context.historicalNotes.isEmpty {
            let historicalContent = context.historicalNotes.prefix(3).map { entry in
                let dateStr = entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                return "• \(dateStr): \(entry.content)"
            }.joined(separator: "\n\n")
            
            let historicalMessage = AIChatMessage(
                content: "🕒 Historical Notes (same day in previous months):\n\n\(historicalContent)",
                isFromUser: true,
                contextData: "historical_notes"
            )
            contextMessages.append(historicalMessage)
        }
        
        // Add recent notes context
        if !context.recentNotes.isEmpty {
            let recentContent = context.recentNotes.prefix(2).map { entry in
                let dateStr = entry.date?.formatted(date: .abbreviated, time: .omitted) ?? "Unknown date"
                return "• \(dateStr): \(entry.content)"
            }.joined(separator: "\n\n")
            
            let recentMessage = AIChatMessage(
                content: "📅 Recent Notes (past week):\n\n\(recentContent)",
                isFromUser: true,
                contextData: "recent_notes"
            )
            contextMessages.append(recentMessage)
        }
        
        // Add all context messages to the chat
        messages.append(contentsOf: contextMessages)
        
        // Add a helpful AI welcome message
        if !contextMessages.isEmpty {
            let welcomeMessage = AIChatMessage(
                content: "I can see your journal context above. Feel free to ask me about patterns, insights, or anything related to your journaling!",
                isFromUser: false,
                contextData: "ai_welcome"
            )
            messages.append(welcomeMessage)
        }
    }
    
    private func sendMessage() {
        let messageText = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty, !isLoading else { return }
        
        // Add user message
        let userMessage = AIChatMessage(content: messageText, isFromUser: true)
        messages.append(userMessage)
        
        // Clear input
        currentMessage = ""
        isLoading = true
        
        // Generate AI response
        Task {
            await generateAIResponse(for: messageText)
        }
    }
    
    private func generateAIResponse(for userMessage: String) async {
        guard let context = currentContext else {
            await handleAIError("No context available")
            return
        }
        
        let prompt = chatContextService.createAIPrompt(userMessage: userMessage, context: context)
        
        do {
            let response = try await openRouterService.completeText(prompt: prompt)
            
            await MainActor.run {
                let aiMessage = AIChatMessage(
                    content: response,
                    isFromUser: false,
                    contextData: nil
                )
                messages.append(aiMessage)
                isLoading = false
            }
        } catch {
            await handleAIError("Sorry, I couldn't process your message right now. Please try again.")
        }
    }
    
    private func handleAIError(_ errorMessage: String) async {
        await MainActor.run {
            let errorResponse = AIChatMessage(content: errorMessage, isFromUser: false)
            messages.append(errorResponse)
            isLoading = false
        }
    }
    
    private func getSuggestedQuestions() -> [String] {
        guard let context = currentContext else { return [] }
        
        var suggestions: [String] = []
        
        if context.currentNote != nil {
            suggestions.append("What patterns do you see in today's entry?")
            suggestions.append("How does today compare to previous entries?")
        }
        
        if !context.historicalNotes.isEmpty {
            suggestions.append("What growth do you notice over time?")
            suggestions.append("What themes appear consistently?")
        }
        
        if suggestions.isEmpty {
            suggestions = [
                "Help me reflect on my recent thoughts",
                "What should I write about today?",
                "How can I improve my journaling practice?"
            ]
        }
        
        return Array(suggestions.prefix(3))
    }
}

#Preview {
    NavigationView {
        AIChatView_OLD(
            chatContextService: ChatContextService(
                dateContextService: DateContextService(dataService: DataService.preview)
            )
        )
        .navigationTitle("AI Chat OLD")
        .navigationBarTitleDisplayMode(.inline)
    }
    .environment(DataService.preview)
    .environment(OpenRouterService.shared)
}