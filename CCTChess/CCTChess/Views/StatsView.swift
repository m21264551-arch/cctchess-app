import SwiftUI
import SwiftData
import Charts

struct StatsView: View {
    @Query(sort: \PuzzleAttempt.date, order: .reverse) private var attempts: [PuzzleAttempt]
    @Query private var ratings: [CCTRating]

    private var totalAttempts: Int { attempts.count }

    private var currentRating: Double {
        ratings.first?.rating ?? 1000
    }

    private var ratingTier: String {
        ratings.first?.ratingTier ?? "Intermediate"
    }

    private var averageAccuracy: Double {
        guard !attempts.isEmpty else { return 0 }
        return attempts.reduce(0.0) { $0 + $1.overallAccuracy } / Double(attempts.count)
    }

    private var avgCheckAccuracy: Double {
        let valid = attempts.filter { $0.checksTotal > 0 }
        guard !valid.isEmpty else { return 0 }
        return valid.reduce(0.0) { $0 + $1.checkAccuracy } / Double(valid.count)
    }

    private var avgCaptureAccuracy: Double {
        let valid = attempts.filter { $0.capturesTotal > 0 }
        guard !valid.isEmpty else { return 0 }
        return valid.reduce(0.0) { $0 + $1.captureAccuracy } / Double(valid.count)
    }

    private var avgThreatAccuracy: Double {
        let valid = attempts.filter { $0.threatsTotal > 0 }
        guard !valid.isEmpty else { return 0 }
        return valid.reduce(0.0) { $0 + $1.threatAccuracy } / Double(valid.count)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                if attempts.isEmpty {
                    emptyState
                } else {
                    ratingCard
                    overviewCard
                    categoryChart
                    ratingOverTime
                    accuracyOverTime
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .appScreenBackground()
        .navigationTitle("Progress")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.accent)
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar")
                .font(.system(size: 48))
                .foregroundStyle(AppTheme.accent)
            Text("No puzzles completed yet")
                .font(.headline)
                .foregroundStyle(AppTheme.ink)
            Text("Complete some CCT puzzles to see your stats here.")
                .font(.subheadline)
                .foregroundStyle(AppTheme.mutedInk)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .appCard(padding: 24)
        .padding(.top, 42)
    }

    private var ratingCard: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text("CCT Rating")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(AppTheme.mutedInk)
                    .textCase(.uppercase)
                Text("\(Int(currentRating))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(AppTheme.ink)
            }

            Spacer()

            Text(ratingTier)
                .font(.subheadline.weight(.bold))
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(AppTheme.accentSoft, in: Capsule())
                .foregroundStyle(AppTheme.accent)
        }
        .appCard()
    }

    private var overviewCard: some View {
        HStack(spacing: 12) {
            statTile(title: "Accuracy", value: "\(Int(averageAccuracy * 100))%", color: AppTheme.accuracyColor(averageAccuracy), systemImage: "scope")
            statTile(title: "Puzzles", value: "\(totalAttempts)", color: AppTheme.accent, systemImage: "checkmark.seal.fill")
        }
    }

    private var categoryChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("By Category")
                .font(.headline)
                .foregroundStyle(AppTheme.ink)

            Chart {
                BarMark(x: .value("Category", "Checks"), y: .value("Accuracy", avgCheckAccuracy * 100))
                    .foregroundStyle(CCTCategory.check.color)
                BarMark(x: .value("Category", "Captures"), y: .value("Accuracy", avgCaptureAccuracy * 100))
                    .foregroundStyle(CCTCategory.capture.color)
                BarMark(x: .value("Category", "Threats"), y: .value("Accuracy", avgThreatAccuracy * 100))
                    .foregroundStyle(CCTCategory.threat.color)
            }
            .chartYScale(domain: 0...100)
            .chartForegroundStyleScale([
                "Checks": CCTCategory.check.color,
                "Captures": CCTCategory.capture.color,
                "Threats": CCTCategory.threat.color
            ])
            .chartYAxis {
                AxisMarks(values: [0, 25, 50, 75, 100]) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        Text("\(value.as(Int.self) ?? 0)%")
                    }
                }
            }
            .frame(height: 200)
        }
        .appCard()
    }

    private var ratingOverTime: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Rating Over Time")
                .font(.headline)
                .foregroundStyle(AppTheme.ink)

            let recentAttempts = Array(attempts.suffix(30).reversed())

            if recentAttempts.count >= 2 {
                Chart(Array(recentAttempts.enumerated()), id: \.offset) { index, attempt in
                    LineMark(
                        x: .value("Puzzle", index + 1),
                        y: .value("Rating", attempt.ratingAfter)
                    )
                    .foregroundStyle(AppTheme.accent)
                    PointMark(
                        x: .value("Puzzle", index + 1),
                        y: .value("Rating", attempt.ratingAfter)
                    )
                    .foregroundStyle(AppTheme.accent)
                }
                .chartXAxisLabel("Puzzle #")
                .chartYAxisLabel("Rating")
                .frame(height: 200)
            } else {
                Text("Complete more puzzles to see rating trends.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
        .appCard()
    }

    private var accuracyOverTime: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Accuracy Over Time")
                .font(.headline)
                .foregroundStyle(AppTheme.ink)

            let recentAttempts = Array(attempts.suffix(20).reversed())

            if recentAttempts.count >= 2 {
                Chart(Array(recentAttempts.enumerated()), id: \.offset) { index, attempt in
                    LineMark(
                        x: .value("Puzzle", index + 1),
                        y: .value("Accuracy", attempt.overallAccuracy * 100)
                    )
                    .foregroundStyle(AppTheme.success)
                    PointMark(
                        x: .value("Puzzle", index + 1),
                        y: .value("Accuracy", attempt.overallAccuracy * 100)
                    )
                    .foregroundStyle(AppTheme.success)
                }
                .chartYScale(domain: 0...100)
                .chartXAxisLabel("Puzzle #")
                .chartYAxisLabel("Accuracy %")
                .frame(height: 200)
            } else {
                Text("Complete more puzzles to see trends.")
                    .font(.caption)
                    .foregroundStyle(AppTheme.mutedInk)
            }
        }
        .appCard()
    }

    private func statTile(title: String, value: String, color: Color, systemImage: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(color)
                .frame(width: 34, height: 34)
                .background(color.opacity(0.12), in: Circle())

            Text(value)
                .font(.system(.title2, design: .rounded, weight: .bold))
                .foregroundStyle(AppTheme.ink)
                .lineLimit(1)
                .minimumScaleFactor(0.75)
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundStyle(AppTheme.mutedInk)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .appCard(padding: 14)
    }
}
