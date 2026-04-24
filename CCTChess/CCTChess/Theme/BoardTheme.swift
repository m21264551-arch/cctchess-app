import SwiftUI

enum AppTheme {
    static let accent = Color(red: 0.09, green: 0.38, blue: 0.31)
    static let accentDeep = Color(red: 0.05, green: 0.21, blue: 0.22)
    static let accentBlue = Color(red: 0.16, green: 0.32, blue: 0.58)
    static let accentSoft = Color(red: 0.09, green: 0.38, blue: 0.31).opacity(0.12)
    static let gold = Color(red: 0.78, green: 0.54, blue: 0.18)
    static let ink = Color(red: 0.08, green: 0.10, blue: 0.13)
    static let mutedInk = Color(red: 0.38, green: 0.43, blue: 0.49)
    static let surface = Color(red: 0.99, green: 0.99, blue: 0.97)
    static let surfaceMuted = Color(red: 0.94, green: 0.96, blue: 0.94)
    static let cardStroke = Color(red: 0.78, green: 0.82, blue: 0.78).opacity(0.9)
    static let shadow = Color(red: 0.08, green: 0.11, blue: 0.13).opacity(0.10)
    static let success = Color(red: 0.12, green: 0.52, blue: 0.31)
    static let warning = Color(red: 0.82, green: 0.45, blue: 0.05)
    static let danger = Color(red: 0.76, green: 0.17, blue: 0.20)

    static let screenBackground = LinearGradient(
        colors: [
            Color(red: 0.96, green: 0.98, blue: 0.96),
            Color(red: 0.92, green: 0.96, blue: 0.98),
            Color(red: 0.97, green: 0.96, blue: 0.91)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let heroGradient = LinearGradient(
        colors: [
            Color(red: 0.05, green: 0.24, blue: 0.24),
            Color(red: 0.09, green: 0.38, blue: 0.31),
            Color(red: 0.18, green: 0.32, blue: 0.52)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static func accuracyColor(_ value: Double) -> Color {
        if value >= 0.7 { return success }
        if value >= 0.4 { return warning }
        return danger
    }
}

extension View {
    func appScreenBackground() -> some View {
        background(AppTheme.screenBackground.ignoresSafeArea())
    }

    func appCard(padding: CGFloat = 16, radius: CGFloat = 8) -> some View {
        self
            .padding(padding)
            .background(AppTheme.surface.opacity(0.95), in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .strokeBorder(AppTheme.cardStroke, lineWidth: 1)
            )
            .shadow(color: AppTheme.shadow, radius: 14, x: 0, y: 8)
    }
}

struct PrimaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .frame(maxWidth: .infinity)
            .frame(minHeight: 52)
            .padding(.horizontal, 18)
            .background(AppTheme.heroGradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .foregroundStyle(.white)
            .shadow(color: AppTheme.accent.opacity(configuration.isPressed ? 0.12 : 0.24), radius: 12, x: 0, y: 6)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

struct SecondaryActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .frame(minHeight: 44)
            .padding(.horizontal, 14)
            .background(AppTheme.surfaceMuted, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 8, style: .continuous)
                    .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
            )
            .foregroundStyle(AppTheme.ink)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
    }
}

enum BoardTheme: String, CaseIterable, Identifiable, Codable, Sendable {
    case classic = "Classic"
    case wood = "Wood"
    case dark = "Dark"
    case blue = "Blue"
    case steel = "Steel"
    case marble = "Marble"
    case forest = "Forest"
    case tournament = "Tournament"

    var id: String { rawValue }

    var lightSquare: Color {
        switch self {
        case .classic:    return Color(red: 0.94, green: 0.95, blue: 0.91)
        case .wood:       return Color(red: 0.90, green: 0.82, blue: 0.66)
        case .dark:       return Color(red: 0.48, green: 0.51, blue: 0.55)
        case .blue:       return Color(red: 0.90, green: 0.94, blue: 0.97)
        case .steel:      return Color(red: 0.81, green: 0.83, blue: 0.88)
        case .marble:     return Color(red: 0.95, green: 0.93, blue: 0.89)
        case .forest:     return Color(red: 0.76, green: 0.87, blue: 0.71)
        case .tournament: return Color(red: 0.95, green: 0.89, blue: 0.73)
        }
    }

    var darkSquare: Color {
        switch self {
        case .classic:    return Color(red: 0.34, green: 0.53, blue: 0.45)
        case .wood:       return Color(red: 0.54, green: 0.39, blue: 0.26)
        case .dark:       return Color(red: 0.18, green: 0.20, blue: 0.23)
        case .blue:       return Color(red: 0.34, green: 0.49, blue: 0.66)
        case .steel:      return Color(red: 0.33, green: 0.36, blue: 0.42)
        case .marble:     return Color(red: 0.43, green: 0.41, blue: 0.49)
        case .forest:     return Color(red: 0.18, green: 0.38, blue: 0.19)
        case .tournament: return Color(red: 0.46, green: 0.25, blue: 0.12)
        }
    }

    var lightSquareGradient: LinearGradient {
        switch self {
        case .wood:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.95, green: 0.87, blue: 0.71), location: 0),
                    .init(color: Color(red: 0.86, green: 0.76, blue: 0.58), location: 0.5),
                    .init(color: Color(red: 0.92, green: 0.83, blue: 0.65), location: 1),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .steel:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.88, green: 0.90, blue: 0.94), location: 0),
                    .init(color: Color(red: 0.74, green: 0.77, blue: 0.83), location: 1),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .marble:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.98, green: 0.96, blue: 0.93), location: 0),
                    .init(color: Color(red: 0.87, green: 0.85, blue: 0.81), location: 1),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .tournament:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.98, green: 0.93, blue: 0.78), location: 0),
                    .init(color: Color(red: 0.90, green: 0.84, blue: 0.67), location: 1),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(colors: [lightSquare], startPoint: .top, endPoint: .bottom)
        }
    }

    var darkSquareGradient: LinearGradient {
        switch self {
        case .wood:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.61, green: 0.44, blue: 0.29), location: 0),
                    .init(color: Color(red: 0.46, green: 0.31, blue: 0.17), location: 0.5),
                    .init(color: Color(red: 0.56, green: 0.40, blue: 0.24), location: 1),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .steel:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.39, green: 0.42, blue: 0.49), location: 0),
                    .init(color: Color(red: 0.26, green: 0.29, blue: 0.35), location: 1),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .marble:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.49, green: 0.47, blue: 0.56), location: 0),
                    .init(color: Color(red: 0.34, green: 0.32, blue: 0.39), location: 1),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .tournament:
            return LinearGradient(
                stops: [
                    .init(color: Color(red: 0.54, green: 0.31, blue: 0.16), location: 0),
                    .init(color: Color(red: 0.37, green: 0.17, blue: 0.07), location: 1),
                ],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        default:
            return LinearGradient(colors: [darkSquare], startPoint: .top, endPoint: .bottom)
        }
    }

    var checkHighlight: Color { .red }
    var captureHighlight: Color { .orange }
    var threatHighlight: Color { .yellow }
    var selectionHighlight: Color { Color(red: 0.13, green: 0.43, blue: 0.95) }
    var boardBorder: Color { Color.black.opacity(0.36) }
    var squareDivider: Color { Color.black.opacity(0.04) }
}
