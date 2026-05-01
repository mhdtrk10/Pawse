//
//  CatCatalogService.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import Foundation

final class CatCatalogService {
    func fetchCats() -> [CatItem] {
        [
            CatItem(
                id: "default_cat",
                name: "Default Cat",
                subtitle: "Free",
                systemImageName: "pawprint.fill",
                isPremium: false
            ),
            CatItem(
                id: "happy_cat",
                name: "Happy Cat",
                subtitle: "Free",
                systemImageName: "heart.fill",
                isPremium: false
            ),
            CatItem(
                id: "sleepy_cat",
                name: "Sleepy Cat",
                subtitle: "Premium",
                systemImageName: "moon.stars.fill",
                isPremium: true
            ),
            CatItem(
                id: "angry_cat",
                name: "Angry Cat",
                subtitle: "Premium",
                systemImageName: "flame.fill",
                isPremium: true
            ),
            CatItem(
                id: "office_cat",
                name: "Office Cat",
                subtitle: "Premium",
                systemImageName: "briefcase.fill",
                isPremium: true
            ),
            CatItem(
                id: "space_cat",
                name: "Space Cat",
                subtitle: "Premium",
                systemImageName: "sparkles",
                isPremium: true
            )
        ]
    }
}
