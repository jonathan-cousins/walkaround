//
//  DisputeDossierView.swift
//  Walkaround
//
//  Complete Dispute Command Center offering side-by-side photo comparison,
//  dispute letter template generation, and 1-tap PDF proof export with real images.
//

import SwiftUI

#if canImport(UIKit)
public struct DisputeDossierView: View {
    @Environment(\.dismiss) private var dismiss

    public let rental: Rental

    @State private var showingPDFPreview = false
    @State private var generatedPDFData: Data?
    @State private var showingLetterGenerator = false
    @State private var showingPaywall = false
    @State private var renterName = "Rental Driver"
    @State private var claimNumber = ""
    @State private var isGenerating = false

    private let emerald = Color(red: 0.02, green: 0.59, blue: 0.41)

    @ObservedObject var storeKit = StoreKitManager.shared

    public init(rental: Rental) {
        self.rental = rental
    }

    public var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Top Hero Banner
                    VStack(spacing: 8) {
                        Image(systemName: "shield.checkerboard")
                            .font(.system(size: 48))
                            .foregroundColor(emerald)

                        Text("Trip Proof & Inspection Report")
                            .font(.title2.bold())

                        Text("Organized photographic evidence summary ready to share with \(rental.agency.rawValue) or your credit card company.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 10)

                    // 1. Side-by-Side Photo Matrix
                    VStack(alignment: .leading, spacing: 10) {
                        Text("1. Visual Comparison Matrix")
                            .font(.headline.bold())
                            .padding(.horizontal)

                        SideBySideCompareView(rental: rental)
                    }
                    .padding(.vertical, 8)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)

                    // 2. Dispute Letter Generator Button
                    Button(action: { showingLetterGenerator = true }) {
                        HStack {
                            Image(systemName: "envelope.badge.shield.half.filled")
                                .font(.title2)
                                .foregroundColor(emerald)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("2. Dispute Response Letter Template")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.primary)
                                Text("Pre-formatted response template for Hertz, Enterprise, or Credit Card CDW")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.bold())
                                .foregroundColor(.secondary)
                        }
                        .padding(16)
                        .background(Color.cardBackground)
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    // 3. Export PDF Dossier Action Box
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .font(.title3)
                                .foregroundColor(.red)
                            Text("Inspection Proof PDF Report")
                                .font(.headline.bold())
                            Spacer()
                            if storeKit.hasProAccess {
                                StatusPill("PRO UNLOCKED", color: emerald)
                            }
                        }

                        Text("Includes high-resolution photo matrix, reverse-geocoded GPS coordinates, odometer verification, and attached summary letter.")
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Button(action: generateAndExportPDF) {
                            HStack {
                                if isGenerating {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "square.and.arrow.up.fill")
                                    Text("Export & Share PDF Report")
                                }
                            }
                            .font(.headline.bold())
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(emerald)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                        }
                        .disabled(isGenerating)
                    }
                    .padding(16)
                    .background(Color.cardBackground)
                    .cornerRadius(16)
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
            .navigationTitle("Inspection Report")
            .inlineNavigationTitle()
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .sheet(isPresented: $showingLetterGenerator) {
                DisputeLetterGeneratorView(rental: rental)
            }
            .sheet(isPresented: $showingPDFPreview) {
                if let data = generatedPDFData {
                    PDFViewerSheet(pdfData: data)
                }
            }
            .sheet(isPresented: $showingPaywall) {
                PaywallSheet()
            }
        }
    }

    private func generateAndExportPDF() {
        if !storeKit.canExportDossier(for: rental) {
            showingPaywall = true
            return
        }

        isGenerating = true
        DispatchQueue.global(qos: .userInitiated).async {
            let pdf = PDFReportGenerator.shared.generateDossier(
                rental: rental,
                imagesProvider: { filename in
                    // Load REAL images from disk storage
                    return ImageStorageService.shared.loadImage(filename: filename)
                },
                renterName: renterName,
                claimNumber: claimNumber
            )

            DispatchQueue.main.async {
                self.generatedPDFData = pdf
                self.isGenerating = false
                self.showingPDFPreview = true
                self.storeKit.consumeTripPass()
            }
        }
    }
}
#endif
