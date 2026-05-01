//
//  OnboardingPageView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.12))
                    .frame(width: 160, height: 160)

                Image(systemName: page.systemImageName)
                    .font(.system(size: 56))
                    .foregroundStyle(AppColors.primary)
            }

            VStack(spacing: 12) {
                Text(LocalizedStringKey(page.title))
                    .font(.largeTitle.bold())
                    .multilineTextAlignment(.center)

                Text(LocalizedStringKey(page.subtitle))
                    .font(.body)
                    .foregroundStyle(AppColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            Spacer()
        }
        .padding()
        .background(AppColors.background)
    }
}
