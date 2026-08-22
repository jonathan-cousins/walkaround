//
//  WalkaroundApp.swift
//  Walkaround
//
//  Main application entrypoint with seamless first-time onboarding and disk persistence.
//

import SwiftUI

@main
struct WalkaroundApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @StateObject private var locationService = LocationService.shared
    @StateObject private var storeKitManager = StoreKitManager.shared
    @StateObject private var rentalStorage = RentalStorageService.shared

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                RentalListView()
                    .environmentObject(locationService)
                    .environmentObject(storeKitManager)
                    .environmentObject(rentalStorage)
            } else {
                OnboardingView {
                    hasSeenOnboarding = true
                }
                .environmentObject(rentalStorage)
            }
        }
    }
}
