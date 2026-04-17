import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var terminalSession: TerminalSession
    @State private var showSettings = false

    var body: some View {
        TabView {
            NavigationStack {
                TextEditor(text: $settings.scratchText)
                    .font(.system(.body, design: .monospaced))
                    .padding(8)
                    .navigationTitle("Editor")
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showSettings = true
                            } label: {
                                Image(systemName: "gearshape")
                            }
                        }
                    }
            }
            .tabItem { Label("Editor", systemImage: "doc.text") }

            NavigationStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text(terminalSession.status)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    RemoteTerminalView(session: terminalSession)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .padding(.horizontal, 8)
                .navigationTitle("Terminal")
                .toolbar {
                    ToolbarItemGroup(placement: .topBarTrailing) {
                        Button {
                            showSettings = true
                        } label: {
                            Image(systemName: "gearshape")
                        }
                        Button("Connect") {
                            if let url = buildWebSocketURL() {
                                terminalSession.connect(wsURL: url)
                            }
                        }
                        .disabled(buildWebSocketURL() == nil)
                        Button("Disconnect") {
                            terminalSession.disconnect()
                        }
                    }
                }
            }
            .tabItem { Label("Terminal", systemImage: "terminal") }
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
            .environmentObject(settings)
        }
    }

    private func buildWebSocketURL() -> URL? {
        let trimmed = settings.wsURLString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard var components = URLComponents(string: trimmed),
              let scheme = components.scheme?.lowercased(),
              scheme == "ws" || scheme == "wss"
        else { return nil }

        var items = components.queryItems ?? []
        if !settings.token.isEmpty {
            items.append(URLQueryItem(name: "token", value: settings.token))
        }
        components.queryItems = items.isEmpty ? nil : items
        return components.url
    }
}
