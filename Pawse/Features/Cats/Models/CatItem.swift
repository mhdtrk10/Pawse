//
//  CatItem.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//
import Foundation

struct CatItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let subtitle: String
    let systemImageName: String
    let imageName: String
    let animatedGIFName: String?
    let isPremium: Bool
    let accentColorKey: String
    let moodMessageEN: String
    let moodMessageTR: String
}
