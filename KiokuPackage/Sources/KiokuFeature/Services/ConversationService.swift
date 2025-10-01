import Foundation
import SwiftData

@Observable
public final class ConversationService: @unchecked Sendable {

    // MARK: - Properties

    private let dataService: DataService
    private let streamingService: StreamingService
    private let openRouterService: OpenRouterService

    // Current active conversation
    public var activeConversation: Conversation?

    // MARK: - Init

    public init(dataService: DataService) {
        self.dataService = dataService
        self.streamingService = StreamingService.shared
        self.openRouterService = OpenRouterService.shared
    }

    // MARK: - Conversation Management

    /// Creates a new conversation and sets it as active
    public func createConversation(title: String = "New Conversation", associatedDate: Date? = nil) -> Conversation {
        let conversation = dataService.createConversation(title: title, associatedDate: associatedDate)
        activeConversation = conversation
        return conversation
    }

    /// Gets or creates a conversation for the current session
    public func getOrCreateDefaultConversation() -> Conversation {
        if let active = activeConversation {
            return active
        }

        // Check if there's an existing conversation
        let conversations = dataService.fetchAllConversations()
        if let recent = conversations.first {
            activeConversation = recent
            return recent
        }

        // Create new conversation
        return createConversation(title: "Chat")
    }

    /// Switches to a different conversation
    public func switchToConversation(_ conversation: Conversation) {
        activeConversation = conversation
    }

    /// Deletes a conversation
    public func deleteConversation(_ conversation: Conversation) {
        if activeConversation?.id == conversation.id {
            activeConversation = nil
        }
        dataService.deleteConversation(conversation)
    }

    /// Fetches all conversations
    public func fetchAllConversations() -> [Conversation] {
        return dataService.fetchAllConversations()
    }

    // MARK: - Message Management

    /// Sends a message and streams the AI response
    public func sendMessage(
        _ content: String,
        contextNotes: [Entry] = [],
        onToken: @escaping (String) -> Void,
        onComplete: @escaping (Result<String, Error>) -> Void
    ) {
        let conversation = getOrCreateDefaultConversation()

        // Add user message
        let userMessage = dataService.addMessage(
            to: conversation,
            content: content,
            isFromUser: true
        )

        // Build context from notes
        var systemPrompt = "You are a helpful AI assistant for a personal journal app called Kioku."

        if !contextNotes.isEmpty {
            systemPrompt += "\n\nHere are some relevant journal entries from the user:\n\n"
            for (index, note) in contextNotes.prefix(15).enumerated() {
                let dateStr = note.date?.formatted(date: .abbreviated, time: .omitted) ?? note.createdAt.formatted(date: .abbreviated, time: .omitted)
                systemPrompt += "Entry \(index + 1) (\(dateStr)):\n\(note.content)\n\n"
            }
            systemPrompt += "Use these entries as context to provide more personalized and relevant responses."
        }

        // Build messages array
        var messages: [OpenRouterService.ChatMessage] = [
            .system(systemPrompt)
        ]

        // Add conversation history (last 10 messages)
        let recentMessages = conversation.messages.suffix(10)
        for msg in recentMessages {
            if msg.id == userMessage.id { continue } // Skip the just-added user message
            if msg.isFromUser {
                messages.append(.user(msg.content))
            } else {
                messages.append(.assistant(msg.content))
            }
        }

        // Add current user message
        messages.append(.user(content))

        // Create AI message placeholder
        let aiMessage = dataService.addMessage(
            to: conversation,
            content: "",
            isFromUser: false,
            contextData: contextNotes.map { $0.id.uuidString }.joined(separator: ",")
        )
        dataService.updateMessageStreamingState(aiMessage, isStreaming: true)

        // Stream response
        streamingService.streamCompletion(
            messages: messages,
            onToken: { [weak self] token in
                guard let self = self else { return }
                // Append token to message
                aiMessage.content += token
                onToken(token)
            },
            onComplete: { [weak self] result in
                guard let self = self else { return }

                dataService.updateMessageStreamingState(aiMessage, isStreaming: false)

                switch result {
                case .success(let fullContent):
                    // Generate title if this is the first exchange
                    if conversation.messages.count == 2 {
                        Task {
                            await self.generateConversationTitle(conversation)
                        }
                    }
                    onComplete(.success(fullContent))

                case .failure(let error):
                    aiMessage.isError = true
                    aiMessage.content = "Error: \(error.localizedDescription)"
                    onComplete(.failure(error))
                }
            }
        )
    }

    /// Regenerates the last AI response
    public func regenerateLastResponse(
        contextNotes: [Entry] = [],
        onToken: @escaping (String) -> Void,
        onComplete: @escaping (Result<String, Error>) -> Void
    ) {
        guard let conversation = activeConversation,
              let lastMessage = conversation.messages.last,
              !lastMessage.isFromUser,
              conversation.messages.count >= 2 else {
            onComplete(.failure(NSError(domain: "ConversationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Cannot regenerate"])))
            return
        }

        // Get the user message before the last AI message
        let userMessage = conversation.messages[conversation.messages.count - 2]

        // Delete the last AI message
        dataService.deleteMessage(lastMessage)

        // Resend with same user message
        sendMessage(userMessage.content, contextNotes: contextNotes, onToken: onToken, onComplete: onComplete)
    }

    /// Stops the current streaming operation
    public func stopStreaming() {
        streamingService.stopStreaming()

        // Update streaming state for active message
        if let conversation = activeConversation,
           let lastMessage = conversation.messages.last,
           !lastMessage.isFromUser {
            dataService.updateMessageStreamingState(lastMessage, isStreaming: false)
        }
    }

    // MARK: - Title Generation

    /// Generates a title for the conversation based on its content
    private func generateConversationTitle(_ conversation: Conversation) async {
        guard conversation.messages.count >= 2 else { return }

        let firstUserMessage = conversation.messages.first { $0.isFromUser }?.content ?? ""
        let prompt = "Generate a short, descriptive title (max 5 words) for a conversation that starts with: \"\(firstUserMessage)\". Only respond with the title, nothing else."

        do {
            let title = try await openRouterService.completeText(
                prompt: prompt,
                model: "google/gemini-2.0-flash-exp:free"
            )

            // Clean up title (remove quotes, trim whitespace)
            let cleanTitle = title
                .trimmingCharacters(in: .whitespacesAndNewlines)
                .trimmingCharacters(in: CharacterSet(charactersIn: "\"'"))
                .prefix(50)

            dataService.updateConversationTitle(conversation, title: String(cleanTitle))

        } catch {
            print("Failed to generate conversation title: \(error)")
            // Fallback: use first few words of first message
            let words = firstUserMessage.split(separator: " ").prefix(5)
            let fallbackTitle = words.joined(separator: " ")
            dataService.updateConversationTitle(conversation, title: String(fallbackTitle))
        }
    }
}

// MARK: - Preview Support

extension ConversationService {
    public static let preview: ConversationService = {
        let service = ConversationService(dataService: DataService.preview)
        return service
    }()
}
