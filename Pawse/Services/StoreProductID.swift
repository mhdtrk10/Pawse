//
//  SturoProductID.swift
//  Pawse
//
//  Created by Mehdi Oturak on 10.05.2026.
//

import Foundation

enum StoreProductID {
    static let sleepyCat = "com.mehdioturak.pawse.cat.sleepy.unlock"
    static let angryCat = "com.mehdioturak.pawse.cat.angry.unlock"
    static let officeCat = "com.mehdioturak.pawse.cat.office.unlock"
    static let spaceCat = "com.mehdioturak.pawse.cat.space.unlock"

    static let premiumMonthly = "com.mehdioturak.pawse.premium.monthly"
    static let premiumYearly = "com.mehdioturak.pawse.premium.yearly"

    static let all: [String] = [
        sleepyCat,
        angryCat,
        officeCat,
        spaceCat,
        premiumMonthly,
        premiumYearly
    ]
}
