//
//  CustomGIFEditorViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 8.05.2026.
//
import Combine
import SwiftUI
import PhotosUI
import UniformTypeIdentifiers

@MainActor
final class CustomGIFEditorViewModel: ObservableObject {
    @Published var selectedGIFItem: PhotosPickerItem?
    @Published var selectedGIFData: Data?
    @Published var didSaveSuccessfully: Bool = false
    @Published var errorMessage: String?

    private let customGIFService: CustomGIFService
    private let settingsService: SettingsService

    init(
        customGIFService: CustomGIFService = CustomGIFService(),
        settingsService: SettingsService = SettingsService()
    ) {
        self.customGIFService = customGIFService
        self.settingsService = settingsService
    }

    var isCustomGIFActive: Bool {
        settingsService.getBreakMediaType() == .customGIF
    }

    var savedGIFURL: URL? {
        customGIFService.loadGIFURL(fileName: settingsService.getCustomGIFFileName())
    }

    func loadPickedGIF() async {
        guard let selectedGIFItem else { return }

        do {
            if let data = try await selectedGIFItem.loadTransferable(type: Data.self) {
                selectedGIFData = data
            } else {
                errorMessage = "Failed to load selected GIF."
            }
        } catch {
            errorMessage = "Failed to load selected GIF."
        }
    }

    func saveCustomGIF() {
        guard let selectedGIFData else {
            errorMessage = "Please select a GIF first."
            return
        }

        guard let fileName = customGIFService.saveGIFData(selectedGIFData) else {
            errorMessage = "Failed to save custom GIF."
            return
        }

        settingsService.setCustomGIFFileName(fileName)
        settingsService.setBreakMediaType(.customGIF)
        didSaveSuccessfully = true
    }

    func removeCustomGIF() {
        let fileName = settingsService.getCustomGIFFileName()
        customGIFService.deleteGIF(fileName: fileName)
        settingsService.clearCustomGIFSettings()
        selectedGIFData = nil
        selectedGIFItem = nil
    }

    func switchBackToBuiltInCats() {
        settingsService.switchToBuiltInCatMedia()
    }
}
