import SwiftUI

struct PrivacyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 18) {
                privacyCard(
                    title: "Data Collection",
                    systemImage: "hand.raised.fill",
                    body: "CCT Chess does not collect, sell, or share personal data. Puzzle history, rating, board theme, piece style, and training preferences are stored on this device."
                )

                privacyCard(
                    title: "Network Access",
                    systemImage: "wifi.slash",
                    body: "The app works offline. It does not use analytics, advertising SDKs, account login, tracking, or third-party network services."
                )

                privacyCard(
                    title: "Stored Progress",
                    systemImage: "internaldrive.fill",
                    body: "You can remove stored progress by deleting the app from your device. iOS may also include this local app data in encrypted device backups depending on your backup settings."
                )
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 18)
        }
        .appScreenBackground()
        .navigationTitle("Privacy")
        .navigationBarTitleDisplayMode(.inline)
        .tint(AppTheme.accent)
    }

    private func privacyCard(title: String, systemImage: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: systemImage)
                .font(.headline)
                .foregroundStyle(AppTheme.accent)
                .frame(width: 34, height: 34)
                .background(AppTheme.accentSoft, in: Circle())

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundStyle(AppTheme.ink)
                Text(body)
                    .font(.subheadline)
                    .foregroundStyle(AppTheme.mutedInk)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .appCard(padding: 14)
    }
}
