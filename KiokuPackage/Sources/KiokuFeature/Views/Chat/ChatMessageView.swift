import SwiftUI

struct ChatMessageView: View {
    let message: AIChatMessage
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            if message.isFromUser {
                Spacer()
                messageContent
                    .background(Color.accentColor)
                    .foregroundColor(.white)
            } else {
                aiAvatar
                messageContent
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
    }
    
    private var messageContent: some View {
        VStack(alignment: message.isFromUser ? .trailing : .leading, spacing: 4) {
            Text(message.content)
                .font(.body)
                .multilineTextAlignment(message.isFromUser ? .trailing : .leading)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
            
            Text(message.timestamp.formatted(date: .omitted, time: .shortened))
                .font(.caption2)
                .foregroundColor(message.isFromUser ? .white.opacity(0.8) : .secondary)
                .padding(.horizontal, 16)
                .padding(.bottom, 6)
        }
        .background(
            RoundedRectangle(cornerRadius: 18)
                .fill(message.isFromUser ? Color.accentColor : Color(.systemGray6))
        )
        .frame(maxWidth: 280, alignment: message.isFromUser ? .trailing : .leading)
    }
    
    private var aiAvatar: some View {
        Circle()
            .fill(Color.accentColor.opacity(0.2))
            .frame(width: 32, height: 32)
            .overlay(
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.accentColor)
            )
    }
}

#Preview {
    VStack(spacing: 16) {
        ChatMessageView(
            message: AIChatMessage(
                content: "How are you feeling today?",
                isFromUser: true
            )
        )
        
        ChatMessageView(
            message: AIChatMessage(
                content: "Based on your journal entries, I notice you've been reflecting a lot on personal growth lately. That's wonderful! What specific aspect would you like to explore further?",
                isFromUser: false
            )
        )
    }
    .padding()
}