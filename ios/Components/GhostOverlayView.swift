//
//  GhostOverlayView.swift
//  Walkaround
//
//  Translucent HUD wireframe silhouettes guiding user camera placement
//  for standard inspection angles.
//

import SwiftUI

public struct GhostOverlayView: View {
    public let type: WireframeType

    public init(type: WireframeType) {
        self.type = type
    }

    public var body: some View {
        GeometryReader { geo in
            ZStack {
                // Outer Guide Frame
                RoundedRectangle(cornerRadius: 16)
                    .strokeBorder(
                        Color.white.opacity(0.35),
                        style: StrokeStyle(lineWidth: 1.5, dash: [8, 6])
                    )
                    .padding(20)

                // Wireframe Silhouette
                VStack(spacing: 8) {
                    Image(systemName: iconForType(type))
                        .resizable()
                        .scaledToFit()
                        .frame(width: geo.size.width * 0.45, height: geo.size.height * 0.35)
                        .foregroundColor(.white.opacity(0.40))

                    Text(guideTitle(type))
                        .font(.caption.bold())
                        .foregroundColor(.white.opacity(0.85))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.6))
                        .clipShape(Capsule())
                }

                // Level Guide Crosshair
                Circle()
                    .stroke(Color.white.opacity(0.3), lineWidth: 1)
                    .frame(width: 40, height: 40)
                Rectangle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 20, height: 1)
                Rectangle()
                    .fill(Color.white.opacity(0.4))
                    .frame(width: 1, height: 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .allowsHitTesting(false)
    }

    private func iconForType(_ type: WireframeType) -> String {
        switch type {
        case .frontCar: return "car.front.waves.up"
        case .rearCar: return "car.rear"
        case .driverSide, .passengerSide: return "car.side"
        case .wheel: return "circle.circle"
        case .hood: return "car.top.radiowaves.rear.left.and.rear.right"
        case .roof: return "car.top.door.sliding.left.open"
        case .dashboard: return "gauge.with.needle"
        case .interior: return "car.seat"
        }
    }

    private func guideTitle(_ type: WireframeType) -> String {
        switch type {
        case .frontCar: return "Align Front Bumper in Frame"
        case .rearCar: return "Align Rear Bumper & Trunk"
        case .driverSide: return "Align Entire Driver Profile"
        case .passengerSide: return "Align Entire Passenger Profile"
        case .wheel: return "Center Wheel Rim & Tire Edge"
        case .hood: return "Capture Hood & Full Windshield"
        case .roof: return "Hold Phone High Above Roofline"
        case .dashboard: return "Close-up: Odometer & Fuel Level"
        case .interior: return "Capture Cabin & Seating Area"
        }
    }
}
