import SwiftUI
import SwiftData

struct StreamingChatView: View {
    @Environment(DataService.self) private var dataService
    @Environment(\.modelContext) private var modelContext

    @State private var conversationService: ConversationService
    @State private var currentMessage = ""
    @State private var isStreaming = false
    @State private var showError: String?

    // Conversation management
    @State private var conversations: [Conversation] = []
    @State private var showSidebar = false

    // Context
    private let chatContextService: ChatContextService
    private let initialContext: ChatContext?

    init(
        dataService: DataService,
        chatContextService: ChatContextService,
        initialContext: ChatContext? = nil
    ) {
        self._conversationService = State(initialValue: ConversationService(dataService: dataService))
        self.chatContextService = chatContextService
        self.initialContext = initialContext
    }

    var body: some View {
        ZStack {
            // Main chat view
            VStack(spacing: 0) {
                // Top bar with sidebar toggle
                topBar

                // Messages list
                messagesListView

                // Message input
                messageInputView
            }

            // Sidebar overlay
            if showSidebar {
                conversationSidebar
            }
        }
        .alert("Error", isPresented: .init(
            get: { showError != nil },
            set: { if !$0 { showError = nil } }
        )) {
            Button("OK") { showError = nil }
        } message: {
            Text(showError ?? "")
        }
        .onAppear {
            setupInitialConversation()
            loadConversations()
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            Button(action: { showSidebar.toggle() }) {
                Image(systemName: showSidebar ? "xmark" : "line.3.horizontal")
                    .font(.title3)
                    .foregroundColor(.accentColor)
            }

            VStack(spacing: 2) {
                Text(conversationService.activeConversation?.title ?? "Chat")
                    .font(.headline)

                if let conversation = conversationService.activeConversation {
                    Text("\(conversation.messageCount) messages")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if isStreaming {
                Button(action: stopStreaming) {
                    Image(systemName: "stop.circle.fill")
                        .font(.title3)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Messages List

    private var messagesListView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 12) {
                    if let conversation = conversationService.activeConversation {
                        if conversation.messages.isEmpty {
                            emptyStateView
                        } else {
                            ForEach(conversation.messages, id: \.id) { message in
                                StreamingMessageBubble(message: message)
                                    .id(message.id)
                            }
                        }
                    }
                }
                .padding()
            }
            .onChange(of: conversationService.activeConversation?.messages.count) {
                if let lastMessage = conversationService.activeConversation?.messages.last {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
            }
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

            Text("Ask me anything about your journal. I'll stream responses in real-time.")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .padding(.vertical, 48)
    }

    // MARK: - Message Input

    private var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(spacing: 12) {
                TextField("Ask me anything...", text: $currentMessage, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(1...4)
                    .disabled(isStreaming)

                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.title2)
                        .foregroundColor(canSendMessage ? .accentColor : .secondary)
                }
                .disabled(!canSendMessage || isStreaming)
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    private var canSendMessage: Bool {
        !currentMessage.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Sidebar

    private var conversationSidebar: some View {
        HStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                // Sidebar header
                HStack {
                    Text("Conversations")
                        .font(.headline)

                    Spacer()

                    Button(action: createNewConversation) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.accentColor)
                    }
                }
                .padding()
                .background(Color(.systemGroupedBackground))

                Divider()

                // Conversation list
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(conversations, id: \.id) { conversation in
                            ConversationRowView(
                                conversation: conversation,
                                isActive: conversationService.activeConversation?.id == conversation.id,
                                onTap: {
                                    switchToConversation(conversation)
                                },
                                onDelete: {
                                    deleteConversation(conversation)
                                }
                            )
                        }
                    }
                }
            }
            .frame(width: 280)
            .background(Color(.systemBackground))
            .shadow(radius: 5)

            // Dimmed background
            Color.black.opacity(0.3)
                .onTapGesture {
                    showSidebar = false
                }
                .ignoresSafeArea()
        }
    }

    // MARK: - Methods

    private func setupInitialConversation() {
        // If we have initial context, create a new conversation for it
        if let context = initialContext {
            let dateStr = context.selectedDate.formatted(date: .abbreviated, time: .omitted)
            _ = conversationService.createConversation(
                title: "Chat for \(dateStr)",
                associatedDate: context.selectedDate
            )
        } else {
            _ = conversationService.getOrCreateDefaultConversation()
        }
    }

    private func loadConversations() {
        conversations = dataService.fetchAllConversations()
    }

    private func createNewConversation() {
        _ = conversationService.createConversation()
        loadConversations()
        showSidebar = false
    }

    private func switchToConversation(_ conversation: Conversation) {
        conversationService.switchToConversation(conversation)
        showSidebar = false
    }

    private func deleteConversation(_ conversation: Conversation) {
        conversationService.deleteConversation(conversation)
        loadConversations()
    }

    private func sendMessage() {
        let messageText = currentMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !messageText.isEmpty, !isStreaming else { return }

        currentMessage = ""
        isStreaming = true

        // Get context notes
        let context = initialContext ?? chatContextService.generateContext()
        let contextNotes = getAllContextNotes(from: context)

        conversationService.sendMessage(
            messageText,
            contextNotes: contextNotes,
            onToken: { _ in
                // Token received - UI updates automatically via SwiftData observation
            },
            onComplete: { @MainActor result in
                isStreaming = false

                switch result {
                case .success:
                    break // Success - messages already in database

                case .failure(let error):
                    showError = error.localizedDescription
                }
            }
        )
    }

    private func stopStreaming() {
        conversationService.stopStreaming()
        isStreaming = false
    }

    private func getAllContextNotes(from context: ChatContext) -> [Entry] {
        var notes: [Entry] = []

        if let currentNote = context.currentNote {
            notes.append(currentNote)
        }

        notes.append(contentsOf: context.historicalNotes.prefix(5))
        notes.append(contentsOf: context.recentNotes.prefix(5))

        return notes
    }
}

