//
//  LocalNotificationManager.swift
//  Pawse
//
//  Created for Local Notifications Support
//

import Foundation
import UserNotifications

/// ADDED FOR LOCAL NOTIFICATIONS
/// Manages scheduling and canceling local notifications for break reminders
final class LocalNotificationManager {
    
    static let shared = LocalNotificationManager()
    
    // MARK: - Constants
    
    /// Unique identifier for break time notification
    private enum NotificationIdentifier {
        static let breakTime = "com.pawse.notification.breakTime"
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// Schedules a notification for when the break starts
    /// - Parameters:
    ///   - breakStartDate: The date when the break should begin (sessionEndDate)
    ///   - language: The user's selected language for localized content
    func scheduleBreakNotification(
        at breakStartDate: Date,
        language: AppLanguage
    ) async {
        // First, remove any existing pending notification
        await removePendingBreakNotification()
        
        // Check if we have permission
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            print("⚠️ [LocalNotificationManager] Not authorized to schedule notifications")
            return
        }
        
        // Check if the date is in the future
        let now = Date()
        guard breakStartDate > now else {
            print("⚠️ [LocalNotificationManager] Break date is in the past, not scheduling")
            return
        }
        
        // Create notification content
        let content = UNMutableNotificationContent()
        content.title = localizedTitle(for: language)
        content.body = localizedBody(for: language)
        content.sound = .default
        content.badge = 1
        
        // Create trigger based on the date
        let triggerDate = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: breakStartDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        
        // Create request
        let request = UNNotificationRequest(
            identifier: NotificationIdentifier.breakTime,
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        do {
            try await UNUserNotificationCenter.current().add(request)
            print("✅ [LocalNotificationManager] Break notification scheduled for \(breakStartDate)")
        } catch {
            print("❌ [LocalNotificationManager] Error scheduling notification: \(error)")
        }
    }
    
    /// Removes any pending break notification
    func removePendingBreakNotification() async {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [NotificationIdentifier.breakTime]
        )
        print("🗑️ [LocalNotificationManager] Pending break notification removed")
    }
    
    /// Removes delivered break notifications from notification center
    func removeDeliveredBreakNotifications() async {
        UNUserNotificationCenter.current().removeDeliveredNotifications(
            withIdentifiers: [NotificationIdentifier.breakTime]
        )
        print("🗑️ [LocalNotificationManager] Delivered break notifications removed")
    }
    
    /// Clears all notifications (both pending and delivered)
    func clearAllBreakNotifications() async {
        await removePendingBreakNotification()
        await removeDeliveredBreakNotifications()
    }
    
    // MARK: - Private Helpers
    
    /// Returns localized notification title
    private func localizedTitle(for language: AppLanguage) -> String {
        switch language {
        case .english:
            return "Break Time 🐾"
        case .turkish:
            return "Mola Zamanı 🐾"
        }
    }
    
    /// Returns localized notification body
    private func localizedBody(for language: AppLanguage) -> String {
        switch language {
        case .english:
            return "Your session is over. Time to take a short break."
        case .turkish:
            return "Oturumun sona erdi. Kısa bir mola zamanı."
        }
    }
}
