class AppConstants {
  AppConstants._();

  static const String appName = 'NIKAT';
  static const String appTagline = 'Har Dukaan, Har Service – Ek Jagah';
  static const String appVersion = '1.0.0';

  // Firebase Collections
  static const String usersCollection = 'users';
  static const String providersCollection = 'providers';
  static const String ordersCollection = 'orders';
  static const String subscriptionsCollection = 'subscriptions';
  static const String categoriesCollection = 'categories';
  static const String reviewsCollection = 'reviews';
  static const String notificationsCollection = 'notifications';
  static const String kycCollection = 'kyc';
  static const String paymentsCollection = 'payments';
  static const String chatsCollection = 'chats';
  static const String messagesCollection = 'messages';
  static const String analyticsCollection = 'analytics';

  // SharedPreferences Keys
  static const String keyLanguage = 'selected_language';
  static const String keyOnboardingDone = 'onboarding_done';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keyAuthToken = 'auth_token';
  static const String keyTheme = 'app_theme';

  // User Roles
  static const String roleCustomer = 'customer';
  static const String roleProvider = 'provider';
  static const String roleAdmin = 'admin';

  // Order Status
  static const String orderPending = 'pending';
  static const String orderConfirmed = 'confirmed';
  static const String orderOnTheWay = 'on_the_way';
  static const String orderDelivered = 'delivered';
  static const String orderCancelled = 'cancelled';

  // Subscription Plans
  static const String planFree = 'free';
  static const String planBasic = 'basic';
  static const String planPro = 'pro';
  static const String planPremium = 'premium';

  // Default Location (New Delhi)
  static const double defaultLat = 28.6139;
  static const double defaultLng = 77.2090;
  static const double defaultRadius = 10.0;

  // WhatsApp Base URL
  static const String whatsappUrl = 'https://wa.me/';
  static const String whatsappDefaultMessage = 'Hi, I found your shop on NIKAT app. I need your service.';

  // Animation Durations
  static const Duration splashDuration = Duration(seconds: 3);
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationNormal = Duration(milliseconds: 350);
  static const Duration animationSlow = Duration(milliseconds: 600);

  // Pagination
  static const int pageSize = 20;
  static const int chatPageSize = 30;

  // Image Sizes
  static const int profileImageSize = 512;
  static const int shopImageSize = 1024;
  static const int thumbnailSize = 256;

  // Razorpay Key (replace with actual key)
  static const String razorpayKey = 'rzp_test_YOUR_KEY_HERE';

  // Subscription Prices (in paise for Razorpay)
  static const Map<String, int> subscriptionPrices = {
    'basic': 4900,
    'pro': 9900,
    'premium': 19900,
    'annual': 39900,
  };

  // Supported Languages
  static const List<Map<String, String>> supportedLanguages = [
    {'code': 'en', 'name': 'English', 'nativeName': 'English', 'flag': '🇬🇧'},
    {'code': 'hi', 'name': 'Hindi', 'nativeName': 'हिंदी', 'flag': '🇮🇳'},
    {'code': 'gu', 'name': 'Gujarati', 'nativeName': 'ગુજરાતી', 'flag': '🇮🇳'},
    {'code': 'mr', 'name': 'Marathi', 'nativeName': 'मराठी', 'flag': '🇮🇳'},
    {'code': 'ta', 'name': 'Tamil', 'nativeName': 'தமிழ்', 'flag': '🇮🇳'},
    {'code': 'te', 'name': 'Telugu', 'nativeName': 'తెలుగు', 'flag': '🇮🇳'},
    {'code': 'bn', 'name': 'Bengali', 'nativeName': 'বাংলা', 'flag': '🇮🇳'},
    {'code': 'pa', 'name': 'Punjabi', 'nativeName': 'ਪੰਜਾਬੀ', 'flag': '🇮🇳'},
    {'code': 'kn', 'name': 'Kannada', 'nativeName': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
    {'code': 'ml', 'name': 'Malayalam', 'nativeName': 'മലയാളം', 'flag': '🇮🇳'},
    {'code': 'or', 'name': 'Odia', 'nativeName': 'ଓଡ଼ିଆ', 'flag': '🇮🇳'},
    {'code': 'as', 'name': 'Assamese', 'nativeName': 'অসমীয়া', 'flag': '🇮🇳'},
  ];

  // Service Categories
  static const List<Map<String, dynamic>> categories = [
    {'id': 'electrician', 'name': 'Electrician', 'icon': '⚡', 'color': 0xFFFFB800},
    {'id': 'plumber', 'name': 'Plumber', 'icon': '🔧', 'color': 0xFF4FC3F7},
    {'id': 'carpenter', 'name': 'Carpenter', 'icon': '🪚', 'color': 0xFF8D6E63},
    {'id': 'ac_repair', 'name': 'AC Repair', 'icon': '❄️', 'color': 0xFF80DEEA},
    {'id': 'medical', 'name': 'Medical', 'icon': '🏥', 'color': 0xFFEF5350},
    {'id': 'salon', 'name': 'Salon', 'icon': '💇', 'color': 0xFFCE93D8},
    {'id': 'grocery', 'name': 'Grocery', 'icon': '🛒', 'color': 0xFF81C784},
    {'id': 'restaurant', 'name': 'Restaurant', 'icon': '🍛', 'color': 0xFFFFB74D},
    {'id': 'laundry', 'name': 'Laundry', 'icon': '👕', 'color': 0xFF4DD0E1},
    {'id': 'tutor', 'name': 'Tutor', 'icon': '📚', 'color': 0xFF9575CD},
    {'id': 'auto_repair', 'name': 'Auto Repair', 'icon': '🚗', 'color': 0xFF78909C},
    {'id': 'painter', 'name': 'Painter', 'icon': '🎨', 'color': 0xFFF48FB1},
    {'id': 'packers', 'name': 'Packers & Movers', 'icon': '📦', 'color': 0xFFFFCC02},
    {'id': 'events', 'name': 'Events', 'icon': '🎉', 'color': 0xFFE91E63},
    {'id': 'cleaning', 'name': 'Cleaning', 'icon': '🧹', 'color': 0xFF26A69A},
    {'id': 'more', 'name': 'More', 'icon': '⋯', 'color': 0xFF607D8B},
  ];
}
