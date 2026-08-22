//
//  DamageAnnotationSheet.swift
//  Walkaround
//
//  Modal to flag, classify, and annotate pre-existing scratches, dents, and chips.
//

import SwiftUI

public struct DamageAnnotationSheet: View {
    @Environment(\.dismiss) private var dismiss

    public let zone: VehicleZoneId
    @State private var damages: [DamagePoint]

    @State private var selectedType: DamageType = .scratch
    @State private var selectedSeverity: DamageSeverity = .minor
    @State private var notes: String = ""
    @State private var showingAddForm = false

    public let onSave: ([DamagePoint]) -> Void

    public init(
        zone: VehicleZoneId,
        existingDamages: [DamagePoint],
        onSave: @escaping ([DamagePoint]) -> Void
    ) {
        self.zone = zone
        _damages = State(initialValue: existingDamages)
        self.onSave = onSave
    }

    public var body: some View {
        NavigationStack {
            List {
                // Section 1: Header
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(zone.title)
                            .font(.headline.bold())
                        Text("Flag any pre-existing blemishes, scratches, or dents found in this area.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }

                // Section 2: Flagged Damages List
                Section(header: Text("Documented Flaws (\(damages.count))")) {
                    if damages.isEmpty {
                        Text("No damage flagged for this zone.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(damages) { dmg in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Image(systemName: dmg.type.icon)
                                        .foregroundColor(Color(hex: dmg.severity.badgeColorHex))
                                    Text(dmg.type.title)
                                        .font(.subheadline.bold())
                                    Spacer()
                                    StatusPill(
                                        dmg.severity.rawValue.capitalized,
                                        color: Color(hex: dmg.severity.badgeColorHex)
                                    )
                                }

                                if !dmg.notes.isEmpty {
                                    Text(dmg.notes)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .onDelete { indices in
                            damages.remove(atOffsets: indices)
                        }
                    }
                }

                // Section 3: Add New Damage Form
                Section(header: Text("Add New Damage Point")) {
                    Picker("Damage Type", selection: $selectedType) {
                        ForEach(DamageType.allCases) { type in
                            Label(type.title, systemImage: type.icon).tag(type)
                        }
                    }

                    Picker("Severity", selection: $selectedSeverity) {
                        ForEach(DamageSeverity.allCases) { sev in
                            Text(sev.title).tag(sev)
                        }
                    }

                    TextField("Specific Location Notes (e.g. 2 inch scratch near lower edge)", text: $notes)

                    Button(action: addDamagePoint) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("Add Damage Tag to \(zone.shortTitle)")
                        }
                        .font(.subheadline.bold())
                    }
                }
            }
            .navigationTitle("Damage Markup")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save All") {
                        onSave(damages)
                        dismiss()
                    }
                }
            }
        }
    }

    private func addDamagePoint() {
        let newPoint = DamagePoint(
            zoneId: zone,
            type: selectedType,
            severity: selectedSeverity,
            notes: notes
        )
        damages.append(newPoint)
        notes = ""
    }
}
