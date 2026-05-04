//
//  TestSessionState.swift
//  Pawse
//
//  Created by Mehdi Oturak on 4.05.2026.
//

import Foundation

enum TestSessionState: Equatable {
    case idle
    case running(remainingSeconds: Int)
    case breakTime(remainingSeconds: Int)
    case completed
}
