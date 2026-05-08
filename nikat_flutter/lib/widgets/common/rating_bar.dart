import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RatingBar extends StatelessWidget {
  const RatingBar({
    super.key,
    required this.rating,
    this.maxRating = 5,
    this.size = 18,
    this.color = AppColors.gold,
    this.onChanged,
  });

  final double rating;
  final int maxRating;
  final double size;
  final Color color;
  final ValueChanged<double>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(maxRating, (i) {
        final starValue = i + 1.0;
        final fill = (rating - i).clamp(0.0, 1.0);

        return GestureDetector(
          onTap: onChanged != null ? () => onChanged!(starValue) : null,
          child: Icon(
            fill >= 1.0
                ? Icons.star
                : fill >= 0.5
                    ? Icons.star_half
                    : Icons.star_border,
            color: color,
            size: size,
          ),
        );
      }),
    );
  }
}

class RatingDisplay extends StatelessWidget {
  const RatingDisplay({super.key, required this.rating, required this.count, this.showCount = true});
  final double rating;
  final int count;
  final bool showCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RatingBar(rating: rating, size: 14),
        const SizedBox(width: 6),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        if (showCount) ...[
          const SizedBox(width: 3),
          Text(
            '($count)',
            style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 13),
          ),
        ],
      ],
    );
  }
}
