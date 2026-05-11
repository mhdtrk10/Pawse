//
//  NotificationPermissionManager.swift
//  Pawse
//
//  Created for Local Notifications Support
//
import Combine
import Foundation
import UserNotifications

/// ADDED FOR LOCAL NOTIFICATIONS
/// Manages notification permission requests and authorization status
@MainActor
final class NotificationPermissionManager: ObservableObject {
    
    static let shared = NotificationPermissionManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    /// Checks the current notification authorization status
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    /// Requests notification permission from the user
    /// - Returns: True if permission granted, false otherwise
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            
            await checkAuthorizationStatus()
            
            if granted {
                print("✅ [NotificationPermissionManager] Permission granted")
            } else {
                print("⚠️ [NotificationPermissionManager] Permission denied by user")
            }
            
            return granted
        } catch {
            print("❌ [NotificationPermissionManager] Error requesting permission: \(error)")
            return false
        }
    }
    
    /// Returns true if notifications are authorized
    var isAuthorized: Bool {
        authorizationStatus == .authorized
    }
    
    /// Returns true if permission has never been requested
    var isNotDetermined: Bool {
        authorizationStatus == .notDetermined
    }
}
