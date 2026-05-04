//
//  BreakPreviewView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 4.05.2026.
//

import SwiftUI

struct BreakPreviewView: View {
    let catName: String
    let remainingSeconds: Int

    @EnvironmentObject private var languageManager: LanguageManager
    
    

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    AppColors.primary.opacity(0.12),
                    AppColors.catAccent.opacity(0.10),
                    Color(.systemBackground)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(AppColors.catAccent.opacity(0.15))
                        .frame(width: 180, height: 180)

                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 70))
                        .foregroundStyle(AppColors.catAccent)
                }

                VStack(spacing: 10) {
                    Text(title)
                        .font(.system(size: 30, weight: .bold))

                    Text(subtitle)
                        .font(.body)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }

                CardContainer {
                    VStack(spacing: 12) {
                        Text(formattedTime)
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(AppColors.primary)

                        Text(catMessage)
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                }
                .padding(.horizontal)

                Spacer()

                VStack(spacing: 8) {
                    Text(languageManager.selectedLanguage == .english ? "Take a short pause" : "Kısa bir mola ver")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(AppColors.secondaryText)

                    Text(languageManager.selectedLanguage == .english ? "Pawse will let you back in when the break ends." : "Mola bittiğinde Pawse seni tekrar içeri alacak.")
                        .font(.caption)
                        .foregroundStyle(AppColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.bottom, 24)
            }
            .padding()
        }
        
    }

    private var title: String {
        switch languageManager.selectedLanguage {
        case .english:
            return "Break Time"
        case .turkish:
            return "Mola Zamanı"
        }
    }

    private var subtitle: String {
        switch languageManager.selectedLanguage {
        case .english:
            return "Pawse stepped in. Take a short break and come back refreshed."
        case .turkish:
            return "Pawse devreye girdi. Kısa bir mola ver ve daha dinç geri dön."
        }
    }

    private var catMessage: String {
        switch languageManager.selectedLanguage {
        case .english:
            return "\(catName) is watching your break."
        case .turkish:
            return "\(catName) molanı takip ediyor."
        }
    }

    private var formattedTime: String {
        let minutes = remainingSeconds / 60
        let seconds = remainingSeconds % 60

        switch languageManager.selectedLanguage {
        case .english:
            return String(format: "%02d:%02d left", minutes, seconds)
        case .turkish:
            return String(format: "%02d:%02d kaldı", minutes, seconds)
        }
    }
}

#Preview {
    BreakPreviewView(catName: "Sleepy Cat", remainingSeconds: 120)
        .environmentObject(LanguageManager())
}
