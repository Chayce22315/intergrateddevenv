import SwiftUI
import SwiftTerm
import UIKit

final class TerminalCoordinator: NSObject, TerminalViewDelegate {
    let session: TerminalSession

    init(session: TerminalSession) {
        self.session = session
    }

    func send(source: TerminalView, data: ArraySlice<UInt8>) {
        session.sendSlice(data)
    }

    func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {}

    func setTerminalTitle(source: TerminalView, title: String) {}

    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}

    func scrolled(source: TerminalView, position: Double) {}

    func requestOpenLink(source: TerminalView, link: String, params: [String: String]) {}

    func bell(source: TerminalView) {}

    func clipboardCopy(source: TerminalView, content: Data) {}

    func clipboardRead(source: TerminalView) -> Data? { nil }

    func iTermContent(source: TerminalView, content: ArraySlice<UInt8>) {}

    func rangeChanged(source: TerminalView, startY: Int, endY: Int) {}
}

struct RemoteTerminalView: UIViewRepresentable {
    @ObservedObject var session: TerminalSession

    func makeCoordinator() -> TerminalCoordinator {
        TerminalCoordinator(session: session)
    }

    func makeUIView(context: Context) -> TerminalView {
        let tv = TerminalView(frame: .zero, font: nil)
        tv.terminalDelegate = context.coordinator
        session.attach(terminal: tv)
        return tv
    }

    func updateUIView(_ uiView: TerminalView, context: Context) {}
}
