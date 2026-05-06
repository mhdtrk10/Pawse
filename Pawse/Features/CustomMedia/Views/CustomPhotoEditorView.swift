//
//  CustomPhotoEditorView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 5.05.2026.
//

import SwiftUI
import PhotosUI

struct CustomPhotoEditorView: View {
    @StateObject private var viewModel = CustomPhotoEditorViewModel()
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
        .navigationTitle(languageManager.selectedLanguage == .english ? "Custom Photo" : "Özel Fotoğraf")
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
                ? "Your custom photo is ready to use."
                : "Özel fotoğrafın kullanıma hazır."
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
        .task(id: viewModel.selectedPhotoItem) {
            await viewModel.loadPickedPhoto()
        }
    }

    @ViewBuilder
    private var previewCard: some View {
        CardContainer {
            VStack(alignment: .leading, spacing: 16) {
                Text(languageManager.selectedLanguage == .english ? "Preview" : "Önizleme")
                    .font(.headline)

                if viewModel.isCustomPhotoActive {
                    Text(languageManager.selectedLanguage == .english ? "Custom photo is currently active." : "Özel fotoğraf şu anda aktif.")
                        .font(.caption)
                        .foregroundStyle(AppColors.primary)
                }

                ZStack {
                    RoundedRectangle(cornerRadius: 28)
                        .fill(AppColors.primary.opacity(0.08))
                        .frame(height: 320)

                    RoundedRectangle(cornerRadius: 28)
                        .stroke(AppColors.primary.opacity(0.12), lineWidth: 1)

                    if let image = viewModel.previewImage {
                        GeometryReader { geometry in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: geometry.size.width, height: geometry.size.height)
                                .scaleEffect(viewModel.scale)
                                .offset(viewModel.offset)
                                .gesture(dragGesture.simultaneously(with: magnificationGesture))
                                .clipShape(RoundedRectangle(cornerRadius: 28))
                        }
                        .frame(height: 320)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                    } else {
                        VStack(spacing: 12) {
                            Image(systemName: "photo")
                                .font(.system(size: 38))
                                .foregroundStyle(AppColors.secondaryText)

                            Text(
                                languageManager.selectedLanguage == .english
                                ? "Select a photo to begin"
                                : "Başlamak için bir fotoğraf seç"
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
                    ? "Pinch to zoom and drag to position the photo the way you want."
                    : "Fotoğrafı istediğin gibi ayarlamak için yakınlaştır ve sürükle."
                )
                .font(.subheadline)
                .foregroundStyle(AppColors.secondaryText)

                PhotosPicker(
                    selection: $viewModel.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    Text(languageManager.selectedLanguage == .english ? "Choose Photo" : "Fotoğraf Seç")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                Button {
                    viewModel.resetTransform()
                } label: {
                    Text(languageManager.selectedLanguage == .english ? "Reset Position" : "Konumu Sıfırla")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(PrimaryButtonStyle())

                if viewModel.previewImage != nil {
                    Button(role: .destructive) {
                        viewModel.removeCustomPhoto()
                    } label: {
                        Text(languageManager.selectedLanguage == .english ? "Remove Custom Photo" : "Özel Fotoğrafı Kaldır")
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
                viewModel.saveCustomPhoto()
            } label: {
                Text(languageManager.selectedLanguage == .english ? "Use This Photo" : "Bu Fotoğrafı Kullan")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(PrimaryButtonStyle())
            .disabled(viewModel.previewImage == nil || viewModel.isSaving)

            if viewModel.isCustomPhotoActive {
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

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                viewModel.offset = CGSize(
                    width: viewModel.lastOffset.width + value.translation.width,
                    height: viewModel.lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                viewModel.lastOffset = viewModel.offset
            }
    }

    private var magnificationGesture: some Gesture {
        MagnificationGesture()
            .onChanged { value in
                let newScale = viewModel.lastScale * value
                viewModel.scale = min(max(newScale, 1.0), 4.0)
            }
            .onEnded { _ in
                viewModel.lastScale = viewModel.scale
            }
    }
}

#Preview {
    NavigationStack {
        CustomPhotoEditorView()
            .environmentObject(LanguageManager())
    }
}
