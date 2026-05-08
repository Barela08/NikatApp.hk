# NIKAT Flutter App 🇮🇳

**Har Dukaan, Har Service – Ek Jagah**

A hyperlocal platform connecting users with nearby shops and services across India. Available for both Android and iOS.

---

## 📱 Features

- **12 Language Support** — English, Hindi, Gujarati, Marathi, Tamil, Telugu, Bengali, Punjabi, Kannada, Malayalam, Odia, Assamese
- **16 Service Categories** — Electrician, Plumber, Salon, Grocery, Restaurant, and more
- **Real-time Location** — Find shops within a configurable radius
- **OTP Login** — Firebase Phone Authentication
- **Provider Discovery** — Browse KYC-verified providers sorted by distance
- **Contact Gating** — Freemium model with subscription-based contact unlock
- **WhatsApp & Direct Call** — One-tap communication
- **Real-time Chat** — In-app messaging with Firestore
- **Order Management** — Book, track, and review services
- **Razorpay Payments** — Integrated payment gateway
- **Provider Dashboard** — Analytics, order management, online/offline toggle
- **Admin Panel** — Full CRUD for users, providers, orders
- **Push Notifications** — Firebase Cloud Messaging + local notifications
- **Dark Neon Theme** — Material 3 with #00FF88 accent on pure black

---

## 🏗️ Architecture

```
lib/
├── main.dart                    # Entry point, Firebase init
├── app.dart                     # MaterialApp.router with theming & l10n
├── firebase_options.dart        # Firebase config (replace with yours)
├── core/
│   ├── constants/
│   │   ├── app_colors.dart      # Color palette & gradients
│   │   ├── app_constants.dart   # All constants, categories, languages
│   │   └── app_theme.dart       # Material 3 dark theme
│   ├── router/
│   │   └── app_router.dart      # GoRouter with auth guards
│   └── l10n/                    # ARB localization files
│       ├── app_en.arb
│       ├── app_hi.arb
│       └── ... (12 total)
├── models/
│   ├── user_model.dart
│   ├── provider_model.dart
│   ├── order_model.dart
│   └── review_model.dart
├── services/
│   ├── auth_service.dart
│   ├── provider_service.dart
│   └── notification_service.dart
├── providers/                   # Riverpod state management
│   ├── auth_provider.dart
│   ├── locale_provider.dart
│   ├── providers_provider.dart
│   └── location_provider.dart
├── screens/
│   ├── splash/
│   ├── language_select/
│   ├── onboarding/
│   ├── auth/                    # Login, OTP, Register, RoleSelect
│   ├── home/                    # Home + MainShell (bottom nav)
│   ├── search/
│   ├── provider_listing/
│   ├── provider_detail/
│   ├── subscription/            # Razorpay-integrated
│   ├── orders/                  # Orders list + Order detail
│   ├── chat/                    # Real-time Firestore chat
│   ├── profile/
│   ├── provider_dashboard/      # Dashboard + Add Store
│   └── admin/                   # Admin panel with tabs
└── widgets/
    ├── provider_card.dart
    ├── category_chip.dart
    ├── banner_slider.dart
    └── nikat_logo.dart
```

---

## 🚀 Setup Instructions

