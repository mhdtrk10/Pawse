//
//  HomeStatusCard.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//

import SwiftUI

struct HomeStatusCard: View {
    let summary: HomeSummary

    var body: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Image(systemName: summary.isFullyConfigured ? "checkmark.seal.fill" : "exclamationmark.triangle.fill")
                        .foregroundStyle(summary.isFullyConfigured ? AppColors.success : .orange)

                    Text(summary.title)
                        .font(.headline)

                    Spacer()
                }

                Text(summary.message)
                    .font(.subheadline)
                    .foregroundStyle(AppColors.secondaryText)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
