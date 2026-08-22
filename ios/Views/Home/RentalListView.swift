//
//  RentalListView.swift
//  Walkaround
//
//  Main Dashboard listing active vehicle rentals with sandbox JSON persistence,
//  swipe-to-delete/archive, and quick inspection launcher.
//

import SwiftUI

public struct RentalListView: View {
    @ObservedObject private var rentalStorage = RentalStorageService.shared

    @State private var showingNewRentalSheet = false
    @State private var selectedRental: Rental?
    @State private var inspectionToLaunch: (rental: Rental, phase: InspectionPhase)?
    @State private var disputeToExport: Rental?
    @State private var showingSettings = false
    @State private var showingPaywall = false

    public init() {}

    private var rentals: [Rental] {
        rentalStorage.rentals
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // 1. Protection Banner Hero
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("EASY CAR RENTAL CHECK-IN")
                                    .font(.system(size: 11, weight: .black))
                                    .foregroundColor(Color(red: 0.02, green: 0.59, blue: 0.41))
                                Text("Document Your Car in 60s")
                                    .font(.title2.bold())
                                    .foregroundColor(.primary)
                            }
                            Spacer()
                            Image(systemName: "camera.viewfinder")
                                .font(.system(size: 36))
                                .foregroundColor(Color(red: 0.02, green: 0.59, blue: 0.41))
                        }

                        Text("Take quick timestamped photos before driving away. Keep an organized record of pre-existing marks.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        HStack {
                            Button(action: { showingNewRentalSheet = true }) {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("New Check-In")
                                }
                                .font(.subheadline.bold())
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(red: 0.02, green: 0.59, blue: 0.41))
                                .foregroundColor(.white)
                                .cornerRadius(20)
                            }
                            .accessibilityLabel("Start new rental inspection")

                            Spacer()

                            Button(action: { showingPaywall = true }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "crown.fill")
                                    Text("PRO PASS")
                                }
                                .font(.caption.bold())
                                .foregroundColor(.amber)
                            }
                            .accessibilityLabel("View premium subscription options")
                        }
                        .padding(.top, 4)
                    }
                    .padding(18)
                    .background(Color(red: 0.95, green: 0.98, blue: 0.96))
                    .cornerRadius(20)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(red: 0.85, green: 0.93, blue: 0.88), lineWidth: 1)
                    )
                    .padding(.horizontal)

                    // 2. Active Rentals Section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Active Rentals")
                                .font(.headline.bold())
                            Spacer()
                            Text("\(rentals.filter { !$0.isArchived }.count) Active")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        if rentals.filter({ !$0.isArchived }).isEmpty {
                            VStack(spacing: 12) {
                                Image(systemName: "car.2.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.secondary.opacity(0.5))
                                Text("No Active Rentals")
                                    .font(.headline)
                                    .foregroundColor(.secondary)
                                Text("Picking up a rental car? Tap below to start your quick 60-second photo check-in.")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 40)

                                Button(action: { showingNewRentalSheet = true }) {
                                    Text("Add Rental Car")
                                        .font(.subheadline.bold())
                                        .padding(.horizontal, 20)
                                        .padding(.vertical, 8)
                                        .background(Color(red: 0.02, green: 0.59, blue: 0.41))
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .padding(.top, 4)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                            .background(Color.cardBackground)
                            .cornerRadius(16)
                            .padding(.horizontal)
                        } else {
                            ForEach(rentals.filter { !$0.isArchived }) { rental in
                                RentalCardView(
                                    rental: rental,
                                    onSelect: { selectedRental = rental },
                                    onStartPickup: {
                                        inspectionToLaunch = (rental, .pickup)
                                    },
                                    onStartDropoff: {
                                        inspectionToLaunch = (rental, .dropoff)
                                    },
                                    onExportDispute: {
                                        disputeToExport = rental
                                    }
                                )
                                .padding(.horizontal)
                                .contextMenu {
                                    Button(role: .destructive) {
                                        deleteRental(rental)
                                    } label: {
                                        Label("Delete Rental", systemImage: "trash")
                                    }
                                    Button {
                                        archiveRental(rental)
                                    } label: {
                                        Label("Archive Rental", systemImage: "archivebox")
                                    }
                                }
                            }
                        }
                    }

                    // 3. Helpful Inspection Tips Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.amber)
                            Text("3 Areas Commonly Missed at Pick-Up")
                                .font(.subheadline.bold())
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("1. **Lower Wheel Rims**: Curb scrapes along alloy edges are easy to miss.")
                                .font(.caption)
                            Text("2. **Roof & Overhead Panels**: Check higher angles before driving away.")
                                .font(.caption)
                            Text("3. **Dashboard & Fuel Gauge**: Take a photo with ignition ON to confirm exact mileage and fuel.")
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                    .padding(16)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Walkaround")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingNewRentalSheet = true }) {
                        Image(systemName: "plus")
                            .font(.headline.bold())
                    }
                    .accessibilityLabel("Add new rental")
                }
                #if os(iOS)
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Open settings")
                }
                #else
                ToolbarItem(placement: .navigation) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Open settings")
                }
                #endif
            }
            .sheet(isPresented: $showingNewRentalSheet) {
                NewRentalSheet { newRental in
                    rentalStorage.addRental(newRental)
                    inspectionToLaunch = (newRental, .pickup)
                }
            }
            .sheet(item: $selectedRental) { rental in
                InspectionHubView(rental: rental)
            }
            #if canImport(UIKit)
            .sheet(item: Binding(
                get: { inspectionToLaunch.map { IdentifiableInspectionLaunch(rental: $0.rental, phase: $0.phase) } },
                set: { _ in inspectionToLaunch = nil }
            )) { launch in
                GuidedCameraFlowView(
                    rental: launch.rental,
                    phase: launch.phase
                )
            }
            .sheet(item: $disputeToExport) { rental in
                DisputeDossierView(rental: rental)
            }
            #endif
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallSheet()
            }
        }
    }

    private func deleteRental(_ rental: Rental) {
        rentalStorage.deleteRental(rental)
    }

    private func archiveRental(_ rental: Rental) {
        rentalStorage.archiveRental(rental)
    }
}

// Helper struct for sheet presentation
struct IdentifiableInspectionLaunch: Identifiable {
    var id: String { "\(rental.id.uuidString)_\(phase.rawValue)" }
    let rental: Rental
    let phase: InspectionPhase
}
