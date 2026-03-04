import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';

class StockBadge extends StatelessWidget {
  final int quantity;

  const StockBadge({super.key, required this.quantity});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (quantity) {
      0 => (AppStrings.outOfStock, AppColors.error),
      <= 5 => ('${AppStrings.lowStock} ($quantity)', AppColors.warningAmber),
      _ => ('$quantity ${AppStrings.inStock.toLowerCase()}', AppColors.successGreen),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}
