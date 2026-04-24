# CCT Chess

CCT Chess is an iOS tactics trainer for the scan pattern I wanted to practice: checks, captures, then threats.

The app loads offline chess positions, asks the player to find candidate moves by category, tracks misses, and adapts the target difficulty with a local rating model.

## What is included

- SwiftUI iOS app targeting iOS 17
- Legal move generation from FEN positions
- Checks, captures, and threats analysis
- SwiftData persistence for attempts and rating history
- Multiple board themes and piece styles
- App Store release assets and screenshots

## Project structure

```text
CCTChess/CCTChess.xcodeproj/     Xcode project
CCTChess/CCTChess/Engine/        Move generation and CCT analysis
CCTChess/CCTChess/Models/        Board, move, puzzle, rating, and attempt models
CCTChess/CCTChess/Data/          FEN database and puzzle selection
CCTChess/CCTChess/Views/         SwiftUI screens and board components
CCTChess/CCTChessTests/          Unit tests
CCTChess/Release/                Store assets
```

## Build

Open `CCTChess/CCTChess.xcodeproj` in Xcode 26.2 or newer and run the `CCTChess` scheme.

From the command line:

```sh
xcodebuild \
  -project CCTChess/CCTChess.xcodeproj \
  -scheme CCTChess \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  build
```

## Data and licenses

Bundled puzzle positions are derived from Lichess database exports. The transformed FEN-only subset is stored locally for offline training. See `CCTChess/THIRD_PARTY_NOTICES.md` for source and license details.

## Notes

This is a native app project, not a web chess engine. The main technical work is move generation, category analysis, local training state, and an iOS interface that keeps the scan routine quick.
