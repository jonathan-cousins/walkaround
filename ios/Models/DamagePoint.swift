//
//  DamagePoint.swift
//  Walkaround
//
//  Specific damage markup and severity classification.
//

import Foundation
import SwiftUI

public enum DamageType: String, Codable, CaseIterable, Identifiable {
    case scratch = "scratch"
    case dent = "dent"
    case paintChip = "paint_chip"
    case curbRash = "curb_rash"
    case windshieldChip = "windshield_chip"
    case scuff = "scuff"
    case crack = "crack"
    case interiorStainTear = "interior_stain_tear"
    case other = "other"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .scratch: return "Scratch / Scrape"
        case .dent: return "Dent / Ding"
        case .paintChip: return "Paint Chip / Peeling"
        case .curbRash: return "Rim Curb Rash"
        case .windshieldChip: return "Glass Chip / Crack"
        case .scuff: return "Surface Scuff"
        case .crack: return "Bumper / Plastic Crack"
        case .interiorStainTear: return "Stain / Burn / Tear"
        case .other: return "Other Pre-existing Damage"
        }
    }

    public var icon: String {
        switch self {
        case .scratch: return "scribble"
        case .dent: return "circle.dotted"
        case .paintChip: return "drop.fill"
        case .curbRash: return "circle.slash"
        case .windshieldChip: return "sparkle"
        case .scuff: return "hand.draw"
        case .crack: return "bolt.horizontal"
        case .interiorStainTear: return "bandage"
        case .other: return "exclamationmark.triangle"
        }
    }
}

public enum DamageSeverity: String, Codable, CaseIterable, Identifiable {
    case minor = "minor"
    case moderate = "moderate"
    case severe = "severe"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .minor: return "Minor (Surface Level < 1 in)"
        case .moderate: return "Moderate (Visible > 1 in / Deep)"
        case .severe: return "Severe (Structural / Cracked / Creased)"
        }
    }

    public var badgeColorHex: String {
        switch self {
        case .minor: return "#EAB308" // yellow
        case .moderate: return "#F97316" // orange
        case .severe: return "#EF4444" // red
        }
    }
}

public struct DamagePoint: Codable, Identifiable, Hashable {
    public var id: UUID
    public var zoneId: VehicleZoneId
    public var type: DamageType
    public var severity: DamageSeverity
    public var notes: String
    public var relativeX: Double // Normalized 0.0 - 1.0 on photo
    public var relativeY: Double // Normalized 0.0 - 1.0 on photo
    public var timestamp: Date

    public init(
        id: UUID = UUID(),
        zoneId: VehicleZoneId = .frontBumper,
        type: DamageType = .scratch,
        severity: DamageSeverity = .minor,
        notes: String = "",
        relativeX: Double = 0.5,
        relativeY: Double = 0.5,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.zoneId = zoneId
        self.type = type
        self.severity = severity
        self.notes = notes
        self.relativeX = relativeX
        self.relativeY = relativeY
        self.timestamp = timestamp
    }
}