// MARK: - Streaming Message Bubble

struct StreamingMessageBubble: View {
    let message: ChatMessage

    var body: some View {
        HStack {
            if message.isFromUser {
                Spacer()
            }

            VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
                Text(message.content.isEmpty && message.isStreaming ? "..." : message.content)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(messageBackground)
                    .foregroundColor(message.isFromUser ? .white : .primary)
                    .cornerRadius(18)

                if message.isStreaming {
                    HStack(spacing: 4) {
                        ForEach(0..<3) { index in
                            Circle()
                                .fill(Color.accentColor.opacity(0.6))
                                .frame(width: 4, height: 4)
                                .scaleEffect(message.isStreaming ? 1.0 : 0.5)
                                .animation(
                                    Animation.easeInOut(duration: 0.6)
                                        .repeatForever()
                                        .delay(Double(index) * 0.2),
                                    value: message.isStreaming
                                )
                        }
                    }
                    .padding(.horizontal, 16)
                }

                if !message.isFromUser && !message.isStreaming {
                    Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 16)
                }
            }

            if !message.isFromUser {
                Spacer()
            }
        }
    }

    private var messageBackground: Color {
        if message.isError {
            return Color.red.opacity(0.2)
        } else if message.isFromUser {
            return Color.accentColor
        } else {
            return Color(.systemGray6)
        }
    }
}

// MARK: - Conversation Row

struct ConversationRowView: View {
    let conversation: Conversation
    let isActive: Bool
    let onTap: () -> Void
    let onDelete: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(conversation.title)
                        .font(.body)
                        .fontWeight(isActive ? .semibold : .regular)
                        .lineLimit(1)

                    if let lastMessage = conversation.lastMessageDate {
                        Text(lastMessage.formatted(date: .abbreviated, time: .shortened))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Text("\(conversation.messageCount) messages")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.caption)
                        .foregroundColor(.red)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(isActive ? Color.accentColor.opacity(0.1) : Color.clear)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationView {
        StreamingChatView(
            dataService: DataService.preview,
            chatContextService: ChatContextService(
                dateContextService: DateContextService(dataService: DataService.preview)
            )
        )
        .navigationTitle("AI Chat")
        .navigationBarTitleDisplayMode(.inline)
    }
    .environment(DataService.preview)
}
