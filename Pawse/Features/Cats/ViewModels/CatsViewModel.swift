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
    @Published var lockedCat: CatItem?

    private let catalogService: CatCatalogService
    private let selectionService: CatSelectionService

    init(
        catalogService: CatCatalogService = CatCatalogService(),
        selectionService: CatSelectionService = CatSelectionService()
    ) {
        self.catalogService = catalogService
        self.selectionService = selectionService
        loadCats()
        loadSelectedCat()
    }

    func loadCats() {
        cats = catalogService.fetchCats()
    }

    func loadSelectedCat() {
        selectedCatName = selectionService.getSelectedCatName()
    }

    func handleTap(on cat: CatItem) {
        if cat.isPremium {
            lockedCat = cat
        } else {
            selectCat(cat)
        }
    }

    func selectCat(_ cat: CatItem) {
        guard !cat.isPremium else { return }
        selectionService.selectCat(named: cat.name)
        selectedCatName = cat.name
    }

    func isSelected(_ cat: CatItem) -> Bool {
        selectedCatName == cat.name
    }

    func cat(named name: String) -> CatItem? {
        cats.first { $0.name == name }
    }

    func dismissLockedCatSheet() {
        lockedCat = nil
    }
}
