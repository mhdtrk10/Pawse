//
//  TimeLimitOption.swift
//  Pawse
//
//  Created by Mehdi Oturak on 30.04.2026.
//

import Foundation

struct TimeLimitOption: Identifiable, Hashable {
    let id = UUID()
    let minutes: Int
}
