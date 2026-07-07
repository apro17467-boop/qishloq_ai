import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

const _statusFilters = [
  _StatusFilter(label: 'Barchasi', value: null),
  _StatusFilter(label: 'Moderatsiyada', value: 'PENDING'),
  _StatusFilter(label: 'Faol', value: 'ACTIVE'),
  _StatusFilter(label: 'Rad etilgan', value: 'REJECTED'),
  _StatusFilter(label: 'Arxivda', value: 'ARCHIVED'),
];

class _StatusFilter {
  final String label;
  final String? value;

  const _StatusFilter({required this.label, required this.value});
}

class MyListingsPage extends ConsumerStatefulWidget {
  const MyListingsPage({super.key});

  @override
  ConsumerState<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends ConsumerState<MyListingsPage> {
  final List<Listing> _listings = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasLoadedMeta = false;
  String? _errorMessage;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  String? _selectedStatus;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoad();
    });
  }

  Future<void> _checkAuthAndLoad() async {
    final authState = ref.read(authControllerProvider);
    if (!authState.isAuthenticated) {
      final ok = await ref.read(authControllerProvider.notifier).checkAuth();
      if (!ok && mounted) {
        context.go('/login');
        return;
      }
    }
    _loadListings(reset: true);
  }

  Future<void> _loadListings({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _listings.clear();
        _currentPage = 1;
        _totalPages = 1;
        _totalItems = 0;
        _hasLoadedMeta = false;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final service = ref.read(listingServiceProvider);
      final response = await service.getMyListings(
        page: _currentPage,
        limit: 10,
        status: _selectedStatus,
      );

      if (!mounted) return;

      setState(() {
        if (reset) {
          _listings.clear();
        }
        _listings.addAll(response.data);
        _totalPages = response.meta.totalPages;
        _totalItems = response.meta.total;
        _hasLoadedMeta = true;
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    _currentPage++;
    await _loadListings();
  }

  void _onStatusChanged(String? newStatus) {
    if (_selectedStatus == newStatus) return;
    _selectedStatus = newStatus;
    _loadListings(reset: true);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (prev, next) {
      if (!next.isAuthenticated && !next.isLoading) {
        context.go('/login');
      }
    });

    if (!authState.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mening e’lonlarim'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/profile');
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSummaryHeader(),
            _buildStatusChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryHeader() {
    final primary = Theme.of(context).colorScheme.primary;
    final title = _hasLoadedMeta ? 'E’lonlaringiz' : 'E’lonlaringiz ro‘yxati';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8ECE8)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.inventory_2_outlined, color: primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (_hasLoadedMeta)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '$_totalItems ta',
                          style: TextStyle(
                            color: primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Bu yerda siz joylagan e’lonlar va ularning moderatsiya holati ko‘rinadi.',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChips() {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isSelected = _selectedStatus == filter.value;
          final color = _getFilterColor(filter.value);

          return InkWell(
            borderRadius: BorderRadius.circular(999),
            onTap: () => _onStatusChanged(filter.value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.white,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: isSelected ? color : const Color(0xFFE0E0E0),
                ),
              ),
              child: Center(
                child: Text(
                  filter.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.grey[700],
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Yuklanmoqda...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        title: 'Mening e’lonlarimni yuklashda xatolik yuz berdi',
        message: _errorMessage,
        onRetry: () => _loadListings(reset: true),
      );
    }

    if (_listings.isEmpty) {
      return _buildEmptyState();
    }

    return _buildListingsView();
  }

  Widget _buildEmptyState() {
    final isFiltered = _selectedStatus != null;
    return AppEmptyState(
      title: isFiltered ? 'Bu holatda e’lon yo‘q' : 'Hali e’lon joylamagansiz',
      message: isFiltered
          ? 'Boshqa statusni tanlab ko‘ring.'
          : 'Birinchi e’loningizni joylashtiring va xaridorlarga ko‘rining.',
      icon: isFiltered ? Icons.filter_list_off : Icons.inventory_2_outlined,
      onAction: isFiltered ? null : () => context.go('/create-listing'),
      actionLabel: isFiltered ? null : 'E’lon joylash',
    );
  }

  Widget _buildListingsView() {
    return RefreshIndicator(
      onRefresh: () => _loadListings(reset: true),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: _listings.length + 1,
        separatorBuilder: (_, index) {
          if (index >= _listings.length - 1) {
            return const SizedBox.shrink();
          }
          return const SizedBox(height: 12);
        },
        itemBuilder: (context, index) {
          if (index == _listings.length) {
            return _buildLoadMoreSection();
          }
          return _buildListingCard(_listings[index]);
        },
      ),
    );
  }

  Widget _buildLoadMoreSection() {
    final hasMore = _currentPage < _totalPages;

    return Padding(
      padding: const EdgeInsets.only(top: 18, bottom: 10),
      child: Column(
        children: [
          Text(
            'Jami: $_totalItems ta e’lon',
            style: TextStyle(color: Colors.grey[600], fontSize: 12),
          ),
          if (hasMore) ...[
            const SizedBox(height: 12),
            AppButton(
              label: 'Yana yuklash',
              loading: _isLoadingMore,
              onPressed: _isLoadingMore ? null : _loadMore,
              fullWidth: true,
            ),
          ] else if (_listings.length > 10) ...[
            const SizedBox(height: 6),
            Text(
              'Barcha e’lonlar yuklandi',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    final statusColor = _getStatusColor(listing.status);
    final canViewDetail = listing.status == 'ACTIVE';
    final canAddImage =
        listing.status == 'PENDING' || listing.status == 'ACTIVE';
    final location = _listingLocation(listing);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _onViewTap(listing, canViewDetail),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE8ECE8)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImagePreview(listing),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          listing.title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            height: 1.25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          listing.formattedPrice,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _buildStatusBadge(listing.status),
                            _buildTypeBadge(listing.typeLabel),
                          ],
                        ),
                        const SizedBox(height: 8),
                        _buildInfoLine(
                          icon: Icons.calendar_today_outlined,
                          text: listing.formattedDate,
                        ),
                        if (location.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          _buildInfoLine(
                            icon: Icons.location_on_outlined,
                            text: location,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              AppInfoBox(
                message: _getStatusDescription(listing.status),
                icon: _getStatusIcon(listing.status),
                backgroundColor: statusColor.withValues(alpha: 0.08),
                foregroundColor: statusColor,
              ),
              const SizedBox(height: 12),
              _buildActionRow(listing, canViewDetail, canAddImage),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview(Listing listing) {
    final firstImage = (listing.images != null && listing.images!.isNotEmpty)
        ? listing.images!.first
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 96,
        height: 96,
        child: firstImage != null
            ? Image.network(
                firstImage.url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _imagePlaceholder(),
              )
            : _imagePlaceholder(),
      ),
    );
  }

  Widget _imagePlaceholder() {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      color: primary.withValues(alpha: 0.08),
      child: Icon(Icons.agriculture_outlined, color: primary, size: 34),
    );
  }

  Widget _buildActionRow(
    Listing listing,
    bool canViewDetail,
    bool canAddImage,
  ) {
    if (listing.status == 'REJECTED') {
      return _buildStatusNote(
        icon: Icons.info_outline,
        text: 'Rad sababi admin panelda',
        color: _getStatusColor(listing.status),
      );
    }

    if (listing.status == 'ARCHIVED') {
      return _buildStatusNote(
        icon: Icons.archive_outlined,
        text: 'Arxivlangan',
        color: _getStatusColor(listing.status),
      );
    }

    final buttons = <Widget>[];

    if (canViewDetail) {
      buttons.add(
        Expanded(
          child: AppButton(
            label: 'Ko‘rish',
            variant: AppButtonVariant.outlined,
            onPressed: () => _onViewTap(listing, true),
          ),
        ),
      );
    }

    if (canAddImage) {
      if (buttons.isNotEmpty) {
        buttons.add(const SizedBox(width: 10));
      }
      buttons.add(
        Expanded(
          child: AppButton(
            label: 'Rasm qo‘shish',
            onPressed: () => context.go(
              '/listings/${listing.id}/images?title=${Uri.encodeComponent(listing.title)}',
            ),
          ),
        ),
      );
    }

    return Row(children: buttons);
  }

  Widget _buildStatusNote({
    required IconData icon,
    required String text,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final color = _getStatusColor(status);
    return _buildBadge(
      label: _getStatusLabel(status),
      color: color,
      icon: _getStatusIcon(status),
      filled: true,
    );
  }

  Widget _buildTypeBadge(String label) {
    return _buildBadge(
      label: label,
      color: Colors.grey[700]!,
      icon: Icons.label_outline,
      filled: false,
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    required IconData icon,
    required bool filled,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? color : Colors.grey.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: filled
            ? null
            : Border.all(color: Colors.grey.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: filled ? Colors.white : color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: filled ? Colors.white : color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoLine({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey[500]),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
              height: 1.25,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  String _listingLocation(Listing listing) {
    final address = listing.address?.trim() ?? '';
    if (address.isNotEmpty) {
      return address;
    }
    return listing.region?.nameUz ?? '';
  }

  void _onViewTap(Listing listing, bool canView) {
    if (canView) {
      context.go('/listings/${listing.id}');
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bu e’lon ommaga ko‘rinmaydi yoki hali tasdiqlanmagan.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Color _getFilterColor(String? status) {
    if (status == null) {
      return Theme.of(context).colorScheme.primary;
    }
    return _getStatusColor(status);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return const Color(0xFF2E7D32);
      case 'PENDING':
        return const Color(0xFFF57C00);
      case 'REJECTED':
        return const Color(0xFFD32F2F);
      case 'ARCHIVED':
        return const Color(0xFF757575);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'ACTIVE':
        return Icons.check_circle_outline;
      case 'PENDING':
        return Icons.hourglass_empty;
      case 'REJECTED':
        return Icons.cancel_outlined;
      case 'ARCHIVED':
        return Icons.archive_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'PENDING':
        return 'Moderatsiyada';
      case 'ACTIVE':
        return 'Faol';
      case 'REJECTED':
        return 'Rad etilgan';
      case 'ARCHIVED':
        return 'Arxivda';
      default:
        return status;
    }
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'E’lon ommaga ko‘rinmoqda. Xaridorlar uni e’lonlar ro‘yxatida ko‘ra oladi.';
      case 'PENDING':
        return 'E’lon admin tasdiqlashini kutmoqda. Shu paytda rasm qo‘shishingiz mumkin.';
      case 'REJECTED':
        return 'E’lon rad etilgan. Sababini admin panel orqali tekshirish kerak.';
      case 'ARCHIVED':
        return 'E’lon arxivlangan va ommaga ko‘rinmaydi.';
      default:
        return status;
    }
  }
}
