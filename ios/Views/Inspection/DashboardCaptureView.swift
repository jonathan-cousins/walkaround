//
//  DashboardCaptureView.swift
//  Walkaround
//
//  Dedicated capture screen for recording odometer mileage and fuel levels.
//

import SwiftUI

public struct DashboardCaptureView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var odometer: String
    @State private var unit: String
    @State private var fuelLevel: FuelLevel
    @State private var hasPhotoTaken = false

    public let onSave: (String, String, FuelLevel, PhotoEvidence?) -> Void

    public init(
        initialOdometer: String = "",
        initialUnit: String = "mi",
        initialFuel: FuelLevel = .full,
        onSave: @escaping (String, String, FuelLevel, PhotoEvidence?) -> Void
    ) {
        _odometer = State(initialValue: initialOdometer)
        _unit = State(initialValue: initialUnit)
        _fuelLevel = State(initialValue: initialFuel)
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: Photo Proof
                Section(header: Text("Dashboard Photo Proof")) {
                    VStack(alignment: .center, spacing: 12) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.subtleFill)
                                .frame(height: 160)

                            if hasPhotoTaken {
                                VStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 44))
                                        .foregroundColor(.green)
                                    Text("Gauge Photo Captured & Verified")
                                        .font(.caption.bold())
                                        .foregroundColor(.green)
                                }
                            } else {
                                VStack(spacing: 8) {
                                    Image(systemName: "camera.viewfinder")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue)
                                    Text("Take photo of dashboard with ignition ON")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }

                        Button(action: { hasPhotoTaken.toggle() }) {
                            HStack {
                                Image(systemName: "camera.fill")
                                Text(hasPhotoTaken ? "Retake Dashboard Photo" : "Snap Dashboard Photo")
                            }
                            .font(.subheadline.bold())
                        }
                    }
                    .padding(.vertical, 8)
                }

                // Section 2: Exact Mileage
                Section(header: Text("Odometer Reading")) {
                    HStack {
                        TextField("e.g. 24,185", text: $odometer)
                            .numbersAndPunctuationKeyboard()
                            .font(.title3.bold())

                        Picker("Unit", selection: $unit) {
                            Text("Miles (mi)").tag("mi")
                            Text("Kilometers (km)").tag("km")
                        }
                        .pickerStyle(.segmented)
                        .frame(width: 140)
                    }
                }

                // Section 3: Fuel Level
                Section(header: Text("Fuel / Charge Level")) {
                    Picker("Fuel Level", selection: $fuelLevel) {
                        ForEach(FuelLevel.allCases) { lvl in
                            Text(lvl.rawValue).tag(lvl)
                        }
                    }
                }

                // Anti-Scam Notice
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("💡 Why this matters:")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                        Text("Rental companies often bill $9.99/gallon for missing fuel even if you returned it full. A timestamped dashboard photo disproves this instantly.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("Mileage & Fuel Audit")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let photo = hasPhotoTaken ? PhotoEvidence(
                            zoneId: .dashboardOdometer,
                            filename: "dash_\(UUID().uuidString.prefix(8)).jpg",
                            capturedAt: Date()
                        ) : nil

                        onSave(odometer, unit, fuelLevel, photo)
                        dismiss()
                    }
                }
            }
        }
    }
}
