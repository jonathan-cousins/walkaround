//
//  NewRentalSheet.swift
//  Walkaround
//
//  Quick onboarding modal to record a new vehicle rental before starting inspection.
//

import SwiftUI

public struct NewRentalSheet: View {
    @Environment(\.dismiss) private var dismiss

    @State private var make: String = ""
    @State private var model: String = ""
    @State private var year: String = "2024"
    @State private var color: String = ""
    @State private var licensePlate: String = ""
    @State private var stateOrCountry: String = "CA"
    @State private var vin: String = ""
    @State private var agency: RentalAgency = .enterprise
    @State private var agreementNumber: String = ""

    public let onSave: (Rental) -> Void

    public init(onSave: @escaping (Rental) -> Void) {
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            Form {
                // Section 1: Rental Agency & Agreement
                Section(header: Text("Rental Agency")) {
                    Picker("Agency", selection: $agency) {
                        ForEach(RentalAgency.allCases) { ag in
                            HStack {
                                Circle()
                                    .fill(Color(hex: ag.brandColorHex))
                                    .frame(width: 8, height: 8)
                                Text(ag.rawValue)
                            }
                            .tag(ag)
                        }
                    }

                    TextField("Reservation / Agreement # (Optional)", text: $agreementNumber)
                        .autocorrectionDisabled()
                }

                // Section 2: Vehicle Details
                Section(header: Text("Vehicle Information")) {
                    HStack {
                        TextField("Make (e.g. Ford, Toyota)", text: $make)
                        Divider()
                        TextField("Model (e.g. Mustang, RAV4)", text: $model)
                    }

                    HStack {
                        TextField("Year", text: $year)
                            .numericKeyboard()
                        Divider()
                        TextField("Color (e.g. Silver, Black)", text: $color)
                    }
                }

                // Section 3: Identification
                Section(header: Text("License Plate & State")) {
                    HStack {
                        TextField("License Plate / Reg", text: $licensePlate)
                            .uppercaseAutocapitalization()
                            .autocorrectionDisabled()
                        Divider()
                        TextField("State / Country", text: $stateOrCountry)
                            .uppercaseAutocapitalization()
                            .frame(width: 80)
                    }

                    TextField("VIN (Optional)", text: $vin)
                        .uppercaseAutocapitalization()
                        .autocorrectionDisabled()
                }

                // Section 4: Quick Tips
                Section {
                    VStack(alignment: .leading, spacing: 6) {
                        Label("Fast Pick-up Inspection Tips", systemImage: "lightbulb.fill")
                            .font(.caption.bold())
                            .foregroundColor(.orange)
                        Text("Once created, you will be guided through a 60-second 360° photo walkthrough. Do this BEFORE driving off the rental lot.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
            .navigationTitle("New Rental")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create & Start") {
                        let newRental = Rental(
                            make: make.isEmpty ? "Vehicle" : make,
                            model: model,
                            year: year,
                            color: color,
                            licensePlate: licensePlate.uppercased(),
                            stateOrCountry: stateOrCountry.uppercased(),
                            vin: vin.uppercased(),
                            agency: agency,
                            agreementNumber: agreementNumber,
                            status: .pendingPickup
                        )
                        onSave(newRental)
                        dismiss()
                    }
                }
            }
        }
    }
}
