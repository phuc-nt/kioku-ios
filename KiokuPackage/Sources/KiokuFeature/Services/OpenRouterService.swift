import Foundation
import Combine

@Observable
public final class OpenRouterService: @unchecked Sendable {
    
    public enum OpenRouterError: Error, LocalizedError {
        case invalidAPIKey
        case networkError(Error)
        case invalidResponse
        case rateLimitExceeded
        case modelNotAvailable(String)
        case requestTooLarge
        case unauthorized
        
        public var errorDescription: String? {
            switch self {
            case .invalidAPIKey:
                return "Invalid OpenRouter API key"
            case .networkError(let error):
                return "Network error: \(error.localizedDescription)"
            case .invalidResponse:
                return "Invalid response from OpenRouter API"
            case .rateLimitExceeded:
                return "API rate limit exceeded"
            case .modelNotAvailable(let model):
                return "Model '\(model)' is not available"
            case .requestTooLarge:
                return "Request payload too large"
            case .unauthorized:
                return "Unauthorized API access"
            }
        }
    }
    
    public struct CompletionRequest {
        let model: String
        let messages: [ChatMessage]
        let maxTokens: Int?
        let temperature: Double?
        let topP: Double?
        
        public init(
            model: String = "openai/gpt-5-mini", // GPT-5 Mini model
            messages: [ChatMessage],
            maxTokens: Int? = 500,
            temperature: Double? = 0.7,
            topP: Double? = 1.0
        ) {
            self.model = model
            self.messages = messages
            self.maxTokens = maxTokens
            self.temperature = temperature
            self.topP = topP
        }
    }
    
    public struct ChatMessage: Sendable {
        let role: String // "system", "user", "assistant"
        let content: String
        
        public init(role: String, content: String) {
            self.role = role
            self.content = content
        }
        
        public static func system(_ content: String) -> ChatMessage {
            ChatMessage(role: "system", content: content)
        }
        
        public static func user(_ content: String) -> ChatMessage {
            ChatMessage(role: "user", content: content)
        }
        
        public static func assistant(_ content: String) -> ChatMessage {
            ChatMessage(role: "assistant", content: content)
        }
    }
    
    public struct CompletionResponse {
        let id: String
        let model: String
        let choices: [Choice]
        let usage: Usage?
        
        public struct Choice {
            let index: Int
            let message: ChatMessage
            let finishReason: String?
        }
        
        public struct Usage {
            let promptTokens: Int
            let completionTokens: Int
            let totalTokens: Int
        }
    }
    
    // MARK: - Properties

    private let session = URLSession.shared
    private let baseURL = "https://openrouter.ai/api/v1"

    // Keychain identifiers - MUST match SettingsView
    private let keychainService = "com.phucnt.kioku.openrouter"
    private let keychainAccount = "api-key"
    
    // API configuration
    public var currentModel = "openai/gpt-4o-mini"
    public var requestTimeout: TimeInterval = 30.0
    public var maxRetries = 3
    
    // Usage tracking
    public private(set) var totalTokensUsed = 0
    public private(set) var totalRequestsCount = 0
    public private(set) var lastRequestTime: Date?
    
    // MARK: - Singleton
    
    public static let shared = OpenRouterService()
    
    private init() {}
    
    // MARK: - API Key Management
    
    /// Sets the OpenRouter API key securely in iOS Keychain
    public func setAPIKey(_ apiKey: String) throws {
        guard !apiKey.isEmpty else {
            throw OpenRouterError.invalidAPIKey
        }

        let keyData = apiKey.data(using: .utf8) ?? Data()

        // Delete existing key if any
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new key
        let addQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecValueData as String: keyData,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]

