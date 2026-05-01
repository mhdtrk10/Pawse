//
//  CatsViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import Foundation
import Combine

@MainActor
final class CatsViewModel: ObservableObject {
    @Published var cats: [CatItem] = []
    @Published var selectedCatName: String = "Default Cat"

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

    func selectCat(_ cat: CatItem) {
        guard !cat.isPremium else { return }
        selectionService.selectCat(named: cat.name)
        selectedCatName = cat.name
    }

    func isSelected(_ cat: CatItem) -> Bool {
        selectedCatName == cat.name
    }
}
