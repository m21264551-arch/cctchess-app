import SwiftUI
import SwiftData

@main
struct CCTChessApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [PuzzleAttempt.self, CCTRating.self])
    }
}
