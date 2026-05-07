//
//  CustomGIFEditorView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 8.05.2026.
//

import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

struct CustomGIFEditorView: View {
    @StateObject private var viewModel = CustomGIFEditorViewModel()
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                previewCard
                controlsCard
                actionButtons
            }
            .padding()
        }
        .background(AppColors.background)
        .navigationTitle(languageManager.selectedLanguage == .english ? "Custom GIF" : "Özel GIF")
        .alert(
            languageManager.selectedLanguage == .english ? "Saved" : "Kaydedildi",
            isPresented: $viewModel.didSaveSuccessfully
        ) {
            Button(languageManager.selectedLanguage == .english ? "OK" : "Tamam") {
                dismiss()
            }
        } message: {
            Text(
                languageManager.selectedLanguage == .english
                ? "Your custom GIF is ready to use."
                : "Özel GIF'in kullanıma hazır."
            )
        }
        .alert(
            languageManager.selectedLanguage == .english ? "Error" : "Hata",
            isPresented: Binding(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )
        ) {
            Button(languageManager.selectedLanguage == .english ? "OK" : "Tamam") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
        .task(id: viewModel.selectedGIFItem) {
            await viewModel.loadPickedGIF()
        }
    }

    @ViewBuilder
    private var previewCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 16) {
                Text(languageManager.selectedLanguage == .english ? "Preview" : "Önizleme")
                    .font(.headline)

                if viewModel.isCustomGIFActive {
                    Text(languageManager.selectedLanguage == .english ? "Custom GIF is currently active." : "Özel GIF şu anda aktif.")
                        .font(.caption)
                        .foregroundStyle(AppColors.primary)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(AppColors.primary.opacity(0.08))
                        .frame(height: 320)
                    

                    RoundedRectangle(cornerRadius: 28)
                        .stroke(AppColors.primary.opacity(0.12), lineWidth: 1)

                    if let savedGIFURL = viewModel.savedGIFURL {
                        AnimatedImageView(
                            fileURL: savedGIFURL,
                            contentMode: .scaleAspectFit,
                            cornerRadius: 24,
                            internalScale: 1.0
                        )
                        .frame(width: 210, height: 280)
                        .scaleEffect(0.48)
                        
                        .clipShape(RoundedRectangle(cornerRadius: 24))
                    } else if viewModel.selectedGIFData != nil {
                        VStack(spacing: 12) {
                            Image(systemName: "sparkles.rectangle.stack")
                                .font(.system(size: 38))
                                .foregroundStyle(AppColors.primary)

                            Text(
                                languageManager.selectedLanguage == .english
                                ? "GIF selected and ready to save"
                                : "GIF seçildi ve kaydetmeye hazır"
                            )
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                        }
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo.stack")
                                .font(.system(size: 38))
                                .foregroundStyle(AppColors.secondaryText)

                            Text(
                                languageManager.selectedLanguage == .english
                                ? "Select a GIF to begin"
                                : "Başlamak için bir GIF seç"
                            )
                            .font(.subheadline)
                            .foregroundStyle(AppColors.secondaryText)
                        }
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var controlsCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 16) {
                Text(languageManager.selectedLanguage == .english ? "Controls" : "Kontroller")
                    .font(.headline)

                Text(
                    languageManager.selectedLanguage == .english
                    ? "Choose an animated GIF from your gallery and use it as your break companion."
                    : "Galerinden animasyonlu bir GIF seç ve mola arkadaşın olarak kullan."
                )
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)

                PhotosPicker(
                    selection: $viewModel.selectedGIFItem,
                    matching: .any(of: [.images]),
                    photoLibrary: .shared()
                ) {
                    Text(languageManager.selectedLanguage == .english ? "Choose GIF" : "GIF Seç")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                if viewModel.savedGIFURL != nil || viewModel.selectedGIFData != nil {
                    Button(role: .destructive) {
                        viewModel.removeCustomGIF()
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Remove Custom GIF" : "Özel GIF'i Kaldır")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
        }
    }

    @ViewBuilder
    private var actionButtons: some View {
        VStack(spacing: 12) {
            Button {
                viewModel.saveCustomGIF()
            } label: {
                Text(languageManager.selectedLanguage == .english ? "Use This GIF" : "Bu GIF'i Kullan")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.selectedGIFData == nil)

            if viewModel.isCustomGIFActive {
                Button {
                    viewModel.switchBackToBuiltInCats()
                } label: {
                    Text(languageManager.selectedLanguage == .english ? "Use Built-in Cats Again" : "Hazır Kedilere Dön")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())
            }
        }
    }
}

#Preview {
    NavigationStack {
        CustomGIFEditorView()
            .environmentObject(LanguageManager())
    }
}
