//
//  StatusPill.swift
//  Walkaround
//
//  Telemetry micro-badge component for statuses, tags, and severity indicators.
//

import SwiftUI

public struct StatusPill: View {
    public let text: String
    public let icon: String?
    public let color: Color

    public init(_ text: String, icon: String? = nil, color: Color = Color(red: 1.0, green: 0.3, blue: 0.0)) {
        self.text = text
        self.icon = icon
        self.color = color
    }

    public var body: some View {
        HStack(spacing: 4) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 9, weight: .bold))
            }
            Text(text.uppercased())
                .font(.system(size: 9, weight: .black, design: .monospaced))
        }
        .padding(.horizontal, 6)
        .padding(.vertical, 3)
        .background(color.opacity(0.12))
        .foregroundColor(color)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .cornerRadius(4)
    }
}
