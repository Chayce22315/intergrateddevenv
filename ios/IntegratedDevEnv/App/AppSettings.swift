import Foundation

@MainActor
final class AppSettings: ObservableObject {
    private let defaults = UserDefaults.standard

    @Published var wsURLString: String {
        didSet { defaults.set(wsURLString, forKey: Keys.wsURLString) }
    }

    @Published var token: String {
        didSet { defaults.set(token, forKey: Keys.token) }
    }

    @Published var scratchText: String {
        didSet { defaults.set(scratchText, forKey: Keys.scratchText) }
    }

    init() {
        wsURLString = defaults.string(forKey: Keys.wsURLString) ?? "ws://127.0.0.1:8080/ws"
        token = defaults.string(forKey: Keys.token) ?? ""
        scratchText = defaults.string(forKey: Keys.scratchText) ?? "// scratch buffer\n"
    }

    private enum Keys {
        static let wsURLString = "ide.wsURLString"
        static let token = "ide.token"
        static let scratchText = "ide.scratchText"
    }
}
