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
                imageName: "default_cat_image",
                animatedGIFName: nil,
                isPremium: false,
                accentColorKey: "orange",
                moodMessageEN: "A calm little break companion.",
                moodMessageTR: "Sakin bir mola arkadaşı."
            ),
            CatItem(
                id: "happy_cat",
                name: "Happy Cat",
                subtitle: "Free",
                systemImageName: "heart.fill",
                imageName: "happy_cat_image",
                animatedGIFName: nil,
                isPremium: false,
                accentColorKey: "pink",
                moodMessageEN: "A cheerful cat for light breaks.",
                moodMessageTR: "Hafif molalar için neşeli bir kedi."
            ),
            CatItem(
                id: "sleepy_cat",
                name: "Sleepy Cat",
                subtitle: "Premium",
                systemImageName: "moon.stars.fill",
                imageName: "sleepy_cat_image",
                animatedGIFName: nil,
                isPremium: true,
                accentColorKey: "blue",
                moodMessageEN: "Soft, sleepy and relaxing.",
                moodMessageTR: "Yumuşak, uykulu ve rahatlatıcı."
            ),
            CatItem(
                id: "angry_cat",
                name: "Angry Cat",
                subtitle: "Premium",
                systemImageName: "flame.fill",
                imageName: "angry_cat_image",
                animatedGIFName: nil,
                isPremium: true,
                accentColorKey: "red",
                moodMessageEN: "Strict mode. No more scrolling.",
                moodMessageTR: "Sert mod. Artık kaydırmak yok."
            ),
            CatItem(
                id: "office_cat",
                name: "Office Cat",
                subtitle: "Premium",
                systemImageName: "briefcase.fill",
                imageName: "office_cat_image",
                animatedGIFName: nil,
                isPremium: true,
                accentColorKey: "gray",
                moodMessageEN: "Professional focus energy.",
                moodMessageTR: "Profesyonel odak enerjisi."
            ),
            CatItem(
                id: "space_cat",
                name: "Space Cat",
                subtitle: "Premium",
                systemImageName: "sparkles",
                imageName: "space_cat_image",
                animatedGIFName: "cat_astronaut.gif",
                isPremium: true,
                accentColorKey: "purple",
                moodMessageEN: "A cosmic pause from the feed.",
                moodMessageTR: "Akıştan kozmik bir mola."
            )
        ]
    }
}
