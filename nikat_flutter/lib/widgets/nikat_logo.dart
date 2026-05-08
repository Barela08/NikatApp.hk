import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

class NikatLogo extends StatelessWidget {
  const NikatLogo({super.key, this.size = 80});
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.22),
        boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, spreadRadius: 2)],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size * 0.22),
        child: Image.asset('assets/images/nikat_logo.png', width: size, height: size, fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: size, height: size,
              color: AppColors.surface,
              child: Center(
                child: Text('N', style: TextStyle(color: AppColors.primary, fontSize: size * 0.5, fontWeight: FontWeight.w800)),
              ),
            )),
      ),
    );
  }
}
