//
//  GuidedCameraView.swift
//  Walkaround
//
//  Guided step-by-step vehicle camera walkthrough with real AVCaptureSession preview,
//  ghost overlays, forensic metadata stamping, and camera roll auto-redundancy.
//

import SwiftUI
import CryptoKit

#if canImport(UIKit)
import AVFoundation
import UIKit

public struct GuidedCameraFlowView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var viewModel: CameraFlowViewModel
    @State private var cameraController: CameraCaptureViewController?

    public init(
        rental: Rental,
        phase: InspectionPhase,
        initialMode: InspectionMode = .quick60Sec
    ) {
        _viewModel = State(initialValue: CameraFlowViewModel(rental: rental, phase: phase, initialMode: initialMode))
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            // 1. Real Camera Viewfinder / Preview
            if let capturedImg = viewModel.capturedPhotos[viewModel.currentZone] {
                Image(uiImage: capturedImg)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
            } else {
                CameraPreviewView(
                    flashEnabled: viewModel.flashEnabled,
                    onPhotoCaptured: { image in
                        viewModel.handleCapturedPhoto(image)
                    },
                    captureController: $cameraController
                )
                .ignoresSafeArea()
            }

            // 2. Ghost Wireframe Overlay
            if viewModel.capturedPhotos[viewModel.currentZone] == nil {
                GhostOverlayView(type: viewModel.currentZone.wireframeType)
            }

            // 3. Top HUD: Phase Badge, Live GPS/Time, Mode Switcher
            VStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .accessibilityLabel("Close camera")

                    Spacer()

                    HUDTimestampBadge()

                    Spacer()

                    Button(action: { viewModel.flashEnabled.toggle() }) {
                        Image(systemName: viewModel.flashEnabled ? "bolt.fill" : "bolt.slash.fill")
                            .font(.title3)
                            .foregroundColor(viewModel.flashEnabled ? .yellow : .white.opacity(0.8))
                            .padding(8)
                            .background(Color.black.opacity(0.5))
                            .clipShape(Circle())
                    }
                    .accessibilityLabel(viewModel.flashEnabled ? "Disable flash" : "Enable flash")
                }
                .padding(.horizontal)
                .padding(.top, 8)

                // Step Progress Bar & Title + Mode Selector
                VStack(spacing: 6) {
                    HStack {
                        Text("\(viewModel.phase == .pickup ? "PICK-UP" : "RETURN") STEP \(viewModel.currentZoneIndex + 1) OF \(viewModel.activeZones.count)")
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(.yellow)
                        Spacer()
                        Text(viewModel.currentZone.shortTitle)
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }

                    ProgressView(value: Double(viewModel.currentZoneIndex + 1), total: Double(viewModel.activeZones.count))
                        .tint(.yellow)

                    // Mode switch toggle (preserves index within bounds)
                    HStack {
                        Button(action: {
                            withAnimation {
                                viewModel.switchMode()
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: viewModel.inspectionMode == .quick60Sec ? "bolt.fill" : "shield.checkered")
                                Text(viewModel.inspectionMode == .quick60Sec ? "⚡ Quick Mode (5 Shots) • Tap for Full" : "🛡️ Full Mode (12 Zones) • Tap for Quick")
                            }
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.white.opacity(0.15))
                            .clipShape(Capsule())
                        }
                        .accessibilityLabel("Switch inspection mode")
                        Spacer()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.black.opacity(0.6))
                .cornerRadius(12)
                .padding(.horizontal)

                Spacer()

                // 4. Bottom Inspection Guidance & Capture Controls
                VStack(spacing: 16) {
                    // Instruction Banner
                    HStack(spacing: 8) {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.yellow)
                        Text(viewModel.currentZone.instruction)
                            .font(.caption.weight(.medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                    }
                    .padding(10)
                    .background(Color.black.opacity(0.75))
                    .cornerRadius(10)
                    .padding(.horizontal)

                    // Capture / Next Row
                    HStack(spacing: 40) {
                        // Previous Button
                        Button(action: {
                            viewModel.previousStep()
                        }) {
                            Image(systemName: "arrow.backward.circle")
                                .font(.system(size: 36))
                                .foregroundColor(viewModel.currentZoneIndex > 0 ? .white : .white.opacity(0.3))
                        }
                        .disabled(viewModel.currentZoneIndex == 0)
                        .accessibilityLabel("Previous zone")

                        // Big Shutter Button with Haptic Feedback
                        Button(action: {
                            let generator = UIImpactFeedbackGenerator(style: .medium)
                            generator.impactOccurred()
                            cameraController?.capturePhoto()
                        }) {
                            ZStack {
                                Circle()
                                    .strokeBorder(Color.white, lineWidth: 4)
                                    .frame(width: 72, height: 72)
                                Circle()
                                    .fill(viewModel.capturedPhotos[viewModel.currentZone] != nil ? Color.green : Color.white)
                                    .frame(width: 58, height: 58)

                                if viewModel.capturedPhotos[viewModel.currentZone] != nil {
                                    Image(systemName: "checkmark")
                                        .font(.title2.bold())
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .accessibilityLabel("Capture photo for \(viewModel.currentZone.title)")
                        .accessibilityHint("Double tap to take a photo of this vehicle zone")

                        // Next / Skip Button
                        Button(action: {
                            viewModel.advanceStep()
                        }) {
                            Image(systemName: "arrow.forward.circle.fill")
                                .font(.system(size: 36))
                                .foregroundColor(.white)
                        }
                        .accessibilityLabel("Next zone")
                    }
                    .padding(.bottom, 20)
                }
            }
        }
        .onAppear {
            // Request location permission in-context when inspection begins (Fix 9)
            LocationService.shared.requestPermission()
        }
        .alert("Complete Inspection?", isPresented: $viewModel.showingFinishConfirmation) {
            Button("Save & Finish") {
                viewModel.finalizeInspection()
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("You've completed all \(viewModel.activeZones.count) zones. Save this \(viewModel.phase == .pickup ? "pick-up" : "return") record?")
        }
    }
}

// MARK: - Single Zone Camera Modal (For retaking or individual zone snaps)
public struct SingleZoneCameraModal: View {
    @Environment(\.dismiss) private var dismiss

    public let rental: Rental
    public let phase: InspectionPhase
    public let zone: VehicleZoneId
    public let onPhotoSaved: (PhotoEvidence) -> Void

    @State private var cameraController: CameraCaptureViewController?
    @State private var flashEnabled = false

    public init(
        rental: Rental,
        phase: InspectionPhase,
        zone: VehicleZoneId,
        onPhotoSaved: @escaping (PhotoEvidence) -> Void
    ) {
        self.rental = rental
        self.phase = phase
        self.zone = zone
        self.onPhotoSaved = onPhotoSaved
    }

    public var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            CameraPreviewView(
                flashEnabled: flashEnabled,
                onPhotoCaptured: { image in
                    handleCapturedSingle(image)
                },
                captureController: $cameraController
            )
            .ignoresSafeArea()

            GhostOverlayView(type: zone.wireframeType)

            VStack {
                HStack {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.white)
                        .accessibilityLabel("Cancel photo capture")
                    Spacer()
                    Text(zone.shortTitle)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    Spacer()
                    HUDTimestampBadge()
                }
                .padding()

                Spacer()

                VStack(spacing: 12) {
                    Text(zone.instruction)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.85))
                        .padding(10)
                        .background(Color.black.opacity(0.7))
                        .cornerRadius(8)
                        .padding(.horizontal)

                    Button(action: {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        cameraController?.capturePhoto()
                    }) {
                        ZStack {
                            Circle()
                                .strokeBorder(Color.white, lineWidth: 4)
                                .frame(width: 70, height: 70)
                            Circle()
                                .fill(Color.white)
                                .frame(width: 56, height: 56)
                        }
                    }
                    .accessibilityLabel("Capture single photo for \(zone.title)")
                    .padding(.bottom, 30)
                }
            }
        }
    }

    private func handleCapturedSingle(_ rawImage: UIImage) {
        let zone = self.zone
        let phase = self.phase
        let rental = self.rental

        Task.detached(priority: .userInitiated) {
            let loc = await LocationService.shared.captureSnapshot()
            let meta = WatermarkMetadata(
                phase: phase,
                timestamp: Date(),
                location: loc,
                vehicleSummary: rental.vehicleTitle,
                licensePlate: rental.licensePlate,
                zoneTitle: zone.title,
                agencyName: rental.agency.rawValue
            )

            let stamped = WatermarkService.shared.stampImage(image: rawImage, metadata: meta)
            let filename = "photo_\(rental.id.uuidString)_\(phase.rawValue)_\(zone.rawValue).jpg"

            if let finalImage = stamped?.stampedImage {
                _ = ImageStorageService.shared.saveImage(finalImage, filename: filename)
                _ = await PhotoBackupService.shared.saveToCameraRoll(image: finalImage, metadata: meta)
            }

            let evidence = PhotoEvidence(
                zoneId: zone,
                filename: filename,
                capturedAt: Date(),
                location: meta.location,
                hasDamage: false,
                hashSHA256: stamped?.sha256
            )

            await MainActor.run {
                onPhotoSaved(evidence)
                dismiss()
            }
        }
    }
}
#endif
