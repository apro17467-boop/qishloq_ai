import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/network/api_exception.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/chat/data/chat_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

class ChatPage extends ConsumerStatefulWidget {
  final String conversationId;

  const ChatPage({super.key, required this.conversationId});

  @override
  ConsumerState<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends ConsumerState<ChatPage> {
  final List<ChatMessage> _messages = [];
  ConversationSummary? _conversation;
  bool _isLoading = false;
  bool _isLoadingOlder = false;
  bool _isSending = false;
  String? _errorMessage;
  int _firstLoadedPage = 1;
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAuthAndLoad();
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkAuthAndLoad() async {
    final authState = ref.read(authControllerProvider);
    if (!authState.isAuthenticated) {
      context.go('/login');
      return;
    }
    _loadChat();
  }

  Future<void> _loadChat() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _messages.clear();
    });

    try {
      final chatService = ref.read(chatServiceProvider);

      // 1. Try to find the conversation details from the list
      final inboxResponse = await chatService.getMyConversations(page: 1, limit: 100);
      final match = inboxResponse.data.firstWhere(
        (c) => c.id == widget.conversationId,
        orElse: () => ConversationSummary(
          id: widget.conversationId,
          listing: const ChatListingSummary(id: '', title: 'Chat', type: '', status: ''),
          buyer: const ChatUserSummary(id: '', fullName: 'Foydalanuvchi', role: '', isVerified: false),
          seller: const ChatUserSummary(id: '', fullName: 'Foydalanuvchi', role: '', isVerified: false),
          unreadCount: 0,
          createdAt: '',
          updatedAt: '',
        ),
      );

      setState(() {
        _conversation = match.listing.id.isNotEmpty ? match : null;
      });

      // 2. Load the first page of messages
      final messagesResponse = await chatService.getMessages(
        conversationId: widget.conversationId,
        page: 1,
        limit: 30,
      );

      final totalPages = messagesResponse.meta.totalPages;

      if (totalPages > 1) {
        // Offset pagination: latest messages are on the last page. Fetch last page.
        final lastPageResponse = await chatService.getMessages(
          conversationId: widget.conversationId,
          page: totalPages,
          limit: 30,
        );

        if (!mounted) return;
        setState(() {
          _messages.addAll(lastPageResponse.data);
          _firstLoadedPage = totalPages;
          _isLoading = false;
        });
      } else {
        if (!mounted) return;
        setState(() {
          _messages.addAll(messagesResponse.data);
          _firstLoadedPage = 1;
          _isLoading = false;
        });
      }

      _scrollToBottom();
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

  Future<void> _loadOlderMessages() async {
    if (_isLoadingOlder || _firstLoadedPage <= 1) return;

    setState(() {
      _isLoadingOlder = true;
    });

    try {
      final prevPage = _firstLoadedPage - 1;
      final chatService = ref.read(chatServiceProvider);
      final response = await chatService.getMessages(
        conversationId: widget.conversationId,
        page: prevPage,
        limit: 30,
      );

      if (!mounted) return;
      setState(() {
        _messages.insertAll(0, response.data);
        _firstLoadedPage = prevPage;
        _isLoadingOlder = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingOlder = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingOlder = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _sendMessage() async {
    final body = _messageController.text.trim();
    if (body.isEmpty || _isSending) return;

    if (body.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Xabar uzunligi 2000 ta belgidan oshmasligi kerak'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final chatService = ref.read(chatServiceProvider);
      final message = await chatService.sendMessage(
        conversationId: widget.conversationId,
        body: body,
      );

      if (!mounted) return;
      setState(() {
        _messages.add(message);
        _messageController.clear();
        _isSending = false;
      });
      _scrollToBottom();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message), behavior: SnackBarBehavior.floating),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSending = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final otherUser = _conversation?.otherParticipant;
    final titleText = otherUser?.fullName ?? 'Chat';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadChat,
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
        onRetry: _loadChat,
      );
    }

    final currentUserId = ref.read(authControllerProvider).user?.id ?? '';
    final showOlderButton = _firstLoadedPage > 1;

    return Column(
      children: [
        // Mini listing card
        if (_conversation != null && _conversation!.listing.id.isNotEmpty)
          _buildMiniListingCard(_conversation!.listing),

        // Message history list
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadChat,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length + (showOlderButton ? 1 : 0),
              itemBuilder: (context, index) {
                if (showOlderButton) {
                  if (index == 0) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TextButton.icon(
                          onPressed: _isLoadingOlder ? null : _loadOlderMessages,
                          icon: _isLoadingOlder
                              ? const SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.history, size: 16),
                          label: const Text('Oldingi xabarlarni yuklash'),
                        ),
                      ),
                    );
                  }
                  return _buildMessageBubble(_messages[index - 1], currentUserId);
                }

                return _buildMessageBubble(_messages[index], currentUserId);
              },
            ),
          ),
        ),

        // Message input area
        _buildInputArea(),
      ],
    );
  }

  Widget _buildMiniListingCard(ChatListingSummary listing) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        listing.typeLabel,
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
                        listing.title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  listing.formattedPrice,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () {
              context.push('/listings/${listing.id}');
            },
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Ko‘rish',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, String currentUserId) {
    final isMe = msg.senderId == currentUserId;
    final timeStr = msg.formattedTime;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary
              : const Color(0xFFF1F3F5),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 0),
            bottomRight: Radius.circular(isMe ? 0 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              msg.body,
              style: TextStyle(
                color: isMe ? Colors.white : Colors.black87,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: TextStyle(
                color: isMe ? Colors.white70 : Colors.grey[500],
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              maxLength: 2000,
              maxLines: null,
              decoration: const InputDecoration(
                hintText: 'Xabar yozing...',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                counterText: '', // Hide the maxLength counter UI to keep it clean
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: _isSending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Icon(
                    Icons.send,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            onPressed: _isSending ? null : _sendMessage,
          ),
        ],
      ),
    );
  }
}
