import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';

class NikatButton extends StatelessWidget {
  const NikatButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.variant = NikatButtonVariant.primary,
    this.size = NikatButtonSize.large,
    this.fullWidth = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final NikatButtonVariant variant;
  final NikatButtonSize size;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final height = size == NikatButtonSize.large ? 54.0 : 42.0;
    final fontSize = size == NikatButtonSize.large ? 16.0 : 14.0;

    Widget child = isLoading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: variant == NikatButtonVariant.primary ? Colors.black : AppColors.primary,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: fontSize + 2),
                  const SizedBox(width: 8),
                  Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700)),
                ],
              )
            : Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700));

    final button = switch (variant) {
      NikatButtonVariant.primary => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: fullWidth ? Size(double.infinity, height) : Size(120, height),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.black,
          ),
          child: child,
        ),
      NikatButtonVariant.outline => OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            minimumSize: fullWidth ? Size(double.infinity, height) : Size(120, height),
            side: const BorderSide(color: AppColors.primary),
            foregroundColor: AppColors.primary,
          ),
          child: child,
        ),
      NikatButtonVariant.ghost => TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            minimumSize: fullWidth ? Size(double.infinity, height) : Size(120, height),
            foregroundColor: AppColors.primary,
          ),
          child: child,
        ),
      NikatButtonVariant.danger => ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            minimumSize: fullWidth ? Size(double.infinity, height) : Size(120, height),
            backgroundColor: AppColors.error,
            foregroundColor: Colors.white,
          ),
          child: child,
        ),
    };

    return button.animate().scale(duration: 150.ms, curve: Curves.easeOut);
  }
}

enum NikatButtonVariant { primary, outline, ghost, danger }
enum NikatButtonSize { large, small }
