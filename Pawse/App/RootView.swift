//
//  RootView.swift
//  Pawse
//
//  Created by Mehdi Oturak on 29.04.2026.
//

import SwiftUI
// ADDED FOR LOCAL NOTIFICATIONS - START
import UserNotifications
// ADDED FOR LOCAL NOTIFICATIONS - END

struct RootView: View {
    @State private var hasSeenOnboarding: Bool = UserDefaultsManager.shared.hasSeenOnboarding
    @State private var showSplash = true
    
    // ADDED FOR LOCAL NOTIFICATIONS - START
    @State private var hasRequestedNotificationPermission: Bool = UserDefaultsManager.shared.hasRequestedNotificationPermission
    @State private var showNotificationPermissionPrompt: Bool = false
    // ADDED FOR LOCAL NOTIFICATIONS - END
    
    var body: some View {
        Group {
            if hasSeenOnboarding {
                ZStack {
                    MainTabView()
                        .opacity(showSplash ? 0 : 1)

                    if showSplash {
                        SplashView()
                            .transition(.opacity)
                            .zIndex(1)
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            showSplash = false
                        }
                        
                        // ADDED FOR LOCAL NOTIFICATIONS - START
                        // Request notification permission after splash if not requested before
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            if !hasRequestedNotificationPermission {
                                showNotificationPermissionPrompt = true
                            }
                        }
                        // ADDED FOR LOCAL NOTIFICATIONS - END
                    }
                }
                // ADDED FOR LOCAL NOTIFICATIONS - START
                .sheet(isPresented: $showNotificationPermissionPrompt) {
                    NotificationPermissionPromptView(hasRequestedPermission: $hasRequestedNotificationPermission)
                }
                // ADDED FOR LOCAL NOTIFICATIONS - END
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
    }
}

#Preview {
    RootView()
}

// ADDED FOR LOCAL NOTIFICATIONS - START
/// Temporary inline view for notification permission
struct NotificationPermissionPromptView: View {
    @Binding var hasRequestedPermission: Bool
    @Environment(\.dismiss) private var dismiss
    @State private var isLoading = false
    
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
                    isLoading = true
                    Task {
                        await requestNotificationPermission()
                        await MainActor.run {
                            hasRequestedPermission = true
                            UserDefaultsManager.shared.hasRequestedNotificationPermission = true
                            dismiss()
                        }
                    }
                } label: {
                    if isLoading {
                        ProgressView()
                            .tint(.white)
                            .frame(maxWidth: .infinity)
                    } else {
                        Text("Enable Notifications")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(.blue.gradient)
                .cornerRadius(16)
                .disabled(isLoading)
                
                Button {
                    hasRequestedPermission = true
                    UserDefaultsManager.shared.hasRequestedNotificationPermission = true
                    dismiss()
                } label: {
                    Text("Skip for Now")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 32)
        }
        .padding()
        .presentationDetents([.medium])
        .interactiveDismissDisabled(false)
    }
    
    private func requestNotificationPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
            print(granted ? "✅ Notification permission granted" : "⚠️ Notification permission denied")
        } catch {
            print("❌ Error requesting notification permission: \(error)")
        }
    }
}
// ADDED FOR LOCAL NOTIFICATIONS - END
