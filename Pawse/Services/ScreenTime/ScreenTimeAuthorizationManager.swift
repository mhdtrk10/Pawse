//
//  ScreenTimeAuthorizationManager.swift
//  Pawse
//
//  Created by Mehdi Oturak on 2.05.2026.
//

import Foundation
import Combine
import FamilyControls

@MainActor
final class ScreenTimeAuthorizationManager: ObservableObject {
    @Published private(set) var authorizationStatus: ScreenTimeAuthorizationStatus = .notDetermined

    func requestAuthorization() async {
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
            authorizationStatus = .approved
        } catch {
            authorizationStatus = .error(error.localizedDescription)
        }
    }
}
