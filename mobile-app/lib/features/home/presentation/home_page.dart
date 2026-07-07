import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_card.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  void _showPlaceholderMessage(BuildContext context, String section) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$section: Bu bo‘lim keyingi bosqichda ulanadi'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _checkBackendHealth(BuildContext context, WidgetRef ref) async {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Backend holati tekshirilmoqda...'),
        duration: Duration(seconds: 1),
      ),
    );

    try {
      final healthService = ref.read(healthServiceProvider);
      final status = await healthService.checkHealth();
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Backend ishlayapti: $status'),
            backgroundColor: Colors.green[700],
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Xatolik yuz berdi: ${e.toString()}'),
            backgroundColor: Colors.red[700],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QISHLOQ AI'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListView(
            children: [
              const SizedBox(height: 12),
              const Text(
                'Asosiy bo‘limlar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              AppCard(
                title: 'E’lonlar',
                subtitle: 'Sotiladigan va ijaraga beriladigan mahsulotlar va texnikalar.',
                icon: Icons.grid_view,
                onTap: () => _showPlaceholderMessage(context, 'E’lonlar'),
              ),
              const SizedBox(height: 8),
              AppCard(
                title: 'E’lon joylash',
                subtitle: 'O‘z mahsulotingiz yoki texnikangizni joylashtiring.',
                icon: Icons.add_circle_outline,
                onTap: () => _showPlaceholderMessage(context, 'E’lon joylash'),
              ),
              const SizedBox(height: 8),
              AppCard(
                title: 'AI maslahat',
                subtitle: 'Qishloq xo‘jaligiga oid barcha savollaringizga AI javoblari.',
                icon: Icons.psychology_alt,
                onTap: () => _showPlaceholderMessage(context, 'AI maslahat'),
              ),
              const SizedBox(height: 8),
              AppCard(
                title: 'Mening profilim',
                subtitle: 'Shaxsiy ma’lumotlar, e’lonlar va sozlamalarni boshqarish.',
                icon: Icons.person_outline,
                onTap: () => _showPlaceholderMessage(context, 'Mening profilim'),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 12),
              const Text(
                'Dasturchilar bo‘limi (Debug)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              AppCard(
                title: 'Backend holatini tekshirish',
                subtitle: 'HealthService orqali backend ulanishini tekshirish.',
                icon: Icons.developer_mode,
                onTap: () => _checkBackendHealth(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
