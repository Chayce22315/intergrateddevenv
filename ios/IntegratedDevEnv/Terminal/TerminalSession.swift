import Foundation
import SwiftUI
import SwiftTerm
import UIKit

final class TerminalSession: ObservableObject {
    @Published var status: String = "Disconnected"

    private var task: URLSessionWebSocketTask?
    private weak var terminalView: TerminalView?

    func attach(terminal: TerminalView) {
        terminalView = terminal
    }

    func disconnect() {
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        status = "Disconnected"
    }

    func connect(wsURL: URL) {
        disconnect()
        let session = URLSession(configuration: .default)
        let t = session.webSocketTask(with: wsURL)
        task = t
        t.resume()
        status = "Connected"
        receiveLoop()
    }

    private func receiveLoop() {
        task?.receive { [weak self] result in
            guard let self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .data(let data):
                    DispatchQueue.main.async {
                        // Data subscript slice is Data.SubSequence, not ArraySlice<UInt8> (Swift 6 / newer SDKs).
                        let bytes = [UInt8](data)
                        self.terminalView?.feed(byteArray: bytes[...])
                    }
                case .string(let s):
                    DispatchQueue.main.async {
                        self.terminalView?.feed(text: s)
                    }
                @unknown default:
                    break
                }
                self.receiveLoop()
            case .failure(let err):
                DispatchQueue.main.async {
                    self.status = "Error: \(err.localizedDescription)"
                }
            }
        }
    }

    func sendSlice(_ data: ArraySlice<UInt8>) {
        task?.send(.data(Data(data))) { _ in }
    }
}
