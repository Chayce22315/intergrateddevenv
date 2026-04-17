import SwiftUI

@main
struct IntegratedDevEnvApp: App {
    @StateObject private var settings = AppSettings()
    @StateObject private var terminalSession = TerminalSession()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(settings)
                .environmentObject(terminalSession)
        }
    }
}
