import SwiftUI
import Combine

@MainActor
class AppState: ObservableObject {
    static let shared = AppState()

    // Processing state
    @Published var isProcessing: Bool = false
    @Published var statusMessage: String = "Ready"

    // Current mode
    @Published var currentMode: Mode?

    // Available modes (set by the app when SwiftData loads)
    @Published var availableModes: [Mode] = []

    // Notification state
    @Published var showNotification: Bool = false
    @Published var notificationMessage: String = ""
    @Published var notificationType: NotificationType = .info

    // Knowledge context (built from abbreviations, names, etc.)
    @Published var knowledgeContext: String = ""

    // LLM Configuration
    @Published var llmConfiguration: LLMConfiguration {
        didSet {
            saveLLMConfiguration()
            LLMServiceCoordinator.shared.configure(with: llmConfiguration)
        }
    }

    // Multi-version feature settings
    @Published var enableMultipleVersions: Bool {
        didSet {
            UserDefaults.standard.set(enableMultipleVersions, forKey: "enableMultipleVersions")
        }
    }

    @Published var numberOfVersions: Int {
        didSet {
            UserDefaults.standard.set(numberOfVersions, forKey: "numberOfVersions")
        }
    }

    // Undo/revert support
    @Published var lastOriginalText: String?
    @Published var lastReplacedText: String?

    enum NotificationType {
        case success, error, info
    }

    private init() {
        self.llmConfiguration = Self.loadLLMConfiguration()
        self.enableMultipleVersions = UserDefaults.standard.bool(forKey: "enableMultipleVersions")
        self.numberOfVersions = UserDefaults.standard.integer(forKey: "numberOfVersions")
        if numberOfVersions < 2 {
            numberOfVersions = 3 // Default to 3 versions
        }
        LLMServiceCoordinator.shared.configure(with: llmConfiguration)
    }

    // MARK: - Mode Cycling

    func cycleToNextMode() {
        guard !availableModes.isEmpty else { return }

        if let current = currentMode,
           let currentIndex = availableModes.firstIndex(where: { $0.id == current.id }) {
            let nextIndex = (currentIndex + 1) % availableModes.count
            currentMode = availableModes[nextIndex]
        } else {
            currentMode = availableModes.first
        }

        // Show toast notification
        if let mode = currentMode {
            showModeChangeNotification(mode: mode)
        }
    }

    private func showModeChangeNotification(mode: Mode) {
        // Show popup near menu bar
        ModePopupWindowController.shared.show(mode: mode)
    }

    func switchToMode(_ mode: Mode) {
        currentMode = mode
        showModeChangeNotification(mode: mode)
    }

    // MARK: - Undo/Revert

    func storeForUndo(original: String, replacement: String) {
        lastOriginalText = original
        lastReplacedText = replacement
    }

    func revertLastChange() async {
        guard lastOriginalText != nil else {
            showError("Nothing to revert")
            return
        }

        statusMessage = "Reverting..."

        // Use the target app's native Cmd+Z undo
        // This is more reliable than trying to replace text again
        await TextCaptureService.shared.simulateUndo()

        showSuccess("Reverted to original")
        lastOriginalText = nil
        lastReplacedText = nil
    }

    var canRevert: Bool {
        lastOriginalText != nil
    }

    func showSuccess(_ message: String) {
        isProcessing = false
        notificationMessage = message
        notificationType = .success
        showNotification = true
        statusMessage = "Ready"

        // Auto-hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.showNotification = false
        }
    }

    func showError(_ message: String) {
        isProcessing = false
        notificationMessage = message
        notificationType = .error
        showNotification = true
        statusMessage = "Error"

        // Auto-hide after delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.showNotification = false
            self?.statusMessage = "Ready"
        }
    }

    func updateKnowledgeContext(abbreviations: [Abbreviation], names: [NameEntry]) {
        knowledgeContext = PromptBuilder.shared.buildKnowledgeContext(
            abbreviations: abbreviations,
            names: names
        )
    }

    // MARK: - Persistence

    private static func loadLLMConfiguration() -> LLMConfiguration {
        if let data = UserDefaults.standard.data(forKey: "llmConfiguration"),
           var config = try? JSONDecoder().decode(LLMConfiguration.self, from: data) {
            // Validate and fix endpoint if empty or invalid
            if config.endpoint.isEmpty || URL(string: config.endpoint) == nil {
                config.endpoint = config.provider.defaultEndpoint
            }
            // Validate model
            if config.model.isEmpty {
                config.model = config.provider.defaultModel
            }
            return config
        }
        return LLMConfiguration.default
    }

    private func saveLLMConfiguration() {
        if let data = try? JSONEncoder().encode(llmConfiguration) {
            UserDefaults.standard.set(data, forKey: "llmConfiguration")
        }
    }

    func resetLLMConfiguration() {
        UserDefaults.standard.removeObject(forKey: "llmConfiguration")
        llmConfiguration = LLMConfiguration.default
    }
}
