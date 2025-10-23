import SwiftUI
import SwiftData

struct AIChatView: View {
    @Environment(DataService.self) private var dataService
    @Environment(OpenRouterService.self) private var openRouterService

    private let chatContextService: ChatContextService
    private let initialContext: ChatContext?
    private let entry: Entry? // Sprint 16: Entry for generating context with related notes
    private let modelIdentifier: String? // Sprint 17: Optional model override

    @State private var messages: [AIChatMessage] = []
    @State private var currentMessage = ""
    @State private var isStreaming = false
    @State private var currentContext: ChatContext?
    @State private var streamingTask: Task<Void, Never>?
    @State private var conversation: Conversation? // Sprint 17: Track conversation for persistence

    init(
        chatContextService: ChatContextService,
        initialContext: ChatContext? = nil,
        entry: Entry? = nil,
        modelIdentifier: String? = nil
    ) {
        self.chatContextService = chatContextService
        self.initialContext = initialContext
        self.entry = entry
        self.modelIdentifier = modelIdentifier
    }

    var body: some View {
        VStack(spacing: 0) {
            // Sprint 17: Model badge
            if let model = modelIdentifier {
                modelBadgeView(model: model)
                    .padding(.horizontal)
                    .padding(.top, 8)
            }

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

                        if isStreaming {
                            streamingIndicator
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

    private var streamingIndicator: some View {
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
                            .scaleEffect(isStreaming ? 1.0 : 0.5)
                            .animation(
                                Animation.easeInOut(duration: 0.6)
                                    .repeatForever()
                                    .delay(Double(index) * 0.2),
                                value: isStreaming
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
                    .disabled(isStreaming)

                if isStreaming {
                    Button(action: stopStreaming) {
                        Image(systemName: "stop.circle.fill")
                            .font(.title2)
                            .foregroundColor(.red)
                    }
                } else {
                    Button(action: sendMessage) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? .secondary : .accentColor)
                    }
                    .disabled(currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Methods

    private func setupInitialContext() {
        if let initialContext = initialContext {
            currentContext = initialContext
            addContextAsMessages()
        } else {
            Task { @MainActor in
                // Sprint 16: Use generateContextForNote() when entry is provided to get related notes
                if let entry = entry {
                    currentContext = await chatContextService.generateContextForNote(entry)
                } else {
                    currentContext = await chatContextService.generateContext()
                }
                addContextAsMessages()
            }
        }
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
        guard !messageText.isEmpty, !isStreaming else { return }

        // Add user message
        let userMessage = AIChatMessage(content: messageText, isFromUser: true)
        messages.append(userMessage)

        // Clear input
        currentMessage = ""
        isStreaming = true

        // Sprint 17: Ensure conversation exists before persisting
        Task {
            await ensureConversationExists()

            // Persist user message
            if let conv = conversation {
                await dataService.addMessage(
                    to: conv,
                    content: messageText,
                    isFromUser: true,
                    contextData: nil
                )
            }

            // Generate AI response with streaming
            await generateStreamingAIResponse(for: messageText)
        }
    }

    private func stopStreaming() {
        streamingTask?.cancel()
        isStreaming = false
    }

    private func generateStreamingAIResponse(for userMessage: String) async {
        guard let context = currentContext else {
            await handleAIError("No context available")
            return
        }

        let prompt = chatContextService.createAIPrompt(userMessage: userMessage, context: context)

        var fullResponse = ""

        do {
            // Sprint 18: Build full message history for context-aware conversation
            var messageHistory: [OpenRouterService.ChatMessage] = []

            // Add system message with context (only once at the beginning)
            if messages.isEmpty {
                messageHistory.append(.system(prompt))
                print("🤖 [Chat] First message - including system context")
            }

            // Add all previous messages from conversation
            print("🤖 [Chat] Building message history...")
            print("   📊 Total messages in UI: \(messages.count)")
            for (index, msg) in messages.enumerated() {
                if msg.isFromUser {
                    messageHistory.append(.user(msg.content))
                    print("   👤 Message \(index + 1): USER - \(msg.content.prefix(50))...")
                } else {
                    messageHistory.append(.assistant(msg.content))
                    print("   🤖 Message \(index + 1): AI - \(msg.content.prefix(50))...")
                }
            }

            // Add current user message
            messageHistory.append(.user(userMessage))
            print("   👤 Current message: \(userMessage)")
            print("   📤 Total messages sending to API: \(messageHistory.count)")

            // Sprint 17: Use conversation-specific model if provided, otherwise use default
            let modelToUse = modelIdentifier ?? ModelValidationService.defaultModel

            // Sprint 18: Use completeWithHistory for context-aware responses
            print("🌐 [Chat] Calling OpenRouter API with \(messageHistory.count) messages...")
            let response = try await openRouterService.completeWithHistory(
                messages: messageHistory,
                model: modelToUse
            )
            print("✅ [Chat] Received response: \(response.prefix(100))...")
            fullResponse = response

            // Add AI response message and stop streaming
            await MainActor.run {
                let aiMessage = AIChatMessage(
                    content: fullResponse,
                    isFromUser: false
                )
                messages.append(aiMessage)
                isStreaming = false
            }

            // Sprint 17: Persist AI response
            if let conv = conversation {
                await dataService.addMessage(
                    to: conv,
                    content: fullResponse,
                    isFromUser: false,
                    contextData: nil
                )
            }
        } catch {
            await handleAIError("Sorry, I couldn't process your message right now. Please try again.")
        }
    }

    // Sprint 17: Ensure conversation exists for persistence
    private func ensureConversationExists() async {
        guard conversation == nil else { return }

        // Use current date (today) as the conversation date
        // In a real app, this would come from the selected date in the calendar
        let date = Date()

        // Check if conversation already exists for this date
        if let existing = await dataService.fetchConversation(forDate: date) {
            await MainActor.run {
                self.conversation = existing
            }
            return
        }

        // Create new conversation
        let title = "Chat for \(DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none))"
        let newConversation = await dataService.createConversation(
            title: title,
            associatedDate: date
        )

        await MainActor.run {
            self.conversation = newConversation
        }
    }

    private func handleAIError(_ errorMessage: String) async {
        await MainActor.run {
            let errorResponse = AIChatMessage(content: errorMessage, isFromUser: false)
            messages.append(errorResponse)
            isStreaming = false
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

    // Sprint 17: Model badge view
    private func modelBadgeView(model: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "cpu")
                .font(.caption)
                .foregroundColor(.secondary)

            if let modelInfo = ModelValidationService.getModelInfo(model) {
                Text(modelInfo.name)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text(model)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    NavigationView {
        AIChatView(
            chatContextService: ChatContextService(
                dateContextService: DateContextService(dataService: DataService.preview),
                dataService: DataService.preview
            )
        )
        .navigationTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    .environment(DataService.preview)
    .environment(OpenRouterService.shared)
}
