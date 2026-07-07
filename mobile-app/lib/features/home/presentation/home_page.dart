import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_card.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

// ... (qolgan o'zgarmaslar)
const Map<String, String> _roleLabels = {
  'FARMER': 'Dehqon/Fermer',
  'LIVESTOCK_OWNER': 'Chorvador',
  'MACHINERY_OWNER': 'Texnika egasi',
  'BUYER': 'Xaridor',
  'AGRONOMIST': 'Agronom',
  'VETERINARIAN': 'Veterinar',
  'ADMIN': 'Admin',
};

String _getRoleLabel(String role) {
  return _roleLabels[role] ?? role;
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthProtection();
    });
  }

  Future<void> _checkAuthProtection() async {
    final authState = ref.read(authControllerProvider);
    if (!authState.isAuthenticated) {
      final isAuthenticated = await ref.read(authControllerProvider.notifier).checkAuth();
      if (!isAuthenticated && mounted) {
        context.go('/login');
      }
    }
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

  Future<void> _handleLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Tizimdan chiqish'),
        content: const Text('Hisobdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Yo‘q'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Ha, chiqish'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await ref.read(authControllerProvider.notifier).logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    // Listen to changes to auto-redirect to login when authenticated state is lost
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!next.isAuthenticated && next.isLoading == false) {
        context.go('/login');
      }
    });

    if (authState.isLoading) {
      return const Scaffold(
        body: AppLoadingState(
          message: 'Profil tekshirilmoqda...',
        ),
      );
    }

    final user = authState.user;
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('QISHLOQ AI'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _handleLogout(context),
            tooltip: 'Chiqish',
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: ListView(
            children: [
              const SizedBox(height: 12),
              // User profile card
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        child: Text(
                          (user.profile?.fullName ?? user.phone).isNotEmpty
                              ? (user.profile?.fullName ?? '?')[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Xush kelibsiz,',
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                              ),
                            ),
                            Text(
                              user.profile?.fullName ?? 'Foydalanuvchi',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user.phone,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                _getRoleLabel(user.role),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
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
                onTap: () => context.go('/listings'),
              ),
              const SizedBox(height: 8),
              AppCard(
                title: 'Kategoriyalar',
                subtitle: 'Mahsulotlar va xizmatlar toifalarini ko‘rish.',
                icon: Icons.category_outlined,
                onTap: () => context.go('/categories'),
              ),
              const SizedBox(height: 8),
              AppCard(
                title: 'E’lon joylash',
                subtitle: 'O‘z mahsulotingiz yoki texnikangizni joylashtiring.',
                icon: Icons.add_circle_outline,
                onTap: () => context.go('/create-listing'),
              ),
              const SizedBox(height: 8),
              AppCard(
                title: 'Mening e’lonlarim',
                subtitle: 'Joylagan e’lonlaringiz holatini kuzating.',
                icon: Icons.list_alt_outlined,
                onTap: () => context.go('/my-listings'),
              ),
              const SizedBox(height: 8),
              AppCard(
                title: 'AI maslahat',
                subtitle: 'Qishloq xo‘jaligiga oid barcha savollaringizga AI javoblari.',
                icon: Icons.psychology_alt,
                onTap: () => context.go('/ai-advice'),
              ),
              const SizedBox(height: 8),
              AppCard(
                title: 'Mening profilim',
                subtitle: 'Shaxsiy ma’lumotlar, e’lonlar va sozlamalarni boshqarish.',
                icon: Icons.person_outline,
                onTap: () => context.go('/profile'),
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
