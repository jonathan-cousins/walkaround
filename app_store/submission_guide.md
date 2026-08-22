# Step-by-Step App Store Submission Guide for walkaround

This guide takes you from your local workspace directly to live on the Apple App Store.

---

### Step 1: Apple Developer Account Prerequisites
1. Enroll in the [Apple Developer Program](https://developer.apple.com/programs/) ($99/year).
2. Open [App Store Connect](https://appstoreconnect.apple.com/) and accept all Paid Applications / Financial agreements under **Agreements, Tax, and Banking**.

---

### Step 2: Create App Identifier & App Store Connect Listing
1. Go to **Apple Developer Portal** $\rightarrow$ **Certificates, Identifiers & Profiles** $\rightarrow$ **Identifiers**.
2. Click `+` and create a new **App ID**:
   * Description: `walkaround`
   * Bundle ID: `Explicit` $\rightarrow$ `com.walkaround.app` (or your preferred domain prefix).
   * Capabilities: Check **In-App Purchase**.
3. Go to **App Store Connect** $\rightarrow$ **My Apps** $\rightarrow$ Click `+` (New App):
   * Platforms: `iOS`
   * Name: `walkaround - Car Rental Defense`
   * Primary Language: `English (U.S.)`
   * Bundle ID: Select `com.walkaround.app`
   * SKU: `walkaround001`
   * User Access: `Full Access`

---

### Step 3: Configure In-App Purchases & Subscriptions
In App Store Connect under **Features $\rightarrow$ In-App Purchases / Subscriptions**:
1. **Single Rental Trip Pass**:
   * Type: `Non-Consumable`
   * Product ID: `com.walkaround.single_trip`
   * Price: `$2.99` (Tier 3)
2. **Annual Pro Pass**:
   * Create Subscription Group: `walkaround Pro Pass`
   * Type: `Auto-Renewable Subscription`
   * Product ID: `com.walkaround.annual_pro`
   * Duration: `1 Year`
   * Price: `$19.99` (Tier 20)

---

### Step 4: Archive & Upload Build from Xcode
1. Open the project in Xcode (`open /Users/jonathancousins/Documents/Software_Lab/projects/not_my_dent/ios/walkaroundApp.swift` or Xcode project).
2. Select target: `Any iOS Device (arm64)`.
3. In Xcode menu bar: **Product $\rightarrow$ Archive**.
4. Once archiving finishes, the **Xcode Organizer** window will appear.
5. Click **Distribute App** $\rightarrow$ Select **App Store Connect** $\rightarrow$ **Upload**.
6. Follow the prompts for automated signing certificates.

---

### Step 5: TestFlight Beta Testing
1. Within 10–15 minutes of upload, your build will appear in App Store Connect under the **TestFlight** tab.
2. Add yourself and your friends under **Internal Testing** to install and test the app on real iPhones immediately via the TestFlight app.

---

### Step 6: Submit for Review
1. In App Store Connect under the **App Store** tab:
   * Paste the Title, Subtitle, Description, and Keywords from `app_store/app_store_metadata.md`.
   * Add screenshots (6.7" iPhone and 6.5" iPhone sizes).
   * Link your Privacy Policy (`https://walkaround.app/privacy` or hosted markdown).
   * Select your uploaded build from TestFlight.
   * Add the Review Notes from `app_store_metadata.md`.
2. Click **Submit to App Review**.
3. Apple review typically takes **24 to 48 hours**. Once approved, your app will go live worldwide!
