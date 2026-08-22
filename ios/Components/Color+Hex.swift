import SwiftUI

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

extension Color {
    public init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let r, g, b: Double
        switch hex.count {
        case 6:
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8) & 0xFF) / 255.0
            b = Double(int & 0xFF) / 255.0
        default:
            r = 0; g = 0; b = 0
        }
        self.init(red: r, green: g, blue: b)
    }
    
    public static let amber = Color(red: 0.85, green: 0.47, blue: 0.02)

    public static var cardBackground: Color {
        #if canImport(UIKit)
        return Color(uiColor: .secondarySystemGroupedBackground)
        #else
        return Color(white: 0.96)
        #endif
    }

    public static var subtleFill: Color {
        #if canImport(UIKit)
        return Color(uiColor: .tertiarySystemFill)
        #else
        return Color.secondary.opacity(0.12)
        #endif
    }
}

extension View {
    public func inlineNavigationTitle() -> some View {
        #if os(iOS)
        return self.navigationBarTitleDisplayMode(.inline)
        #else
        return self
        #endif
    }

    public func numericKeyboard() -> some View {
        #if os(iOS)
        return self.keyboardType(.numberPad)
        #else
        return self
        #endif
    }

    public func numbersAndPunctuationKeyboard() -> some View {
        #if os(iOS)
        return self.keyboardType(.numbersAndPunctuation)
        #else
        return self
        #endif
    }

    public func uppercaseAutocapitalization() -> some View {
        #if os(iOS)
        return self.textInputAutocapitalization(.characters)
        #else
        return self
        #endif
    }

    public func pagedTabViewStyle() -> some View {
        #if os(iOS)
        return self.tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        #else
        return self
        #endif
    }
}
