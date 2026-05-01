//
//  CardContainer.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct CardContainer<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding()
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.05), radius: 6, x: 0, y: 2)
    }
}

#Preview {
    CardContainer {
        Text("Example Card")
    }
    .padding()
    .background(AppColors.background)
}
