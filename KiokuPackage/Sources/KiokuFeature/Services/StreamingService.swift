import Foundation
import Combine

@Observable
public final class StreamingService: @unchecked Sendable {

    public enum StreamingError: Error, LocalizedError {
        case invalidAPIKey
        case networkError(Error)
        case invalidResponse
        case streamInterrupted
        case decodingError
        case rateLimitExceeded

        public var errorDescription: String? {
            switch self {
            case .invalidAPIKey:
                return "Invalid OpenRouter API key"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from server"
            case .streamInterrupted:
                return "Stream was interrupted"
            case .decodingError:
                return "Failed to decode streaming response"
            case .rateLimitExceeded:
                return "API rate limit exceeded"
            }
        }
    }

    // MARK: - Properties

    private let baseURL = "https://openrouter.ai/api/v1"
    private let keyIdentifier = "com.phucnt.kioku.openrouter.apikey"
    private let geminiModel = "google/gemini-2.0-flash-exp:free"

    // Stream control
    private var currentTask: Task<Void, Never>?
    public private(set) var isStreaming = false

    // MARK: - Singleton

    public static let shared = StreamingService()

    private init() {}

    // MARK: - API Key Management (shared với OpenRouterService)

    public func getAPIKey() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: keyIdentifier,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let keyData = result as? Data,
              let apiKey = String(data: keyData, encoding: .utf8) else {
            throw StreamingError.invalidAPIKey
        }

        return apiKey
    }

    public var hasAPIKey: Bool {
        do {
            _ = try getAPIKey()
            return true
        } catch {
            return false
        }
    }

    // MARK: - Streaming Methods

    /// Streams chat completion với SSE, calling onToken for each token received
    public func streamCompletion(
        messages: [OpenRouterService.ChatMessage],
        onToken: @escaping @MainActor @Sendable (String) -> Void,
        onComplete: @escaping @MainActor @Sendable (Result<String, Error>) -> Void
    ) {
        guard !isStreaming else {
            Task { @MainActor in
                onComplete(.failure(StreamingError.streamInterrupted))
            }
            return
        }

        isStreaming = true

        currentTask = Task { @Sendable [weak self, onToken, onComplete] in
            guard let self = self else { return }

            do {
                guard self.hasAPIKey else {
                    throw StreamingError.invalidAPIKey
                }

                let apiKey = try self.getAPIKey()
                var request = try self.buildStreamingRequest(messages: messages, apiKey: apiKey)

                let (bytes, response) = try await URLSession.shared.bytes(for: request)

                guard let httpResponse = response as? HTTPURLResponse else {
                    throw StreamingError.invalidResponse
                }

                switch httpResponse.statusCode {
                case 200...299:
                    break
                case 401:
                    throw StreamingError.invalidAPIKey
                case 429:
                    throw StreamingError.rateLimitExceeded
                default:
                    throw StreamingError.invalidResponse
                }

                var fullContent = ""

                for try await line in bytes.lines {
                    // Check if task was cancelled
                    if Task.isCancelled {
                        throw StreamingError.streamInterrupted
                    }

                    // SSE format: "data: {json}" hoặc "data: [DONE]"
                    guard line.hasPrefix("data: ") else { continue }

                    let jsonString = String(line.dropFirst(6))

                    // Check for stream completion
                    if jsonString.trimmingCharacters(in: .whitespaces) == "[DONE]" {
                        break
                    }

                    // Parse SSE chunk
                    guard let data = jsonString.data(using: .utf8),
                          let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                          let choices = json["choices"] as? [[String: Any]],
                          let firstChoice = choices.first,
                          let delta = firstChoice["delta"] as? [String: Any],
                          let content = delta["content"] as? String else {
                        continue
                    }

                    // Emit token
                    fullContent += content
                    await MainActor.run {
                        onToken(content)
                    }
                }

                await MainActor.run {
                    isStreaming = false
                    onComplete(.success(fullContent))
                }

            } catch {
                await MainActor.run {
                    isStreaming = false
                    onComplete(.failure(error))
                }
            }
        }
    }

    /// Stops the current streaming operation
    public func stopStreaming() {
        currentTask?.cancel()
        currentTask = nil
        isStreaming = false
    }

    // MARK: - Private Methods

    private func buildStreamingRequest(
        messages: [OpenRouterService.ChatMessage],
        apiKey: String
    ) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw StreamingError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 60.0

        // Headers
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Kioku-iOS/1.0", forHTTPHeaderField: "User-Agent")
        request.setValue("https://github.com/phuc-nt/kioku-ios", forHTTPHeaderField: "HTTP-Referer")

        // Request body với stream: true
        let requestBody: [String: Any] = [
            "model": geminiModel,
            "messages": messages.map { message in
                ["role": message.role, "content": message.content]
            },
            "stream": true,
            "max_tokens": 1000,
            "temperature": 0.7
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)

        return request
    }
}

// MARK: - Preview Support

extension StreamingService {
    public static let preview: StreamingService = {
        let service = StreamingService()
        return service
    }()
}
