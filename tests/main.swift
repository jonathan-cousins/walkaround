//
//  main.swift
//  Walkaround
//
//  Automated test runner testing models, letter templates, persistence, and audit modes.
//

import Foundation
import WalkaroundCore

func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String = "", file: String = #file, line: Int = #line) {
    if actual != expected {
        print("❌ Assertion Failed at \(file):\(line) — Expected \(expected), got \(actual). \(message)")
        exit(1)
    }
}

func assertTrue(_ condition: Bool, _ message: String = "", file: String = #file, line: Int = #line) {
    if !condition {
        print("❌ Assertion Failed at \(file):\(line) — Condition was false. \(message)")
        exit(1)
    }
}

print("🧪 Starting Walkaround Test Suite...")

// 1. Test Zones & Requirements
print("  • Running testZoneCountAndRequirements()...")
let allZones = VehicleZoneId.allCases
assertEqual(allZones.count, 12, "Should have 12 standardized vehicle inspection zones")
let requiredZones = allZones.filter { $0.isRequiredForBasicPass }
assertTrue(requiredZones.count >= 4, "Should have critical required zones")

// 2. Test Sample Rental Data Integrity
print("  • Running testSampleRentalIntegrity()...")
let sample = Rental.sampleRental
assertEqual(sample.make, "Ford")
assertEqual(sample.model, "Mustang GT")
assertEqual(sample.agency, .hertz)
assertTrue(sample.hasPickupCompleted)
assertTrue(sample.hasDropoffCompleted)
assertEqual(sample.totalPickupDamagesCount, 2)

// 3. Test Dispute Letter Generation
print("  • Running testDisputeLetterGeneration()...")
let letter = DisputeLetterTemplate.generateLetter(
    rental: sample,
    recipient: .rentalAgency,
    renterName: "Jane Smith",
    claimNumber: "CLM-99214",
    disputedDescription: "rear bumper scrape"
)
assertTrue(letter.contains("Hertz - Damage Recovery Unit"))
assertTrue(letter.contains("CLM-99214"))
assertTrue(letter.contains("Jane Smith"))
assertTrue(letter.contains("8TRP492"))
assertTrue(letter.contains("Walkaround"))

// 4. Test Inspection Modes (Quick 60s vs Full 360)
print("  • Running testInspectionModes()...")
let quickZones = VehicleZoneId.quickAuditZones
assertEqual(quickZones.count, 5, "Quick audit should contain exactly 5 critical shots")
assertTrue(quickZones.contains(.frontBumper))
assertTrue(quickZones.contains(.dashboardOdometer))

let fullZones = VehicleZoneId.fullAuditZones
assertEqual(fullZones.count, 12, "Full audit should contain all 12 zones")

// 5. Test Vehicle Title Fallback
print("  • Running testRentalVehicleTitleFallback()...")
let empty = Rental()
assertEqual(empty.vehicleTitle, "Rental Vehicle")
let partial = Rental(make: "Tesla", model: "", year: "2024")
assertEqual(partial.vehicleTitle, "2024 Tesla")

// 6. Test Inspection Completion Percentage
print("  • Running testInspectionCompletionPercentage()...")
var inspection = Inspection(phase: .pickup)
assertEqual(inspection.completionPercentage, 0.0)
let photo = PhotoEvidence(zoneId: .frontBumper, filename: "test.jpg")
inspection.setPhoto(photo, for: .frontBumper)
assertTrue(inspection.completionPercentage > 0.0)
assertEqual(inspection.completedZoneCount, 1)

// 7. Test Damage Point Defaults
print("  • Running testDamagePointDefaults()...")
let dmg = DamagePoint(zoneId: .frontBumper)
assertEqual(dmg.type, .scratch)
assertEqual(dmg.severity, .minor)
assertEqual(dmg.relativeX, 0.5)
assertEqual(dmg.relativeY, 0.5)

// 8. Test All Dispute Letter Recipients
print("  • Running testAllDisputeLetterRecipients()...")
for recipient in DisputeRecipientType.allCases {
    let letContent = DisputeLetterTemplate.generateLetter(
        rental: sample,
        recipient: recipient,
        renterName: "Test Renter"
    )
    assertTrue(!letContent.isEmpty)
    assertTrue(letContent.contains("Test Renter"))
}

// 9. Test Rental Model JSON Serialization
print("  • Running testRentalModelJSONSerialization()...")
do {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    let data = try encoder.encode(sample)

    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let decoded = try decoder.decode(Rental.self, from: data)

    assertEqual(decoded.id, sample.id)
    assertEqual(decoded.make, sample.make)
    assertEqual(decoded.model, sample.model)
    assertEqual(decoded.agency, sample.agency)
    assertEqual(decoded.pickupInspection?.damagePoints.count, 2)
} catch {
    print("❌ JSON serialization failed: \(error)")
    exit(1)
}

print("\n🎉 ALL 9/9 WALKAROUND UNIT TESTS PASSED SUCCESSFULLY!\n")
