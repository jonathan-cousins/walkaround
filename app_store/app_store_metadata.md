# App Store Metadata - Walkaround

## 1. App Store Product Page Info
* **App Name:** `Walkaround: Car Rental Proof` (29 chars)
* **Subtitle:** `30-Sec Photo Shield & Dispute` (30 chars)
* **Primary Category:** Travel
* **Secondary Category:** Utilities
* **Age Rating:** 4+ (No unmoderated user content, no gambling, no adult material)
* **Pricing & Availability:** Free with In-App Purchases (Single Trip Pass & Annual Pro)

---

## 2. Keywords (Max 100 Characters)
`car rental,hertz,enterprise,turo,damage inspection,car insurance,rental car claim,dent,scratch,claim`

---

## 3. Promotional Text (170 Characters Max - Can be updated without a new build)
`Never get blamed for pre-existing rental scratches again. Capture a 30-sec timestamped & GPS-verified walkaround and generate structured dispute reports in 1 tap.`

---

## 4. Full App Store Description

```markdown
Protect yourself from unfair rental car damage charges with Walkaround.

Did you know rental agencies (Hertz, Enterprise, Avis, Budget, Sixt, Turo) send thousands of unexpected damage bills to drivers weeks after returning a vehicle? In dim airport parking lots, it is easy to miss pre-existing scratches, windshield rock chips, or wheel curb rash.

Walkaround gives you a structured, timestamped evidence record in under 30 seconds before you drive off the lot.

WHY DRIVERS USE WALKAROUND:
• FAST 30-SECOND WALKAROUND: Follow smart ghost wireframes that guide you around 5 critical perimeter angles (front, sides, rear, wheels, and dashboard).
• TAMPER-EVIDENT METADATA STAMPS: Every photo is stamped with UTC time, local date, reverse-geocoded airport/lot location, and a cryptographic SHA-256 hash burned directly into the image pixels.
• DASHBOARD & ODOMETER VERIFICATION: Document your exact starting/ending mileage and fuel gauge level so you have proof of fuel return and odometer readings.
• 1-TAP DISPUTE REPORT (PDF): When an agency sends an unexpected charge, generate a structured, multi-page PDF comparison pack showing side-by-side Pick-up vs. Return photos.
• PRE-FORMATTED DISPUTE RESPONSE LETTERS: Automatically generate customized response templates addressed to rental damage recovery units, Turo support, or credit card collision coverage (Chase, Amex, Capital One).
• 100% OFFLINE-FIRST & PRIVATE: Works completely offline in concrete underground airport garages with zero cell reception. Your photos stay strictly on your device.

WHO IS WALKAROUND FOR?
- Vacationers & Business Travelers renting from major agencies
- Turo and Getaround guests & hosts
- Moving truck & van renters (U-Haul, Budget Truck, Penske)
- Anyone who wants peace of mind against unexpected credit card damage charges

Download Walkaround today and protect your wallet before you drive off the lot.
```

---

## 5. In-App Purchase Configuration for App Store Connect

| Reference Name | Product ID | Type | Price Tier |
| :--- | :--- | :--- | :--- |
| **Single Trip Pass** | `com.walkaround.single_trip` | Non-Consumable | Tier 3 ($2.99) |
| **Annual Pro Pass** | `com.walkaround.annual_pro` | Auto-Renewable Subscription | Tier 20 ($19.99/yr) |
| **Lifetime Unlimited** | `com.walkaround.lifetime` | Non-Consumable | Tier 40 ($39.99) |

---

## 6. App Review Notes (For Apple Review Team)
* **Demo Instructions:** The app is pre-loaded with a verified sample rental (2024 Ford Mustang GT at LAX Hertz Lot) with completed Pick-up and Return inspections.
* Tap **"Dispute Dossier (PDF)"** on the sample rental card to test instant multi-page PDF generation, side-by-side comparison slider, and legal letter export.
* Location and camera permissions can be granted or simulated using the Xcode simulator location presets.
