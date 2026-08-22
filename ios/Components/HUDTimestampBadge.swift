//
//  HUDTimestampBadge.swift
//  Walkaround
//
//  Live camera HUD showing real-time UTC clock and GPS lock status.
//

import SwiftUI
import CoreLocation

public struct HUDTimestampBadge: View {
    @ObservedObject var locationService = LocationService.shared
    @State private var currentTime = Date()
    private let timer = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    public init() {}

    private var timeString: String {
        let df = DateFormatter()
        df.timeZone = TimeZone(abbreviation: "UTC")
        df.dateFormat = "HH:mm:ss 'UTC'"
        return df.string(from: currentTime)
    }

    public var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(locationService.currentCoordinate != nil ? Color.green : Color.yellow)
                .frame(width: 8, height: 8)

            Text("REC")
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .foregroundColor(.red)

            Text("•")
                .foregroundColor(.white.opacity(0.4))

            Text(timeString)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundColor(.white)

            if let coord = locationService.currentCoordinate {
                Text("•")
                    .foregroundColor(.white.opacity(0.4))
                Text(String(format: "%.3f, %.3f", coord.latitude, coord.longitude))
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.black.opacity(0.75))
        .clipShape(Capsule())
        .onReceive(timer) { input in
            currentTime = input
        }
    }
}
