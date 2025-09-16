import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final VoidCallback onAddToCartPressed;
  final VoidCallback onFavoritePressed;
  final String addToCartText;
  final IconData favoriteIcon;

  const ActionButtons({
    super.key,
    required this.onAddToCartPressed,
    required this.onFavoritePressed,
    this.addToCartText = 'Add to Cart',
    this.favoriteIcon = Icons.favorite_border,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: onAddToCartPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xff004CFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              addToCartText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: onFavoritePressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xff004CFF),
            side: const BorderSide(
              color: Color(0xff004CFF),
            ),
            padding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 16,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Icon(favoriteIcon),
        ),
      ],
    );
  }
}