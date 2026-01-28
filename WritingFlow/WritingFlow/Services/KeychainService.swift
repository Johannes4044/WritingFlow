import Foundation

class KeychainService {
    static let shared = KeychainService()

    private let defaults = UserDefaults.standard
    private let keyPrefix = "com.writingflow.apikey."

    private init() {}

    func saveAPIKey(_ key: String, for provider: LLMProvider) {
        defaults.set(key, forKey: keyPrefix + provider.rawValue)
    }

    func getAPIKey(for provider: LLMProvider) -> String? {
        defaults.string(forKey: keyPrefix + provider.rawValue)
    }

    func deleteAPIKey(for provider: LLMProvider) {
        defaults.removeObject(forKey: keyPrefix + provider.rawValue)
    }

    func hasAPIKey(for provider: LLMProvider) -> Bool {
        getAPIKey(for: provider) != nil
    }
}
