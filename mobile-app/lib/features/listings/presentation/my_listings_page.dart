import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

// ---------------------------------------------------------------------------
// Status filter tanlovlari
// ---------------------------------------------------------------------------
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
  // State
  final List<Listing> _listings = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  // Filter
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

      setState(() {
        if (reset) {
          _listings.clear();
        }
        _listings.addAll(response.data);
        _totalPages = response.meta.totalPages;
        _totalItems = response.meta.total;
        _isLoading = false;
        _isLoadingMore = false;
        _errorMessage = null;
      });
    } catch (e) {
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
        title: const Text('Mening e\'lonlarim'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildFilterChips(),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _statusFilters.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = _statusFilters[index];
          final isSelected = _selectedStatus == filter.value;
          return FilterChip(
            label: Text(filter.label),
            selected: isSelected,
            onSelected: (_) => _onStatusChanged(filter.value),
            selectedColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(
        message: 'Yuklanmoqda...',
      );
    }

    if (_errorMessage != null) {
      return AppErrorState(
        title: 'Mening e\'lonlarimni yuklashda xatolik yuz berdi',
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
      title: isFiltered ? 'Bu statusda e\'lonlar topilmadi' : 'Sizda hali e\'lon yo\'q',
      message: isFiltered
          ? 'Boshqa filtr tanlang yoki barcha e\'lonlarni ko\'ring'
          : 'Birinchi e\'loningizni joylashtiring!',
      icon: isFiltered ? Icons.filter_list_off : Icons.inventory_2_outlined,
      onAction: isFiltered ? () => _onStatusChanged(null) : () => context.go('/create-listing'),
      actionLabel: isFiltered ? 'Filtrni tozalash' : 'E\'lon joylash',
    );
  }

  // ---------------------------------------------------------------------------
  // Listings list view
  // ---------------------------------------------------------------------------
  Widget _buildListingsView() {
    return RefreshIndicator(
      onRefresh: () => _loadListings(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _listings.length + 1, // +1 for load more button
        itemBuilder: (context, index) {
          if (index == _listings.length) {
            return _buildLoadMoreSection();
          }
          return _buildListingCard(_listings[index]);
        },
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Load more section
  // ---------------------------------------------------------------------------
  Widget _buildLoadMoreSection() {
    final hasMore = _currentPage < _totalPages;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          Text(
            'Jami: $_totalItems ta e\'lon',
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          if (hasMore) ...[
            const SizedBox(height: 12),
            _isLoadingMore
                ? const CircularProgressIndicator()
                : OutlinedButton.icon(
                    icon: const Icon(Icons.expand_more),
                    label: const Text('Yana yuklash'),
                    onPressed: _loadMore,
                  ),
          ] else if (_listings.length > 10) ...[
            const SizedBox(height: 4),
            const Text(
              'Barcha e\'lonlar yuklandi',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Single listing card
  // ---------------------------------------------------------------------------
  Widget _buildListingCard(Listing listing) {
    final statusColor = _getStatusColor(listing.status);
    final statusIcon = _getStatusIcon(listing.status);
    final statusDescription = _getStatusDescription(listing.status);
    final canViewDetail = listing.status == 'ACTIVE';
    final canAddImage = listing.status == 'PENDING' || listing.status == 'ACTIVE';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: image + title/status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image preview
                _buildImagePreview(listing),
                const SizedBox(width: 12),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(statusIcon, size: 12, color: statusColor),
                                const SizedBox(width: 4),
                                Text(
                                  listing.statusLabel,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                listing.typeLabel,
                                style: const TextStyle(fontSize: 10, color: Colors.grey),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      // Title
                      Text(
                        listing.title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Price
                      Text(
                        listing.formattedPrice,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Address / Region
            if (listing.address != null || listing.region != null) ...[
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      listing.address ?? listing.region?.nameUz ?? '',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
            ],

            // Date
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  listing.formattedDate,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Status description
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusDescription,
                style: TextStyle(fontSize: 12, color: statusColor.withValues(alpha: 0.85)),
              ),
            ),
            const SizedBox(height: 10),

            // Action buttons
            Row(
              children: [
                // "Ko'rish" button
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.visibility_outlined, size: 16),
                    label: const Text('Ko\'rish', style: TextStyle(fontSize: 13)),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      foregroundColor: canViewDetail
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      side: BorderSide(
                        color: canViewDetail
                            ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                            : Colors.grey.withValues(alpha: 0.4),
                      ),
                    ),
                    onPressed: () => _onViewTap(listing, canViewDetail),
                  ),
                ),
                const SizedBox(width: 8),
                // "Rasm qo'shish" button
                if (canAddImage)
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                      label: const Text('Rasm', style: TextStyle(fontSize: 13)),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                      onPressed: () => context.go(
                        '/listings/${listing.id}/images?title=${Uri.encodeComponent(listing.title)}',
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.add_photo_alternate_outlined, size: 16),
                      label: const Text('Rasm', style: TextStyle(fontSize: 13)),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        backgroundColor: Colors.grey.withValues(alpha: 0.3),
                        foregroundColor: Colors.grey,
                      ),
                      onPressed: null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Image preview widget
  // ---------------------------------------------------------------------------
  Widget _buildImagePreview(Listing listing) {
    final firstImage = (listing.images != null && listing.images!.isNotEmpty)
        ? listing.images!.first
        : null;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 80,
        height: 80,
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
    return Container(
      color: Colors.grey[200],
      child: const Icon(Icons.image_outlined, color: Colors.grey, size: 32),
    );
  }

  // ---------------------------------------------------------------------------
  // Action handlers
  // ---------------------------------------------------------------------------
  void _onViewTap(Listing listing, bool canView) {
    if (canView) {
      context.go('/listings/${listing.id}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu e\'lon ommaga ko\'rinmaydi yoki hali tasdiqlanmagan.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Status helpers
  // ---------------------------------------------------------------------------
  Color _getStatusColor(String status) {
    switch (status) {
      case 'ACTIVE':
        return Colors.green;
      case 'PENDING':
        return Colors.orange;
      case 'REJECTED':
        return Colors.red;
      case 'ARCHIVED':
        return Colors.grey;
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

  String _getStatusDescription(String status) {
    switch (status) {
      case 'ACTIVE':
        return 'Ommaga ko\'rinmoqda';
      case 'PENDING':
        return 'Admin tasdiqlashini kutmoqda';
      case 'REJECTED':
        return 'Admin tomonidan rad etilgan';
      case 'ARCHIVED':
        return 'Arxivlangan';
      default:
        return status;
    }
  }
}
