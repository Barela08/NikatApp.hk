import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_colors.dart';
import '../constants/app_constants.dart';

class AppHelpers {
  AppHelpers._();

  // Format currency
  static String formatPrice(double price, {String symbol = '₹'}) {
    if (price >= 100000) return '$symbol${(price / 100000).toStringAsFixed(1)}L';
    if (price >= 1000) return '$symbol${(price / 1000).toStringAsFixed(1)}K';
    return '$symbol${price.toInt()}';
  }

  // Format date
  static String formatDate(DateTime date) => DateFormat('dd MMM yyyy').format(date);
  static String formatDateTime(DateTime date) => DateFormat('dd MMM, hh:mm a').format(date);
  static String formatTime(DateTime date) => DateFormat('hh:mm a').format(date);

  // Time ago
  static String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
    return formatDate(date);
  }

  // Launch phone call
  static Future<bool> callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
      return true;
    }
    return false;
  }

  // Launch WhatsApp
  static Future<bool> openWhatsApp(String phone, {String? message}) async {
    final msg = Uri.encodeComponent(message ?? AppConstants.whatsappDefaultMessage);
    final uri = Uri.parse('${AppConstants.whatsappUrl}$phone?text=$msg');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  // Launch Google Maps
  static Future<bool> openMaps(double lat, double lng, {String? label}) async {
    final query = label != null ? Uri.encodeComponent(label) : '$lat,$lng';
    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  // Open URL in browser
  static Future<bool> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  // Show snackbar
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : null,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // Show confirmation dialog
  static Future<bool> showConfirmDialog(
    BuildContext context, {
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message, style: const TextStyle(color: AppColors.onSurfaceMuted)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(cancelText)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: isDestructive ? AppColors.error : null),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Mask phone number
  static String maskPhone(String phone) {
    if (phone.length < 7) return phone;
    return '${phone.substring(0, 3)}****${phone.substring(phone.length - 3)}';
  }

  // Mask Aadhaar
  static String maskAadhaar(String aadhaar) {
    final digits = aadhaar.replaceAll(' ', '');
    if (digits.length != 12) return aadhaar;
    return 'XXXX XXXX ${digits.substring(8)}';
  }

  // Distance format
  static String formatDistance(double km) {
    if (km < 1) return '${(km * 1000).toInt()}m';
    return '${km.toStringAsFixed(1)}km';
  }

  // Color from hex
  static Color colorFromHex(String hex) {
    final h = hex.replaceAll('#', '');
    return Color(int.parse('FF$h', radix: 16));
  }
}
