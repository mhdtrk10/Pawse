//
//  PremiumFeature.swift
//  Pawse
//
//  Created by Mehdi Oturak on 8.05.2026.
//

import Foundation

enum PremiumFeature: Identifiable {
    case premiumCat(catID: String, catName: String)
    case customPhoto
    case customGIF

    var id: String {
        switch self {
        case .premiumCat(let catID, _):
            return "premiumCat_\(catID)"
        case .customPhoto:
            return "customPhoto"
        case .customGIF:
            return "customGIF"
        }
    }

    var titleEN: String {
        switch self {
        case .premiumCat(_, let catName):
            return "\(catName) is Premium"
        case .customPhoto:
            return "Custom Photo is Premium"
        case .customGIF:
            return "Custom GIF is Premium"
        }
    }

    var titleTR: String {
        switch self {
        case .premiumCat(_, let catName):
            return "\(catName) Premium"
        case .customPhoto:
            return "Özel Fotoğraf Premium"
        case .customGIF:
            return "Özel GIF Premium"
        }
    }

    var messageEN: String {
        switch self {
        case .premiumCat:
            return "Unlock only this cat or get the monthly premium plan for all premium features."
        case .customPhoto:
            return "Custom Photo is included in the monthly premium plan."
        case .customGIF:
            return "Custom GIF is included in the monthly premium plan."
        }
    }

    var messageTR: String {
        switch self {
        case .premiumCat:
            return "Sadece bu kedinin kilidini açabilir veya tüm premium özellikler için aylık planı alabilirsin."
        case .customPhoto:
            return "Özel Fotoğraf aylık premium planına dahildir."
        case .customGIF:
            return "Özel GIF aylık premium planına dahildir."
        }
    }

    var singleUnlockProductID: String? {
        switch self {
        case .premiumCat(let catID, _):
            switch catID {
            case "sleepy_cat": return StoreProductID.sleepyCat
            case "angry_cat": return StoreProductID.angryCat
            case "office_cat": return StoreProductID.officeCat
            case "space_cat": return StoreProductID.spaceCat
            default: return nil
            }
        case .customPhoto, .customGIF:
            return nil
        }
    }

    var monthlyProductID: String {
        StoreProductID.premiumMonthly
    }
}
