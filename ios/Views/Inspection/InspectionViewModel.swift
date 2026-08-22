//
//  InspectionViewModel.swift
//  Walkaround
//
//  ViewModel managing inspection hub state, zone updates, damage tagging, and persistence.
//

import SwiftUI
import Observation

@MainActor
@Observable
public class InspectionViewModel {
    public var rental: Rental
    public var selectedPhase: InspectionPhase
    public var showingCameraForZone: VehicleZoneId?
    public var showingDamageSheetForZone: VehicleZoneId?
    public var showingDashboardCapture = false
    public var showingDisputeDossier = false

    public var currentInspection: Inspection? {
        selectedPhase == .pickup ? rental.pickupInspection : rental.dropoffInspection
    }

    public init(rental: Rental) {
        self.rental = rental
        self.selectedPhase = (rental.hasPickupCompleted && !rental.hasDropoffCompleted) ? .dropoff : .pickup
    }

    public func savePhotoForZone(zone: VehicleZoneId, photo: PhotoEvidence) {
        if selectedPhase == .pickup {
            if rental.pickupInspection == nil {
                rental.pickupInspection = Inspection(phase: .pickup)
            }
            rental.pickupInspection?.setPhoto(photo, for: zone)
        } else {
            if rental.dropoffInspection == nil {
                rental.dropoffInspection = Inspection(phase: .dropoff)
            }
            rental.dropoffInspection?.setPhoto(photo, for: zone)
        }
        rental.updatedAt = Date()
        RentalStorageService.shared.updateRental(rental)
    }

    public func updateDamagesForZone(zone: VehicleZoneId, damages: [DamagePoint]) {
        if selectedPhase == .pickup {
            if rental.pickupInspection == nil {
                rental.pickupInspection = Inspection(phase: .pickup)
            }
            rental.pickupInspection?.damagePoints.removeAll(where: { $0.zoneId == zone })
            rental.pickupInspection?.damagePoints.append(contentsOf: damages)
        } else {
            if rental.dropoffInspection == nil {
                rental.dropoffInspection = Inspection(phase: .dropoff)
            }
            rental.dropoffInspection?.damagePoints.removeAll(where: { $0.zoneId == zone })
            rental.dropoffInspection?.damagePoints.append(contentsOf: damages)
        }
        rental.updatedAt = Date()
        RentalStorageService.shared.updateRental(rental)
    }

    public func saveDashboard(odo: String, unit: String, fuel: FuelLevel, photo: PhotoEvidence?) {
        if selectedPhase == .pickup {
            if rental.pickupInspection == nil {
                rental.pickupInspection = Inspection(phase: .pickup)
            }
            rental.pickupInspection?.odometerReading = odo
            rental.pickupInspection?.odometerUnit = unit
            rental.pickupInspection?.fuelLevel = fuel
            if let p = photo { rental.pickupInspection?.setPhoto(p, for: .dashboardOdometer) }
        } else {
            if rental.dropoffInspection == nil {
                rental.dropoffInspection = Inspection(phase: .dropoff)
            }
            rental.dropoffInspection?.odometerReading = odo
            rental.dropoffInspection?.odometerUnit = unit
            rental.dropoffInspection?.fuelLevel = fuel
            if let p = photo { rental.dropoffInspection?.setPhoto(p, for: .dashboardOdometer) }
        }
        rental.updatedAt = Date()
        RentalStorageService.shared.updateRental(rental)
    }

    public func certifyCurrentPhase() async {
        let loc = await LocationService.shared.captureSnapshot()
        if selectedPhase == .pickup {
            if rental.pickupInspection == nil {
                rental.pickupInspection = Inspection(phase: .pickup)
            }
            rental.pickupInspection?.completedAt = Date()
            rental.pickupInspection?.location = loc
            rental.pickupInspection?.isCompleted = true
            rental.status = .active
        } else {
            if rental.dropoffInspection == nil {
                rental.dropoffInspection = Inspection(phase: .dropoff)
            }
            rental.dropoffInspection?.completedAt = Date()
            rental.dropoffInspection?.location = loc
            rental.dropoffInspection?.isCompleted = true
            rental.status = .returned
        }
        rental.updatedAt = Date()
        RentalStorageService.shared.updateRental(rental)
    }
}
