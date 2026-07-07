import 'package:flutter/material.dart';

enum AppButtonVariant { filled, outlined }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final bool fullWidth;
  final AppButtonVariant variant;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
    this.fullWidth = false,
    this.variant = AppButtonVariant.filled,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = variant == AppButtonVariant.outlined
        ? theme.colorScheme.primary
        : Colors.white;

    final buttonContent = loading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
            ),
          )
        : Text(label);

    final Widget button = switch (variant) {
      AppButtonVariant.filled => ElevatedButton(
        onPressed: loading ? null : onPressed,
        child: buttonContent,
      ),
      AppButtonVariant.outlined => OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(88, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: buttonContent,
      ),
    };

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: button);
    }

    return button;
  }
}
