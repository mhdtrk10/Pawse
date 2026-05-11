//
//  CatsViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//


import Combine
import Foundation

@MainActor
final class CatsViewModel: ObservableObject {
    @Published var cats: [CatItem] = []
    @Published var selectedCatName: String = "Default Cat"
    @Published var premiumFeature: PremiumFeature?

    private let catalogService: CatCatalogService
    private let selectionService: CatSelectionService
    private let settingsService: SettingsService

    init(
        catalogService: CatCatalogService = CatCatalogService(),
        selectionService: CatSelectionService = CatSelectionService(),
        settingsService: SettingsService = SettingsService()
    ) {
        self.catalogService = catalogService
        self.selectionService = selectionService
        self.settingsService = settingsService
        loadCats()
        loadSelectedCat()
    }

    func loadCats() {
        cats = catalogService.fetchCats()
    }

    func loadSelectedCat() {
        selectedCatName = selectionService.getSelectedCatName()
    }

    func handleTap(on cat: CatItem, hasAccess: Bool) {
        if hasAccess {
            selectCat(cat)
        } else {
            premiumFeature = .premiumCat(catID: cat.id, catName: cat.name)
        }
    }

    func selectCat(_ cat: CatItem) {
        selectionService.selectCat(named: cat.name)

        var settings = settingsService.getAppSettings()
        settings.activeCatName = cat.name
        settings.selectedBreakMediaType = .builtInCat
        settingsService.saveAppSettings(settings)

        selectedCatName = cat.name
    }

    func isSelected(_ cat: CatItem) -> Bool {
        selectedCatName == cat.name
    }

    func openPremiumFeature(_ feature: PremiumFeature) {
        premiumFeature = feature
    }
}
