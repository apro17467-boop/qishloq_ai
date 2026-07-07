import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/network/api_response.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

class FavoritesPage extends ConsumerStatefulWidget {
  const FavoritesPage({super.key});

  @override
  ConsumerState<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends ConsumerState<FavoritesPage> {
  final List<Listing> _favorites = [];
  PaginatedMeta? _meta;
  int _currentPage = 1;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  final Set<String> _updatingIds = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
      if (!isAuthenticated) {
        context.go('/login');
        return;
      }
      _fetchFavorites();
    });
  }

  Future<void> _fetchFavorites({bool loadMore = false}) async {
    if (loadMore) {
      if (_isLoadingMore) return;
      setState(() => _isLoadingMore = true);
    } else {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _favorites.clear();
        _currentPage = 1;
      });
    }

    try {
      final nextPage = loadMore ? _currentPage + 1 : 1;
      final response = await ref
          .read(favoriteServiceProvider)
          .getMyFavorites(page: nextPage, limit: 10);

      if (!mounted) return;

      setState(() {
        if (loadMore) {
          _currentPage = nextPage;
        }
        _favorites.addAll(response.data);
        _meta = response.meta;
        _isLoading = false;
        _isLoadingMore = false;
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

  Future<void> _removeFavorite(Listing listing) async {
    if (_updatingIds.contains(listing.id)) return;

    setState(() {
      _updatingIds.add(listing.id);
    });

    try {
      await ref.read(favoriteServiceProvider).removeFavorite(listing.id);
      if (!mounted) return;

      setState(() {
        _favorites.removeWhere((item) => item.id == listing.id);
        if (_meta != null) {
          final nextTotal = _meta!.total > 0 ? _meta!.total - 1 : 0;
          _meta = PaginatedMeta(
            page: _meta!.page,
            limit: _meta!.limit,
            total: nextTotal,
            totalPages: _meta!.totalPages,
          );
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E’lon sevimlilardan olib tashlandi'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _updatingIds.remove(listing.id);
        });
      }
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sevimlilar'),
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
      body: SafeArea(child: _buildBody()),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Sevimlilar yuklanmoqda...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        title: 'Sevimlilarni yuklashda xatolik',
        message: _errorMessage,
        onRetry: () => _fetchFavorites(),
      );
    }

    if (_favorites.isEmpty) {
      return AppEmptyState(
        title: 'Sevimli e’lonlar yo‘q',
        message: 'Yoqtirgan e’lonlaringizni shu yerda saqlab boring.',
        icon: Icons.favorite_border,
        actionLabel: 'E’lonlarni ko‘rish',
        onAction: () => context.go('/listings'),
      );
    }

    final hasMore = _meta != null && _currentPage < _meta!.totalPages;

    return RefreshIndicator(
      onRefresh: () => _fetchFavorites(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        itemCount: _favorites.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == _favorites.length) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 24),
              child: AppButton(
                label: 'Yana yuklash',
                loading: _isLoadingMore,
                fullWidth: true,
                onPressed: _isLoadingMore
                    ? null
                    : () => _fetchFavorites(loadMore: true),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildFavoriteCard(_favorites[index]),
          );
        },
      ),
    );
  }

  Widget _buildFavoriteCard(Listing listing) {
    final firstImage = (listing.images != null && listing.images!.isNotEmpty)
        ? listing.images!.first
        : null;
    final isUpdating = _updatingIds.contains(listing.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!, width: 1.5),
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
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          tooltip: 'Sevimlilardan olib tashlash',
                          onPressed: isUpdating
                              ? null
                              : () => _removeFavorite(listing),
                          icon: isUpdating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.favorite, color: Colors.red),
                        ),
                      ],
                    ),
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
