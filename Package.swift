// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Walkaround",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
        .macOS(.v14)
    ],
    products: [
        .library(
            name: "WalkaroundCore",
            targets: ["WalkaroundCore"]
        ),
        .executable(
            name: "test-runner",
            targets: ["test-runner"]
        )
    ],
    targets: [
        .target(
            name: "WalkaroundCore",
            path: "ios",
            exclude: [
                "App/Info.plist",
                "App/PrivacyInfo.xcprivacy",
                "App/Assets.xcassets",
                "App/WalkaroundApp.swift"
            ],
            sources: [
                "Models",
                "Services",
                "Components",
                "Views"
            ]
        ),
        .executableTarget(
            name: "test-runner",
            dependencies: ["WalkaroundCore"],
            path: "tests"
        )
    ]
)
