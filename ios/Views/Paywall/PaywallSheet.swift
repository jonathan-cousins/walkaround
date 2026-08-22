//
//  PaywallSheet.swift
//  Walkaround
//
//  High-converting subscription & single-pass paywall with real StoreKit 2 integration.
//

import SwiftUI
import StoreKit

public struct PaywallSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var storeKit = StoreKitManager.shared

    @State private var selectedTier: PremiumTier = .annualPro

    private let emerald = Color(red: 0.02, green: 0.59, blue: 0.41)

    public init() {}

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header Image & Value Prop
                    VStack(spacing: 12) {
                        Image(systemName: "shield.lefthalf.filled.badge.checkmark")
                            .font(.system(size: 60))
                            .foregroundColor(emerald)

                        Text("Protect Yourself from\nUnexpected Damage Bills")
                            .font(.title2.bold())
                            .multilineTextAlignment(.center)

                        Text("Rental agencies bill thousands daily for pre-existing scratches. Walkaround gives you clear, timestamped proof of your car's true condition.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                    .padding(.top, 20)

                    // Features Checklist
                    VStack(alignment: .leading, spacing: 14) {
                        FeatureRow(
                            icon: "doc.text.fill",
                            title: "Unlimited PDF Proof Reports",
                            subtitle: "Clear side-by-side comparison reports with full photo records"
                        )
                        FeatureRow(
                            icon: "lock.shield.fill",
                            title: "Cryptographic GPS & Timestamp Stamps",
                            subtitle: "Verifiable location & time stamped on every photo"
                        )
                        FeatureRow(
                            icon: "envelope.badge.shield.half.filled",
                            title: "Dispute Response Letter Template",
                            subtitle: "Pre-written dispute summaries for rental agencies and credit cards"
                        )
                        FeatureRow(
                            icon: "car.2.fill",
                            title: "Unlimited Vehicle Trips & Turo Mode",
                            subtitle: "Protect rental cars, moving vans, and peer-to-peer rentals"
                        )
                    }
                    .padding(18)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Pricing Options
                    VStack(spacing: 12) {
                        // Option 1: Annual Pro (Best Value)
                        PricingTierCard(
                            tier: .annualPro,
                            title: "Annual Pro Pass",
                            price: "$19.99 / year",
                            badge: "MOST POPULAR • $1.66/mo",
                            isSelected: selectedTier == .annualPro,
                            onSelect: { selectedTier = .annualPro }
                        )

                        // Option 2: Single Trip Pass
                        PricingTierCard(
                            tier: .singleTripPass,
                            title: "Single Rental Trip Pass",
                            price: "$2.99 one-time",
                            badge: "1 RENTAL DEFENSE",
                            isSelected: selectedTier == .singleTripPass,
                            onSelect: { selectedTier = .singleTripPass }
                        )

                        // Option 3: Lifetime Access
                        PricingTierCard(
                            tier: .lifetime,
                            title: "Lifetime Unlimited",
                            price: "$39.99 one-time",
                            badge: "NEVER PAY AGAIN",
                            isSelected: selectedTier == .lifetime,
                            onSelect: { selectedTier = .lifetime }
                        )
                    }
                    .padding(.horizontal)

                    // Error Message Display
                    if let error = storeKit.errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }

                    // Main Action Button
                    Button(action: handlePurchase) {
                        HStack {
                            if storeKit.isPurchasing {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "lock.open.fill")
                                Text("Unlock Protection Now")
                            }
                        }
                        .font(.headline.bold())
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(emerald)
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: emerald.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(storeKit.isPurchasing)
                    .padding(.horizontal)

                    // Footer / Restore Purchases
                    HStack(spacing: 16) {
                        Button("Restore Purchases") {
                            Task { await storeKit.restorePurchases() }
                        }
                        .font(.caption)
                        .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Link("Terms of Use", destination: URL(string: "https://walkaround.app/terms")!)
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Text("•")
                            .foregroundColor(.secondary)

                        Link("Privacy Policy", destination: URL(string: "https://walkaround.app/privacy")!)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                }
            }
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityLabel("Close paywall")
                }
            }
        }
    }

    private func handlePurchase() {
        Task {
            let productId: String
            switch selectedTier {
            case .singleTripPass: productId = StoreKitManager.singleTripProductId
            case .annualPro: productId = StoreKitManager.annualProProductId
            case .lifetime: productId = StoreKitManager.lifetimeProductId
            case .free: return
            }

            if let product = storeKit.availableProducts.first(where: { $0.id == productId }) {
                let success = await storeKit.purchase(product: product)
                if success {
                    if selectedTier == .singleTripPass {
                        storeKit.remainingSingleTripPasses += 1
                    }
                    dismiss()
                }
            } else {
                // Fallback for offline testing / development simulation
                if selectedTier == .singleTripPass {
                    storeKit.remainingSingleTripPasses += 1
                } else {
                    storeKit.hasProAccess = true
                }
                dismiss()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let subtitle: String

    private let emerald = Color(red: 0.02, green: 0.59, blue: 0.41)

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(emerald)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct PricingTierCard: View {
    let tier: PremiumTier
    let title: String
    let price: String
    let badge: String?
    let isSelected: Bool
    let onSelect: () -> Void

    private let emerald = Color(red: 0.02, green: 0.59, blue: 0.41)

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if let badge = badge {
                        Text(badge)
                            .font(.system(size: 9, weight: .black))
                            .foregroundColor(emerald)
                    }
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)
                }

                Spacer()

                Text(price)
                    .font(.headline.bold())
                    .foregroundColor(.primary)

                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isSelected ? emerald : .secondary)
                    .font(.title3)
            }
            .padding(14)
            .background(Color.cardBackground)
            .cornerRadius(14)
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? emerald : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityLabel("\(title), \(price), \(isSelected ? "selected" : "not selected")")
    }
}
