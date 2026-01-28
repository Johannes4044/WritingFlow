import Foundation

class OllamaService: LLMServiceProtocol {
    private let config: LLMConfiguration

    init(config: LLMConfiguration) {
        self.config = config
    }

    func sendMessage(prompt: String, systemPrompt: String) async throws -> String {
        guard let url = URL(string: config.endpoint) else {
            throw LLMError.invalidResponse
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120 // Local models may be slower

        let body: [String: Any]

        // Check if using Ollama native endpoint or OpenAI-compatible endpoint
        if config.endpoint.contains("/api/chat") {
            // Ollama native format
            body = [
                "model": config.model,
                "messages": [
                    ["role": "system", "content": systemPrompt],
                    ["role": "user", "content": prompt]
                ],
                "stream": false,
                "options": [
                    "num_predict": config.maxTokens,
                    "temperature": config.temperature
                ]
            ]
        } else {
            // OpenAI-compatible format (LM Studio, etc.)
            body = [
                "model": config.model,
                "messages": [
                    ["role": "system", "content": systemPrompt],
                    ["role": "user", "content": prompt]
                ],
                "max_tokens": config.maxTokens,
                "temperature": config.temperature
            ]
        }

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw LLMError.invalidResponse
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = parseErrorMessage(from: data) ?? "Local LLM not responding. Is Ollama/LM Studio running?"
            throw LLMError.requestFailed(statusCode: httpResponse.statusCode, message: errorMessage)
        }

        // Parse response based on format
        if config.endpoint.contains("/api/chat") {
            // Ollama native response format
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let message = json["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw LLMError.invalidResponse
            }
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            // OpenAI-compatible response format
            guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let choices = json["choices"] as? [[String: Any]],
                  let firstChoice = choices.first,
                  let message = firstChoice["message"] as? [String: Any],
                  let content = message["content"] as? String else {
                throw LLMError.invalidResponse
            }
            return content.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }

    private func parseErrorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let error = json["error"] as? String else {
            return nil
        }
        return error
    }
}
