//
//  ScreenTimeAuthorizationStatus.swift
//  Pawse
//
//  Created by Mehdi Oturak on 2.05.2026.
//

import Foundation

enum ScreenTimeAuthorizationStatus: Equatable {
    case notDetermined
    case approved
    case denied
    case error(String)
}
