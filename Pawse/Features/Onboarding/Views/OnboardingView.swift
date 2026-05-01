//
//  OnboardingView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage: Int = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "onboarding.title1",
            subtitle: "onboarding.subtitle1",
            systemImageName: "pawprint.fill"
        ),
        OnboardingPage(
            title: "onboarding.title2",
            subtitle: "onboarding.subtitle2",
            systemImageName: "app.badge.fill"
        ),
        OnboardingPage(
            title: "onboarding.title3",
            subtitle: "onboarding.subtitle3",
            systemImageName: "timer"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))

            VStack(spacing: 12) {
                Button {
                    handlePrimaryButtonTapped()
                } label: {
                    Text(currentPage == pages.count - 1 ? L10n.getStarted : L10n.next)
                }
                .buttonStyle(PrimaryButtonStyle())

                if currentPage < pages.count - 1 {
                    Button {
                        completeOnboarding()
                    } label: {
                        Text(L10n.skip)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                }
            }
            .padding()
            .background(AppColors.background)
        }
    }

    private func handlePrimaryButtonTapped() {
        if currentPage < pages.count - 1 {
            withAnimation {
                currentPage += 1
            }
        } else {
            completeOnboarding()
        }
    }

    private func completeOnboarding() {
        UserDefaultsManager.shared.hasSeenOnboarding = true
        hasSeenOnboarding = true
    }
}

#Preview {
    OnboardingView(hasSeenOnboarding: .constant(false))
}
