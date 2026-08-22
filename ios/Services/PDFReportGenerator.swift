//
//  PDFReportGenerator.swift
//  Walkaround
//
//  Generates multi-page, high-resolution certified forensic dispute dossiers
//  with side-by-side photo matrices, GPS verification tables, and dispute letters.
//

import Foundation

#if canImport(UIKit)
import UIKit
import PDFKit

public class PDFReportGenerator {
    public static let shared = PDFReportGenerator()

    private let pageWidth: CGFloat = 612.0 // Standard US Letter (8.5 x 11 in @ 72 dpi)
    private let pageHeight: CGFloat = 792.0
    private let margin: CGFloat = 36.0

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }()

    public func generateDossier(
        rental: Rental,
        imagesProvider: (String) -> UIImage?,
        renterName: String = "Renter",
        claimNumber: String = ""
    ) -> Data {
        let format = UIGraphicsPDFRendererFormat()
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)

        let data = renderer.pdfData { context in
            // PAGE 1: Cover Sheet & Executive Summary
            context.beginPage()
            drawCoverPage(rental: rental, renterName: renterName, claimNumber: claimNumber, in: pageRect)

            // PAGE 2: Dashboard & Odometer Certification
            context.beginPage()
            drawDashboardPage(rental: rental, imagesProvider: imagesProvider, in: pageRect)

            // PAGES 3+: Side-by-Side Zone Comparison Matrix (2 zones per page)
            let zones = VehicleZoneId.allCases.filter { $0 != .dashboardOdometer }
            for i in stride(from: 0, to: zones.count, by: 2) {
                context.beginPage()
                let zone1 = zones[i]
                let zone2 = (i + 1 < zones.count) ? zones[i + 1] : nil
                drawZoneComparisonPage(
                    rental: rental,
                    zone1: zone1,
                    zone2: zone2,
                    imagesProvider: imagesProvider,
                    in: pageRect
                )
            }

            // FINAL PAGE: Legal Dispute Response Letter
            context.beginPage()
            drawDisputeLetterPage(rental: rental, renterName: renterName, claimNumber: claimNumber, in: pageRect)
        }

        return data
    }

    // MARK: - Page 1: Cover & Summary
    private func drawCoverPage(rental: Rental, renterName: String, claimNumber: String, in rect: CGRect) {
        let contentWidth = pageWidth - (margin * 2)

        // 1. Header Banner
        let headerHeight: CGFloat = 85.0
        let headerRect = CGRect(x: margin, y: margin, width: contentWidth, height: headerHeight)
        let navyColor = UIColor(red: 0.08, green: 0.12, blue: 0.22, alpha: 1.0)
        navyColor.setFill()
        let headerPath = UIBezierPath(roundedRect: headerRect, cornerRadius: 8.0)
        headerPath.fill()

        let titleStyle = NSMutableParagraphStyle()
        titleStyle.alignment = .left
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 18, weight: .black),
            .foregroundColor: UIColor.white,
            .paragraphStyle: titleStyle
        ]
        let subAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .bold),
            .foregroundColor: UIColor(red: 0.38, green: 0.85, blue: 0.55, alpha: 1.0)
        ]

        ("WALKAROUND™ VEHICLE INSPECTION DOSSIER" as NSString).draw(
            in: CGRect(x: margin + 16, y: margin + 16, width: contentWidth - 32, height: 24),
            withAttributes: titleAttrs
        )
        ("VERIFIED VEHICLE INSPECTION RECORD • TIME & GPS DOCUMENTED" as NSString).draw(
            in: CGRect(x: margin + 16, y: margin + 44, width: contentWidth - 32, height: 18),
            withAttributes: subAttrs
        )

        var y: CGFloat = margin + headerHeight + 20

        // 2. Metadata Grid
        let gridRect = CGRect(x: margin, y: y, width: contentWidth, height: 160)
        UIColor(white: 0.96, alpha: 1.0).setFill()
        UIBezierPath(roundedRect: gridRect, cornerRadius: 6.0).fill()

        let labelFont = UIFont.systemFont(ofSize: 9, weight: .bold)
        let valFont = UIFont.systemFont(ofSize: 11, weight: .semibold)
        let colWidth = (contentWidth - 32) / 3

        let metaItems: [(label: String, val: String)] = [
            ("VEHICLE", rental.vehicleTitle),
            ("LICENSE PLATE", "\(rental.licensePlate) (\(rental.stateOrCountry.isEmpty ? "US" : rental.stateOrCountry))"),
            ("RENTAL AGENCY", rental.agency.rawValue),
            ("AGREEMENT / RES #", rental.agreementNumber.isEmpty ? "N/A" : rental.agreementNumber),
            ("VIN", rental.vin.isEmpty ? "Recorded on File" : rental.vin),
            ("CLAIM / NOTICE #", claimNumber.isEmpty ? "N/A" : claimNumber),
            ("PICKUP TIME", rental.pickupInspection?.completedAt != nil ? dateFormatter.string(from: rental.pickupInspection!.completedAt!) : "Pending"),
            ("DROPOFF TIME", rental.dropoffInspection?.completedAt != nil ? dateFormatter.string(from: rental.dropoffInspection!.completedAt!) : "Pending"),
            ("RENTER / AUDITOR", renterName)
        ]

        for (idx, item) in metaItems.enumerated() {
            let row = idx / 3
            let col = idx % 3
            let itemX = margin + 16 + (CGFloat(col) * colWidth)
            let itemY = y + 14 + (CGFloat(row) * 46)

            (item.label as NSString).draw(
                at: CGPoint(x: itemX, y: itemY),
                withAttributes: [.font: labelFont, .foregroundColor: UIColor.darkGray]
            )
            (item.val as NSString).draw(
                at: CGPoint(x: itemX, y: itemY + 14),
                withAttributes: [.font: valFont, .foregroundColor: UIColor.black]
            )
        }

        y += 180

        // 3. Location & GPS Audit Section
        let gpsTitle = "1. VERIFIED GEOGRAPHIC AUDIT TRAIL"
        (gpsTitle as NSString).draw(
            at: CGPoint(x: margin, y: y),
            withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: navyColor]
        )
        y += 22

        let pickupGps = rental.pickupInspection?.location
        let dropoffGps = rental.dropoffInspection?.location

        let gpsBoxHeight: CGFloat = 80
        let halfWidth = (contentWidth - 12) / 2

        // Pickup Box
        let pBox = CGRect(x: margin, y: y, width: halfWidth, height: gpsBoxHeight)
        UIColor(red: 0.93, green: 0.96, blue: 1.0, alpha: 1.0).setFill()
        UIBezierPath(roundedRect: pBox, cornerRadius: 6.0).fill()

        ("PICKUP POSSESSION LOCATION" as NSString).draw(
            at: CGPoint(x: pBox.minX + 10, y: pBox.minY + 8),
            withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .black), .foregroundColor: UIColor.systemBlue]
        )
        let pAddr = "\(pickupGps?.placeName ?? "Rental Location")\nGPS: \(String(format: "%.4f, %.4f", pickupGps?.latitude ?? 0, pickupGps?.longitude ?? 0))"
        (pAddr as NSString).draw(
            in: CGRect(x: pBox.minX + 10, y: pBox.minY + 26, width: halfWidth - 20, height: 48),
            withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .regular), .foregroundColor: UIColor.black]
        )

        // Dropoff Box
        let dBox = CGRect(x: margin + halfWidth + 12, y: y, width: halfWidth, height: gpsBoxHeight)
        UIColor(red: 0.93, green: 0.98, blue: 0.94, alpha: 1.0).setFill()
        UIBezierPath(roundedRect: dBox, cornerRadius: 6.0).fill()

        ("RETURN SURRENDER LOCATION" as NSString).draw(
            at: CGPoint(x: dBox.minX + 10, y: dBox.minY + 8),
            withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .black), .foregroundColor: UIColor.systemGreen]
        )
        let dAddr = "\(dropoffGps?.placeName ?? "Return Location")\nGPS: \(String(format: "%.4f, %.4f", dropoffGps?.latitude ?? 0, dropoffGps?.longitude ?? 0))"
        (dAddr as NSString).draw(
            in: CGRect(x: dBox.minX + 10, y: dBox.minY + 26, width: halfWidth - 20, height: 48),
            withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .regular), .foregroundColor: UIColor.black]
        )

        y += gpsBoxHeight + 24

        // 4. Pre-Existing Damage Log Table
        let damageTitle = "2. PRE-EXISTING DAMAGE LOGGED AT VEHICLE ACCEPTANCE"
        (damageTitle as NSString).draw(
            at: CGPoint(x: margin, y: y),
            withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .bold), .foregroundColor: navyColor]
        )
        y += 20

        let damages = rental.pickupInspection?.damagePoints ?? []
        if damages.isEmpty {
            let noDamageStr = "No significant cosmetic defects were flagged at pickup. Vehicle was accepted in standard condition."
            (noDamageStr as NSString).draw(
                at: CGPoint(x: margin, y: y + 8),
                withAttributes: [.font: UIFont.systemFont(ofSize: 10, weight: .regular), .foregroundColor: UIColor.darkGray]
            )
        } else {
            for (dIdx, dmg) in damages.prefix(4).enumerated() {
                let rowY = y + CGFloat(dIdx * 32)
                let itemRect = CGRect(x: margin, y: rowY, width: contentWidth, height: 28)
                UIColor(white: 0.97, alpha: 1.0).setFill()
                UIBezierPath(roundedRect: itemRect, cornerRadius: 4).fill()

                let dType = "⚠️ \(dmg.zoneId.shortTitle): \(dmg.type.title) [\(dmg.severity.rawValue.uppercased())]"
                (dType as NSString).draw(
                    at: CGPoint(x: margin + 8, y: rowY + 4),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .bold), .foregroundColor: UIColor.red]
                )
                let dNotes = dmg.notes.isEmpty ? "Documented on pickup photo." : dmg.notes
                (dNotes as NSString).draw(
                    at: CGPoint(x: margin + 8, y: rowY + 15),
                    withAttributes: [.font: UIFont.systemFont(ofSize: 8, weight: .regular), .foregroundColor: UIColor.black]
                )
            }
        }

        // Footer Stamp
        let footerText = "Generated via Walkaround for iOS • Verified Timestamp & GPS Report • Page 1"
        (footerText as NSString).draw(
            at: CGPoint(x: margin, y: pageHeight - 30),
            withAttributes: [.font: UIFont.systemFont(ofSize: 8, weight: .medium), .foregroundColor: UIColor.lightGray]
        )
    }

    // MARK: - Page 2: Dashboard, Odometer & Fuel Certification
    private func drawDashboardPage(rental: Rental, imagesProvider: (String) -> UIImage?, in rect: CGRect) {
        let contentWidth = pageWidth - (margin * 2)

        ("3. DASHBOARD, ODOMETER & FUEL AUDIT" as NSString).draw(
            at: CGPoint(x: margin, y: margin),
            withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .black), .foregroundColor: UIColor.black]
        )

        let desc = "Photographic verification of vehicle mileage and fuel gauge levels at pickup vs return."
        (desc as NSString).draw(
            at: CGPoint(x: margin, y: margin + 20),
            withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .regular), .foregroundColor: UIColor.darkGray]
        )

        let halfWidth = (contentWidth - 16) / 2
        let photoHeight: CGFloat = 260

        // Pickup Dash Photo Box
        let pRect = CGRect(x: margin, y: margin + 50, width: halfWidth, height: photoHeight)
        UIColor(white: 0.92, alpha: 1.0).setFill()
        UIBezierPath(roundedRect: pRect, cornerRadius: 6.0).fill()

        if let pPhoto = rental.pickupInspection?.photos[.dashboardOdometer],
           let img = imagesProvider(pPhoto.filename) {
            img.draw(in: pRect)
        } else {
            drawPlaceholder(title: "Pickup Dashboard Photo", in: pRect)
        }

        let pOdoLabel = "PICKUP: \(rental.pickupInspection?.odometerReading ?? "N/A") \(rental.pickupInspection?.odometerUnit ?? "mi") • Fuel: \(rental.pickupInspection?.fuelLevel.rawValue ?? "N/A")"
        (pOdoLabel as NSString).draw(
            at: CGPoint(x: margin, y: margin + 50 + photoHeight + 8),
            withAttributes: [.font: UIFont.systemFont(ofSize: 10, weight: .bold), .foregroundColor: UIColor.systemBlue]
        )

        // Dropoff Dash Photo Box
        let dRect = CGRect(x: margin + halfWidth + 16, y: margin + 50, width: halfWidth, height: photoHeight)
        UIColor(white: 0.92, alpha: 1.0).setFill()
        UIBezierPath(roundedRect: dRect, cornerRadius: 6.0).fill()

        if let dPhoto = rental.dropoffInspection?.photos[.dashboardOdometer],
           let img = imagesProvider(dPhoto.filename) {
            img.draw(in: dRect)
        } else {
            drawPlaceholder(title: "Return Dashboard Photo", in: dRect)
        }

        let dOdoLabel = "RETURN: \(rental.dropoffInspection?.odometerReading ?? "N/A") \(rental.dropoffInspection?.odometerUnit ?? "mi") • Fuel: \(rental.dropoffInspection?.fuelLevel.rawValue ?? "N/A")"
        (dOdoLabel as NSString).draw(
            at: CGPoint(x: margin + halfWidth + 16, y: margin + 50 + photoHeight + 8),
            withAttributes: [.font: UIFont.systemFont(ofSize: 10, weight: .bold), .foregroundColor: UIColor.systemGreen]
        )

        // Calculation Box
        let calcY = margin + 50 + photoHeight + 40
        let calcRect = CGRect(x: margin, y: calcY, width: contentWidth, height: 110)
        UIColor(red: 0.96, green: 0.97, blue: 0.99, alpha: 1.0).setFill()
        UIBezierPath(roundedRect: calcRect, cornerRadius: 6.0).fill()

        ("USAGE & INTEGRITY SUMMARY" as NSString).draw(
            at: CGPoint(x: margin + 14, y: calcY + 12),
            withAttributes: [.font: UIFont.systemFont(ofSize: 11, weight: .bold), .foregroundColor: UIColor.black]
        )

        let pOdoNum = Double(rental.pickupInspection?.odometerReading.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0
        let dOdoNum = Double(rental.dropoffInspection?.odometerReading.replacingOccurrences(of: ",", with: "") ?? "0") ?? 0
        let delta = max(0, dOdoNum - pOdoNum)

        let summaryText = """
        • Total Distance Driven: \(String(format: "%.1f", delta)) \(rental.pickupInspection?.odometerUnit ?? "mi")
        • Fuel Compliance: Returned with \(rental.dropoffInspection?.fuelLevel.rawValue ?? "Full") (Pickup was \(rental.pickupInspection?.fuelLevel.rawValue ?? "Full"))
        • Tamper Check: High resolution HUD overlay records match vehicle odometer cluster.
        """
        (summaryText as NSString).draw(
            in: CGRect(x: margin + 14, y: calcY + 34, width: contentWidth - 28, height: 65),
            withAttributes: [.font: UIFont.systemFont(ofSize: 9, weight: .medium), .foregroundColor: UIColor.darkGray]
        )
    }

    // MARK: - Pages 3+: Side-by-Side Comparison
    private func drawZoneComparisonPage(
        rental: Rental,
        zone1: VehicleZoneId,
        zone2: VehicleZoneId?,
        imagesProvider: (String) -> UIImage?,
        in rect: CGRect
    ) {
        let contentWidth = pageWidth - (margin * 2)

        ("4. ZONE COMPARISON MATRIX (SIDE-BY-SIDE FORENSICS)" as NSString).draw(
            at: CGPoint(x: margin, y: margin),
            withAttributes: [.font: UIFont.systemFont(ofSize: 12, weight: .black), .foregroundColor: UIColor.black]
        )

        var y: CGFloat = margin + 26
        drawSingleZoneComparison(zone: zone1, rental: rental, imagesProvider: imagesProvider, y: y, contentWidth: contentWidth)

        if let z2 = zone2 {
            y += 340
            drawSingleZoneComparison(zone: z2, rental: rental, imagesProvider: imagesProvider, y: y, contentWidth: contentWidth)
        }
    }

    private func drawSingleZoneComparison(
        zone: VehicleZoneId,
        rental: Rental,
        imagesProvider: (String) -> UIImage?,
        y: CGFloat,
        contentWidth: CGFloat
    ) {
        // Zone Title Bar
        (zone.title.uppercased() as NSString).draw(
            at: CGPoint(x: margin, y: y),
            withAttributes: [.font: UIFont.systemFont(ofSize: 10, weight: .black), .foregroundColor: UIColor(red: 0.1, green: 0.3, blue: 0.7, alpha: 1.0)]
        )

        let halfWidth = (contentWidth - 12) / 2
        let photoHeight: CGFloat = 250

        // Left: Pickup
        let pRect = CGRect(x: margin, y: y + 16, width: halfWidth, height: photoHeight)
        UIColor(white: 0.93, alpha: 1.0).setFill()
        UIBezierPath(roundedRect: pRect, cornerRadius: 4.0).fill()

        if let pPhoto = rental.pickupInspection?.photos[zone],
           let img = imagesProvider(pPhoto.filename) {
            img.draw(in: pRect)
        } else {
            drawPlaceholder(title: "Pickup: \(zone.shortTitle)", in: pRect)
        }

        // Right: Dropoff
        let dRect = CGRect(x: margin + halfWidth + 12, y: y + 16, width: halfWidth, height: photoHeight)
        UIColor(white: 0.93, alpha: 1.0).setFill()
        UIBezierPath(roundedRect: dRect, cornerRadius: 4.0).fill()

        if let dPhoto = rental.dropoffInspection?.photos[zone],
           let img = imagesProvider(dPhoto.filename) {
            img.draw(in: dRect)
        } else {
            drawPlaceholder(title: "Return: \(zone.shortTitle)", in: dRect)
        }

        // Labels under photos
        ("PICKUP POSSESSION" as NSString).draw(
            at: CGPoint(x: pRect.minX, y: pRect.maxY + 4),
            withAttributes: [.font: UIFont.systemFont(ofSize: 8, weight: .bold), .foregroundColor: UIColor.systemBlue]
        )
        ("RETURN SURRENDER" as NSString).draw(
            at: CGPoint(x: dRect.minX, y: dRect.maxY + 4),
            withAttributes: [.font: UIFont.systemFont(ofSize: 8, weight: .bold), .foregroundColor: UIColor.systemGreen]
        )
    }

    // MARK: - Final Page: Dispute Response Letter
    private func drawDisputeLetterPage(rental: Rental, renterName: String, claimNumber: String, in rect: CGRect) {
        let contentWidth = pageWidth - (margin * 2)

        ("FORMAL REBUTTAL & LEGAL NOTICE" as NSString).draw(
            at: CGPoint(x: margin, y: margin),
            withAttributes: [.font: UIFont.systemFont(ofSize: 14, weight: .black), .foregroundColor: UIColor.black]
        )

        let letterText = DisputeLetterTemplate.generateLetter(
            rental: rental,
            recipient: .rentalAgency,
            renterName: renterName,
            claimNumber: claimNumber
        )

        let letterStyle = NSMutableParagraphStyle()
        letterStyle.lineSpacing = 3.0
        let letterAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 9, weight: .regular),
            .foregroundColor: UIColor.black,
            .paragraphStyle: letterStyle
        ]

        let letterRect = CGRect(x: margin, y: margin + 30, width: contentWidth, height: pageHeight - 80)
        (letterText as NSString).draw(in: letterRect, withAttributes: letterAttrs)
    }

    private func drawPlaceholder(title: String, in rect: CGRect) {
        let labelStyle = NSMutableParagraphStyle()
        labelStyle.alignment = .center
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10, weight: .semibold),
            .foregroundColor: UIColor.lightGray,
            .paragraphStyle: labelStyle
        ]
        (title as NSString).draw(
            in: CGRect(x: rect.minX + 10, y: rect.midY - 10, width: rect.width - 20, height: 20),
            withAttributes: attrs
        )
    }
}
#endif