### Prerequisites
- Flutter SDK 3.16+ — [Install Flutter](https://flutter.dev/docs/get-started/install)
- Dart SDK 3.2+
- Android Studio / Xcode
- Firebase account
- Google Maps API key
- Razorpay account (test key for development)

### Step 1 — Clone & Install
```bash
# Open in your editor
cd nikat_flutter

# Install dependencies
flutter pub get
```

### Step 2 — Firebase Setup
1. Go to [Firebase Console](https://console.firebase.google.com)
2. Create a new project called `nikat-app`
3. Enable **Phone Authentication**
4. Enable **Cloud Firestore** (Start in production mode)
5. Enable **Firebase Storage**
6. Enable **Firebase Cloud Messaging**
7. Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```
8. Configure Firebase:
   ```bash
   flutterfire configure --project=your-firebase-project-id
   ```
   This replaces `lib/firebase_options.dart` with real values.

9. Download and place config files:
   - **Android**: `google-services.json` → `android/app/google-services.json`
   - **iOS**: `GoogleService-Info.plist` → `ios/Runner/GoogleService-Info.plist`

### Step 3 — API Keys
Replace placeholder API keys in these files:

| File | Key to Replace |
|------|---------------|
| `android/app/build.gradle` | `YOUR_GOOGLE_MAPS_API_KEY` |
| `ios/Runner/AppDelegate.swift` | `YOUR_GOOGLE_MAPS_IOS_API_KEY` |
| `ios/Runner/Info.plist` | `YOUR_GOOGLE_MAPS_IOS_API_KEY` |
| `lib/core/constants/app_constants.dart` | `rzp_test_YOUR_KEY_HERE` |

### Step 4 — Firestore Rules
Deploy the included security rules:
```bash
firebase deploy --only firestore:rules
```

### Step 5 — Run the App
```bash
# Android
flutter run

# iOS (requires Mac + Xcode)
cd ios && pod install && cd ..
flutter run

# Release build
flutter build apk --release          # Android
flutter build ipa --release           # iOS
```

---

## 💳 Razorpay Setup
1. Sign up at [razorpay.com](https://razorpay.com)
2. Get your test key from Dashboard → API Keys
3. Replace `rzp_test_YOUR_KEY_HERE` in `app_constants.dart`
4. For production: replace with `rzp_live_` key

---

## 🌍 Adding More Languages
1. Create `lib/l10n/app_XX.arb` (where XX is language code)
2. Add the language to `AppConstants.supportedLanguages`
3. Run: `flutter gen-l10n`

---

## 📦 Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | State management |
| `go_router` | Navigation |
| `firebase_*` | Backend (Auth, Firestore, Storage, FCM) |
| `firebase_crashlytics` | Crash reporting |
| `google_maps_flutter` | Maps |
| `geolocator` | GPS location |
| `razorpay_flutter` | Payments |
| `flutter_animate` | Animations |
| `pinput` | OTP input |
| `cached_network_image` | Image caching |
| `dio` | HTTP client |
| `hive_flutter` | Local storage |
| `shared_preferences` | Preferences |
| `flutter_local_notifications` | Local push notifications |
| `lottie` | Lottie animations |
| `fl_chart` | Charts (admin analytics) |

---

## 🎨 Design System

- **Background**: `#000000` (pure black)
- **Primary**: `#00FF88` (neon green)
- **Surface**: `#111111`
- **Font**: Inter (400, 500, 600, 700, 800)
- **Corner Radius**: 12px-20px
- **Theme**: Material 3 dark

---

## 📋 Firestore Collections

| Collection | Description |
|-----------|-------------|
| `users` | Customer & provider profiles |
| `providers` | Shop listings with location |
| `orders` | Service bookings |
| `subscriptions` | Premium plan subscriptions |
| `reviews` | Provider reviews |
| `chats` | Chat rooms |
| `messages` | Chat messages (subcollection) |
| `notifications` | Push notification history |
| `kyc` | KYC documents |
| `payments` | Payment records |
| `categories` | Service categories |
| `analytics` | Business analytics |

---

## 🔒 Security

- All routes protected with auth guards (GoRouter redirect)
- Firestore security rules enforce data access control
- OTP-based authentication (no passwords)
- Phone number obfuscation in UI
- KYC verification before provider listing goes live
- Contact gating requires subscription (Freemium)

---

## 🏢 Business Model

| Tier | Price | Features |
|------|-------|---------|
| Free | ₹0 | 3 contact views, browse all listings |
| Basic | ₹49/mo | Unlimited contacts, direct calls |
| Pro | ₹99/mo | Everything + priority support |
| Premium | ₹199/mo | Everything + business tools |
| Annual | ₹399/yr | Everything + 3 months free |

---

## 📞 Support

Built by **HackifyPro**  
For support: support@nikat.app

---

## 📄 License

MIT License — See LICENSE file
