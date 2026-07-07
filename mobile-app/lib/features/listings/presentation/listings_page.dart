import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/core/network/api_response.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';

class ListingsPage extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ListingsPage({
    super.key,
    this.categoryId,
    this.categoryName,
  });

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

      setState(() {
        if (loadMore) {
          _currentPage = nextPage;
        }
        _listings.addAll(response.data);
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

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (!next.isAuthenticated && next.isLoading == false) {
        context.go('/login');
      }
    });

    if (!authState.isAuthenticated) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final hasMore = _meta != null && _currentPage < _meta!.totalPages;

    return Scaffold(
      appBar: AppBar(
        title: const Text('E’lonlar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 12),
              // Search Box
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'E’lonlarni qidirish...',
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      onSubmitted: (_) {
                        setState(() {
                          _searchQuery = _searchController.text;
                        });
                        _fetchListings(loadMore: false);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    onPressed: () {
                      setState(() {
                        _searchQuery = _searchController.text;
                      });
                      _fetchListings(loadMore: false);
                    },
                    icon: const Icon(Icons.search),
                  ),
                  if (_searchQuery != null && _searchQuery!.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    IconButton.outlined(
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _searchQuery = null;
                        });
                        _fetchListings(loadMore: false);
                      },
                      icon: const Icon(Icons.clear),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              // Type Filter
              Row(
                children: [
                  const Text(
                    'Turi: ',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedType,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      isDense: true,
                      items: const [
                        DropdownMenuItem(value: null, child: Text('Barchasi')),
                        DropdownMenuItem(value: 'MACHINERY_RENT', child: Text('Texnika ijarasi')),
                        DropdownMenuItem(value: 'PRODUCT_SALE', child: Text('Dehqon mahsulotlari')),
                        DropdownMenuItem(value: 'LIVESTOCK_SALE', child: Text('Chorva savdosi')),
                        DropdownMenuItem(value: 'MACHINERY_SALE', child: Text('Texnika savdosi')),
                        DropdownMenuItem(value: 'SERVICE', child: Text('Agro xizmatlar')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedType = value;
                        });
                        _fetchListings(loadMore: false);
                      },
                    ),
                  ),
                ],
              ),
              // Category Chip (if filtered by category)
              if (_categoryId != null && _categoryName != null) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: InputChip(
                    label: Text('Kategoriya: $_categoryName'),
                    onDeleted: () {
                      setState(() {
                        _categoryId = null;
                        _categoryName = null;
                      });
                      _fetchListings(loadMore: false);
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              // Main content area
              Expanded(
                child: _buildMainContent(hasMore),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent(bool hasMore) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'E’lonlar yuklanmoqda...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Xatolik yuz berdi:\n$_errorMessage',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Qayta urinib ko‘rish',
                onPressed: () => _fetchListings(loadMore: false),
              ),
            ],
          ),
        ),
      );
    }

    if (_listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Mos e’lonlar topilmadi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            AppButton(
              label: 'Yangilash',
              onPressed: () => _fetchListings(loadMore: false),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _listings.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _listings.length) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: _isLoadingMore
                ? const Center(child: CircularProgressIndicator())
                : AppButton(
                    label: 'Yana yuklash',
                    onPressed: () => _fetchListings(loadMore: true),
                  ),
          );
        }

        final listing = _listings[index];
        final firstImage = (listing.images != null && listing.images!.isNotEmpty)
            ? listing.images!.first
            : null;

        return Card(
          clipBehavior: Clip.antiAlias,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.grey[200]!),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              context.push('/listings/${listing.id}');
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 90,
                      height: 90,
                      color: Colors.grey[100],
                      child: firstImage != null
                          ? Image.network(
                              firstImage.url,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported_outlined,
                                color: Colors.grey,
                              ),
                            )
                          : const Icon(
                              Icons.image_outlined,
                              color: Colors.grey,
                              size: 32,
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                listing.typeLabel,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                ),
                              ),
                            ),
                            Text(
                              listing.formattedDate,
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
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          listing.formattedPrice,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on_outlined, size: 12, color: Colors.grey),
                            const SizedBox(width: 2),
                            Expanded(
                              child: Text(
                                listing.address ?? listing.region?.nameUz ?? 'Hudud ko‘rsatilmagan',
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        if (listing.contactPhone != null && listing.contactPhone!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.phone_outlined, size: 12, color: Colors.grey),
                              const SizedBox(width: 2),
                              Text(
                                listing.contactPhone!,
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
    );
  }
}
