import 'package:flutter/material.dart';

// =============================================================================
// AppLoadingState — yagona loading ko'rinishi
// =============================================================================
class AppLoadingState extends StatelessWidget {
  final String message;
  final bool fullScreen;

  const AppLoadingState({
    super.key,
    this.message = 'Yuklanmoqda...',
    this.fullScreen = true,
  });

  @override
  Widget build(BuildContext context) {
    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text(
          message,
          style: const TextStyle(color: Colors.grey, fontSize: 15),
          textAlign: TextAlign.center,
        ),
      ],
    );

    if (fullScreen) {
      return Center(child: content);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: content,
    );
  }
}

// =============================================================================
// AppErrorState — yagona xatolik ko'rinishi
// =============================================================================
class AppErrorState extends StatelessWidget {
  final String title;
  final String? message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onBack;
  final String backLabel;
  final IconData icon;

  const AppErrorState({
    super.key,
    this.title = 'Xatolik yuz berdi',
    this.message,
    this.onRetry,
    this.retryLabel = 'Qayta urinish',
    this.onBack,
    this.backLabel = 'Ortga qaytish',
    this.icon = Icons.error_outline,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            if (onRetry != null)
              FilledButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(retryLabel),
                onPressed: onRetry,
              ),
            if (onBack != null) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                icon: const Icon(Icons.arrow_back, size: 18),
                label: Text(backLabel),
                onPressed: onBack,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// AppEmptyState — yagona bo'sh ro'yxat ko'rinishi
// =============================================================================
class AppEmptyState extends StatelessWidget {
  final String title;
  final String? message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  const AppEmptyState({
    super.key,
    this.title = 'Ma\'lumot topilmadi',
    this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message!,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(actionLabel!),
                onPressed: onAction,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// AppSuccessState — yagona muvaffaqiyat ko'rinishi
// =============================================================================
class AppSuccessState extends StatelessWidget {
  final String title;
  final String? message;
  final List<Widget>? actions;

  const AppSuccessState({
    super.key,
    this.title = 'Muvaffaqiyatli bajarildi',
    this.message,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_outline,
              size: 80,
              color: Colors.green,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (message != null && message!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                message!,
                style: const TextStyle(fontSize: 15, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
            if (actions != null && actions!.isNotEmpty) ...[
              const SizedBox(height: 32),
              ...actions!,
            ],
          ],
        ),
      ),
    );
  }
}

// =============================================================================
// AppInfoBox — yagona info card
// =============================================================================
class AppInfoBox extends StatelessWidget {
  final String message;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const AppInfoBox({
    super.key,
    required this.message,
    this.icon = Icons.info_outline,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final bgColor = backgroundColor ?? primary.withValues(alpha: 0.07);
    final fgColor = foregroundColor ?? primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fgColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: fgColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: fgColor.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
