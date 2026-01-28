import SwiftUI

struct LLMSettingsView: View {
    @EnvironmentObject var appState: AppState

    @State private var apiKey = ""
    @State private var showAPIKey = false
    @State private var isTesting = false
    @State private var testResult: TestResult?

    enum TestResult {
        case success
        case failure(String)
    }

    var body: some View {
        Form {
            // Provider selection
            Section {
                Picker("Provider", selection: Binding(
                    get: { appState.llmConfiguration.provider },
                    set: { newProvider in
                        appState.llmConfiguration.updateProvider(newProvider)
                        loadAPIKey(for: newProvider)
                    }
                )) {
                    ForEach(LLMProvider.allCases) { provider in
                        HStack {
                            Image(systemName: provider.iconName)
                            Text(provider.rawValue)
                        }
                        .tag(provider)
                    }
                }
            } header: {
                Text("Provider")
            }

            // API Key (if required)
            if appState.llmConfiguration.provider.requiresAPIKey {
                Section {
                    HStack {
                        if showAPIKey {
                            TextField("API Key", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        } else {
                            SecureField("API Key", text: $apiKey)
                                .textFieldStyle(.roundedBorder)
                        }

                        Button(action: { showAPIKey.toggle() }) {
                            Image(systemName: showAPIKey ? "eye.slash" : "eye")
                        }
                        .buttonStyle(.plain)
                    }

                    Button("Save API Key") {
                        saveAPIKey()
                    }
                    .disabled(apiKey.isEmpty)
                } header: {
                    Text("API Key")
                } footer: {
                    Text("Your API key is stored in app preferences.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Model selection
            Section {
                if appState.llmConfiguration.provider == .custom {
                    TextField("Model", text: Binding(
                        get: { appState.llmConfiguration.model },
                        set: { appState.llmConfiguration.model = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                } else if !appState.llmConfiguration.provider.availableModels.isEmpty {
                    Picker("Model", selection: Binding(
                        get: { appState.llmConfiguration.model },
                        set: { appState.llmConfiguration.model = $0 }
                    )) {
                        ForEach(appState.llmConfiguration.provider.availableModels, id: \.self) { model in
                            Text(model).tag(model)
                        }
                    }
                }
            } header: {
                Text("Model")
            }

            // Endpoint (for custom or local)
            if appState.llmConfiguration.provider == .custom ||
               appState.llmConfiguration.provider == .ollama ||
               appState.llmConfiguration.provider == .lmStudio {
                Section {
                    TextField("Endpoint URL", text: Binding(
                        get: { appState.llmConfiguration.endpoint },
                        set: { appState.llmConfiguration.endpoint = $0 }
                    ))
                    .textFieldStyle(.roundedBorder)
                } header: {
                    Text("Endpoint")
                } footer: {
                    if appState.llmConfiguration.provider == .ollama {
                        Text("Default: http://localhost:11434/api/chat")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else if appState.llmConfiguration.provider == .lmStudio {
                        Text("Default: http://localhost:1234/v1/chat/completions")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }

            // Advanced settings
            Section {
                HStack {
                    Text("Max Tokens")
                    Spacer()
                    TextField("", value: Binding(
                        get: { appState.llmConfiguration.maxTokens },
                        set: { appState.llmConfiguration.maxTokens = $0 }
                    ), format: .number)
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
                }

                HStack {
                    Text("Temperature")
                    Spacer()
                    Slider(value: Binding(
                        get: { appState.llmConfiguration.temperature },
                        set: { appState.llmConfiguration.temperature = $0 }
                    ), in: 0...2, step: 0.1)
                    .frame(width: 150)
                    Text(String(format: "%.1f", appState.llmConfiguration.temperature))
                        .foregroundColor(.secondary)
                        .frame(width: 30)
                }
            } header: {
                Text("Advanced")
            }

            // Test connection
            Section {
                HStack {
                    Button(action: testConnection) {
                        HStack {
                            if isTesting {
                                ProgressView()
                                    .scaleEffect(0.8)
                            }
                            Text(isTesting ? "Testing..." : "Test Connection")
                        }
                    }
                    .disabled(isTesting || (appState.llmConfiguration.provider.requiresAPIKey && apiKey.isEmpty))

                    Spacer()

                    if let result = testResult {
                        switch result {
                        case .success:
                            Label("Success", systemImage: "checkmark.circle.fill")
                                .foregroundColor(WritingFlowColors.success)
                        case .failure:
                            Label("Failed", systemImage: "xmark.circle.fill")
                                .foregroundColor(WritingFlowColors.error)
                        }
                    }
                }

                // Show full error message below
                if case .failure(let message) = testResult {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Error Details:")
                            .font(.caption)
                            .fontWeight(.semibold)
                        Text(message)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .textSelection(.enabled)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(WritingFlowColors.error.opacity(0.1))
                    .cornerRadius(6)
                }
            }
        }
        .formStyle(.grouped)
        .padding()
        .onAppear {
            loadAPIKey(for: appState.llmConfiguration.provider)
        }
    }

    private func loadAPIKey(for provider: LLMProvider) {
        apiKey = KeychainService.shared.getAPIKey(for: provider) ?? ""
    }

    private func saveAPIKey() {
        KeychainService.shared.saveAPIKey(apiKey, for: appState.llmConfiguration.provider)
        LLMServiceCoordinator.shared.configure(with: appState.llmConfiguration)
    }

    private func testConnection() {
        isTesting = true
        testResult = nil

        Task {
            do {
                // Ensure the service is configured with current settings
                if appState.llmConfiguration.provider.requiresAPIKey && !apiKey.isEmpty {
                    KeychainService.shared.saveAPIKey(apiKey, for: appState.llmConfiguration.provider)
                }
                LLMServiceCoordinator.shared.configure(with: appState.llmConfiguration)

                // Create a test mode
                let testMode = Mode(
                    name: "Test",
                    systemPrompt: "Reply with exactly: 'Connection successful'"
                )

                _ = try await LLMServiceCoordinator.shared.reformat(
                    text: "Test",
                    using: testMode,
                    knowledgeContext: ""
                )

                await MainActor.run {
                    testResult = .success
                    isTesting = false
                }
            } catch {
                await MainActor.run {
                    testResult = .failure(error.localizedDescription)
                    isTesting = false
                }
            }
        }
    }
}
