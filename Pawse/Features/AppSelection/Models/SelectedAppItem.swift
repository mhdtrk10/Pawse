//
//  SelectedAppItem.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//

import Foundation

struct SelectedAppItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let systemImageName: String
    var isSelected: Bool
}
