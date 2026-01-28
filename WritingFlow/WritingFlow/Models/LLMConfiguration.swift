import Foundation

enum LLMProvider: String, Codable, CaseIterable, Identifiable {
    case openAI = "OpenAI"
    case anthropic = "Anthropic"
    case ollama = "Ollama"
    case lmStudio = "LM Studio"
    case custom = "Custom"

    var id: String { rawValue }

    var defaultEndpoint: String {
        switch self {
        case .openAI: return "https://api.openai.com/v1/chat/completions"
        case .anthropic: return "https://api.anthropic.com/v1/messages"
        case .ollama: return "http://localhost:11434/api/chat"
        case .lmStudio: return "http://localhost:1234/v1/chat/completions"
        case .custom: return ""
        }
    }

    var defaultModel: String {
        switch self {
        case .openAI: return "gpt-4o-mini"
        case .anthropic: return "claude-3-5-sonnet-20241022"
        case .ollama: return "llama3.2"
        case .lmStudio: return "local-model"
        case .custom: return ""
        }
    }

    var requiresAPIKey: Bool {
        switch self {
        case .openAI, .anthropic, .custom: return true
        case .ollama, .lmStudio: return false
        }
    }

    var iconName: String {
        switch self {
        case .openAI: return "brain"
        case .anthropic: return "sparkles"
        case .ollama: return "desktopcomputer"
        case .lmStudio: return "server.rack"
        case .custom: return "gearshape"
        }
    }

    var availableModels: [String] {
        switch self {
        case .openAI: return ["gpt-4o", "gpt-4o-mini", "gpt-4-turbo", "gpt-3.5-turbo"]
        case .anthropic: return ["claude-3-5-sonnet-20241022", "claude-3-opus-20240229", "claude-3-haiku-20240307"]
        case .ollama: return ["llama3.2", "llama3.1", "mistral", "codellama", "phi3"]
        case .lmStudio: return ["local-model"]
        case .custom: return []
        }
    }
}

struct LLMConfiguration: Codable, Equatable {
    var provider: LLMProvider
    var endpoint: String
    var model: String
    var maxTokens: Int
    var temperature: Double

    static var `default`: LLMConfiguration {
        LLMConfiguration(
            provider: .openAI,
            endpoint: LLMProvider.openAI.defaultEndpoint,
            model: "gpt-4o-mini",
            maxTokens: 2048,
            temperature: 0.7
        )
    }

    mutating func updateProvider(_ newProvider: LLMProvider) {
        provider = newProvider
        endpoint = newProvider.defaultEndpoint
        model = newProvider.defaultModel
    }
}
