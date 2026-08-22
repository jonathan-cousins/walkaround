//
//  Inspection.swift
//  Walkaround
//
//  Represents a single inspection session (Pickup or Dropoff) with GPS,
//  odometer, fuel level, and zone photo evidence.
//

import Foundation
import CoreLocation

public enum InspectionPhase: String, Codable, CaseIterable {
    case pickup = "pickup"
    case dropoff = "dropoff"

    public var title: String {
        switch self {
        case .pickup: return "Pick-up Inspection"
        case .dropoff: return "Return / Drop-off Inspection"
        }
    }

    public var stampPrefix: String {
        switch self {
        case .pickup: return "PICKUP VERIFICATION"
        case .dropoff: return "RETURN VERIFICATION"
        }
    }
}

public enum FuelLevel: String, Codable, CaseIterable, Identifiable {
    case full = "8/8 (Full)"
    case sevenEighths = "7/8"
    case threeQuarters = "6/8 (3/4)"
    case fiveEighths = "5/8"
    case half = "4/8 (1/2)"
    case threeEighths = "3/8"
    case oneQuarter = "2/8 (1/4)"
    case oneEighth = "1/8"
    case empty = "Empty (< 1/8)"
    case ev100 = "EV 100%"
    case ev80 = "EV 80%+"
    case ev50 = "EV ~50%"
    case ev20 = "EV Low (<20%)"

    public var id: String { rawValue }
}

public struct LocationSnapshot: Codable, Hashable {
    public var latitude: Double
    public var longitude: Double
    public var altitude: Double?
    public var placeName: String
    public var formattedAddress: String
    public var recordedAt: Date

    public init(
        latitude: Double = 0.0,
        longitude: Double = 0.0,
        altitude: Double? = nil,
        placeName: String = "Location Not Recorded",
        formattedAddress: String = "N/A",
        recordedAt: Date = Date()
    ) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
        self.placeName = placeName
        self.formattedAddress = formattedAddress
        self.recordedAt = recordedAt
    }
}

public struct PhotoEvidence: Codable, Identifiable, Hashable {
    public var id: UUID
    public var zoneId: VehicleZoneId
    public var filename: String // Relative filename in app documents sandbox
    public var capturedAt: Date
    public var location: LocationSnapshot?
    public var notes: String
    public var hasDamage: Bool
    public var hashSHA256: String? // Cryptographic verification hash

    public init(
        id: UUID = UUID(),
        zoneId: VehicleZoneId = .frontBumper,
        filename: String = "",
        capturedAt: Date = Date(),
        location: LocationSnapshot? = nil,
        notes: String = "",
        hasDamage: Bool = false,
        hashSHA256: String? = nil
    ) {
        self.id = id
        self.zoneId = zoneId
        self.filename = filename
        self.capturedAt = capturedAt
        self.location = location
        self.notes = notes
        self.hasDamage = hasDamage
        self.hashSHA256 = hashSHA256
    }
}

public struct Inspection: Codable, Identifiable, Hashable {
    public var id: UUID
    public var phase: InspectionPhase
    public var completedAt: Date?
    public var location: LocationSnapshot?
    public var odometerReading: String // e.g. "34,210"
    public var odometerUnit: String // "mi" or "km"
    public var fuelLevel: FuelLevel
    public var photos: [VehicleZoneId: PhotoEvidence]
    public var damagePoints: [DamagePoint]
    public var inspectorNotes: String
    public var isCompleted: Bool

    public init(
        id: UUID = UUID(),
        phase: InspectionPhase = .pickup,
        completedAt: Date? = nil,
        location: LocationSnapshot? = nil,
        odometerReading: String = "",
        odometerUnit: String = "mi",
        fuelLevel: FuelLevel = .full,
        photos: [VehicleZoneId: PhotoEvidence] = [:],
        damagePoints: [DamagePoint] = [],
        inspectorNotes: String = "",
        isCompleted: Bool = false
    ) {
        self.id = id
        self.phase = phase
        self.completedAt = completedAt
        self.location = location
        self.odometerReading = odometerReading
        self.odometerUnit = odometerUnit
        self.fuelLevel = fuelLevel
        self.photos = photos
        self.damagePoints = damagePoints
        self.inspectorNotes = inspectorNotes
        self.isCompleted = isCompleted
    }

    public func photo(for zone: VehicleZoneId) -> PhotoEvidence? {
        photos[zone]
    }

    public mutating func setPhoto(_ photo: PhotoEvidence, for zone: VehicleZoneId) {
        photos[zone] = photo
    }

    public var completedZoneCount: Int {
        photos.count
    }

    public var totalZoneCount: Int {
        VehicleZoneId.allCases.count
    }

    public var completionPercentage: Double {
        Double(completedZoneCount) / Double(totalZoneCount)
    }
}
