import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        TabView {
            GeneralSettingsView()
                .tabItem {
                    Label("General", systemImage: "gearshape")
                }

            ModesSettingsView()
                .tabItem {
                    Label("Modes", systemImage: "text.bubble")
                }

            KnowledgeBaseView()
                .tabItem {
                    Label("Knowledge", systemImage: "book")
                }

            LLMSettingsView()
                .environmentObject(appState)
                .tabItem {
                    Label("LLM", systemImage: "brain")
                }

            HotkeySettingsView()
                .tabItem {
                    Label("Hotkey", systemImage: "command")
                }
        }
        .frame(width: 550, height: 450)
    }
}
