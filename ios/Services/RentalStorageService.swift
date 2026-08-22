//
//  RentalStorageService.swift
//  Walkaround
//
//  Production sandbox file persistence for vehicle rentals, inspections,
//  and damage records with automatic JSON serialization to Documents directory.
//

import Foundation
import Combine

@MainActor
public class RentalStorageService: ObservableObject {
    public static let shared = RentalStorageService()

    @Published public var rentals: [Rental] = []

    private var storageFileURL: URL {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return docs.appendingPathComponent("walkaround_rentals.json")
    }

    public init() {
        loadRentals()
    }

    public func loadRentals() {
        do {
            if FileManager.default.fileExists(atPath: storageFileURL.path) {
                let data = try Data(contentsOf: storageFileURL)
                let decoder = JSONDecoder()
                decoder.dateDecodingStrategy = .iso8601
                self.rentals = try decoder.decode([Rental].self, from: data)
            } else {
                // First launch: seed with sample rental
                self.rentals = [Rental.sampleRental]
                saveRentals()
            }
        } catch {
            print("Failed to load rentals from disk: \(error). Falling back to sample.")
            self.rentals = [Rental.sampleRental]
        }
    }

    public func saveRentals() {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(rentals)
            try data.write(to: storageFileURL, options: [.atomicWrite])
        } catch {
            print("Failed to save rentals to disk: \(error)")
        }
    }

    public func addRental(_ rental: Rental) {
        rentals.insert(rental, at: 0)
        saveRentals()
    }

    public func updateRental(_ rental: Rental) {
        if let idx = rentals.firstIndex(where: { $0.id == rental.id }) {
            rentals[idx] = rental
            saveRentals()
        }
    }

    public func deleteRental(_ rental: Rental) {
        rentals.removeAll(where: { $0.id == rental.id })
        saveRentals()
    }

    public func archiveRental(_ rental: Rental) {
        if let idx = rentals.firstIndex(where: { $0.id == rental.id }) {
            rentals[idx].isArchived = true
            saveRentals()
        }
    }
}
