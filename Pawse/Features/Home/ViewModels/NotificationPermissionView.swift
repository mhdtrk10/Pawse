//
//  NotificationPermissionView.swift
//  Pawse
//
//  Created for Local Notifications Support
//

import SwiftUI

/// ADDED FOR LOCAL NOTIFICATIONS
/// Optional view to request notification permission during app first launch
struct NotificationPermissionView: View {
    
    @StateObject private var permissionManager = NotificationPermissionManager.shared
    @Binding var hasRequestedPermission: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "bell.badge.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
            
            VStack(spacing: 12) {
                Text("Stay on Track")
                    .font(.title.bold())
                
                Text("Get notified when it's time for your break, even when Pawse is in the background.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            VStack(spacing: 12) {
                Button {
                    Task {
                        await permissionManager.requestAuthorization()
                        hasRequestedPermission = true
                    }
                } label: {
                    Text("Enable Notifications")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.blue.gradient)
                        .cornerRadius(16)
                }
                
                Button {
                    hasRequestedPermission = true
                } label: {
                    Text("Skip for Now")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
        }
        .padding()
    }
}

#Preview {
    NotificationPermissionView(hasRequestedPermission: .constant(false))
}
