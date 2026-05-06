//
//  CustomPhotoEditorViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 5.05.2026.
//
import Combine
import SwiftUI
import PhotosUI


@MainActor
final class CustomPhotoEditorViewModel: ObservableObject {
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var previewImage: UIImage?

    @Published var scale: CGFloat = 1.0
    @Published var lastScale: CGFloat = 1.0

    @Published var offset: CGSize = .zero
    @Published var lastOffset: CGSize = .zero

    @Published var isSaving: Bool = false
    @Published var didSaveSuccessfully: Bool = false
    @Published var errorMessage: String?

    private let customPhotoService: CustomPhotoService
    private let settingsService: SettingsService
    var isCustomPhotoActive: Bool {
        settingsService.getBreakMediaType() == .customPhoto
    }

    init(
        customPhotoService: CustomPhotoService = CustomPhotoService(),
        settingsService: SettingsService = SettingsService()
    ) {
        self.customPhotoService = customPhotoService
        self.settingsService = settingsService
        loadExistingPhotoIfNeeded()
    }

    func loadPickedPhoto() async {
        guard let selectedPhotoItem else { return }

        do {
            if let data = try await selectedPhotoItem.loadTransferable(type: Data.self),
               let image = UIImage(data: data) {
                selectedImage = image
                previewImage = image
                resetTransform()
            }
        } catch {
            errorMessage = "Failed to load selected photo."
        }
    }

    func saveCustomPhoto() {
        guard let image = selectedImage else { return }

        isSaving = true

        let fileName = customPhotoService.saveImage(image)
        guard let fileName else {
            isSaving = false
            errorMessage = "Failed to save custom photo."
            return
        }

        settingsService.setCustomPhotoFileName(fileName)
        settingsService.setBreakMediaType(.customPhoto)
        settingsService.saveCustomPhotoTransform(
            scale: Double(scale),
            offsetX: Double(offset.width),
            offsetY: Double(offset.height)
        )

        isSaving = false
        didSaveSuccessfully = true
    }

    func loadExistingPhotoIfNeeded() {
        let fileName = settingsService.getCustomPhotoFileName()
        if let image = customPhotoService.loadImage(fileName: fileName) {
            selectedImage = image
            previewImage = image

            let transform = settingsService.getCustomPhotoTransform()
            scale = CGFloat(transform.scale)
            lastScale = CGFloat(transform.scale)
            offset = CGSize(width: transform.offsetX, height: transform.offsetY)
            lastOffset = CGSize(width: transform.offsetX, height: transform.offsetY)
        }
    }

    func resetTransform() {
        scale = 1.0
        lastScale = 1.0
        offset = .zero
        lastOffset = .zero
    }

    func removeCustomPhoto() {
        let fileName = settingsService.getCustomPhotoFileName()
        customPhotoService.deleteImage(fileName: fileName)
        settingsService.clearCustomPhotoSettings()

        selectedImage = nil
        previewImage = nil
        selectedPhotoItem = nil
        resetTransform()
    }
    func switchBackToBuiltInCats() {
        settingsService.switchToBuiltInCatMedia()
    }
    
}
