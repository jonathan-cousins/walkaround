//
//  InspectionHubView.swift
//  Walkaround
//
//  Detailed hub for managing Pick-up vs Return inspections,
//  reviewing zones, viewing pre-existing damages, and exporting dispute packs.
//

import SwiftUI
import SwiftData

public struct InspectionHubView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: InspectionViewModel

    public init(rental: Rental) {
        _viewModel = State(initialValue: InspectionViewModel(rental: rental))
    }

    private var emerald: Color { Color(red: 0.02, green: 0.59, blue: 0.41) }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 18) {
                    // Phase Switcher (Pickup vs Return)
                    Picker("Phase", selection: $viewModel.selectedPhase) {
                        Text("1. Pick-up Inspection").tag(InspectionPhase.pickup)
                        Text("2. Return Inspection").tag(InspectionPhase.dropoff)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)

                    // Vehicle & GPS Status Header
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(viewModel.rental.vehicleTitle)
                                    .font(.headline.bold())
                                Text("\(viewModel.rental.agency.rawValue) • \(viewModel.rental.licensePlate)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            StatusPill(
                                (viewModel.currentInspection?.isCompleted == true) ? "Completed" : "In Progress",
                                color: (viewModel.currentInspection?.isCompleted == true) ? emerald : .orange
                            )
                        }

                        Divider()

                        // Inspection stats
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("COMPLETED ZONES")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.currentInspection?.completedZoneCount ?? 0) / \(VehicleZoneId.allCases.count)")
                                    .font(.subheadline.bold())
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("ODOMETER")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.secondary)
                                Text(viewModel.currentInspection?.odometerReading.isEmpty == false ? "\(viewModel.currentInspection!.odometerReading) \(viewModel.currentInspection!.odometerUnit)" : "Not Set")
                                    .font(.subheadline.bold())
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("FLAGGED FLAWS")
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundColor(.secondary)
                                Text("\(viewModel.currentInspection?.damagePoints.count ?? 0) Damage Tags")
                                    .font(.subheadline.bold())
                                    .foregroundColor((viewModel.currentInspection?.damagePoints.count ?? 0) > 0 ? .orange : .primary)
                            }
                        }
                    }
                    .padding(16)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // Quick Action: Dashboard Odometer & Fuel
                    Button(action: { viewModel.showingDashboardCapture = true }) {
                        HStack {
                            Image(systemName: "gauge.with.needle.fill")
                                .font(.title2)
                                .foregroundColor(emerald)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Dashboard, Mileage & Fuel Level")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.primary)
                                Text(viewModel.currentInspection?.odometerReading.isEmpty == false ? "Recorded: \(viewModel.currentInspection!.odometerReading) \(viewModel.currentInspection!.odometerUnit) • Fuel: \(viewModel.currentInspection!.fuelLevel.rawValue)" : "Tap to record odometer reading & snap gauge photo")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                        }
                        .padding(14)
                        .background(Color.cardBackground)
                        .cornerRadius(14)
                        .padding(.horizontal)
                    }

                    // 12 Vehicle Zones Checklist
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Standard Inspection Zones")
                                .font(.headline.bold())
                            Spacer()
                            Text("Tap camera to capture")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)

                        ForEach(VehicleZoneId.allCases.filter { $0 != .dashboardOdometer }) { zone in
                            let photo = viewModel.currentInspection?.photo(for: zone)
                            let hasDamage = viewModel.currentInspection?.damagePoints.contains(where: { $0.zoneId == zone }) ?? false

                            ZoneCardView(
                                zone: zone,
                                photo: photo,
                                hasDamage: hasDamage,
                                onRetake: {
                                    viewModel.showingCameraForZone = zone
                                },
                                onFlagDamage: {
                                    viewModel.showingDamageSheetForZone = zone
                                }
                            )
                            .padding(.horizontal)
                            .accessibilityLabel("\(zone.title), \(photo != nil ? "captured" : "not yet captured")")
                        }
                    }

                    // Bottom Action Bar
                    VStack(spacing: 8) {
                        Button(action: {
                            Task {
                                await viewModel.certifyCurrentPhase()
                            }
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save & Finish \(viewModel.selectedPhase == .pickup ? "Pick-up" : "Return") Record")
                            }
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(emerald)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .padding(.horizontal)

                        Text("You can save at any time with as few or as many photos as you want.")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)

                        if viewModel.rental.hasPickupCompleted && viewModel.rental.hasDropoffCompleted {
                            Button(action: { viewModel.showingDisputeDossier = true }) {
                                HStack {
                                    Image(systemName: "doc.text.fill")
                                    Text("View Inspection Report (PDF)")
                                }
                                .font(.headline.bold())
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(Color.white)
                                .foregroundColor(emerald)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(emerald, lineWidth: 1.5)
                                )
                                .cornerRadius(14)
                            }
                            .padding(.horizontal)
                            .padding(.top, 4)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding(.vertical)
            }
            .navigationTitle("Vehicle Inspection")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
            #if canImport(UIKit)
            .sheet(item: $viewModel.showingCameraForZone) { zone in
                SingleZoneCameraModal(
                    rental: viewModel.rental,
                    phase: viewModel.selectedPhase,
                    zone: zone,
                    onPhotoSaved: { photo in
                        viewModel.savePhotoForZone(zone: zone, photo: photo)
                    }
                )
            }
            #endif
            .sheet(item: $viewModel.showingDamageSheetForZone) { zone in
                DamageAnnotationSheet(
                    zone: zone,
                    existingDamages: viewModel.currentInspection?.damagePoints.filter { $0.zoneId == zone } ?? [],
                    onSave: { newDamages in
                        viewModel.updateDamagesForZone(zone: zone, damages: newDamages)
                    }
                )
            }
            .sheet(isPresented: $viewModel.showingDashboardCapture) {
                DashboardCaptureView(
                    initialOdometer: viewModel.currentInspection?.odometerReading ?? "",
                    initialUnit: viewModel.currentInspection?.odometerUnit ?? "mi",
                    initialFuel: viewModel.currentInspection?.fuelLevel ?? .full,
                    onSave: { odo, unit, fuel, photo in
                        viewModel.saveDashboard(odo: odo, unit: unit, fuel: fuel, photo: photo)
                    }
                )
            }
            #if canImport(UIKit)
            .sheet(isPresented: $viewModel.showingDisputeDossier) {
                DisputeDossierView(rental: viewModel.rental)
            }
            #endif
        }
    }
}
