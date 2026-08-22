//
//  LocationService.swift
//  Walkaround
//
//  CoreLocation wrapper providing real-time GPS coordinates, reverse-geocoding,
//  and offline snapshotting for tamper-proof photo metadata.
//

import Foundation
import CoreLocation
import Combine

@MainActor
public class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    public static let shared = LocationService()

    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()

    @Published public var currentCoordinate: CLLocationCoordinate2D?
    @Published public var currentAltitude: Double?
    @Published public var currentAddress: String = "Detecting Location..."
    @Published public var currentPlaceName: String = "Locating..."
    @Published public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published public var isLocating: Bool = false

    override private init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    public func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    public func startUpdating() {
        isLocating = true
        manager.startUpdatingLocation()
    }

    public func stopUpdating() {
        isLocating = false
        manager.stopUpdatingLocation()
    }

    public func captureSnapshot() async -> LocationSnapshot {
        guard let loc = manager.location else {
            return LocationSnapshot(
                latitude: currentCoordinate?.latitude ?? 0.0,
                longitude: currentCoordinate?.longitude ?? 0.0,
                placeName: currentPlaceName.isEmpty ? "Location Offline" : currentPlaceName,
                formattedAddress: currentAddress.isEmpty ? "GPS Available" : currentAddress
            )
        }

        var place = "Rental Facility"
        var fullAddr = String(format: "%.5f, %.5f", loc.coordinate.latitude, loc.coordinate.longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(loc)
            if let mark = placemarks.first {
                let name = mark.name ?? ""
                let locality = mark.locality ?? ""
                let adminArea = mark.administrativeArea ?? ""
                let country = mark.country ?? ""

                place = mark.areasOfInterest?.first ?? name
                if place.isEmpty { place = locality }
                fullAddr = [name, locality, adminArea, country].filter { !$0.isEmpty }.joined(separator: ", ")
            }
        } catch {
            fullAddr = String(format: "Lat: %.5f, Lon: %.5f", loc.coordinate.latitude, loc.coordinate.longitude)
        }

        return LocationSnapshot(
            latitude: loc.coordinate.latitude,
            longitude: loc.coordinate.longitude,
            altitude: loc.altitude,
            placeName: place,
            formattedAddress: fullAddr,
            recordedAt: Date()
        )
    }

    // MARK: - CLLocationManagerDelegate
    nonisolated public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        let status = manager.authorizationStatus
        Task { @MainActor in
            self.authorizationStatus = status
            #if os(iOS)
            let isAuthorized = (status == .authorizedWhenInUse || status == .authorizedAlways)
            #else
            let isAuthorized = (status == .authorizedAlways)
            #endif
            if isAuthorized {
                manager.startUpdatingLocation()
            }
        }
    }

    nonisolated public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        Task { @MainActor in
            self.currentCoordinate = location.coordinate
            self.currentAltitude = location.altitude

            self.geocoder.reverseGeocodeLocation(location) { placemarks, _ in
                guard let mark = placemarks?.first else { return }
                let name = mark.name ?? ""
                let locality = mark.locality ?? ""
                let state = mark.administrativeArea ?? ""
                let place = mark.areasOfInterest?.first ?? (!name.isEmpty ? name : locality)
                let address = [name, locality, state].filter { !$0.isEmpty }.joined(separator: ", ")

                Task { @MainActor in
                    self.currentPlaceName = place
                    self.currentAddress = address
                }
            }
        }
    }
}
