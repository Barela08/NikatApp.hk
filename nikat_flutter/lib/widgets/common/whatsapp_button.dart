import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/helpers.dart';

class WhatsAppButton extends StatelessWidget {
  const WhatsAppButton({
    super.key,
    required this.phone,
    this.message,
    this.label = 'WhatsApp',
    this.compact = false,
  });

  final String phone;
  final String? message;
  final String label;
  final bool compact;

  Future<void> _launch(BuildContext context) async {
    final success = await AppHelpers.openWhatsApp(phone, message: message);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('WhatsApp not installed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        onPressed: () => _launch(context),
        icon: const Text('💬', style: TextStyle(fontSize: 22)),
        tooltip: 'WhatsApp',
      );
    }

    return ElevatedButton.icon(
      onPressed: () => _launch(context),
      icon: const Text('💬', style: TextStyle(fontSize: 18)),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
    ).animate().scale(duration: 200.ms, curve: Curves.easeOut);
  }
}

class CallButton extends StatelessWidget {
  const CallButton({
    super.key,
    required this.phone,
    this.label = 'Call',
    this.compact = false,
  });

  final String phone;
  final String label;
  final bool compact;

  Future<void> _launch(BuildContext context) async {
    final success = await AppHelpers.callPhone(phone);
    if (!success && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot make calls on this device')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return IconButton(
        onPressed: () => _launch(context),
        icon: const Icon(Icons.phone, color: AppColors.success),
        tooltip: 'Call',
      );
    }

    return OutlinedButton.icon(
      onPressed: () => _launch(context),
      icon: const Icon(Icons.phone, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.success,
        side: const BorderSide(color: AppColors.success),
      ),
    );
  }
}

class ContactActionRow extends StatelessWidget {
  const ContactActionRow({
    super.key,
    required this.phone,
    this.whatsappMessage,
  });

  final String phone;
  final String? whatsappMessage;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: CallButton(phone: phone)),
        const SizedBox(width: 12),
        Expanded(child: WhatsAppButton(phone: phone, message: whatsappMessage)),
      ],
    );
  }
}
