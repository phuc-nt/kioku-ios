import Foundation

/// Service for validating AI model identifiers with OpenRouter API
@Observable
public final class ModelValidationService: @unchecked Sendable {

    // MARK: - Popular Models

    public struct ModelInfo: Identifiable, Sendable {
        public let id: String // OpenRouter model ID
        public let name: String
        public let provider: String
        public let description: String
        public let pricing: String?

        public init(id: String, name: String, provider: String, description: String, pricing: String? = nil) {
            self.id = id
            self.name = name
            self.provider = provider
            self.description = description
            self.pricing = pricing
        }
    }

    /// Popular models with good balance of quality/cost/speed
    public static let popularModels: [ModelInfo] = [
        ModelInfo(
            id: "openai/gpt-4o-mini",
            name: "GPT-4o Mini",
            provider: "OpenAI",
            description: "Fast, cost-effective, high quality (default)",
            pricing: "$0.15/M tokens"
        ),
        ModelInfo(
            id: "openai/gpt-4o",
            name: "GPT-4o",
            provider: "OpenAI",
            description: "Highest quality, slower, more expensive",
            pricing: "$2.50/M tokens"
        ),
        ModelInfo(
            id: "anthropic/claude-3.5-sonnet",
            name: "Claude 3.5 Sonnet",
            provider: "Anthropic",
            description: "High quality, good reasoning",
            pricing: "$3.00/M tokens"
        ),
        ModelInfo(
            id: "anthropic/claude-3-haiku",
            name: "Claude 3 Haiku",
            provider: "Anthropic",
            description: "Fast and cheap alternative",
            pricing: "$0.25/M tokens"
        ),
        ModelInfo(
            id: "meta-llama/llama-3.1-70b-instruct",
            name: "Llama 3.1 70B",
            provider: "Meta",
            description: "Open source, good quality",
            pricing: "$0.35/M tokens"
        )
    ]

    public static let defaultModel = "openai/gpt-4o-mini"

    // MARK: - Validation

    /// Validate a model identifier format
    public static func validateFormat(_ modelId: String) -> Bool {
        let trimmed = modelId.trimmingCharacters(in: .whitespacesAndNewlines)

        // Basic format: provider/model-name
        let components = trimmed.components(separatedBy: "/")
        guard components.count == 2 else { return false }

        let provider = components[0]
        let model = components[1]

        // Provider and model must be non-empty
        guard !provider.isEmpty, !model.isEmpty else { return false }

        // Valid characters: alphanumeric, dash, underscore, dot
        let validCharacters = CharacterSet.alphanumerics
            .union(CharacterSet(charactersIn: "-_."))

        return provider.unicodeScalars.allSatisfy { validCharacters.contains($0) } &&
               model.unicodeScalars.allSatisfy { validCharacters.contains($0) }
    }

    /// Check if a model ID is in the popular models list
    public static func isPopularModel(_ modelId: String) -> Bool {
        return popularModels.contains { $0.id == modelId }
    }

    /// Get model info from popular models list
    public static func getModelInfo(_ modelId: String) -> ModelInfo? {
        return popularModels.first { $0.id == modelId }
    }

    // MARK: - OpenRouter API Validation (Optional Enhancement)

    /// Validate model availability with OpenRouter API
    /// Note: Requires network call, should be used sparingly
    public static func validateWithAPI(
        _ modelId: String,
        apiKey: String
    ) async throws -> Bool {
        // Format validation first
        guard validateFormat(modelId) else {
            throw ValidationError.invalidFormat
        }

        // Query OpenRouter /models endpoint
        let url = URL(string: "https://openrouter.ai/api/v1/models")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ValidationError.networkError
        }

        guard httpResponse.statusCode == 200 else {
            throw ValidationError.apiError(httpResponse.statusCode)
        }

        // Parse response to check if model exists
        let decoder = JSONDecoder()
        let modelsResponse = try decoder.decode(ModelsResponse.self, from: data)

        return modelsResponse.data.contains { $0.id == modelId }
    }

    // MARK: - Supporting Types

    public enum ValidationError: LocalizedError {
        case invalidFormat
        case networkError
        case apiError(Int)
        case modelNotFound

        public var errorDescription: String? {
            switch self {
            case .invalidFormat:
                return "Invalid model ID format. Expected: provider/model-name"
            case .networkError:
                return "Network error while validating model"
            case .apiError(let code):
                return "API error: HTTP \(code)"
            case .modelNotFound:
                return "Model not found in OpenRouter"
            }
        }
    }

    private struct ModelsResponse: Codable {
        let data: [ModelData]
    }

    private struct ModelData: Codable {
        let id: String
    }
}
