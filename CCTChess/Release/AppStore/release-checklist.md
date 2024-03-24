# CCT Chess Release Checklist

Completed locally:

- App Store metadata drafted
- Privacy policy drafted
- Support page drafted
- iPhone 6.9 inch screenshot captured
- iPad 13 inch screenshot captured
- iOS deployment target lowered to 17.0
- Unit tests passed on iPhone 17 simulator
- Release device build succeeds with signing disabled
- App icon verified at 1024 x 1024 with no alpha channel
- Privacy manifest validates with `plutil`

Still requires Apple account access:

- Sign in to Xcode with the Apple Account that owns the Developer Program membership
- Create or download Apple Development / Distribution signing identities
- Confirm Apple Developer Team ID in Xcode signing settings
- Create the App Store Connect app record
- Upload the archive to App Store Connect
- Attach screenshots and metadata
- Complete App Privacy in App Store Connect using the answers in `metadata.md`
- Submit the build to TestFlight or App Review

Recommended first build:

- Version: 1.0.0
- Build: 1
- Bundle ID: com.cctchess.CCTChess
- Minimum iOS: 17.0
