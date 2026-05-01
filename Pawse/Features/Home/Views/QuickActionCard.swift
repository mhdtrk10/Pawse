//
//  QuickActionCard.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//

import SwiftUI

struct QuickActionCard: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey
    let systemImageName: String

    var body: some View {
        CardContainer {
            HStack(spacing: 12) {
                Image(systemName: systemImageName)
                    .font(.title2)
                    .foregroundStyle(AppColors.primary)
                    .frame(width: 36)

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(AppColors.secondaryText)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(AppColors.secondaryText)
            }
        }
    }
}

#Preview {
    QuickActionCard(
        title: L10n.chooseApps,
        subtitle: L10n.chooseAppsSubtitle,
        systemImageName: "app.badge.fill"
    )
    .padding()
}
