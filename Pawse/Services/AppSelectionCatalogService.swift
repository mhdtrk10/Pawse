//
//  AppSelectionCatalogService.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//

import Foundation

final class AppSelectionCatalogService {
    func fetchDemoApps() -> [SelectedAppItem] {
        [
            SelectedAppItem(id: "instagram", name: "Instagram", systemImageName: "camera.fill", isSelected: false),
            SelectedAppItem(id: "x", name: "X", systemImageName: "bubble.left.and.bubble.right.fill", isSelected: false),
            SelectedAppItem(id: "tiktok", name: "TikTok", systemImageName: "music.note", isSelected: false),
            SelectedAppItem(id: "youtube", name: "YouTube", systemImageName: "play.rectangle.fill", isSelected: false),
            SelectedAppItem(id: "reddit", name: "Reddit", systemImageName: "text.bubble.fill", isSelected: false),
            SelectedAppItem(id: "safari", name: "Safari", systemImageName: "safari.fill", isSelected: false)
        ]
    }
}
