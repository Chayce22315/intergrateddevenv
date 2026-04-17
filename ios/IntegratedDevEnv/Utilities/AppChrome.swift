import SwiftUI

enum AppChrome {
    static let backgroundGradient = LinearGradient(
        colors: [
            Color(red: 0.07, green: 0.09, blue: 0.18),
            Color(red: 0.12, green: 0.14, blue: 0.28),
            Color(red: 0.06, green: 0.08, blue: 0.16),
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
