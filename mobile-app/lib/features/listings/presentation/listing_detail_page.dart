import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/network/api_exception.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/listings/data/listing_models.dart';
import 'package:qishloq_ai_mobile/shared/utils/contact_actions.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

class ListingDetailPage extends ConsumerStatefulWidget {
  final String listingId;

  const ListingDetailPage({super.key, required this.listingId});

  @override
  ConsumerState<ListingDetailPage> createState() => _ListingDetailPageState();
}

class _ListingDetailPageState extends ConsumerState<ListingDetailPage> {
  bool _isLoading = false;
  String? _errorMessage;
  int _statusCode = 200;
  Listing? _listing;
  int _currentImageIndex = 0;
  bool _isFavoriteUpdating = false;
  bool _isCreatingConversation = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchDetail();
    });
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _statusCode = 200;
    });

    try {
      final service = ref.read(listingServiceProvider);
      final listing = await service.getListingDetail(widget.listingId);
      final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
      final favoriteIds = isAuthenticated
          ? await ref.read(favoriteServiceProvider).getFavoriteIds()
          : <String>[];
      setState(() {
        _listing = listing.copyWith(
          isFavorite: favoriteIds.contains(listing.id),
        );
        _isLoading = false;
      });
    } on ApiException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _statusCode = e.statusCode ?? 500;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _statusCode = 500;
        _isLoading = false;
      });
    }
  }

  void _showContactBottomSheet(BuildContext context, String phone) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Bog‘lanish',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[50],
                  child: Icon(Icons.phone, color: Colors.green[700]),
                ),
                title: const Text(
                  'Qo‘ng‘iroq qilish',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(phone),
                onTap: () {
                  Navigator.pop(context);
                  ContactActions.launchPhoneCall(this.context, phone);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blue[50],
                  child: Icon(Icons.sms_outlined, color: Colors.blue[700]),
                ),
                title: const Text(
                  'SMS yuborish',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(phone),
                onTap: () {
                  Navigator.pop(context);
                  ContactActions.launchSms(this.context, phone);
                },
              ),
              ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.orange[50],
                  child: Icon(Icons.copy, color: Colors.orange[700]),
                ),
                title: const Text(
                  'Telefonni nusxalash',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(phone),
                onTap: () {
                  Navigator.pop(context);
                  ContactActions.copyPhone(this.context, phone);
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  Future<void> _toggleFavorite() async {
    final listing = _listing;
    if (listing == null || _isFavoriteUpdating) return;
    if (!ref.read(authControllerProvider).isAuthenticated) {
      context.push('/login');
      return;
    }

    setState(() {
      _isFavoriteUpdating = true;
      _listing = listing.copyWith(isFavorite: !listing.isFavorite);
    });

    try {
      final service = ref.read(favoriteServiceProvider);
      if (listing.isFavorite) {
        await service.removeFavorite(listing.id);
      } else {
        await service.addFavorite(listing.id);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            !listing.isFavorite
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
        _listing = listing;
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
          _isFavoriteUpdating = false;
        });
      }
    }
  }

  Future<void> _startConversation(String listingId) async {
    final authState = ref.read(authControllerProvider);
    if (!authState.isAuthenticated) {
      context.push('/login');
      return;
    }

    setState(() {
      _isCreatingConversation = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final conversation = await chatService.createConversation(listingId);
      if (mounted) {
        setState(() {
          _isCreatingConversation = false;
        });
        context.push('/chat/${conversation.id}');
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingConversation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isCreatingConversation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color fgColor;
    String label;

    switch (status) {
      case 'ACTIVE':
        bgColor = Colors.green[50]!;
        fgColor = Colors.green[700]!;
        label = 'Faol';
        break;
      case 'PENDING':
        bgColor = Colors.amber[50]!;
        fgColor = Colors.amber[800]!;
        label = 'Moderatsiyada';
        break;
      case 'REJECTED':
        bgColor = Colors.red[50]!;
        fgColor = Colors.red[700]!;
        label = 'Rad etilgan';
        break;
      case 'ARCHIVED':
        bgColor = Colors.grey[100]!;
        fgColor = Colors.grey[600]!;
        label = 'Arxivda';
        break;
      default:
        bgColor = Colors.blue[50]!;
        fgColor = Colors.blue[700]!;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: fgColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: fgColor,
        ),
      ),
    );
  }

  Widget _buildImageGallery(List<ListingImage> images) {
    if (images.isEmpty) {
      return Container(
        height: 280,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.agriculture, size: 64, color: Colors.green[300]),
            const SizedBox(height: 12),
            Text(
              'Rasm qo‘shilmagan',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      children: [
        ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: SizedBox(
            height: 300,
            child: PageView.builder(
              itemCount: images.length,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.network(
                  images[index].url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: Colors.green[50],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.agriculture,
                          size: 64,
                          color: Colors.green[300],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Rasm yuklanmadi',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${_currentImageIndex + 1} / ${images.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildMainInfoCard(Listing listing) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Type Badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    listing.typeLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Status Badge
                _buildStatusBadge(listing.status),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              listing.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              listing.formattedPrice,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            const Divider(height: 24),
            Row(
              children: [
                const Icon(Icons.access_time, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  'Yaratilgan: ${listing.formattedDate}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            if (listing.updatedAt != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(
                    Icons.edit_calendar_outlined,
                    size: 14,
                    color: Colors.grey,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Yangilangan: ${_formatDate(listing.updatedAt!)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionCard(Listing listing) {
    final hasDesc =
        listing.description != null && listing.description!.trim().isNotEmpty;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tavsif',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              hasDesc ? listing.description! : 'Tavsif kiritilmagan.',
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: hasDesc ? Colors.black87 : Colors.grey[600],
                fontStyle: hasDesc ? FontStyle.normal : FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(Listing listing) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Joylashuv',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (listing.region?.nameUz != null) ...[
                        Text(
                          listing.region!.nameUz,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                      ],
                      Text(
                        listing.address ?? 'Hudud ko‘rsatilmagan',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(Listing listing) {
    final hasPhone =
        listing.contactPhone != null && listing.contactPhone!.trim().isNotEmpty;
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bog‘lanish',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.phone_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    hasPhone
                        ? listing.contactPhone!
                        : 'Telefon raqam ko‘rsatilmagan',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: hasPhone ? Colors.black87 : Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
            if (hasPhone) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => ContactActions.launchPhoneCall(context, listing.contactPhone!),
                      icon: const Icon(Icons.phone, size: 18),
                      label: const Text('Qo‘ng‘iroq'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ContactActions.launchSms(context, listing.contactPhone!),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Icon(
                        Icons.sms_outlined,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => ContactActions.copyPhone(context, listing.contactPhone!),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Icon(
                        Icons.copy,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget? _buildSellerCard(Listing listing) {
    final seller = listing.seller;
    if (seller == null || seller.id.isEmpty) {
      return null;
    }

    final currentUserId = ref.read(authControllerProvider).user?.id;
    final isOwnListing = currentUserId == seller.id;
    final showChatButton = !isOwnListing && listing.status == 'ACTIVE';

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'E’lon egasi',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(
                    Icons.person_outline,
                    color: Theme.of(context).colorScheme.primary,
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
                              seller.displayName,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (seller.isVerified == true) ...[
                            const SizedBox(width: 6),
                            Icon(
                              Icons.verified_outlined,
                              size: 18,
                              color: Colors.green[700],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        seller.roleLabel,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (showChatButton) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isCreatingConversation
                      ? null
                      : () => _startConversation(listing.id),
                  icon: _isCreatingConversation
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.chat_bubble_outline, size: 18),
                  label: Text(_isCreatingConversation ? 'Bog‘lanmoqda...' : 'Xabar yozish'),
                  style: ElevatedButton.styleFrom(
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/sellers/${seller.id}'),
                icon: const Icon(Icons.person_search_outlined, size: 18),
                label: const Text('Profilni ko‘rish'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget? _buildBottomNavigationBar(Listing? listing) {
    if (listing == null) return null;
    final hasPhone =
        listing.contactPhone != null && listing.contactPhone!.trim().isNotEmpty;
    if (!hasPhone) return null;

    final phone = listing.contactPhone!;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: 12 + MediaQuery.of(context).padding.bottom,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aloqa uchun raqam:',
                  style: TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () => ContactActions.launchPhoneCall(context, phone),
            icon: const Icon(Icons.phone, size: 18),
            label: const Text('Qo‘ng‘iroq'),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _showContactBottomSheet(context, phone),
            icon: Icon(
              Icons.more_horiz,
              color: Theme.of(context).colorScheme.primary,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              padding: const EdgeInsets.all(12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('E’lon tafsiloti'),
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
        actions: authState.isAuthenticated
            ? [
                IconButton(
                  tooltip: _listing?.isFavorite == true
                      ? 'Sevimlilardan olish'
                      : 'Sevimlilarga qo‘shish',
                  onPressed: _listing == null || _isFavoriteUpdating
                      ? null
                      : _toggleFavorite,
                  icon: _isFavoriteUpdating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _listing?.isFavorite == true
                              ? Icons.favorite
                              : Icons.favorite_border,
                          color: _listing?.isFavorite == true
                              ? Colors.red
                              : null,
                        ),
                ),
              ]
            : null,
      ),
      body: SafeArea(child: _buildBody()),
      bottomNavigationBar: _buildBottomNavigationBar(_listing),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Tafsilotlar yuklanmoqda...');
    }

    if (_errorMessage != null) {
      final isNotFound = _statusCode == 404;
      return AppErrorState(
        title: isNotFound
            ? 'E’lon topilmadi yoki faol emas'
            : 'Xatolik yuz berdi',
        message: isNotFound ? null : _errorMessage,
        icon: isNotFound ? Icons.search_off : Icons.error_outline,
        retryLabel: 'Qayta urinish',
        onRetry: isNotFound ? null : _fetchDetail,
        backLabel: 'E’lonlar ro‘yxatiga qaytish',
        onBack: () => context.go('/listings'),
      );
    }

    final listing = _listing;
    if (listing == null) {
      return const Center(child: Text('Ma’lumot topilmadi'));
    }

    final images = listing.images ?? [];
    final sellerCard = _buildSellerCard(listing);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image gallery section
          _buildImageGallery(images),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Main Info Card
                _buildMainInfoCard(listing),
                const SizedBox(height: 16),
                // Description Card
                _buildDescriptionCard(listing),
                const SizedBox(height: 16),
                // Location Card
                _buildLocationCard(listing),
                const SizedBox(height: 16),
                if (sellerCard != null) ...[
                  sellerCard,
                  const SizedBox(height: 16),
                ],
                // Contact Card
                _buildContactCard(listing),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString).toLocal();
      final day = dateTime.day.toString().padLeft(2, '0');
      final month = dateTime.month.toString().padLeft(2, '0');
      final year = dateTime.year;
      final hour = dateTime.hour.toString().padLeft(2, '0');
      final minute = dateTime.minute.toString().padLeft(2, '0');
      return '$day.$month.$year $hour:$minute';
    } catch (_) {
      return dateString;
    }
  }
}
