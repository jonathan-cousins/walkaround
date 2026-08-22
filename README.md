# Walkaround - 30-Second Car Rental Proof & Dispute Pack

> **"Never get blamed for pre-existing rental car scratches again."**

**Walkaround** is a cross-platform (Native iOS, Native Android & Web Companion) application engineered to protect car, moving truck, and peer-to-peer (Turo/Getaround) renters from fraudulent or pre-existing damage penalties ($400–$1,500+). In under 30 seconds before driving off the lot, it guides drivers through a rapid 5-angle photo inspection with cryptographic UTC timestamps, reverse-geocoded GPS coordinates, and 1-tap PDF dispute dossiers.

---

## 🚗 Key Capabilities

1. **Fast 30-Second Walkaround (5 Key Perimeter Shots)**:
   - Front Bumper & Hood, Driver Side & Wheels, Rear Bumper & Trunk, Passenger Side & Wheels, and Dashboard (Odometer & Fuel).
2. **Tamper-Evident HUD Stamps & Cryptographic Hashes**:
   - Burns UTC timestamp, local date, GPS coordinates, vehicle registration, and a pixel-level SHA-256 hash directly into the photo metadata.
3. **Dashboard & Odometer Certification**:
   - Verified starting/ending mileage and fuel gauge level to stop bogus "$9.99/gal missing fuel" fees.
4. **Certified Dispute Dossier & Legal Rebuttal Letter (PDF)**:
   - Multi-page vector PDF combining photographic matrices, GPS audit logs, and pre-written dispute letters for Hertz, Enterprise, Avis, Sixt, Turo, or credit card CDW benefits (Chase Sapphire, Amex Platinum, Capital One Venture).
5. **100% Offline-First & Privacy Guaranteed**:
   - Operates completely without network connectivity in underground airport concrete garages. Data remains strictly on-device.

---

## 📁 Repository Structure

```text
walkaround/
├── README.md                          # Main project guide
├── Walkaround.xcodeproj               # Native iOS Xcode Project
├── Package.swift                      # Swift Package Manager manifest
├── ios/                               # Native iOS SwiftUI Application
│   ├── App/                           # App main entrypoint, Info.plist, Privacy
│   ├── Models/                        # Rental, Inspection, Zone, Damage models
│   ├── Services/                      # CameraCapture, Watermark, PDF, StoreKit 2
│   ├── Views/                         # SwiftUI Views (Home, Camera, Dispute, Paywall)
│   └── Components/                    # Wireframe ghost overlays, HUD badges, pills
├── android/                           # Native Android Application (Kotlin + Jetpack Compose)
│   ├── app/src/main/                  # AndroidManifest, Kotlin sources, resources
│   ├── build.gradle.kts               # Modern Gradle configuration
│   └── gradle/libs.versions.toml      # Dependency catalog (CameraX, Compose, Play Services)
├── web/                               # Standalone Web / PWA Companion
│   ├── index.html                     # Responsive simulator
│   ├── app.js                         # In-browser jsPDF engine & inspection flow
│   └── style.css                      # Modern light porcelain design system
├── tests/                             # Automated test suite
│   └── main.swift                     # Fast CLI test runner
└── app_store/                         # App Store & Google Play Submission Assets
    ├── app_store_metadata.md          # Title, subtitle, keywords, pricing tiers
    ├── privacy_policy.md              # Privacy policy
    ├── terms_of_service.md            # Terms of service (EULA)
    └── submission_guide.md            # App Store Connect upload guide
```

---

## 🛠️ Building & Running

### 📱 iOS (Xcode)
1. Open `Walkaround.xcodeproj` in **Xcode**.
2. Select any iPhone simulator or connected device.
3. Press `⌘ + R` to run.
4. Run automated test suite: `swift run test-runner`.

### 🤖 Android (Android Studio)
1. Open the `android/` directory in **Android Studio**.
2. Sync Gradle dependencies.
3. Press `Control + R` (or `Shift + F10`) to run on an emulator or physical device.

### 🌐 Web Companion
1. Open `web/index.html` in Google Chrome or any modern browser.

---

## 📄 License & Legal Notice
Walkaround is a photo evidence documentation utility. It does not provide legal representation.
