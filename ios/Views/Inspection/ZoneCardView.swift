//
//  ZoneCardView.swift
//  Walkaround
//
//  Display row/card for a specific vehicle zone during inspection.
//

import SwiftUI

public struct ZoneCardView: View {
    public let zone: VehicleZoneId
    public let photo: PhotoEvidence?
    public let hasDamage: Bool
    public let onRetake: () -> Void
    public let onFlagDamage: () -> Void

    public init(
        zone: VehicleZoneId,
        photo: PhotoEvidence?,
        hasDamage: Bool,
        onRetake: @escaping () -> Void,
        onFlagDamage: @escaping () -> Void
    ) {
        self.zone = zone
        self.photo = photo
        self.hasDamage = hasDamage
        self.onRetake = onRetake
        self.onFlagDamage = onFlagDamage
    }

    public var body: some View {
        HStack(spacing: 12) {
            // Left Icon / Thumbnail
            ZStack {
                if photo != nil {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.green.opacity(0.15))
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.green)
                        .font(.title2)
                } else {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.subtleFill)
                    Image(systemName: zone.iconName)
                        .foregroundColor(.secondary)
                        .font(.title3)
                }
            }
            .frame(width: 52, height: 52)

            // Center Info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(zone.title)
                        .font(.subheadline.bold())
                        .foregroundColor(.primary)

                    if zone.isRequiredForBasicPass {
                        Text("REQUIRED")
                            .font(.system(size: 8, weight: .black))
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(4)
                    }
                }

                Text(zone.instruction)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)

                if hasDamage {
                    HStack(spacing: 4) {
                        Image(systemName: "exclamationmark.triangle.fill")
                        Text("Pre-existing Damage Flagged")
                    }
                    .font(.caption2.bold())
                    .foregroundColor(.orange)
                }
            }

            Spacer()

            // Right Action
            VStack(spacing: 6) {
                Button(action: onRetake) {
                    Image(systemName: photo == nil ? "camera.fill" : "arrow.triangle.2.circlepath.camera.fill")
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .frame(width: 38, height: 38)
                        .background(photo == nil ? Color.blue : Color.secondary)
                        .clipShape(Circle())
                }

                if photo != nil {
                    Button(action: onFlagDamage) {
                        Image(systemName: hasDamage ? "exclamationmark.bubble.fill" : "plus.bubble")
                            .font(.caption)
                            .foregroundColor(hasDamage ? .orange : .secondary)
                    }
                }
            }
        }
        .padding(12)
        .background(Color.cardBackground)
        .cornerRadius(14)
    }
}
