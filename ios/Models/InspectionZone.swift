//
//  InspectionZone.swift
//  Walkaround
//
//  Standardized vehicle inspection zones with guided camera positions,
//  ghost overlay templates, and inspection best-practice tips.
//

import Foundation
import SwiftUI

public enum VehicleZoneId: String, Codable, CaseIterable, Identifiable {
    case frontBumper = "front_bumper"
    case hoodWindshield = "hood_windshield"
    case frontLeftWheel = "front_left_wheel"
    case driverSide = "driver_side"
    case rearLeftWheel = "rear_left_wheel"
    case rearBumperTrunk = "rear_bumper_trunk"
    case rearRightWheel = "rear_right_wheel"
    case passengerSide = "passenger_side"
    case frontRightWheel = "front_right_wheel"
    case roof = "roof"
    case dashboardOdometer = "dashboard_odometer"
    case interiorCabin = "interior_cabin"

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .frontBumper: return "Front Bumper & Grille"
        case .hoodWindshield: return "Hood & Windshield"
        case .frontLeftWheel: return "Front Left Wheel & Fender"
        case .driverSide: return "Driver Doors & Mirrors"
        case .rearLeftWheel: return "Rear Left Wheel & Quarter"
        case .rearBumperTrunk: return "Rear Bumper & Trunk"
        case .rearRightWheel: return "Rear Right Wheel & Quarter"
        case .passengerSide: return "Passenger Doors & Mirrors"
        case .frontRightWheel: return "Front Right Wheel & Fender"
        case .roof: return "Roof & Sunroof"
        case .dashboardOdometer: return "Dashboard (Odometer & Fuel)"
        case .interiorCabin: return "Interior Seats & Consoles"
        }
    }

    public var shortTitle: String {
        switch self {
        case .frontBumper: return "Front Bumper"
        case .hoodWindshield: return "Windshield"
        case .frontLeftWheel: return "Front-L Wheel"
        case .driverSide: return "Driver Side"
        case .rearLeftWheel: return "Rear-L Wheel"
        case .rearBumperTrunk: return "Rear Bumper"
        case .rearRightWheel: return "Rear-R Wheel"
        case .passengerSide: return "Passenger Side"
        case .frontRightWheel: return "Front-R Wheel"
        case .roof: return "Roof"
        case .dashboardOdometer: return "Odometer/Fuel"
        case .interiorCabin: return "Interior"
        }
    }

    public var iconName: String {
        switch self {
        case .frontBumper: return "car.front.waves.up"
        case .hoodWindshield: return "sun.horizon"
        case .frontLeftWheel, .rearLeftWheel, .rearRightWheel, .frontRightWheel: return "circle.circle"
        case .driverSide, .passengerSide: return "car.side"
        case .rearBumperTrunk: return "car.rear"
        case .roof: return "arrow.up.and.down.and.sparkles"
        case .dashboardOdometer: return "gauge.with.needle"
        case .interiorCabin: return "car.seat"
        }
    }

    public var instruction: String {
        switch self {
        case .frontBumper:
            return "Stand 6 feet back facing front. Check for low curb scrapes, license plate mount cracks, and fog light chips."
        case .hoodWindshield:
            return "Look closely across the windshield for tiny rock chips, bullseye cracks, and hood stone dings."
        case .frontLeftWheel:
            return "Capture wheel rim edges for curb rash and check tire sidewalls for bubbles or scuffs."
        case .driverSide:
            return "Check door edges for parking lot dings, key scratches, and side mirror housing scrapes."
        case .rearLeftWheel:
            return "Inspect rear left rim and lower rocker panel."
        case .rearBumperTrunk:
            return "Check top of bumper where luggage is dragged out, parking sensor scrapes, and exhaust area."
        case .rearRightWheel:
            return "Check rear right rim and fuel door area."
        case .passengerSide:
            return "Check passenger doors, handles, and side mirror."
        case .frontRightWheel:
            return "Inspect front right rim (most commonly curbed wheel when parallel parking)."
        case .roof:
            return "Step back or hold phone high. Check for roof rack scratches or hail dents."
        case .dashboardOdometer:
            return "Take a clear, glare-free photo of ignition ON showing exact odometer mileage and fuel gauge level."
        case .interiorCabin:
            return "Capture seats, steering wheel, cup holders, and floor mats for pre-existing stains, burns, or tears."
        }
    }

    public var isRequiredForBasicPass: Bool {
        switch self {
        case .frontBumper, .driverSide, .rearBumperTrunk, .passengerSide, .dashboardOdometer:
            return true
        default:
            return false
        }
    }

    public var wireframeType: WireframeType {
        switch self {
        case .frontBumper: return .frontCar
        case .hoodWindshield: return .hood
        case .driverSide: return .driverSide
        case .passengerSide: return .passengerSide
        case .rearBumperTrunk: return .rearCar
        case .frontLeftWheel, .frontRightWheel, .rearLeftWheel, .rearRightWheel: return .wheel
        case .roof: return .roof
        case .dashboardOdometer: return .dashboard
        case .interiorCabin: return .interior
        }
    }

    public static var quickAuditZones: [VehicleZoneId] {
        [.frontBumper, .driverSide, .rearBumperTrunk, .passengerSide, .dashboardOdometer]
    }

    public static var fullAuditZones: [VehicleZoneId] {
        allCases
    }
}

public enum InspectionMode: String, Codable, CaseIterable, Identifiable {
    case quick60Sec = "Quick 60-Sec (5 Key Shots)"
    case full360 = "Full 360° Protection (12 Zones)"

    public var id: String { rawValue }

    public var zones: [VehicleZoneId] {
        switch self {
        case .quick60Sec: return VehicleZoneId.quickAuditZones
        case .full360: return VehicleZoneId.fullAuditZones
        }
    }
}

public enum WireframeType: String, Codable {
    case frontCar
    case rearCar
    case driverSide
    case passengerSide
    case wheel
    case hood
    case roof
    case dashboard
    case interior
}

