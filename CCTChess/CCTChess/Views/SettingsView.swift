import SwiftUI

struct SettingsView: View {
    @AppStorage("boardTheme") private var themeName: String = BoardTheme.classic.rawValue
    @AppStorage("pieceStyle") private var pieceStyleName: String = PieceStyle.chessnut.rawValue
    @AppStorage("hideCounts") private var hideCounts: Bool = false

    private var selectedTheme: BoardTheme {
        BoardTheme(rawValue: themeName) ?? .classic
    }

    private var selectedPieceStyle: PieceStyle {
        PieceStyle(rawValue: pieceStyleName) ?? .chessnut
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                VStack(spacing: 0) {
                    Text("Training")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Hide Move Counts")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(AppTheme.ink)
                                Text("Show found moves without revealing the total")
                                    .font(.caption)
                                    .foregroundStyle(AppTheme.mutedInk)
                            }
                            Spacer()
                            Toggle("", isOn: $hideCounts)
                                .labelsHidden()
                                .tint(AppTheme.accent)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .appCard(padding: 0)
                }

                VStack(spacing: 0) {
                    Text("Board Theme")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        ForEach(Array(BoardTheme.allCases.enumerated()), id: \.element.id) { index, theme in
                            themeRow(theme)
                            if index < BoardTheme.allCases.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .appCard(padding: 0)
                }

                VStack(spacing: 0) {
                    Text("Piece Style")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 2)
                        .padding(.bottom, 8)

                    VStack(spacing: 0) {
                        ForEach(Array(PieceStyle.allCases.enumerated()), id: \.element.id) { index, style in
                            pieceStyleRow(style)
                            if index < PieceStyle.allCases.count - 1 {
                                Divider()
                            }
                        }
                    }
                    .appCard(padding: 0)
                }

                Label {
                    Text("\(FENDatabase.shared.count.formatted()) puzzles loaded")
                        .font(.caption)
                } icon: {
                    Image(systemName: "archivebox.fill")
                }
                .foregroundStyle(AppTheme.mutedInk)
                .padding(.top, 4)

                VStack(spacing: 0) {
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "hand.raised.fill")
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 24)
                            Text("Privacy")
                                .foregroundStyle(.primary)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.mutedInk)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
                .appCard(padding: 0)

                VStack(spacing: 0) {
                    NavigationLink {
                        AcknowledgementsView()
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "info.circle.fill")
                                .foregroundStyle(AppTheme.accent)
                                .frame(width: 24)
                            Text("Acknowledgements")
                                .foregroundStyle(.primary)
                                .font(.subheadline.weight(.semibold))
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(AppTheme.mutedInk)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                    }
                    .buttonStyle(.plain)
                }
                .appCard(padding: 0)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .appScreenBackground()
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.accent)
    }

    private func themeRow(_ theme: BoardTheme) -> some View {
        Button {
            themeName = theme.rawValue
        } label: {
            HStack(spacing: 12) {
                miniBoard(theme: theme)
                    .frame(width: 48, height: 48)
                    .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .strokeBorder(Color.black.opacity(0.08), lineWidth: 1)
                    )

                Text(theme.rawValue)
                    .foregroundStyle(.primary)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                if theme == selectedTheme {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(theme == selectedTheme ? AppTheme.accentSoft : Color.clear, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint(theme == selectedTheme ? "Selected" : "Selects this board theme")
    }

    private func pieceStyleRow(_ style: PieceStyle) -> some View {
        Button {
            pieceStyleName = style.rawValue
        } label: {
            HStack(spacing: 12) {
                miniPieceStylePreview(style)
                    .frame(width: 112, height: 42)

                Text(style.rawValue)
                    .foregroundStyle(.primary)
                    .font(.subheadline.weight(.semibold))

                Spacer()

                if style == selectedPieceStyle {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(AppTheme.accent)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(style == selectedPieceStyle ? AppTheme.accentSoft : Color.clear, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        }
        .buttonStyle(.plain)
        .accessibilityHint(style == selectedPieceStyle ? "Selected" : "Selects this visual style")
    }

    private func miniPieceStylePreview(_ style: PieceStyle) -> some View {
        HStack(spacing: 3) {
            PieceView(piece: Piece(type: .king, color: .white), size: 36, styleOverride: style)
            PieceView(piece: Piece(type: .queen, color: .black), size: 36, styleOverride: style)
            PieceView(piece: Piece(type: .knight, color: .white), size: 36, styleOverride: style)
        }
    }

    private func miniBoard(theme: BoardTheme) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { col in
                        let isLight = (row + col) % 2 == 0
                        Rectangle()
                            .fill(isLight ? theme.lightSquareGradient : theme.darkSquareGradient)
                    }
                }
            }
        }
    }
}
