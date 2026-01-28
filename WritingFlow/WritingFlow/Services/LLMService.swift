import Foundation
import Combine

enum LLMError: LocalizedError {
    case notConfigured
    case invalidAPIKey
    case requestFailed(statusCode: Int, message: String)
    case invalidResponse
    case rateLimited
    case networkError(underlying: Error)

    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "LLM service not configured. Please set up your API key in Settings."
        case .invalidAPIKey:
            return "Invalid API key. Please check your API key in Settings."
        case .requestFailed(let code, let message):
            return "Request failed (\(code)): \(message)"
        case .invalidResponse:
            return "Invalid response from API."
        case .rateLimited:
            return "Rate limited. Please try again later."
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        }
    }
}

protocol LLMServiceProtocol {
    func sendMessage(prompt: String, systemPrompt: String) async throws -> String
}

@MainActor
class LLMServiceCoordinator: ObservableObject {
    static let shared = LLMServiceCoordinator()

    @Published var isProcessing: Bool = false
    @Published var currentResponse: String = ""
    @Published var error: Error?

    private var currentService: LLMServiceProtocol?
    private var currentConfig: LLMConfiguration?

    private init() {}

    func configure(with config: LLMConfiguration) {
        currentConfig = config

        switch config.provider {
        case .openAI:
            let apiKey = KeychainService.shared.getAPIKey(for: .openAI) ?? ""
            currentService = OpenAIService(apiKey: apiKey, config: config)
        case .anthropic:
            let apiKey = KeychainService.shared.getAPIKey(for: .anthropic) ?? ""
            currentService = AnthropicService(apiKey: apiKey, config: config)
        case .ollama, .lmStudio:
            currentService = OllamaService(config: config)
        case .custom:
            let apiKey = KeychainService.shared.getAPIKey(for: .custom) ?? ""
            currentService = OpenAIService(apiKey: apiKey, config: config)
        }
    }

    func reformat(text: String, using mode: Mode, knowledgeContext: String) async throws -> String {
        guard let service = currentService else {
            throw LLMError.notConfigured
        }

        isProcessing = true
        error = nil
        defer { isProcessing = false }

        let fullSystemPrompt = buildSystemPrompt(mode: mode, knowledgeContext: knowledgeContext)

        do {
            let result = try await service.sendMessage(prompt: text, systemPrompt: fullSystemPrompt)
            currentResponse = result
            return result
        } catch {
            self.error = error
            throw error
        }
    }

    private func buildSystemPrompt(mode: Mode, knowledgeContext: String) -> String {
        var prompt = mode.systemPrompt

        if !knowledgeContext.isEmpty {
            prompt += "\n\nAdditional context for reference:\n\(knowledgeContext)"
        }

        prompt += "\n\nIMPORTANT: Return ONLY the reformatted text. Do not include any explanations, meta-commentary, or additional text."

        return prompt
    }
}
