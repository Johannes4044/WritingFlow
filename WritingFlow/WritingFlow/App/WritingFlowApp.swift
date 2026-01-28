import SwiftUI
import SwiftData

struct MenuBarLabel: View {
    @ObservedObject var appState: AppState

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: appState.isProcessing ? "text.bubble.fill" : "text.bubble")
                .symbolEffect(.pulse, isActive: appState.isProcessing)

            // Show mode indicator if a mode is selected
            if let mode = appState.currentMode {
                Circle()
                    .fill(Color(hex: mode.colorHex))
                    .frame(width: 8, height: 8)
            }
        }
    }
}

@main
struct WritingFlowApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var appState = AppState.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Mode.self,
            Abbreviation.self,
            NameEntry.self
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        MenuBarExtra {
            MenuBarView()
                .environmentObject(appState)
                .modelContainer(sharedModelContainer)
        } label: {
            MenuBarLabel(appState: appState)
        }
        .menuBarExtraStyle(.window)

        Settings {
            SettingsView()
                .environmentObject(appState)
                .modelContainer(sharedModelContainer)
        }
    }
}
