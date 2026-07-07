import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/network/api_exception.dart';
import 'package:qishloq_ai_mobile/core/network/api_response.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/chat/data/chat_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_button.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

class ChatListPage extends ConsumerStatefulWidget {
  const ChatListPage({super.key});

  @override
  ConsumerState<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends ConsumerState<ChatListPage> {
  final List<ConversationSummary> _conversations = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _errorMessage;
  int _currentPage = 1;
  PaginatedMeta? _meta;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchConversations();
    });
  }

  Future<void> _fetchConversations() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _currentPage = 1;
      _conversations.clear();
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final response = await chatService.getMyConversations(
        page: 1,
        limit: 20,
      );

      if (!mounted) return;
      setState(() {
        _conversations.addAll(response.data);
        _meta = response.meta;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.message;
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

  Future<void> _loadMoreConversations() async {
    if (_isLoadingMore || _meta == null || _currentPage >= _meta!.totalPages) {
      return;
    }

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final chatService = ref.read(chatServiceProvider);
      final response = await chatService.getMyConversations(
        page: nextPage,
        limit: 20,
      );

      if (!mounted) return;
      setState(() {
        _conversations.addAll(response.data);
        _currentPage = nextPage;
        _meta = response.meta;
        _isLoadingMore = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingMore = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
        title: const Text('Xabarlar'),
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _fetchConversations,
          ),
        ],
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const AppLoadingState(message: 'Xabarlar yuklanmoqda...');
    }

    if (_errorMessage != null) {
      return AppErrorState(
        title: 'Xabarlarni yuklab bo‘lmadi',
        message: _errorMessage,
        onRetry: _fetchConversations,
      );
    }

    if (_conversations.isEmpty) {
      return RefreshIndicator(
        onRefresh: _fetchConversations,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.7,
            child: AppEmptyState(
              title: 'Xabarlar yo‘q',
              message: 'E’lon egalariga yozgan xabarlaringiz shu yerda ko‘rinadi.',
              icon: Icons.chat_bubble_outline_rounded,
              actionLabel: 'E’lonlarni ko‘rish',
              onAction: () => context.go('/listings'),
            ),
          ),
        ),
      );
    }

    final hasMore = _meta != null && _currentPage < _meta!.totalPages;

    return RefreshIndicator(
      onRefresh: _fetchConversations,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
        itemCount: _conversations.length + 1 + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeaderCard();
          }

          final convIndex = index - 1;

          if (convIndex == _conversations.length) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: AppButton(
                label: 'Yana yuklash',
                loading: _isLoadingMore,
                fullWidth: true,
                onPressed: _isLoadingMore ? null : _loadMoreConversations,
              ),
            );
          }

          final conv = _conversations[convIndex];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildConversationCard(conv),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.chat_bubble_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Xabarlaringiz',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'E’lon egalari va xaridorlar bilan yozishmalaringiz shu yerda ko‘rinadi.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[700],
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(ConversationSummary conv) {
    final currentUserId = ref.read(authControllerProvider).user?.id;
    final otherUser = conv.otherParticipant ??
        (currentUserId == conv.buyer.id ? conv.seller : conv.buyer);
    final partnerName = otherUser.fullName.isNotEmpty ? otherUser.fullName : 'Foydalanuvchi';
    final partnerRole = otherUser.roleLabel;

    final lastMsg = conv.lastMessage;
    final hasLastMsg = lastMsg != null && lastMsg.body.trim().isNotEmpty;
    final lastMsgText = hasLastMsg ? lastMsg.body : 'Hali xabar yozilmagan';
    final isUnread = conv.unreadCount > 0;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isUnread
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.4)
              : const Color(0xFFEFEFEF),
          width: isUnread ? 1.5 : 1.0,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () async {
          await context.push('/chat/${conv.id}');
          _fetchConversations();
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.12),
                    child: Text(
                      partnerName.isNotEmpty ? partnerName[0].toUpperCase() : '?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
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
                                partnerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (otherUser.isVerified) ...[
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.verified,
                                size: 16,
                                color: Colors.green,
                              ),
                            ],
                          ],
                        ),
                        if (partnerRole.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            partnerRole,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    conv.formattedUpdatedAt.split(' ').first,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
              const Divider(height: 24),
              // Listing Row
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      conv.listing.typeLabel,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      conv.listing.title,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    conv.listing.formattedPrice,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Message Body + Badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      lastMsgText,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
                        color: isUnread
                            ? Colors.black87
                            : (hasLastMsg ? Colors.grey[600] : Colors.grey[400]),
                        fontStyle: hasLastMsg ? FontStyle.normal : FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isUnread) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green[600],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 20,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        conv.unreadCount > 99 ? '99+' : '${conv.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
