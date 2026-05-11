//
//  ActiveSessionSnapshot.swift
//  Pawse
//
//  Created by Mehdi Oturak on 8.05.2026.
//

import Foundation

struct ActiveSessionSnapshot: Codable {
    let sessionStartDate: Date
    let sessionEndDate: Date
    let breakEndDate: Date
    let selectedAtLeastOneTarget: Bool
}
