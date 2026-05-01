//
//  ScreenTimeSelectionStore.swift
//  Pawse
//
//  Created by Mehdi Oturak on 2.05.2026.
//

import Foundation
import FamilyControls
import Combine
@MainActor
final class ScreenTimeSelectionStore: ObservableObject {
    @Published var familyActivitySelection: FamilyActivitySelection
    @Published var isPickerPresented = false

    private let persistence: ScreenTimeSelectionPersistence

    init(persistence: ScreenTimeSelectionPersistence = ScreenTimeSelectionPersistence()) {
        self.persistence = persistence
        self.familyActivitySelection = persistence.load()
    }

    func saveSelection() {
        persistence.save(familyActivitySelection)
    }
}
