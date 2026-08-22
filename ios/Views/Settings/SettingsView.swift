//
//  SettingsView.swift
//  Walkaround
//
//  User settings, distance units, legal disclaimers, and support.
//

import SwiftUI

public struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss

    @AppStorage("defaultUnit") private var defaultUnit = "mi"
    @AppStorage("highResPhotos") private var highResPhotos = true
    @AppStorage("burnGpsToPixels") private var burnGpsToPixels = true
    @AppStorage("renterFullName") private var renterFullName = "John Doe"

    @State private var showingPaywall = false

    public init() {}

    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: User Profile
                Section(header: Text("Renter Profile")) {
                    TextField("Full Legal Name", text: $renterFullName)
                }

                // Section 2: Inspection Preferences
                Section(header: Text("Audit Preferences")) {
                    Picker("Default Distance Unit", selection: $defaultUnit) {
                        Text("Miles (mi)").tag("mi")
                        Text("Kilometers (km)").tag("km")
                    }

                    Toggle("High-Resolution Forensic Photos", isOn: $highResPhotos)
                    Toggle("Burn GPS & Timestamp to Pixels", isOn: $burnGpsToPixels)
                }

                // Section 3: Premium Access
                Section(header: Text("Subscription Status")) {
                    HStack {
                        Text("Current Plan")
                        Spacer()
                        Text(StoreKitManager.shared.hasProAccess ? "Pro Pass (Active)" : "Free Tier")
                            .foregroundColor(.secondary)
                    }

                    Button(action: { showingPaywall = true }) {
                        HStack {
                            Image(systemName: "crown.fill")
                                .foregroundColor(.yellow)
                            Text("Manage Subscription / Upgrade")
                        }
                    }
                }

                // Section 4: Privacy & Legal
                Section(header: Text("Privacy & Compliance")) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("100% On-Device Privacy Guarantee")
                            .font(.caption.bold())
                        Text("Walkaround stores all vehicle photos, GPS data, and dispute dossiers locally on your device. We do not sell your location or photo history.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)

                    Link("Terms of Service", destination: URL(string: "https://walkaround.app/terms")!)
                    Link("Privacy Policy", destination: URL(string: "https://walkaround.app/privacy")!)
                }

                // Section 5: App Version
                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0 (Build 2026.1)")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallSheet()
            }
        }
    }
}
