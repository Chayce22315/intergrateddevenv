import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var settings: AppSettings
    @EnvironmentObject private var terminalSession: TerminalSession
    @State private var showSettings = false

    var body: some View {
        ZStack {
            AppChrome.backgroundGradient
                .ignoresSafeArea()

            TabView {
                NavigationStack {
                    editorTab
                }
                .tabItem { Label("Editor", systemImage: "doc.text") }

                NavigationStack {
                    terminalTab
                }
                .tabItem { Label("Terminal", systemImage: "terminal") }
            }
        }
        .overlay(alignment: .topLeading) {
            DismissKeyboardOnTapOutside()
                .frame(width: 0, height: 0)
                .allowsHitTesting(false)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SettingsView()
            }
            .environmentObject(settings)
        }
    }

    @ViewBuilder
    private var editorTab: some View {
        ScrollView {
            TextEditor(text: $settings.scratchText)
                .font(.system(.body, design: .monospaced))
                .lineSpacing(4)
                .frame(minHeight: 420)
                .padding(12)
                .scrollContentBackground(.hidden)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
        }
        .scrollDismissesKeyboard(.interactively)
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .navigationTitle("Editor")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    KeyboardDismiss.dismiss()
                }
                .fontWeight(.semibold)
            }
        }
    }

    @ViewBuilder
    private var terminalTab: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(terminalSession.status)
                .font(.caption)
                .foregroundStyle(.secondary)
            RemoteTerminalView(session: terminalSession)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(Color.black.opacity(0.35))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
                )
        }
        .padding(.horizontal, 12)
        .padding(.bottom, 8)
        .navigationTitle("Terminal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
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
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    KeyboardDismiss.dismiss()
                }
                .fontWeight(.semibold)
            }
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
