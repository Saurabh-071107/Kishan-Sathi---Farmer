# Kishan-Sathi — Farmer App 🌾

A Flutter application empowering farmers to sell their agricultural produce directly to warehouses, track live mandi rates, manage harvest batches, and monitor real-time orders and wallet earnings.

---

## 🚀 Key Features

- **Direct Warehouse Sales:** Create crop sale listings with grade, quantity, expected price, and instant warehouse inspection requests.
- **Live Mandi Rates:** Real-time commodity tracking across major APMC markets with daily trend analysis.
- **Harvest & Inventory Tracking:** Manage active crop inventory with categorized storage and status tracking.
- **Quality Inspection Reports:** Detailed moisture, purity, grain size, and quality grading reports with verification badges.
- **Multilingual Support:** Localized interface in English, Hindi, Punjabi, Marathi, Telugu, Tamil, and other regional languages.
- **Digital Wallet & Secure Settlements:** Direct bank transfer tracking, instant UPI payouts, and detailed sales invoice summaries.
- **Farmer & FPO Authentication:** Streamlined phone OTP registration, Aadhaar/Kishan Card KYC verification, and biometric login.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev) (Dart)
- **State Management & DI:** Provider
- **Design System:** Material Design 3 with custom agricultural color palette, glassmorphic cards, and smooth micro-animations.
- **Hardware Integration:** Local authentication (Biometrics), camera, image picker, battery & network info.

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/       # App assets, colors, and styling tokens
│   ├── models/          # User profile and role domain models
│   ├── providers/       # Language and theme state management
│   ├── services/        # Biometrics, Auth, and Device hardware services
│   ├── theme/           # Light & Dark theme definitions
│   └── widgets/         # Reusable animations, counters, and scroll reveals
├── features/
│   ├── auth/            # Farmer & FPO onboarding, registration, login
│   ├── dashboard/       # Core dashboard container
│   ├── home/            # Home screen, live rates, advisories, statistics
│   ├── marketplace/     # Add crop, orders, warehouse sales & inspections
│   ├── navigation/      # Floating navigation bar & routing
│   ├── notifications/   # Alerts and advisory notifications
│   ├── profile/         # Farmer profile, KYC details, wallet & transactions
│   └── reports/         # Sales and harvest performance reports
└── main.dart            # Application entry point
```

---

## 📦 Getting Started

### Prerequisites

- Flutter SDK (v3.0.0 or higher)
- Android Studio / VS Code with Flutter extension
- An active Android/iOS emulator or connected physical device

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/Saurabh-071107/Kishan-Sathi---Farmer.git
   cd Kishan-Sathi---Farmer
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the application:**
   ```bash
   flutter run
   ```

---

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
