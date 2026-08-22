//
//  OnboardingView.swift
//  Walkaround
//
//  Clean, friendly, welcoming 4-slide visual onboarding tutorial teaching new users
//  exactly how to use Walkaround in under 30 seconds.
//

import SwiftUI

public struct OnboardingView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var currentTab = 0

    public var onFinish: (() -> Void)?

    private let emerald = Color(red: 0.02, green: 0.59, blue: 0.41)
    private let amber = Color(red: 0.85, green: 0.47, blue: 0.02)
    private let porcelainBg = Color(red: 0.97, green: 0.98, blue: 0.99)

    public init(onFinish: (() -> Void)? = nil) {
        self.onFinish = onFinish
    }

    public var body: some View {
        ZStack {
            porcelainBg.ignoresSafeArea()

            VStack(spacing: 16) {
                // Top Header: Step Indicator & Skip Button
                HStack {
                    Text("STEP \(currentTab + 1) OF 4")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.secondary)

                    Spacer()

                    Button("Skip") {
                        completeOnboarding()
                    }
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(emerald)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)

                // Tab Content Carousel
                TabView(selection: $currentTab) {
                    // Slide 1: Step 1 Camera Walkthrough
                    OnboardingSlide(
                        icon: "camera.viewfinder",
                        iconColor: emerald,
                        badge: "STEP 1: 60-SEC WALKTHROUGH",
                        title: "Follow the Friendly Guides",
                        description: "Just walk around your car. The app shows you exactly where to stand (Front, Sides, Rear, Wheels) and auto-stamps GPS & UTC time."
                    )
                    .tag(0)

                    // Slide 2: Step 2 Damage Tagging
                    OnboardingSlide(
                        icon: "hand.tap.fill",
                        iconColor: amber,
                        badge: "STEP 2: PRE-EXISTING DAMAGE",
                        title: "Spot a Scratch? Just Tap It",
                        description: "If you see a pre-existing scratch or curb rash, tap it on screen. It adds a certified note and pin to your inspection report in 1 second."
                    )
                    .tag(1)

                    // Slide 3: Step 3 Dashboard Check
                    OnboardingSlide(
                        icon: "gauge.with.needle.fill",
                        iconColor: emerald,
                        badge: "STEP 3: DASHBOARD CHECK",
                        title: "Lock In Mileage & Gas Level",
                        description: "Snap one photo of the dashboard cluster with ignition ON so the agency can never charge you $9.99/gal for 'missing fuel.'"
                    )
                    .tag(2)

                    // Slide 4: Step 4 Dispute Dossier
                    OnboardingSlide(
                        icon: "shield.checkerboard",
                        iconColor: emerald,
                        badge: "STEP 4: 1-TAP REPORT",
                        title: "Vehicle Inspection Proof Report",
                        description: "If you ever receive an unexpected damage charge weeks later, tap 1 button to export a structured PDF photo report and dispute letter template."
                    )
                    .tag(3)
                }
                .pagedTabViewStyle()

                // Bottom Action Button
                VStack(spacing: 12) {
                    Button(action: {
                        if currentTab < 3 {
                            withAnimation { currentTab += 1 }
                        } else {
                            completeOnboarding()
                        }
                    }) {
                        Text(currentTab == 3 ? "Start My First Inspection (Free)" : "Next Step")
                            .font(.system(size: 15, weight: .bold))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(emerald)
                            .foregroundColor(.white)
                            .cornerRadius(14)
                            .shadow(color: emerald.opacity(0.3), radius: 10, x: 0, y: 4)
                    }
                    .padding(.horizontal, 24)

                    Text("100% Offline • No Sign-up Required • Stored on Device")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }
                .padding(.bottom, 24)
            }
        }
    }

    private func completeOnboarding() {
        hasSeenOnboarding = true
        onFinish?()
    }
}

struct OnboardingSlide: View {
    let icon: String
    let iconColor: Color
    let badge: String
    let title: String
    let description: String

    var body: some View {
        VStack(spacing: 18) {
            Spacer()

            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.12))
                    .frame(width: 110, height: 110)
                    .overlay(
                        Circle().stroke(iconColor.opacity(0.2), lineWidth: 1)
                    )

                Image(systemName: icon)
                    .font(.system(size: 48))
                    .foregroundColor(iconColor)
            }

            VStack(spacing: 8) {
                Text(badge)
                    .font(.system(size: 11, weight: .black))
                    .foregroundColor(iconColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(iconColor.opacity(0.12))
                    .cornerRadius(6)

                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 28)
                    .lineSpacing(3)
            }

            Spacer()
        }
    }
}
