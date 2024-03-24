import SwiftUI

struct SquareView: View {
    let square: Square
    let piece: Piece?
    let isLight: Bool
    let isSelected: Bool
    let isLegalTarget: Bool
    let feedbackColor: Color?
    let isFeedbackDestination: Bool
    let rankLabel: String?
    let fileLabel: String?
    let size: CGFloat
    let theme: BoardTheme
    let isDragSource: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(backgroundGradient)

            if isSelected {
                Rectangle()
                    .fill(theme.selectionHighlight.opacity(0.18))
                Rectangle()
                    .strokeBorder(theme.selectionHighlight, lineWidth: 3.5)
            }

            if let feedbackColor {
                Rectangle()
                    .fill(feedbackColor.opacity(isFeedbackDestination ? 0.36 : 0.20))
                Rectangle()
                    .strokeBorder(feedbackColor.opacity(0.95), lineWidth: isFeedbackDestination ? 4 : 2.5)
            }

            if isLegalTarget && piece == nil {
                Circle()
                    .fill(theme.selectionHighlight.opacity(0.72))
                    .frame(width: size * 0.20, height: size * 0.20)
            }

            if isLegalTarget && piece != nil {
                Circle()
                    .strokeBorder(theme.selectionHighlight.opacity(0.78), lineWidth: size * 0.065)
                    .frame(width: size * 0.82, height: size * 0.82)
            }

            if let piece, !isDragSource {
                PieceView(piece: piece, size: size)
            }

            coordinateLabels

            Rectangle()
                .strokeBorder(theme.squareDivider, lineWidth: 0.5)
        }
        .frame(width: size, height: size)
        .contentShape(Rectangle())
        .accessibilityLabel(accessibilityLabel)
    }

    private var backgroundGradient: LinearGradient {
        isLight ? theme.lightSquareGradient : theme.darkSquareGradient
    }

    private var coordinateColor: Color {
        isLight ? Color.black.opacity(0.48) : Color.white.opacity(0.72)
    }

    @ViewBuilder
    private var coordinateLabels: some View {
        VStack {
            HStack {
                if let rankLabel {
                    Text(rankLabel)
                        .font(.system(size: max(9, size * 0.16), weight: .bold, design: .rounded))
                        .foregroundStyle(coordinateColor)
                        .padding(.top, 3)
                        .padding(.leading, 4)
                }
                Spacer(minLength: 0)
            }

            Spacer(minLength: 0)

            HStack {
                Spacer(minLength: 0)
                if let fileLabel {
                    Text(fileLabel)
                        .font(.system(size: max(9, size * 0.16), weight: .bold, design: .rounded))
                        .foregroundStyle(coordinateColor)
                        .padding(.trailing, 4)
                        .padding(.bottom, 3)
                }
            }
        }
        .allowsHitTesting(false)
        .accessibilityHidden(true)
    }

    private var accessibilityLabel: String {
        if let piece {
            return "\(piece.color.rawValue.capitalized) \(piece.type.rawValue) on \(square.algebraic)"
        }
        return "Empty square \(square.algebraic)"
    }
}
