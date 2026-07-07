import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/features/auth/data/auth_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_bottom_nav.dart';

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

String _getRoleLabel(String role) => _roleLabels[role] ?? role;

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isRefreshing = false;
  String? _refreshError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initialCheck();
    });
  }

  Future<void> _initialCheck() async {
    final authState = ref.read(authControllerProvider);
    if (!authState.isAuthenticated) {
      final ok = await ref.read(authControllerProvider.notifier).checkAuth();
      if (!ok && mounted) {
        context.go('/login');
      }
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _isRefreshing = true;
      _refreshError = null;
    });
    try {
      final ok = await ref.read(authControllerProvider.notifier).checkAuth();
      if (!ok && mounted) {
        context.go('/login');
        return;
      }
    } catch (e) {
      setState(() {
        _refreshError = 'Profil ma\'lumotlarini yangilashda xatolik yuz berdi';
      });
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hisobdan chiqish'),
        content: const Text('Hisobdan chiqmoqchimisiz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Yo\'q'),
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

    ref.listen<AuthState>(authControllerProvider, (_, next) {
      if (!next.isAuthenticated && !next.isLoading) {
        context.go('/login');
      }
    });

    // Loading
    if (authState.isLoading || _isRefreshing) {
      return Scaffold(
        appBar: AppBar(title: const Text('Mening profilim')),
        body: const AppLoadingState(message: 'Profil yuklanmoqda...'),
      );
    }

    // Not authenticated
    if (!authState.isAuthenticated || authState.user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = authState.user!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mening profilim'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Yangilash',
            onPressed: _isRefreshing ? null : _refresh,
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              // Refresh error
              if (_refreshError != null) ...[
                _buildErrorBanner(_refreshError!),
                const SizedBox(height: 12),
              ],

              // Avatar + main info card
              _buildAvatarCard(context, user),
              const SizedBox(height: 16),

              // Account status card
              _buildStatusCard(context, user),
              const SizedBox(height: 16),

              // Profile data card
              _buildProfileDataCard(context, user),
              const SizedBox(height: 16),

              // Quick actions card
              _buildQuickActionsCard(context),
              const SizedBox(height: 24),

              // Logout
              _buildLogoutButton(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 4),
    );
  }

  Widget _buildErrorBanner(String message) {
    return AppInfoBox(
      message: message,
      icon: Icons.error_outline,
      backgroundColor: Colors.red[50],
      foregroundColor: Colors.red[800],
    );
  }

  Widget _buildAvatarCard(BuildContext context, AuthUser user) {
    final fullName = user.profile?.fullName;
    final initials = _getInitials(fullName, user.phone);
    final roleLabel = _getRoleLabel(user.role);

    return Card(
      elevation: 0,
      color: Theme.of(
        context,
      ).colorScheme.primaryContainer.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: Theme.of(context).colorScheme.primaryContainer),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 22,
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
                    fullName != null && fullName.isNotEmpty
                        ? fullName
                        : 'Ism kiritilmagan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.phone,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(
                        context,
                      ).colorScheme.onPrimaryContainer.withValues(alpha: 0.75),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      roleLabel,
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
    );
  }

  Widget _buildStatusCard(BuildContext context, AuthUser user) {
    return _SectionCard(
      title: 'Hisob holati',
      icon: Icons.verified_user_outlined,
      children: [
        _StatusRow(
          label: 'Telefon tasdiqlangan',
          value: user.isVerified ? 'Tasdiqlangan' : 'Tasdiqlanmagan',
          valueColor: user.isVerified ? Colors.green : Colors.orange,
          icon: user.isVerified
              ? Icons.check_circle_outline
              : Icons.warning_amber_outlined,
        ),
        const Divider(height: 16),
        _StatusRow(
          label: 'Hisob faoliyati',
          value: user.isActive ? 'Faol' : 'Faol emas',
          valueColor: user.isActive ? Colors.green : Colors.red,
          icon: user.isActive
              ? Icons.radio_button_checked
              : Icons.radio_button_unchecked,
        ),
        const Divider(height: 16),
        Row(
          children: [
            const Icon(Icons.fingerprint, size: 16, color: Colors.grey),
            const SizedBox(width: 8),
            const Text(
              'ID:',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                user.id,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: user.id));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('ID nusxalandi'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Icon(
                Icons.copy_outlined,
                size: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileDataCard(BuildContext context, AuthUser user) {
    final profile = user.profile;
    final fullNameVal = profile?.fullName;
    final addressVal = profile?.address;
    final hasFullName = fullNameVal != null && fullNameVal.isNotEmpty;
    final hasAddress = addressVal != null && addressVal.isNotEmpty;
    final hasData = hasFullName || hasAddress;

    return _SectionCard(
      title: 'Profil ma\'lumotlari',
      icon: Icons.person_outline,
      children: [
        if (hasFullName) ...[
          _InfoRow(
            label: 'To\'liq ism',
            value: fullNameVal,
            icon: Icons.badge_outlined,
          ),
          if (hasAddress) const Divider(height: 16),
        ],
        if (hasAddress) ...[
          _InfoRow(
            label: 'Manzil',
            value: addressVal,
            icon: Icons.location_on_outlined,
          ),
        ],
        if (!hasData) ...[
          const SizedBox(height: 4),
          const AppInfoBox(
            message:
                'Profil ma\'lumotlari to\'liq emas. Profilni tahrirlash keyingi bosqichda qo\'shiladi.',
          ),
        ],
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Quick actions card
  // ---------------------------------------------------------------------------
  Widget _buildQuickActionsCard(BuildContext context) {
    return _SectionCard(
      title: 'Tezkor harakatlar',
      icon: Icons.apps_outlined,
      children: [
        _ActionTile(
          icon: Icons.list_alt_outlined,
          label: 'Mening e\'lonlarim',
          onTap: () => context.go('/my-listings'),
        ),
        const Divider(height: 1),
        _ActionTile(
          icon: Icons.favorite_border,
          label: 'Sevimlilar',
          onTap: () => context.push('/favorites'),
        ),
        const Divider(height: 1),
        _ActionTile(
          icon: Icons.add_circle_outline,
          label: 'E\'lon joylash',
          onTap: () => context.go('/create-listing'),
        ),
        const Divider(height: 1),
        _ActionTile(
          icon: Icons.psychology_alt,
          label: 'AI maslahatlarim',
          onTap: () => context.go('/ai-advice'),
        ),
        const Divider(height: 1),
        _ActionTile(
          icon: Icons.grid_view_outlined,
          label: 'Barcha e\'lonlar',
          onTap: () => context.go('/listings'),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Logout button
  // ---------------------------------------------------------------------------
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton.icon(
        icon: const Icon(Icons.logout_outlined, color: Colors.red),
        label: const Text(
          'Hisobdan chiqish',
          style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: _handleLogout,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Initials helper
  // ---------------------------------------------------------------------------
  String _getInitials(String? fullName, String phone) {
    if (fullName != null && fullName.trim().isNotEmpty) {
      final parts = fullName.trim().split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return fullName.trim()[0].toUpperCase();
    }
    // Phone oxirgi 2 raqami
    if (phone.length >= 2) {
      return phone.substring(phone.length - 2);
    }
    return '?';
  }
}

// ---------------------------------------------------------------------------
// Reusable section card
// ---------------------------------------------------------------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section header
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Status row widget
// ---------------------------------------------------------------------------
class _StatusRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final IconData icon;

  const _StatusRow({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: valueColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Info row widget
// ---------------------------------------------------------------------------
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 14)),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Action tile widget
// ---------------------------------------------------------------------------
class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        icon,
        size: 20,
        color: Theme.of(context).colorScheme.primary,
      ),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
      onTap: onTap,
    );
  }
}
