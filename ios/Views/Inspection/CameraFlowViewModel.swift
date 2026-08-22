//
//  CameraFlowViewModel.swift
//  Walkaround
//
//  ViewModel managing the guided camera flow, photo capture, watermarking,
//  disk storage, and safe inspection finalization.
//

#if canImport(UIKit)
import UIKit
import SwiftUI
import Observation

@MainActor
@Observable
public class CameraFlowViewModel {
    public var rental: Rental
    public let phase: InspectionPhase
    public var inspectionMode: InspectionMode = .quick60Sec
    public var currentZoneIndex: Int = 0
    public var capturedPhotos: [VehicleZoneId: UIImage] = [:]
    public var flashEnabled: Bool = false
    public var isCapturing: Bool = false
    public var showingFinishConfirmation: Bool = false

    public var activeZones: [VehicleZoneId] {
        inspectionMode.zones
    }

    public var currentZone: VehicleZoneId {
        guard currentZoneIndex < activeZones.count else {
            return activeZones.first ?? .frontBumper
        }
        return activeZones[currentZoneIndex]
    }

    public init(rental: Rental, phase: InspectionPhase, initialMode: InspectionMode = .quick60Sec) {
        self.rental = rental
        self.phase = phase
        self.inspectionMode = initialMode
    }

    public func switchMode() {
        let newMode: InspectionMode = (inspectionMode == .quick60Sec) ? .full360 : .quick60Sec
        inspectionMode = newMode
        // Preserve position within new range rather than resetting to 0 (UX Fix #3)
        if currentZoneIndex >= activeZones.count {
            currentZoneIndex = max(0, activeZones.count - 1)
        }
    }

    public func handleCapturedPhoto(_ rawImage: UIImage) {
        capturedPhotos[currentZone] = rawImage
        isCapturing = true

        let currentZone = self.currentZone
        let phase = self.phase
        let rentalId = self.rental.id
        let vehicleTitle = self.rental.vehicleTitle
        let licensePlate = self.rental.licensePlate
        let agencyName = self.rental.agency.rawValue

        // Perform watermarking, hashing, and disk writing asynchronously off the main thread
        Task.detached(priority: .userInitiated) {
            let loc = await LocationService.shared.captureSnapshot()
            let meta = WatermarkMetadata(
                phase: phase,
                timestamp: Date(),
                location: loc,
                vehicleSummary: vehicleTitle,
                licensePlate: licensePlate,
                zoneTitle: currentZone.title,
                agencyName: agencyName
            )

            let stamped = WatermarkService.shared.stampImage(image: rawImage, metadata: meta)
            let filename = "photo_\(rentalId.uuidString)_\(phase.rawValue)_\(currentZone.rawValue).jpg"

            // 1. Save watermarked photo to local app storage
            if let finalImage = stamped?.stampedImage {
                _ = ImageStorageService.shared.saveImage(finalImage, filename: filename)
                
                // 2. Redundant backup to Camera Roll if authorized
                _ = await PhotoBackupService.shared.saveToCameraRoll(image: finalImage, metadata: meta)
            }

            let evidence = PhotoEvidence(
                zoneId: currentZone,
                filename: filename,
                capturedAt: Date(),
                location: meta.location,
                hasDamage: false,
                hashSHA256: stamped?.sha256
            )

            await MainActor.run {
                if phase == .pickup {
                    if self.rental.pickupInspection == nil {
                        self.rental.pickupInspection = Inspection(phase: .pickup)
                    }
                    self.rental.pickupInspection?.setPhoto(evidence, for: currentZone)
                } else {
                    if self.rental.dropoffInspection == nil {
                        self.rental.dropoffInspection = Inspection(phase: .dropoff)
                    }
                    self.rental.dropoffInspection?.setPhoto(evidence, for: currentZone)
                }
                self.rental.updatedAt = Date()
                RentalStorageService.shared.updateRental(self.rental)

                self.isCapturing = false
                self.advanceStep()
            }
        }
    }

    public func advanceStep() {
        if currentZoneIndex < activeZones.count - 1 {
            currentZoneIndex += 1
        } else {
            // Confirm before completing inspection (UX Fix #1 & Fix #7)
            showingFinishConfirmation = true
        }
    }

    public func previousStep() {
        if currentZoneIndex > 0 {
            currentZoneIndex -= 1
        }
    }

    public func finalizeInspection() {
        if phase == .pickup {
            if rental.pickupInspection == nil {
                rental.pickupInspection = Inspection(phase: .pickup)
            }
            rental.pickupInspection?.isCompleted = true
            rental.pickupInspection?.completedAt = Date()
            rental.status = .active
        } else {
            if rental.dropoffInspection == nil {
                rental.dropoffInspection = Inspection(phase: .dropoff)
            }
            rental.dropoffInspection?.isCompleted = true
            rental.dropoffInspection?.completedAt = Date()
            rental.status = .returned
        }
        rental.updatedAt = Date()
        RentalStorageService.shared.updateRental(rental)
    }
}
#endif