        let status = SecItemAdd(addQuery as CFDictionary, nil)
        guard status == errSecSuccess else {
            throw OpenRouterError.invalidAPIKey
        }
    }
    
    /// Retrieves the OpenRouter API key from iOS Keychain
    public func getAPIKey() throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: keychainService,
            kSecAttrAccount as String: keychainAccount,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)

        guard status == errSecSuccess,
              let keyData = result as? Data,
              let apiKey = String(data: keyData, encoding: .utf8) else {
            throw OpenRouterError.invalidAPIKey
        }

        return apiKey
    }
    
    /// Checks if API key is configured
    public var hasAPIKey: Bool {
        do {
            _ = try getAPIKey()
            return true
        } catch {
            return false
        }
    }
    
    // MARK: - API Methods
    
    /// Sends a completion request to OpenRouter API
    public func completion(request: CompletionRequest) async throws -> CompletionResponse {
        guard hasAPIKey else {
            throw OpenRouterError.invalidAPIKey
        }
        
        let apiKey = try getAPIKey()
        var urlRequest = try buildURLRequest(for: request, apiKey: apiKey)
        
        var lastError: Error?
        
        // Retry logic
        for attempt in 1...maxRetries {
            do {
                let (data, response) = try await session.data(for: urlRequest)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw OpenRouterError.invalidResponse
                }
                
                // Handle HTTP errors
                switch httpResponse.statusCode {
                case 200...299:
                    let completionResponse = try parseCompletionResponse(data)
                    updateUsageTracking(completionResponse)
                    return completionResponse
                    
                case 401:
                    throw OpenRouterError.unauthorized
                    
                case 413:
                    throw OpenRouterError.requestTooLarge
                    
                case 429:
                    if attempt < maxRetries {
                        // Wait before retry for rate limiting
                        let delay = pow(2.0, Double(attempt)) // Exponential backoff
                        try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                        continue
                    }
                    throw OpenRouterError.rateLimitExceeded
                    
                default:
                    throw OpenRouterError.invalidResponse
                }
                
            } catch let error as OpenRouterError {
                throw error
            } catch {
                lastError = error
                if attempt < maxRetries {
                    // Wait before retry
                    try await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
                    continue
                }
            }
        }
        
        throw OpenRouterError.networkError(lastError ?? URLError(.unknown))
    }
    
    /// Convenience method for simple text completion
    public func completeText(
        prompt: String,
        systemMessage: String? = nil,
        model: String? = nil
    ) async throws -> String {
        var messages: [ChatMessage] = []

        if let system = systemMessage {
            messages.append(.system(system))
        }

        messages.append(.user(prompt))

        let request = CompletionRequest(
            model: model ?? currentModel,
            messages: messages
        )

        let response = try await completion(request: request)

        guard let firstChoice = response.choices.first else {
            throw OpenRouterError.invalidResponse
        }

        return firstChoice.message.content
    }

    /// Complete with full conversation history for context-aware responses
    /// - Parameters:
    ///   - messages: Full message history including system, user, and assistant messages
    ///   - model: Model identifier to use (optional, defaults to currentModel)
    /// - Returns: AI response text
    public func completeWithHistory(
        messages: [ChatMessage],
        model: String? = nil
    ) async throws -> String {
        let request = CompletionRequest(
            model: model ?? currentModel,
            messages: messages
        )

        let response = try await completion(request: request)

        guard let firstChoice = response.choices.first else {
            throw OpenRouterError.invalidResponse
        }

        return firstChoice.message.content
    }

    // MARK: - Private Methods
    
    private func buildURLRequest(for request: CompletionRequest, apiKey: String) throws -> URLRequest {
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw OpenRouterError.invalidResponse
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.timeoutInterval = requestTimeout
        
        // Headers
        urlRequest.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.setValue("Kioku-iOS/1.0", forHTTPHeaderField: "User-Agent")
        urlRequest.setValue("https://github.com/phuc-nt/kioku-ios", forHTTPHeaderField: "HTTP-Referer")
        
        // Request body
        let requestBody: [String: Any] = [
            "model": request.model,
            "messages": request.messages.map { message in
                ["role": message.role, "content": message.content]
            },
            "max_tokens": request.maxTokens as Any,
            "temperature": request.temperature as Any,
            "top_p": request.topP as Any
        ]
        
        urlRequest.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        return urlRequest
    }
    
    private func parseCompletionResponse(_ data: Data) throws -> CompletionResponse {
        do {
            guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                throw OpenRouterError.invalidResponse
            }
            
            guard let id = json["id"] as? String,
                  let model = json["model"] as? String,
                  let choicesArray = json["choices"] as? [[String: Any]] else {
                throw OpenRouterError.invalidResponse
            }
            
            let choices = try choicesArray.map { choiceDict -> CompletionResponse.Choice in
                guard let index = choiceDict["index"] as? Int,
                      let messageDict = choiceDict["message"] as? [String: Any],
                      let role = messageDict["role"] as? String,
                      let content = messageDict["content"] as? String else {
                    throw OpenRouterError.invalidResponse
                }
                
                let message = ChatMessage(role: role, content: content)
                let finishReason = choiceDict["finish_reason"] as? String
                
                return CompletionResponse.Choice(
                    index: index,
                    message: message,
                    finishReason: finishReason
                )
            }
            
            let usage: CompletionResponse.Usage?
            if let usageDict = json["usage"] as? [String: Any],
               let promptTokens = usageDict["prompt_tokens"] as? Int,
               let completionTokens = usageDict["completion_tokens"] as? Int,
               let totalTokens = usageDict["total_tokens"] as? Int {
                usage = CompletionResponse.Usage(
                    promptTokens: promptTokens,
                    completionTokens: completionTokens,
                    totalTokens: totalTokens
                )
            } else {
                usage = nil
            }
            
            return CompletionResponse(
                id: id,
                model: model,
                choices: choices,
                usage: usage
            )
            
        } catch {
            print("Failed to parse OpenRouter response: \(error)")
            throw OpenRouterError.invalidResponse
        }
    }
    
    private func updateUsageTracking(_ response: CompletionResponse) {
        if let usage = response.usage {
            totalTokensUsed += usage.totalTokens
        }
        totalRequestsCount += 1
        lastRequestTime = Date()
    }
    
    // MARK: - Available Models
    
    /// Common OpenRouter models với cost considerations
    public static let availableModels = [
        "openai/gpt-5-mini": "GPT-5 Mini",
        "openai/gpt-4o-mini": "GPT-4o Mini (Cost-effective)",
        "openai/gpt-4o": "GPT-4o (Most capable)",
        "anthropic/claude-3-haiku": "Claude 3 Haiku (Fast)",
        "anthropic/claude-3-sonnet": "Claude 3 Sonnet (Balanced)",
        "anthropic/claude-3-opus": "Claude 3 Opus (Most capable)",
        "meta-llama/llama-3.1-8b-instruct": "Llama 3.1 8B (Open source)",
        "google/gemini-pro": "Gemini Pro (Google)"
    ]
    
    /// Gets usage statistics
    public func getUsageStats() -> (tokens: Int, requests: Int, lastRequest: Date?) {
        return (totalTokensUsed, totalRequestsCount, lastRequestTime)
    }
    
    /// Resets usage statistics
    public func resetUsageStats() {
        totalTokensUsed = 0
        totalRequestsCount = 0
        lastRequestTime = nil
    }
}

// MARK: - Preview Support

extension OpenRouterService {
    public static let preview: OpenRouterService = {
        let service = OpenRouterService()
        return service
    }()
}