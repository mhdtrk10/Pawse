//
//  AppSelectionViewModel.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//

import Foundation
import Combine

@MainActor
final class AppSelectionViewModel: ObservableObject {
    @Published var apps: [SelectedAppItem] = []
    @Published var didSaveSuccessfully: Bool = false

    private let appSelectionService: AppSelectionService

    init(appSelectionService: AppSelectionService = AppSelectionService()) {
        self.appSelectionService = appSelectionService
        loadApps()
    }

    var selectedCount: Int {
        apps.filter(\.isSelected).count
    }

    func loadApps() {
        apps = appSelectionService.getApps()
    }

    func toggleSelection(for app: SelectedAppItem) {
        guard let index = apps.firstIndex(where: { $0.id == app.id }) else { return }
        apps[index].isSelected.toggle()
    }

    func saveSelections() {
        appSelectionService.saveApps(apps)
        didSaveSuccessfully = true
    }

    func resetSaveState() {
        didSaveSuccessfully = false
    }
}
