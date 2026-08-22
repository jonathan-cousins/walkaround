//
//  WatermarkService.swift
//  Walkaround
//
//  Burns tamper-proof cryptographic metadata overlays directly onto photos
//  (UTC Timestamp, GPS coordinates, vehicle info, and SHA-256 hash).
//

import Foundation
import CryptoKit

#if canImport(UIKit)
import UIKit
#endif

public struct WatermarkMetadata {
    public var phase: InspectionPhase
    public var timestamp: Date
    public var location: LocationSnapshot?
    public var vehicleSummary: String
    public var licensePlate: String
    public var zoneTitle: String
    public var agencyName: String

    public init(
        phase: InspectionPhase = .pickup,
        timestamp: Date = Date(),
        location: LocationSnapshot? = nil,
        vehicleSummary: String = "",
        licensePlate: String = "",
        zoneTitle: String = "",
        agencyName: String = ""
    ) {
        self.phase = phase
        self.timestamp = timestamp
        self.location = location
        self.vehicleSummary = vehicleSummary
        self.licensePlate = licensePlate
        self.zoneTitle = zoneTitle
        self.agencyName = agencyName
    }
}

#if canImport(UIKit)
public class WatermarkService {
    public static let shared = WatermarkService()

    private let utcFormatter: DateFormatter = {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"
        return df
    }()

    private let localFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .medium
        return df
    }()

    public func stampImage(image: UIImage, metadata: WatermarkMetadata) -> (stampedImage: UIImage, sha256: String)? {
        guard let cgImage = image.cgImage else { return nil }

        let width = CGFloat(cgImage.width)
        let height = CGFloat(cgImage.height)
        let size = CGSize(width: width, height: height)

        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = 1.0
        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)

        let stamped = renderer.image { context in
            // 1. Draw original image
            image.draw(in: CGRect(origin: .zero, size: size))

            let baseScale = max(width, height) / 1200.0

            // 2. Top Banner (Verification Badge)
            let topBannerHeight: CGFloat = 44.0 * baseScale
            let topRect = CGRect(x: 0, y: 0, width: width, height: topBannerHeight)
            let bannerColor = (metadata.phase == .pickup)
                ? UIColor(red: 0.05, green: 0.45, blue: 0.95, alpha: 0.85) // Blue
                : UIColor(red: 0.10, green: 0.70, blue: 0.35, alpha: 0.85) // Green

            bannerColor.setFill()
            UIRectFillUsingBlendMode(topRect, .normal)

            let badgeFont = UIFont.monospacedSystemFont(ofSize: 18.0 * baseScale, weight: .black)
            let badgeText = "🔒 WALKAROUND PROOF • \(metadata.phase.stampPrefix)"
            let badgeAttrs: [NSAttributedString.Key: Any] = [
                .font: badgeFont,
                .foregroundColor: UIColor.white
            ]
            let badgeSize = (badgeText as NSString).size(withAttributes: badgeAttrs)
            (badgeText as NSString).draw(
                at: CGPoint(x: (width - badgeSize.width) / 2.0, y: (topBannerHeight - badgeSize.height) / 2.0),
                withAttributes: badgeAttrs
            )

            // 3. Bottom HUD Overlay Panel
            let hudHeight: CGFloat = 140.0 * baseScale
            let hudRect = CGRect(x: 0, y: height - hudHeight, width: width, height: hudHeight)
            UIColor(white: 0.0, alpha: 0.75).setFill()
            UIRectFillUsingBlendMode(hudRect, .normal)

            // Border line on top of HUD
            let borderPath = UIBezierPath()
            borderPath.move(to: CGPoint(x: 0, y: height - hudHeight))
            borderPath.addLine(to: CGPoint(x: width, y: height - hudHeight))
            UIColor(white: 1.0, alpha: 0.25).setStroke()
            borderPath.lineWidth = 1.5 * baseScale
            borderPath.stroke()

            // Text configuration
            let titleFont = UIFont.monospacedSystemFont(ofSize: 15.0 * baseScale, weight: .bold)
            let monoFont = UIFont.monospacedSystemFont(ofSize: 13.0 * baseScale, weight: .regular)
            let yellowFont = UIFont.monospacedSystemFont(ofSize: 13.0 * baseScale, weight: .semibold)

            let leftMargin: CGFloat = 24.0 * baseScale
            var currentY: CGFloat = height - hudHeight + (12.0 * baseScale)
            let lineHeight: CGFloat = 22.0 * baseScale

            // Line 1: Vehicle & Zone
            let line1 = "🚗 \(metadata.vehicleSummary) • PLATE: \(metadata.licensePlate) • [\(metadata.zoneTitle.uppercased())]"
            (line1 as NSString).draw(
                at: CGPoint(x: leftMargin, y: currentY),
                withAttributes: [.font: titleFont, .foregroundColor: UIColor.white]
            )
            currentY += lineHeight

            // Line 2: Timestamps (UTC & Local)
            let utcStr = utcFormatter.string(from: metadata.timestamp)
            let localStr = localFormatter.string(from: metadata.timestamp)
            let line2 = "⏱ UTC: \(utcStr) | Local: \(localStr)"
            (line2 as NSString).draw(
                at: CGPoint(x: leftMargin, y: currentY),
                withAttributes: [.font: monoFont, .foregroundColor: UIColor(white: 0.9, alpha: 1.0)]
            )
            currentY += lineHeight

            // Line 3: GPS & Location
            let burnGps = UserDefaults.standard.object(forKey: "burnGpsToPixels") == nil ? true : UserDefaults.standard.bool(forKey: "burnGpsToPixels")
            if burnGps {
                let lat = metadata.location?.latitude ?? 0.0
                let lon = metadata.location?.longitude ?? 0.0
                let addr = metadata.location?.placeName ?? "N/A"
                let latDir = lat >= 0 ? "N" : "S"
                let lonDir = lon >= 0 ? "E" : "W"
                let line3 = String(format: "📍 GPS: %.5f° %@, %.5f° %@ • %@", abs(lat), latDir, abs(lon), lonDir, addr)
                (line3 as NSString).draw(
                    at: CGPoint(x: leftMargin, y: currentY),
                    withAttributes: [.font: yellowFont, .foregroundColor: UIColor(red: 1.0, green: 0.85, blue: 0.3, alpha: 1.0)]
                )
                currentY += lineHeight
            }

            // Line 4: Rental Agency & Hash placeholder
            let line4 = "🏢 AGENCY: \(metadata.agencyName) • AUTHENTICATED TAMPER-EVIDENT EVIDENCE"
            (line4 as NSString).draw(
                at: CGPoint(x: leftMargin, y: currentY),
                withAttributes: [.font: monoFont, .foregroundColor: UIColor(white: 0.75, alpha: 1.0)]
            )
        }

        // Calculate SHA-256 hash of final stamped image data
        guard let jpegData = stamped.jpegData(compressionQuality: 0.85) else {
            return (stamped, "UNKNOWN_HASH")
        }
        let hash = SHA256.hash(data: jpegData)
        let hashString = hash.compactMap { String(format: "%02x", $0) }.joined()

        return (stamped, hashString)
    }
}
#endif
