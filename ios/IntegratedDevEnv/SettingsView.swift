import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var settings: AppSettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        Form {
            Section {
                TextField("WebSocket URL", text: $settings.wsURLString)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                SecureField("TERMD_TOKEN", text: $settings.token)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            } header: {
                Text("Remote shell")
            } footer: {
                Text("Example: ws://192.168.1.10:8080/ws — token is sent as the token query parameter.")
            }
        }
        .navigationTitle("Settings")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
}
