import SwiftUI

/// Batch Dye - Tie Dye Log's own palette: distinct from every sibling app in the portfolio.
enum BDTheme {
    static let backdrop = Color(red: 0.969, green: 0.953, blue: 0.965)
    static let card = Color.white

    static let ink = Color(red: 0.145, green: 0.098, blue: 0.129)
    static let inkFaded = Color(red: 0.145, green: 0.098, blue: 0.129).opacity(0.56)

    static let accent = Color(red: 0.831, green: 0.204, blue: 0.443)
    static let accentDeep = Color(red: 0.751, green: 0.12399999999999999, blue: 0.363)
    static let accent2 = Color(red: 0.157, green: 0.612, blue: 0.588)

    static let rule = Color.black.opacity(0.06)

    static let titleFont = Font.system(.title2, design: .rounded).weight(.bold)
    static let displayFont = Font.system(size: 40, weight: .bold, design: .rounded)
    static let headlineFont = Font.system(.headline, design: .rounded).weight(.semibold)
}

struct BDDismissKeyboardOnTap: ViewModifier {
    func body(content: Content) -> some View {
        content.simultaneousGesture(
            TapGesture().onEnded {
                UIApplication.shared.sendAction(
                    #selector(UIResponder.resignFirstResponder),
                    to: nil, from: nil, for: nil
                )
            }
        )
    }
}

extension View {
    func dismissKeyboardOnTap() -> some View {
        modifier(BDDismissKeyboardOnTap())
    }
}

enum BDHaptics {
    static var enabled: Bool = true

    static func light() {
        guard enabled else { return }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    static func success() {
        guard enabled else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }
}
