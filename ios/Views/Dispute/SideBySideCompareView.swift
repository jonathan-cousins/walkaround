//
//  SideBySideCompareView.swift
//  Walkaround
//
//  Visual comparison matrix allowing side-by-side inspection of Pick-up vs Return photos.
//

import SwiftUI

public struct SideBySideCompareView: View {
    public let rental: Rental
    @State private var selectedZone: VehicleZoneId = .frontBumper

    public init(rental: Rental) {
        self.rental = rental
    }

    public var body: some View {
        VStack(spacing: 16) {
            // Zone Picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(VehicleZoneId.allCases) { zone in
                        Button(action: { selectedZone = zone }) {
                            Text(zone.shortTitle)
                                .font(.caption.bold())
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(selectedZone == zone ? Color.blue : Color.subtleFill)
                                .foregroundColor(selectedZone == zone ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }

            // Comparison View
            VStack(spacing: 12) {
                Text(selectedZone.title)
                    .font(.headline.bold())

                HStack(spacing: 12) {
                    // Pick-up Photo Card
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(.blue)
                            Text("PICK-UP")
                                .font(.caption.bold())
                                .foregroundColor(.blue)
                        }

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.subtleFill)
                                .frame(height: 180)

                            if rental.pickupInspection?.photos[selectedZone] != nil {
                                VStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                    Text("Verified Pick-up Photo")
                                        .font(.caption2.bold())
                                }
                            } else {
                                Text("No Photo Taken")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Text(rental.pickupInspection?.completedAt != nil ? "Timestamped: \(rental.pickupInspection!.completedAt!.formatted(date: .numeric, time: .shortened))" : "N/A")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }

                    // Drop-off Photo Card
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(.green)
                            Text("RETURN")
                                .font(.caption.bold())
                                .foregroundColor(.green)
                        }

                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.subtleFill)
                                .frame(height: 180)

                            if rental.dropoffInspection?.photos[selectedZone] != nil {
                                VStack {
                                    Image(systemName: "checkmark.seal.fill")
                                        .font(.title)
                                        .foregroundColor(.green)
                                    Text("Verified Return Photo")
                                        .font(.caption2.bold())
                                }
                            } else {
                                Text("No Photo Taken")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Text(rental.dropoffInspection?.completedAt != nil ? "Timestamped: \(rental.dropoffInspection!.completedAt!.formatted(date: .numeric, time: .shortened))" : "N/A")
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)

                // Damage Annotation Callout if any
                let flagged = (rental.pickupInspection?.damagePoints.filter { $0.zoneId == selectedZone } ?? [])
                if !flagged.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("Pre-existing Damage Logged for \(selectedZone.shortTitle)")
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                        }

                        ForEach(flagged) { d in
                            Text("• **\(d.type.title)**: \(d.notes.isEmpty ? "Documented on pickup photo" : d.notes)")
                                .font(.caption)
                        }
                    }
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
            }
        }
    }
}
