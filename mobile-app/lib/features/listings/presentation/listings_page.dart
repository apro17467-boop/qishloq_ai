import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/core/network/api_response.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_bottom_nav.dart';

class ListingsPage extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ListingsPage({super.key, this.categoryId, this.categoryName});

  @override
  ConsumerState<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends ConsumerState<ListingsPage> {
  final TextEditingController _searchController = TextEditingController();

  int _currentPage = 1;
  String? _selectedType;
  String? _categoryId;
  String? _categoryName;
  String? _searchQuery;

  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;

  final List<Listing> _listings = [];
  PaginatedMeta? _meta;
  Set<String> _favoriteListingIds = {};
  final Set<String> _favoriteUpdatingIds = {};

  final List<Map<String, String?>> _types = const [
    {'label': 'Barchasi', 'value': null},
    {'label': 'Texnika ijarasi', 'value': 'MACHINERY_RENT'},
    {'label': 'Dehqon mahsulotlari', 'value': 'PRODUCT_SALE'},
    {'label': 'Chorva savdosi', 'value': 'LIVESTOCK_SALE'},
    {'label': 'Texnika savdosi', 'value': 'MACHINERY_SALE'},
    {'label': 'Agro xizmatlar', 'value': 'SERVICE'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
      if (!isAuthenticated) {
        context.go('/login');
        return;
      }
      _categoryId = widget.categoryId;
      _categoryName = widget.categoryName;
      _fetchListings();
    });
  }

  @override
  void didUpdateWidget(covariant ListingsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.categoryId != oldWidget.categoryId ||
        widget.categoryName != oldWidget.categoryName) {
      setState(() {
        _categoryId = widget.categoryId;
        _categoryName = widget.categoryName;
      });
      _fetchListings(loadMore: false);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchListings({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore) return;
      setState(() {
        _isLoadingMore = true;
      });
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        if (!loadMore) {
          _listings.clear();
          _currentPage = 1;
        }
      });
    }

    try {
      final service = ref.read(listingServiceProvider);
      final nextPage = loadMore ? _currentPage + 1 : 1;
      final response = await service.getListings(
        page: nextPage,
        limit: 10,
        type: _selectedType,
        categoryId: _categoryId,
        search: _searchQuery,
      );
      final favoriteIds = await ref
          .read(favoriteServiceProvider)
          .getFavoriteIds();
      final listings = response.data
          .map(
            (listing) =>
                listing.copyWith(isFavorite: favoriteIds.contains(listing.id)),
          )
          .toList();

      setState(() {
        if (loadMore) {
          _currentPage = nextPage;
        }
        _favoriteListingIds = favoriteIds.toSet();
        _listings.addAll(listings);
        _meta = response.meta;
        _isLoading = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = null;
      _selectedType = null;
      _categoryId = null;
      _categoryName = null;
    });
    if (widget.categoryId != null) {
      context.go('/listings');
    } else {
      _fetchListings(loadMore: false);
    }
  }

  void _onSearchSubmitted() {
    setState(() {
      _searchQuery = _searchController.text.trim().isEmpty
          ? null
          : _searchController.text.trim();
    });
    _fetchListings(loadMore: false);
  }

  Future<void> _toggleFavorite(Listing listing) async {
    if (_favoriteUpdatingIds.contains(listing.id)) return;

    final wasFavorite = _favoriteListingIds.contains(listing.id);
    final nextFavorite = !wasFavorite;

    setState(() {
      _favoriteUpdatingIds.add(listing.id);
      _setListingFavoriteState(listing.id, nextFavorite);
    });

    try {
      final service = ref.read(favoriteServiceProvider);
      if (wasFavorite) {
        await service.removeFavorite(listing.id);
      } else {
        await service.addFavorite(listing.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nextFavorite
                ? 'E’lon sevimlilarga qo‘shildi'
                : 'E’lon sevimlilardan olib tashlandi',
          ),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _setListingFavoriteState(listing.id, wasFavorite);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _favoriteUpdatingIds.remove(listing.id);
        });
      }
    }
  }

  void _setListingFavoriteState(String listingId, bool isFavorite) {
    if (isFavorite) {
      _favoriteListingIds.add(listingId);
    } else {
      _favoriteListingIds.remove(listingId);
    }

    final index = _listings.indexWhere((item) => item.id == listingId);
    if (index != -1) {
      _listings[index] = _listings[index].copyWith(isFavorite: isFavorite);
    }
  }

  Widget _buildPlaceholderIcon() {
    return Container(
      color: Colors.green[50],
      child: Icon(Icons.agriculture, color: Colors.green[300], size: 36),
    );
  }

  Widget _buildTypeChips() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _types.length,
        itemBuilder: (context, index) {
          final type = _types[index];
          final isSelected = _selectedType == type['value'];
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                type['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[800],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 12,
                ),
              ),
              selected: isSelected,
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey[300]!,
                  width: 1,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() {
                    _selectedType = type['value'];
                  });
                  _fetchListings(loadMore: false);
                }
              },
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMainContent(bool hasMore) {
    if (_isLoading) {
      return const AppLoadingState(message: 'E‘lonlar yuklanmoqda...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        title: 'E‘lonlarni yuklashda xatolik',
        message: _errorMessage,
        onRetry: () => _fetchListings(loadMore: false),
      );
    }

    if (_listings.isEmpty) {
      return AppEmptyState(
        title: 'Mos e‘lonlar topilmadi',
        message: 'Hozircha bu filterga mos e‘lonlar mavjud emas',
        icon: Icons.search_off_outlined,
        onAction: () => _fetchListings(loadMore: false),
        actionLabel: 'Yangilash',
      );
    }

    return RefreshIndicator(
      onRefresh: () => _fetchListings(loadMore: false),
      child: ListView.builder(
        itemCount: _listings.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _listings.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
              child: AppButton(
                label: 'Yana yuklash',
                loading: _isLoadingMore,
                fullWidth: true,
                onPressed: () => _fetchListings(loadMore: true),
              ),
            );
          }

          final listing = _listings[index];
          final firstImage =
              (listing.images != null && listing.images!.isNotEmpty)
              ? listing.images!.first
              : null;

          return Card(
            clipBehavior: Clip.antiAlias,
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey[100]!, width: 1.5),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                context.push('/listings/${listing.id}');
              },
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Image/Placeholder
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: 96,
                        height: 96,
                        color: Colors.grey[50],
                        child: firstImage != null
                            ? Image.network(
                                firstImage.url,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildPlaceholderIcon(),
                              )
                            : _buildPlaceholderIcon(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Information
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Type Badge and Date
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    listing.typeLabel,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              IconButton(
                                tooltip: listing.isFavorite
                                    ? 'Sevimlilardan olish'
                                    : 'Sevimlilarga qo‘shish',
                                visualDensity: VisualDensity.compact,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 32,
                                  minHeight: 32,
                                ),
                                onPressed:
                                    _favoriteUpdatingIds.contains(listing.id)
                                    ? null
                                    : () => _toggleFavorite(listing),
                                icon: _favoriteUpdatingIds.contains(listing.id)
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        listing.isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: listing.isFavorite
                                            ? Colors.red
                                            : Colors.grey[500],
                                      ),
                              ),
                            ],
                          ),
                          Text(
                            listing.formattedDate.split(' ').first,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[500],
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Title
                          Text(
                            listing.title,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          // Price
                          Text(
                            listing.formattedPrice,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Location and optional contact
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 2),
                              Expanded(
                                child: Text(
                                  listing.address ??
                                      listing.region?.nameUz ??
                                      'Hudud ko‘rsatilmagan',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          if (listing.contactPhone != null &&
                              listing.contactPhone!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.phone_outlined,
                                  size: 12,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  listing.contactPhone!,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!next.isAuthenticated && next.isLoading == false) {
        context.go('/login');
      }
    });

    if (!authState.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasMore = _meta != null && _currentPage < _meta!.totalPages;

    // Active Filters and Clear Buttons
    final hasActiveFilters =
        (_searchQuery != null && _searchQuery!.isNotEmpty) ||
        _selectedType != null ||
        (_categoryId != null && _categoryName != null);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E’lonlar'),
        leading: widget.categoryId != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/categories'),
              )
            : null,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Search Panel Card
              Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey[200]!, width: 1.5),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          decoration: InputDecoration(
                            hintText: 'E’lon qidirish...',
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.grey,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            errorBorder: InputBorder.none,
                            disabledBorder: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 12,
                            ),
                            filled: false,
                          ),
                          onSubmitted: (_) => _onSearchSubmitted(),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _onSearchSubmitted,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Qidirish'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Type Chips Horizontal List
              _buildTypeChips(),

              if (hasActiveFilters) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          if (_categoryId != null && _categoryName != null)
                            Chip(
                              label: Text(
                                'Kategoriya: $_categoryName',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.08),
                              side: BorderSide(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () {
                                setState(() {
                                  _categoryId = null;
                                  _categoryName = null;
                                });
                                if (widget.categoryId != null) {
                                  context.go('/listings');
                                } else {
                                  _fetchListings(loadMore: false);
                                }
                              },
                            ),
                          if (_searchQuery != null && _searchQuery!.isNotEmpty)
                            Chip(
                              label: Text(
                                'Matn: $_searchQuery',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              backgroundColor: Colors.blue[50],
                              side: BorderSide(color: Colors.blue[200]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.zero,
                              deleteIcon: const Icon(Icons.close, size: 14),
                              onDeleted: () {
                                setState(() {
                                  _searchController.clear();
                                  _searchQuery = null;
                                });
                                _fetchListings(loadMore: false);
                              },
                            ),
                        ],
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _clearAllFilters,
                      icon: const Icon(Icons.clear_all, size: 16),
                      label: const Text(
                        'Tozalash',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              // Main content area
              Expanded(child: _buildMainContent(hasMore)),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}
