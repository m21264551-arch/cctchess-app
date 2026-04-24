import SwiftUI

struct ResultsView: View {
    let viewModel: PuzzleViewModel
    let ratingChange: Double
    let onNewPuzzle: () -> Void

    private var totalFound: Int {
        viewModel.foundChecks.count + viewModel.foundCaptures.count + viewModel.foundThreats.count
    }

    private var totalExpected: Int {
        viewModel.analysis.totalMoves
    }

    private var overallPercent: Int {
        guard totalExpected > 0 else { return 100 }
        return Int(Double(totalFound) / Double(totalExpected) * 100)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                scoreHeader

                ratingChangeCard

                categoryBreakdown

                nextFocusCard

                if !viewModel.missedChecks.isEmpty || !viewModel.missedCaptures.isEmpty || !viewModel.missedThreats.isEmpty {
                    missedMovesSection
                }

                HStack(spacing: 12) {
                    Button {
                        onNewPuzzle()
                    } label: {
                        Label("Train Another Puzzle", systemImage: "arrow.clockwise")
                    }
                    .buttonStyle(PrimaryActionButtonStyle())
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 18)
        }
        .appScreenBackground()
        .navigationTitle("Results")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .tint(AppTheme.accent)
    }

    private var scoreHeader: some View {
        HStack(spacing: 18) {
            ZStack {
                Circle()
                    .stroke(AppTheme.accentSoft, lineWidth: 12)
                Circle()
                    .trim(from: 0, to: CGFloat(Double(overallPercent) / 100))
                    .stroke(scoreColor, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(overallPercent)%")
                        .font(.system(size: 30, weight: .bold, design: .rounded))
                        .foregroundStyle(scoreColor)
                    Text("score")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(AppTheme.mutedInk)
                }
            }
            .frame(width: 112, height: 112)
            .accessibilityLabel("Score \(overallPercent) percent")

            VStack(alignment: .leading, spacing: 8) {
                Text(resultTitle)
                    .font(.title3.weight(.bold))
                    .foregroundStyle(AppTheme.ink)

                Text(resultSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)

                Label(timeText, systemImage: "timer")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedInk)
            }

            Spacer(minLength: 0)
        }
        .appCard()
        .padding(.horizontal)
    }

    private var scoreColor: Color {
        AppTheme.accuracyColor(Double(overallPercent) / 100)
    }

    private var resultTitle: String {
        switch overallPercent {
        case 90...: return "Clean scan"
        case 70..<90: return "Good board vision"
        case 40..<70: return "Useful reps"
        default: return "Keep scanning"
        }
    }

    private var resultSubtitle: String {
        "\(totalFound) of \(totalExpected) motifs found. \(focusSentence)"
    }

    private var focusSentence: String {
        guard let category = weakestCategory else {
            return "No category stood out."
        }
        return "Watch \(category.rawValue.lowercased()) next."
    }

    private var timeText: String {
        let time = Int(Date().timeIntervalSince(viewModel.startTime))
        return "\(time / 60)m \(time % 60)s"
    }

    private var ratingChangeCard: some View {
        HStack(spacing: 12) {
            Image(systemName: ratingChangeIcon)
                .font(.title2)
                .foregroundStyle(ratingChangeColor)
                .frame(width: 42, height: 42)
                .background(ratingChangeColor.opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(ratingChangeTitle)
                    .font(.headline)
                    .foregroundStyle(ratingChangeColor)
                Text(ratingChangeDetail)
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer()
        }
        .appCard(padding: 14)
        .padding(.horizontal)
    }

    private var ratingChangeIcon: String {
        if ratingChange > 0 { return "arrow.up.right" }
        if ratingChange < 0 { return "arrow.down.right" }
        return "minus"
    }

    private var ratingChangeColor: Color {
        if ratingChange > 0 { return AppTheme.success }
        if ratingChange < 0 { return AppTheme.danger }
        return AppTheme.mutedInk
    }

    private var ratingChangeTitle: String {
        if ratingChange > 0 { return "Rating +\(Int(ratingChange))" }
        if ratingChange < 0 { return "Rating \(Int(ratingChange))" }
        return "Rating unchanged"
    }

    private var ratingChangeDetail: String {
        if ratingChange > 0 { return "Rating moved up from this scan" }
        if ratingChange < 0 { return "Rating dipped, but the missed motifs are below" }
        return "Steady result. Keep building reps."
    }

    private var nextFocusCard: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: weakestCategory?.systemImage ?? "scope")
                .font(.headline.weight(.bold))
                .foregroundStyle(weakestCategory?.color ?? AppTheme.accent)
                .frame(width: 38, height: 38)
                .background((weakestCategory?.color ?? AppTheme.accent).opacity(0.12), in: Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text("Next rep")
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Text(nextFocusText)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer(minLength: 0)
        }
        .appCard(padding: 14)
        .padding(.horizontal)
    }

    private var nextFocusText: String {
        guard let category = weakestCategory else {
            return "Keep the same rhythm: checks first, then captures, then threats."
        }
        return "Spend an extra beat on \(category.rawValue.lowercased()). That was the softest part of this scan."
    }

    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Category breakdown")
                .font(.headline)
                .foregroundStyle(AppTheme.ink)

            categoryRow(
                category: .check,
                found: viewModel.foundChecks.count,
                total: viewModel.analysis.checks.count
            )
            categoryRow(
                category: .capture,
                found: viewModel.foundCaptures.count,
                total: viewModel.analysis.captures.count
            )
            categoryRow(
                category: .threat,
                found: viewModel.foundThreats.count,
                total: viewModel.analysis.threats.count
            )
        }
        .appCard()
        .padding(.horizontal)
    }

    private func categoryRow(category: CCTCategory, found: Int, total: Int) -> some View {
        let pct = total > 0 ? Double(found) / Double(total) : 1.0

        return VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 10) {
                Image(systemName: category.systemImage)
                    .foregroundStyle(category.color)
                    .frame(width: 24)
                Text(category.rawValue)
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(AppTheme.ink)
                Spacer()
                Text("\(found)/\(total)")
                    .font(.subheadline.monospacedDigit().weight(.semibold))
                    .foregroundStyle(AppTheme.mutedInk)
            }

            ProgressView(value: pct)
                .tint(AppTheme.accuracyColor(pct))
                .accessibilityLabel(category.rawValue)
                .accessibilityValue("\(Int(pct * 100)) percent")
        }
        .padding(.vertical, 4)
    }

    private var missedMovesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Review missed moves")
                .font(.headline)
                .foregroundStyle(AppTheme.ink)

            if !viewModel.missedChecks.isEmpty {
                missedGroup(title: "Checks", moves: viewModel.missedChecks, color: CCTCategory.check.color)
            }
            if !viewModel.missedCaptures.isEmpty {
                missedGroup(title: "Captures", moves: viewModel.missedCaptures, color: CCTCategory.capture.color)
            }
            if !viewModel.missedThreats.isEmpty {
                missedGroup(title: "Threats", moves: viewModel.missedThreats, color: CCTCategory.threat.color)
            }
        }
        .appCard()
        .padding(.horizontal)
    }

    private func missedGroup(title: String, moves: [Move], color: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.caption.weight(.bold))
                .foregroundStyle(AppTheme.mutedInk)

            ForEach(moves, id: \.key) { move in
                HStack(spacing: 8) {
                    Circle()
                        .fill(color)
                        .frame(width: 8, height: 8)
                    PieceView(piece: move.piece, size: 28)
                    Text("\(move.notation)")
                        .font(.subheadline.monospaced())
                    Text("(\(move.from.algebraic) \u{2192} \(move.to.algebraic))")
                        .font(.caption)
                        .foregroundStyle(AppTheme.mutedInk)
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 2)
            }
        }
    }

    private var weakestCategory: CCTCategory? {
        let categoryScores: [(category: CCTCategory, total: Int, accuracy: Double)] = [
            (.check, viewModel.analysis.checks.count, viewModel.analysis.checks.isEmpty ? 1 : Double(viewModel.foundChecks.count) / Double(viewModel.analysis.checks.count)),
            (.capture, viewModel.analysis.captures.count, viewModel.analysis.captures.isEmpty ? 1 : Double(viewModel.foundCaptures.count) / Double(viewModel.analysis.captures.count)),
            (.threat, viewModel.analysis.threats.count, viewModel.analysis.threats.isEmpty ? 1 : Double(viewModel.foundThreats.count) / Double(viewModel.analysis.threats.count))
        ]
        return categoryScores
            .filter { $0.total > 0 }
            .min { $0.accuracy < $1.accuracy }?
            .category
    }
}
