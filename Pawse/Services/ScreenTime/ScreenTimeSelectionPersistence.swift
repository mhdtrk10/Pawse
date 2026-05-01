//
//  ScreenTimeSelectionPersistence.swift
//  Pawse
//
//  Created by Mehdi Oturak on 2.05.2026.
//

import Foundation
import FamilyControls

final class ScreenTimeSelectionPersistence {
    private let key = "screenTime.familyActivitySelection"

    func save(_ selection: FamilyActivitySelection) {
        do {
            let data = try JSONEncoder().encode(selection)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            print("Failed to save FamilyActivitySelection: \(error)")
        }
    }

    func load() -> FamilyActivitySelection {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return FamilyActivitySelection()
        }

        do {
            return try JSONDecoder().decode(FamilyActivitySelection.self, from: data)
        } catch {
            print("Failed to load FamilyActivitySelection: \(error)")
            return FamilyActivitySelection()
        }
    }
}
