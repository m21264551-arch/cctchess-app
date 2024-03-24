import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var ratings: [CCTRating]
    @Query(sort: \PuzzleAttempt.date, order: .reverse) private var attempts: [PuzzleAttempt]
    @State private var navigateToPuzzle = false
    @State private var selectedPuzzle: Puzzle?
    @State private var isLoading = false

    private var rating: CCTRating {
        if let existing = ratings.first { return existing }
        let newRating = CCTRating()
        modelContext.insert(newRating)
        return newRating
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    topActionBar
                    heroCard
                    scanMethodCard
                    ratingCard

                    if !attempts.isEmpty {
                        recentPerformanceCard
                    }

                    if FENDatabase.shared.isEmpty {
                        databaseWarning
                    }
                }
                .padding(.horizontal, 18)
                .padding(.top, 18)
                .padding(.bottom, 32)
            }
            .appScreenBackground()
            .navigationTitle("")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToPuzzle) {
                if let puzzle = selectedPuzzle {
                    PuzzleView(puzzle: puzzle)
                }
            }
            .tint(AppTheme.accent)
        }
    }

    private var topActionBar: some View {
        HStack {
            NavigationLink {
                StatsView()
            } label: {
                Image(systemName: "chart.bar.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 52, height: 52)
                    .background(AppTheme.surface.opacity(0.92), in: Circle())
                    .shadow(color: AppTheme.shadow, radius: 12, x: 0, y: 7)
            }
            .accessibilityLabel("Progress")

            Spacer()

            NavigationLink {
                SettingsView()
            } label: {
                Image(systemName: "gearshape.fill")
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.accent)
                    .frame(width: 52, height: 52)
                    .background(AppTheme.surface.opacity(0.92), in: Circle())
                    .shadow(color: AppTheme.shadow, radius: 12, x: 0, y: 7)
            }
            .accessibilityLabel("Settings")
        }
        .buttonStyle(.plain)
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 18) {
            HStack(alignment: .center, spacing: 14) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("CCT Chess")
                        .font(.system(.largeTitle, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                    Text("Build the habit strong players use: scan checks, captures, then threats before you move.")
                        .font(.callout)
                        .foregroundStyle(.white.opacity(0.82))
                        .fixedSize(horizontal: false, vertical: true)
                }
                .layoutPriority(1)

                heroMiniBoard
            }

            HStack(spacing: 10) {
                heroMetric(title: "Rating", value: "\(Int(rating.rating))", systemImage: "scope")
                heroMetric(title: "Target", value: targetRangeText, systemImage: "slider.horizontal.3")
            }

            Button {
                startTraining()
            } label: {
                HStack(spacing: 10) {
                    if isLoading {
                        ProgressView()
                            .tint(AppTheme.accentDeep)
                    } else {
                        Image(systemName: "play.fill")
                    }
                    Text(isLoading ? "Loading puzzle" : primaryActionTitle)
                    Spacer(minLength: 0)
                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.bold))
                }
                .font(.headline)
                .foregroundStyle(AppTheme.accentDeep)
                .frame(minHeight: 52)
                .padding(.horizontal, 16)
                .background(.white, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            }
            .buttonStyle(.plain)
            .disabled(isLoading)
            .opacity(isLoading ? 0.78 : 1)
            .accessibilityHint("Starts a puzzle matched to your current rating")
        }
        .padding(18)
        .background(AppTheme.heroGradient, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(Color.white.opacity(0.20), lineWidth: 1)
        )
        .shadow(color: AppTheme.shadow, radius: 18, x: 0, y: 10)
    }

    private var heroMiniBoard: some View {
        VStack(spacing: 0) {
            ForEach(0..<4, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<4, id: \.self) { col in
                        ZStack {
                            Rectangle()
                                .fill((row + col).isMultiple(of: 2) ? Color.white.opacity(0.86) : Color(red: 0.36, green: 0.55, blue: 0.48))

                            if let piece = heroPreviewPiece(row: row, col: col) {
                                PieceView(piece: piece, size: 27)
                            }
                        }
                    }
                }
            }
        }
        .frame(width: 116, height: 116)
        .clipShape(RoundedRectangle(cornerRadius: 7, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 7, style: .continuous)
                .strokeBorder(Color.white.opacity(0.38), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.18), radius: 12, x: 0, y: 8)
        .accessibilityHidden(true)
    }

    private func heroPreviewPiece(row: Int, col: Int) -> Piece? {
        switch (row, col) {
        case (0, 0): return Piece(type: .king, color: .black)
        case (0, 2): return Piece(type: .rook, color: .black)
        case (1, 1): return Piece(type: .queen, color: .white)
        case (2, 2): return Piece(type: .knight, color: .white)
        case (3, 0): return Piece(type: .rook, color: .white)
        case (3, 3): return Piece(type: .king, color: .white)
        default: return nil
        }
    }

    private func heroMetric(title: String, value: String, systemImage: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Color.white.opacity(0.16), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(.white.opacity(0.66))
                    .textCase(.uppercase)
                Text(value)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.78)
            }
            Spacer(minLength: 0)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(Color.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .frame(maxWidth: .infinity)
    }

    private var scanMethodCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text("The scan")
                        .font(.headline)
                        .foregroundStyle(AppTheme.ink)
                    Text("Each puzzle walks one decision habit in order.")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedInk)
                }
                Spacer()
                Image(systemName: "sparkle.magnifyingglass")
                    .font(.title3)
                    .foregroundStyle(AppTheme.gold)
            }

            HStack(spacing: 10) {
                scanStep(.check, index: 1, detail: "Forcing moves")
                scanStep(.capture, index: 2, detail: "Material swings")
                scanStep(.threat, index: 3, detail: "Next-move ideas")
            }
        }
        .appCard()
    }

    private func scanStep(_ category: CCTCategory, index: Int, detail: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Text("\(index)")
                    .font(.caption2.monospacedDigit().weight(.bold))
                    .foregroundStyle(.white)
                    .frame(width: 20, height: 20)
                    .background(category.color, in: Circle())
                Image(systemName: category.systemImage)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(category.color)
            }

            Text(category.rawValue)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.78)
            Text(detail)
                .font(.caption2)
                .foregroundStyle(AppTheme.mutedInk)
                .lineLimit(2)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(category.color.opacity(0.08), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .strokeBorder(category.color.opacity(0.18), lineWidth: 1)
        )
    }

    private var ratingCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(alignment: .top, spacing: 16) {
                VStack(alignment: .leading, spacing: 5) {
                    Text("Current level")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppTheme.mutedInk)
                        .textCase(.uppercase)
                    Text("\(Int(rating.rating))")
                        .font(.system(size: 46, weight: .bold, design: .rounded))
                        .foregroundStyle(AppTheme.ink)
                        .contentTransition(.numericText())
                }

                Spacer()

                Text(rating.ratingTier)
                    .font(.subheadline.weight(.bold))
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(AppTheme.accentSoft, in: Capsule())
                    .foregroundStyle(AppTheme.accent)
            }

            ProgressView(value: tierProgress)
                .tint(AppTheme.accent)
                .accessibilityLabel("Progress through current rating tier")

            HStack(spacing: 12) {
                compactStat(title: "Target", value: targetRangeText, systemImage: "scope", color: AppTheme.accent)
                compactStat(title: "Completed", value: gamesText, systemImage: "checkmark.seal.fill", color: AppTheme.accentBlue)
            }
        }
        .appCard()
        .accessibilityElement(children: .combine)
    }

    private var recentPerformanceCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Label("Recent form", systemImage: "chart.line.uptrend.xyaxis")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Text("\(Int(averageAccuracy * 100))% avg")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.accuracyColor(averageAccuracy))
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(AppTheme.accuracyColor(averageAccuracy).opacity(0.12), in: Capsule())
            }

            Text(focusText)
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedInk)
                .fixedSize(horizontal: false, vertical: true)
        }
        .appCard()
    }

    private func compactStat(title: String, value: String, systemImage: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Image(systemName: systemImage)
                .font(.caption.weight(.bold))
                .foregroundStyle(color)
                .frame(width: 28, height: 28)
                .background(color.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 1) {
                Text(title)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedInk)
                    .textCase(.uppercase)
                Text(value)
                    .font(.caption.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity)
    }

    private var databaseWarning: some View {
        Label {
            Text("Puzzle database not loaded")
                .font(.subheadline.weight(.semibold))
        } icon: {
            Image(systemName: "exclamationmark.triangle.fill")
        }
        .foregroundStyle(AppTheme.danger)
        .appCard(padding: 14)
    }

    private var primaryActionTitle: String {
        attempts.isEmpty ? "Start first scan" : "Train next puzzle"
    }

    private var targetRangeText: String {
        let range = rating.targetCCTRange
        return "\(range.lowerBound)-\(range.upperBound) motifs"
    }

    private var gamesText: String {
        rating.gamesPlayed == 1 ? "1 puzzle" : "\(rating.gamesPlayed) puzzles"
    }

    private var averageAccuracy: Double {
        let recent = Array(attempts.prefix(8))
        guard !recent.isEmpty else { return 0 }
        return recent.reduce(0.0) { $0 + $1.overallAccuracy } / Double(recent.count)
    }

    private var focusText: String {
        guard let focusCategory else {
            return "Keep building reps. The app will keep matching puzzle density to your rating."
        }
        return "Next focus: slow down on \(focusCategory.rawValue.lowercased()). Those are costing the most points lately."
    }

    private var focusCategory: CCTCategory? {
        guard let attempt = attempts.first else { return nil }
        let categoryScores: [(category: CCTCategory, total: Int, accuracy: Double)] = [
            (.check, attempt.checksTotal, attempt.checkAccuracy),
            (.capture, attempt.capturesTotal, attempt.captureAccuracy),
            (.threat, attempt.threatsTotal, attempt.threatAccuracy)
        ]
        return categoryScores
            .filter { $0.total > 0 }
            .min { $0.accuracy < $1.accuracy }?
            .category
    }

    private var tierProgress: Double {
        let value = rating.rating
        let bounds: (lower: Double, upper: Double) = switch value {
        case ..<700: (400, 700)
        case 700..<900: (700, 900)
        case 900..<1100: (900, 1100)
        case 1100..<1300: (1100, 1300)
        case 1300..<1500: (1300, 1500)
        case 1500..<1700: (1500, 1700)
        case 1700..<1900: (1700, 1900)
        default: (1900, 2400)
        }
        return min(1, max(0, (value - bounds.lower) / (bounds.upper - bounds.lower)))
    }

    private func startTraining() {
        isLoading = true
        Task {
            let puzzle = PuzzleStore.randomPuzzle(targetCCTRange: rating.targetCCTRange)
            await MainActor.run {
                selectedPuzzle = puzzle
                isLoading = false
                navigateToPuzzle = true
            }
        }
    }
}
