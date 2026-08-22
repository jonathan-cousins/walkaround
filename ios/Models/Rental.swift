//
//  Rental.swift
//  Walkaround
//
//  Main Rental Trip Model tracking vehicle details, agency info,
//  pickup inspection, dropoff inspection, and dispute status.
//

import Foundation
import SwiftUI

public enum RentalAgency: String, Codable, CaseIterable, Identifiable {
    case hertz = "Hertz"
    case enterprise = "Enterprise"
    case avis = "Avis"
    case budget = "Budget"
    case sixt = "Sixt"
    case turo = "Turo"
    case national = "National"
    case alamo = "Alamo"
    case europcar = "Europcar"
    case dollar = "Dollar"
    case thrifty = "Thrifty"
    case uhaul = "U-Haul / Moving Truck"
    case getaround = "Getaround"
    case zipcar = "Zipcar"
    case other = "Other Agency"

    public var id: String { rawValue }

    public var brandColorHex: String {
        switch self {
        case .hertz: return "#F59E0B" // Hertz Yellow
        case .enterprise: return "#10B981" // Enterprise Green
        case .avis, .budget: return "#EF4444" // Avis Red
        case .sixt: return "#F97316" // Sixt Orange
        case .turo: return "#8B5CF6" // Turo Purple
        case .national: return "#059669"
        case .alamo: return "#3B82F6"
        case .europcar: return "#84CC16"
        case .dollar, .thrifty: return "#0284C7"
        case .uhaul: return "#EA580C"
        case .getaround, .zipcar: return "#06B6D4"
        case .other: return "#64748B"
        }
    }
}

public enum RentalStatus: String, Codable, CaseIterable {
    case active = "Active (Pick-up Done)"
    case pendingPickup = "Pending Pick-up"
    case returned = "Returned / Completed"
    case disputeActive = "Dispute in Progress"
    case resolved = "Resolved (No Charge)"

    public var badgeColor: Color {
        switch self {
        case .active: return .blue
        case .pendingPickup: return .orange
        case .returned: return .green
        case .disputeActive: return .red
        case .resolved: return .purple
        }
    }
}

public struct Rental: Codable, Identifiable, Hashable {
    public var id: UUID
    public var make: String
    public var model: String
    public var year: String
    public var color: String
    public var licensePlate: String
    public var stateOrCountry: String
    public var vin: String
    public var agency: RentalAgency
    public var agreementNumber: String
    public var createdAt: Date
    public var updatedAt: Date

    public var pickupInspection: Inspection?
    public var dropoffInspection: Inspection?

    public var status: RentalStatus
    public var disputeSummary: String?
    public var isArchived: Bool

    public init(
        id: UUID = UUID(),
        make: String = "",
        model: String = "",
        year: String = "",
        color: String = "",
        licensePlate: String = "",
        stateOrCountry: String = "",
        vin: String = "",
        agency: RentalAgency = .enterprise,
        agreementNumber: String = "",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        pickupInspection: Inspection? = nil,
        dropoffInspection: Inspection? = nil,
        status: RentalStatus = .pendingPickup,
        disputeSummary: String? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.make = make
        self.model = model
        self.year = year
        self.color = color
        self.licensePlate = licensePlate
        self.stateOrCountry = stateOrCountry
        self.vin = vin
        self.agency = agency
        self.agreementNumber = agreementNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.pickupInspection = pickupInspection
        self.dropoffInspection = dropoffInspection
        self.status = status
        self.disputeSummary = disputeSummary
        self.isArchived = isArchived
    }

    public var vehicleTitle: String {
        let name = [year, make, model].filter { !$0.isEmpty }.joined(separator: " ")
        return name.isEmpty ? "Rental Vehicle" : name
    }

    public var subtitle: String {
        var parts: [String] = [agency.rawValue]
        if !licensePlate.isEmpty {
            parts.append(licensePlate)
        }
        return parts.joined(separator: " • ")
    }

    public var hasPickupCompleted: Bool {
        pickupInspection?.isCompleted == true
    }

    public var hasDropoffCompleted: Bool {
        dropoffInspection?.isCompleted == true
    }

    public var totalPickupDamagesCount: Int {
        pickupInspection?.damagePoints.count ?? 0
    }

    public var totalDropoffDamagesCount: Int {
        dropoffInspection?.damagePoints.count ?? 0
    }

    public static var sampleRental: Rental {
        let pickup = Inspection(
            phase: .pickup,
            completedAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()),
            location: LocationSnapshot(
                latitude: 33.9416,
                longitude: -118.4085,
                placeName: "LAX Terminal 1 - Hertz Lot",
                formattedAddress: "1 World Way, Los Angeles, CA 90045"
            ),
            odometerReading: "18,452",
            odometerUnit: "mi",
            fuelLevel: .full,
            damagePoints: [
                DamagePoint(
                    zoneId: .rearBumperTrunk,
                    type: .scratch,
                    severity: .moderate,
                    notes: "3-inch vertical scratch on lower black trim near left reverse sensor",
                    relativeX: 0.65,
                    relativeY: 0.72
                ),
                DamagePoint(
                    zoneId: .frontRightWheel,
                    type: .curbRash,
                    severity: .minor,
                    notes: "Existing 1-inch curb scuff on outer aluminum bead",
                    relativeX: 0.45,
                    relativeY: 0.55
                )
            ],
            isCompleted: true
        )

        let dropoff = Inspection(
            phase: .dropoff,
            completedAt: Date(),
            location: LocationSnapshot(
                latitude: 33.9416,
                longitude: -118.4085,
                placeName: "LAX Rental Return Zone B",
                formattedAddress: "1 World Way, Los Angeles, CA 90045"
            ),
            odometerReading: "18,740",
            odometerUnit: "mi",
            fuelLevel: .full,
            isCompleted: true
        )

        return Rental(
            make: "Ford",
            model: "Mustang GT",
            year: "2024",
            color: "Shadow Black",
            licensePlate: "8TRP492",
            stateOrCountry: "CA",
            vin: "1FA6P8CF9R5102983",
            agency: .hertz,
            agreementNumber: "H89204128",
            createdAt: Calendar.current.date(byAdding: .day, value: -3, to: Date()) ?? Date(),
            updatedAt: Date(),
            pickupInspection: pickup,
            dropoffInspection: dropoff,
            status: .returned
        )
    }
}
