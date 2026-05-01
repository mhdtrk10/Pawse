//
//  OptionChip.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//

import SwiftUI

struct OptionChip: View {
    let title: String
    let isSelected: Bool

    var body: some View {
        Text(title)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(isSelected ? .white : AppColors.primary)
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                isSelected
                ? AppColors.primary
                : AppColors.primary.opacity(0.12)
            )
            .clipShape(Capsule())
    }
}

#Preview {
    VStack(spacing: 12) {
        OptionChip(title: "15 min", isSelected: true)
        OptionChip(title: "30 min", isSelected: false)
    }
    .padding()
}
