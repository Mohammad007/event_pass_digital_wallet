# 🎟️ EventPass - Next-Gen Decentralized Event Wallet

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SpruceKit](https://img.shields.io/badge/SSI-SpruceKit-orange?style=for-the-badge)
![Security](https://img.shields.io/badge/Security-Biometric-green?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-blue?style=for-the-badge)

## 🚀 Overview

**EventPass** is a production-grade, decentralized mobile application designed to revolutionize the event ticketing industry. Built with **Flutter** and **Self-Sovereign Identity (SSI)** technology, it solves the critical problems of ticket fraud, scalping, and data privacy.

Unlike traditional ticketing apps that rely on centralized databases, EventPass issues tickets as **W3C Verifiable Credentials (VCs)** anchored by **Decentralized Identifiers (DIDs)**. This ensures that every ticket is cryptographically secure, unforgeable, and fully owned by the user.

## 🌟 Why Use EventPass? (Benefits)

Traditional ticketing is broken. EventPass fixes it:

*   **🛡️ Eliminate Fraud:** Fake tickets are mathematically impossible. Every ticket is a signed credential from the organizer's DID.
*   **🚫 Stop Scalping:** Tickets are bound to the user's identity (DID). Transfers can be controlled, tracked, or restricted by smart policies.
*   **🔒 Absolute Privacy:** Your data stays on your device. You share only what is needed (Zero-Knowledge Proof capabilities).
*   **📡 Offline First:** Verification happens instantly on-device. No internet required at the venue gate, ensuring 100% uptime.
*   **⚡ Frictionless Entry:** Dynamic QR codes prevent screen-shotting and allow entry in milliseconds.

## 📱 Key Features

### 👤 For Attendees (The Wallet)
*   **Secure Storage:** Military-grade encryption (Secure Enclave) for your digital ID and passes.
*   **Biometric Access:** Login with FaceID or Fingerprint for seamless security.
*   **Smart Wallet:** View upcoming, past, and active passes in a beautiful UI.
*   **Dynamic QRs:** Anti-cloning QR codes that refresh automatically every 30 seconds.

### 🏢 For Organizers (The Issuer)
*   **Issue VCs:** Create tamper-proof digital tickets instantly.
*   **Dashboard:** Manage events and track issuance stats.
*   **Direct Issuance:** Issue tickets directly to user DIDs via QR exchange.

### 🔍 For Verifiers (The Gatekeeper)
*   **Instant Verification:** Scan QRs to verify cryptographic signatures.
*   **Offline Mode:** Verify tickets without server connectivity.
*   **Fraud Detection:** Validates expiration, revocation, and issuer authenticity.

## 🛠️ Technology Stack

This project leverages the latest in mobile and identity tech:

*   **Frontend Framework:** [Flutter](https://flutter.dev) (Dart) - for beautiful, native performance on iOS & Android.
*   **Identity Layer:** SpruceKit (SSIKit) & Custom DID Implementation - for managing DIDs and Verifiable Credentials.
*   **State Management:** `Provider` - for efficient and scalable state handling.
*   **Local Storage:** `flutter_secure_storage` & `shared_preferences` - for encrypted key management.
*   **Biometrics:** `local_auth` - for secure device authentication.
*   **Scanning:** `mobile_scanner` / `qr_code_scanner` - for high-speed QR code processing.

## 🚀 Installation & Setup

Follow these steps to get the app running locally:

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.10+)
*   VS Code or Android Studio
*   Android Emulator or Physical Device

### Steps

1.  **Clone the Repository**
    ```bash
    git clone https://github.com/yourusername/eventpass-wallet.git
    cd wallet_digital
    ```

2.  **Install Dependencies**
    ```bash
    flutter pub get
    ```

3.  **Run the App**
    ```bash
    flutter run
    ```
    *Note: For best performance, run on a physical device in Profile/Release mode.*

### Platform Specifics

**Android:**
*   Requires `minSdkVersion 21` (configured in `build.gradle`).
*   Biometric permissions added to `AndroidManifest.xml`.

**iOS:**
*   Requires `NSFaceIDUsageDescription` and `NSCameraUsageDescription` in `Info.plist`.

## 📂 Project Structure

We follow a clean, feature-driven architecture:

```
lib/
├── core/
│   ├── constants/       # App colors, strings, styles
│   └── theme/           # Theme configuration
├── models/              # Data models (EventPass, UserProfile, Wallet)
├── providers/           # State management logic (AppProvider)
├── services/            # Business logic (Wallet, SpruceKit, Biometrics)
├── screens/
│   ├── splash/          # App initialization
│   ├── onboarding/      # Intro screens
│   ├── wallet_setup/    # DID creation & PIN setup
│   ├── home/            # Attendee Dashboard
│   ├── organizer_dashboard/ # Issuer Dashboard
│   ├── verifier_dashboard/  # Scanner Dashboard
│   └── profile/         # User Profile & Settings
└── main.dart            # Entry point
```

## 🤝 Contributing

We welcome contributions! Please fork the repository and submit a Pull Request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.

---
**EventPass** - *Trust The Ticket, Not The Scalper.*
Built with ❤️ using Flutter and SSI Technology.
