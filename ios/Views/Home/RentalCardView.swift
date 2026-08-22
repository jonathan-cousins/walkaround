//
//  RentalCardView.swift
//  Walkaround
//
//  Clean, friendly card displaying vehicle trip details, inspection progress,
//  and quick action buttons for pickup/dropoff or dispute export.
//

import SwiftUI

public struct RentalCardView: View {
    public let rental: Rental
    public let onSelect: () -> Void
    public let onStartPickup: () -> Void
    public let onStartDropoff: () -> Void
    public let onExportDispute: () -> Void

    private let emerald = Color(red: 0.02, green: 0.59, blue: 0.41)
    private let amber = Color(red: 0.85, green: 0.47, blue: 0.02)

    public init(
        rental: Rental,
        onSelect: @escaping () -> Void,
        onStartPickup: @escaping () -> Void,
        onStartDropoff: @escaping () -> Void,
        onExportDispute: @escaping () -> Void
    ) {
        self.rental = rental
        self.onSelect = onSelect
        self.onStartPickup = onStartPickup
        self.onStartDropoff = onStartDropoff
        self.onExportDispute = onExportDispute
    }

    public var body: some View {
        Button(action: onSelect) {
            VStack(alignment: .leading, spacing: 14) {
                // Top Header: Agency & Status Pill
                HStack {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(emerald)
                            .frame(width: 8, height: 8)
                        Text(rental.agency.rawValue)
                            .font(.subheadline.bold())
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    StatusPill(rental.status.rawValue, color: rental.status == .active ? emerald : amber)
                }

                // Vehicle Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(rental.vehicleTitle)
                        .font(.title3.bold())
                        .foregroundColor(.primary)

                    HStack(spacing: 12) {
                        if !rental.licensePlate.isEmpty {
                            Label(rental.licensePlate, systemImage: "rectangle.fill")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                        }
                        if !rental.agreementNumber.isEmpty {
                            Label("Res: \(rental.agreementNumber)", systemImage: "doc.text")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Divider()

                // Inspection Progress Metrics
                HStack(spacing: 16) {
                    // Pickup Status
                    VStack(alignment: .leading, spacing: 4) {
                        Text("PICK-UP")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)

                        if rental.hasPickupCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(emerald)
                                Text("\(rental.pickupInspection?.completedZoneCount ?? 0) Zones Verified")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(emerald)
                            }
                        } else {
                            Text("Pending Inspection")
                                .font(.caption.weight(.medium))
                                .foregroundColor(amber)
                        }
                    }

                    Spacer()

                    // Dropoff Status
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("RETURN")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)

                        if rental.hasDropoffCompleted {
                            HStack(spacing: 4) {
                                Image(systemName: "checkmark.seal.fill")
                                    .foregroundColor(emerald)
                                Text("Verified")
                                    .font(.caption.weight(.semibold))
                                    .foregroundColor(emerald)
                            }
                        } else {
                            Text(rental.hasPickupCompleted ? "Ready for Return" : "Waiting for Pick-up")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Action Bar
                HStack(spacing: 10) {
                    if !rental.hasPickupCompleted {
                        Button(action: onStartPickup) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Start Pick-up Audit")
                            }
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(emerald)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    } else if !rental.hasDropoffCompleted {
                        Button(action: onStartDropoff) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text("Start Return Audit")
                            }
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(emerald)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                    } else {
                        Button(action: onExportDispute) {
                            HStack {
                                Image(systemName: "shield.checkered")
                                Text("View Dispute Dossier (PDF)")
                            }
                            .font(.subheadline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color.white)
                            .foregroundColor(emerald)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(emerald, lineWidth: 1.5)
                            )
                            .cornerRadius(12)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.cardBackground)
            .cornerRadius(16)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
