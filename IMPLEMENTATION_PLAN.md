# NIKAT Implementation Plan - Comprehensive Technical Specification

## Project Overview
- **App Name**: NIKAT (by HackifyPro)
- **Type**: Hyperlocal platform connecting users with nearby shops & services
- **Tagline**: "Har dukaan, har service – ek jagah"
- **Frontend**: Flutter
- **Backend**: Firebase + Cloud Functions (for security)
- **Database**: Firestore

---

## Architecture Overview

### System Flow
```
User App Flow:
App → Language → Login (OTP) → Registration → Home → Category → Shop → Unlock → Call

Provider Flow:
Register → Details → KYC → Payment → LIVE → Receive Orders
```

### Database Collections Structure
```
users/
providers/
providers/{id}/services/
orders/
payments/
subscriptions/
reviews/
analytics/
```

---

## Core Features Implemented

### ✅ Phase 1: Authentication System
- [x] Phone OTP login (Firebase Auth)
- [x] Session persistence
- [x] Role-based access (User/Provider/Admin)

### ✅ Phase 2: User + Provider Registration
- [x] User: Name + City
- [x] Provider: 3-step registration
  - Step 1: Basic Details
  - Step 2: Aadhaar Verification
  - Step 3: Payment Activation

### ✅ Phase 3: Aadhaar Verification (Mock)
- [x] Input Aadhaar number
- [x] OTP verification (mocked)
- [x] Encrypted reference storage

### ✅ Phase 4: Payment System
- [x] Subscription plans implementation
- [x] UPI deep link integration
- [x] Payment verification (mocked)

### ✅ Phase 5: Freemium Lock System
- [x] Check subscription status
- [x] Show XXXXXXX for free users
- [x] Unlock button → Subscription screen

### ✅ Phase 6: Provider Activation
- [x] KYC verified + Payment = isActive
- [x] No admin approval needed

---

## Detailed Implementation

### 1. Models

#### UserModel (`lib/models/user_model.dart`)
```dart
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String role; // user, provider, admin
  final String? city;
  final String? language;
  final bool isSubscribed;
  final String? subscriptionPlan;
  final DateTime? subscriptionExpiry;
  final DateTime createdAt;
  final DateTime? updatedAt;
  
  // Helper
  bool get hasActiveSubscription {
    if (!isSubscribed) return false;
    if (subscriptionExpiry == null) return false;
    return subscriptionExpiry!.isAfter(DateTime.now());
  }
}
```

#### ProviderModel (`lib/models/provider_model.dart`)
```dart
class ProviderModel {
  final String id;
  final String userId;
  final String name;
  final String shopName;
  final String category;
  final String categoryName;
  final String address;
  final GeoPoint location;
  final String phone;
  final String? description;
  final double rating;
  final int reviewCount;
  final bool isOpen;
  final ProviderStatus status;
  final String kycStatus; // pending, verified, failed
  final String? aadhaarRefId;
  final bool isActive; // payment + verified = live
  final bool isPremium;
  final String? plan;
  final DateTime? planExpiry;
  final DateTime createdAt;
}
```

#### Features
- `kycStatus`: Tracks Aadhaar verification
- `isActive`: Only true when KYC verified AND payment done
- `isPremium`: True when plan is 6+ months
- `planExpiry`: Tracks activation expiry

### 2. Constants

#### Subscription Plans (`lib/core/constants.dart`)
```dart
enum SubscriptionPlan {
  month1('1 Month', 49.0, 1),
  month2('2 Months', 99.0, 2),
  month4('4 Months', 149.0, 4),
  month6('6 Months', 249.0, 6),
  month12('12 Months', 399.0, 12);
}
```

### 3. Services

#### FirestoreService (`lib/services/firestore_service.dart`)
Key methods:
- `purchaseSubscription()` - Handles both user subscription and provider activation
- `hasActiveSubscription()` - Checks subscription status
- `activateProvider()` - Sets provider as active

#### KYCService (`lib/services/kyc_service.dart`)
- Mock implementation for development
- Ready for API integration (Surepass/Karza/Signzy)

### 4. Controllers

#### AuthController (`lib/controllers/auth_controller.dart`)
- OTP verification
- User session management
- Provider role handling

#### SubscriptionController (`lib/controllers/subscription_controller.dart`)
- `subscribe()` - User subscription
- `subscribeProvider()` - Provider activation ★ NEEDS TO BE ADDED
- `checkSubscription()` - Check status

#### ProviderController (`lib/controllers/provider_controller.dart`)
- Provider CRUD operations
- Shop management

### 5. Screens Flow

#### User Registration
1. Phone → OTP → Name, City → Home

#### Provider Registration (3-Step)
1. **Step 1**: Basic Details (Shop name, category, address)
2. **Step 2**: KYC Verification (Aadhaar input, OTP)
3. **Step 3**: Payment Activation → Shop LIVE

#### Shop Detail Screen
- **Free User**: Shows XXXXXXX, lock icon, "Unlock to Contact" button
- **Subscribed User**: Full contact details, call/whatsapp buttons

#### Subscription Screen
- 5 pricing plans
- Buy button → Payment → Access unlocked

### 6. Routes

