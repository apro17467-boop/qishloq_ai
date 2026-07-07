import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/network/api_response.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';
import 'package:qishloq_ai_mobile/features/sellers/data/seller_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

class SellerProfilePage extends ConsumerStatefulWidget {
  final String sellerId;

  const SellerProfilePage({super.key, required this.sellerId});

  @override
  ConsumerState<SellerProfilePage> createState() => _SellerProfilePageState();
}

class _SellerProfilePageState extends ConsumerState<SellerProfilePage> {
  final List<Listing> _listings = [];
  SellerProfile? _profile;
  PaginatedMeta? _meta;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSellerProfile();
    });
  }

  Future<void> _fetchSellerProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _listings.clear();
      _currentPage = 1;
    });

    try {
      final service = ref.read(sellerServiceProvider);
      final profile = await service.getSellerProfile(widget.sellerId);
      final listingsResponse = await service.getSellerListings(
        sellerId: widget.sellerId,
        page: 1,
        limit: 10,
      );

      if (!mounted) return;

      setState(() {
        _profile = profile;
        _listings.addAll(listingsResponse.data);
        _meta = listingsResponse.meta;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _loadMoreListings() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await ref
          .read(sellerServiceProvider)
          .getSellerListings(
            sellerId: widget.sellerId,
            page: nextPage,
            limit: 10,
          );

      if (!mounted) return;

      setState(() {
        _currentPage = nextPage;
        _listings.addAll(response.data);
        _meta = response.meta;
        _isLoadingMore = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('E’lon egasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/listings');
            }
          },
        ),
      ),
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'E’lon egasi yuklanmoqda...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        title: 'E’lon egasi topilmadi',
        message: _errorMessage,
        icon: Icons.person_off_outlined,
        onRetry: _fetchSellerProfile,
      );
    }

    final profile = _profile;
    if (profile == null) {
      return const Center(child: Text('Ma’lumot topilmadi'));
    }

    final hasMore = _meta != null && _currentPage < _meta!.totalPages;

    return RefreshIndicator(
      onRefresh: _fetchSellerProfile,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _buildProfileHeader(profile),
          const SizedBox(height: 20),
          Text(
            'Faol e’lonlari',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),
          if (_listings.isEmpty)
            _buildEmptyListingsCard()
          else
            ..._listings.map(
              (listing) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _buildListingCard(listing),
              ),
            ),
          if (hasMore)
            Padding(
              padding: const EdgeInsets.only(top: 4, bottom: 20),
              child: AppButton(
                label: 'Yana yuklash',
                loading: _isLoadingMore,
                fullWidth: true,
                onPressed: _isLoadingMore ? null : _loadMoreListings,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader(SellerProfile profile) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    profile.initials,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildBadge(
                            label: profile.roleLabel,
                            icon: Icons.work_outline,
                          ),
                          if (profile.isVerified)
                            _buildBadge(
                              label: 'Tasdiqlangan',
                              icon: Icons.verified_outlined,
                              color: Colors.green,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 28),
            _buildInfoRow(
              Icons.location_on_outlined,
              profile.region?.nameUz ?? 'Hudud ko‘rsatilmagan',
              profile.address,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.inventory_2_outlined,
              '${profile.activeListingsCount} ta faol e’lon',
              'Platformadagi ommaviy e’lonlari',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.event_available_outlined,
              'Qo‘shilgan sana',
              profile.joinedDate,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge({
    required String label,
    required IconData icon,
    Color? color,
  }) {
    final badgeColor = color ?? Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: badgeColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String? subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null && subtitle.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyListingsCard() {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1.4),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 28),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined, size: 44, color: Colors.grey[400]),
            const SizedBox(height: 12),
            const Text(
              'Bu foydalanuvchida faol e’lonlar yo‘q',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingCard(Listing listing) {
    final firstImage = (listing.images != null && listing.images!.isNotEmpty)
        ? listing.images!.first
        : null;

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1.4),
      ),
      child: InkWell(
        onTap: () => context.push('/listings/${listing.id}'),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: firstImage != null
                      ? Image.network(
                          firstImage.url,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _buildPlaceholderIcon(),
                        )
                      : _buildPlaceholderIcon(),
                ),
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
                            listing.typeLabel,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          listing.formattedDate.split(' ').first,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      listing.formattedPrice,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 13,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Expanded(
                          child: Text(
                            listing.address ??
                                listing.region?.nameUz ??
                                'Hudud ko‘rsatilmagan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.green[50],
      child: Icon(Icons.agriculture, color: Colors.green[300], size: 36),
    );
  }
}