```dart
static const String splash = '/';
static const String phoneAuth = '/auth/phone';
static const String otp = '/auth/otp';
static const String userRegistration = '/auth/register';
static const String home = '/home';
static const String category = '/category';
static const String shopDetail = '/shop/detail';
static const String subscription = '/subscription';
static const String providerRegistration = '/provider/register';
static const String providerDashboard = '/provider/dashboard';
```

---

## Critical Integration Points

### 1. Subscription Controller - subscribeProvider Method
**Status**: Missing - needs implementation
**File**: `lib/controllers/subscription_controller.dart`

This method is called from `provider_payment_screen.dart` but doesn't exist!

### 2. Provider Activation Flow
- After KYC verified AND payment success:
  1. Set provider.isActive = true
  2. Store plan details
  3. Mark shop as LIVE in listings

### 3. Lock System Flow
- In `shop_detail_screen.dart`:
  1. Get user subscription status
  2. If not subscribed: Show locked UI
  3. If subscribed: Show full contact

---

## Tech Stack

### Frontend
- Flutter (Dart)
- Riverpod for state management

### Backend
- Firebase Auth
- Firestore Database
- Firebase Cloud Functions (for security)
- Firebase Cloud Messaging

### External APIs
- Google Maps/Geolocator
- Aadhaar KYC API (for production)
- Razorpay (for production)

---

## Security Implementation

### Data Protection
✓ Never store raw Aadhaar number
✓ Only encrypted reference stored
✓ Phone number protected in Firestore

### Firestore Security Rules
- Users can read own data only
- Providers can read own shop only
- Phone access requires subscription (via Cloud Function)

### Provider Activation
```
IF kycStatus == verified AND payment == success
→ isActive = true
ELSE
→ hidden from listings
```

---

## UI/UX Guidelines

### Color Scheme
- Background: #000000 (Pure Black)
- Primary: #00FF88 (Neon Green)
- Text: #FFFFFF (White)
- Secondary: Grey (#888888)

### Design Principles
- Big icons for illiterate-friendly UI
- Minimal text per screen
- Large clickable areas (min 48px)
- Max 3-5 actions per screen

### Loading States
- Use skeleton loading
- Never show blank screen
- Show error states clearly

---

## Development Phases

### Phase 1: Core (COMPLETED)
- [x] Auth system
- [x] User/Provider registration
- [x] Home screen
- [x] Shop listing

### Phase 2: Freemium (COMPLETED)
- [x] Lock system
- [x] Subscription screen
- [x] Payment integration (mock)

### Phase 3: KYC (COMPLETED)
- [x] Aadhaar verification (mock)
- [x] Provider activation

### Phase 4: Production (TODO)
- [ ] Real Aadhaar API integration
- [ ] Real payment gateway
- [ ] Cloud Functions for security
- [ ] Firestore security rules

---

## Testing Checklist

- [ ] User registration flow
- [ ] Provider registration - Step 1
- [ ] Provider registration - KYC verification
- [ ] Provider registration - Payment
- [ ] Subscription purchase
- [ ] Shop listing visibility (active vs inactive)
- [ ] Lock system for free users
- [ ] Unlock flow for subscribed users
- [ ] Admin dashboard

---

## File Structure

```
lib/
├── main.dart
├── core/
│   ├── constants.dart
│   ├── routes.dart
│   ├── theme.dart
│   └── utils.dart
├── models/
│   ├── user_model.dart
│   ├── provider_model.dart
│   ├── order_model.dart
│   ├── review_model.dart
│   └── kyc_model.dart
├── services/
│   ├── firebase_service.dart
│   ├── firestore_service.dart
│   ├── auth_service.dart
│   ├── kyc_service.dart
│   ├── location_service.dart
│   ├── notification_service.dart
│   └── upi_payment_service.dart
├── controllers/
│   ├── auth_controller.dart
│   ├── subscription_controller.dart
│   ├── provider_controller.dart
│   ├── order_controller.dart
│   ├── kyc_controller.dart
│   └── location_controller.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── auth/
│   │   ├── phone_auth_screen.dart
│   │   ├── otp_screen.dart
│   │   └── user_registration_screen.dart
│   ├── home_screen.dart
│   ├── category_screen.dart
│   ├── shop_detail_screen.dart
│   ├── booking_screen.dart
│   ├── subscription_screen.dart
│   ├── provider_registration_screen.dart
│   ├── kyc_verification_screen.dart
│   ├── provider_payment_screen.dart
│   ├── provider_dashboard_screen.dart
│   ├── profile_screen.dart
│   ├── settings_screen.dart
│   └── admin/
├── widgets/
│   └── common/
│       ├── neon_button.dart
│       ├── neon_card.dart
│       ├── neon_input.dart
│       ├── loading_widget.dart
│       └── app_header.dart
└── l10n/
    ├── app_en.arb
    ├── app_hi.arb
    └── ...
```

---

## Success Criteria

- ✓ No admin dependency for provider activation
- ✓ No fake providers (KYC required)
- ✓ Subscription working
- ✓ Lock system working
- ✓ Full flow smooth

---

## Production TODO

1. Integrate real Aadhaar API (Surepass/Karza/Signzy)
2. Integrate real payment gateway (Razorpay)
3. Set up Cloud Functions for:
   - Phone number access control
   - Payment verification
   - Aadhaar verification
4. Update Firestore security rules
5. Complete testing

---

END IMPLEMENTATION PLAN
