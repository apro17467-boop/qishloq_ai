import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/network/api_exception.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/ai_advice/data/ai_question_models.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

// ---------------------------------------------------------------------------
// Status filter
// ---------------------------------------------------------------------------
const _statusFilters = [
  _StatusFilter(label: 'Barchasi', value: null),
  _StatusFilter(label: 'Kutilmoqda', value: 'PENDING'),
  _StatusFilter(label: 'Javob berilgan', value: 'ANSWERED'),
  _StatusFilter(label: 'Xatolik', value: 'FAILED'),
];

class _StatusFilter {
  final String label;
  final String? value;
  const _StatusFilter({required this.label, required this.value});
}

class AiAdvicePage extends ConsumerStatefulWidget {
  const AiAdvicePage({super.key});

  @override
  ConsumerState<AiAdvicePage> createState() => _AiAdvicePageState();
}

class _AiAdvicePageState extends ConsumerState<AiAdvicePage> {
  // ---------- Form ----------
  final _questionController = TextEditingController();
  bool _isSubmitting = false;
  String? _submitError;
  String? _submitSuccess;

  // ---------- Questions list ----------
  final List<AiQuestion> _questions = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;
  String? _loadError;
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

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
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
    _loadQuestions(reset: true);
  }

  Future<void> _loadQuestions({bool reset = false}) async {
    if (reset) {
      setState(() {
        _isLoading = true;
        _loadError = null;
        _questions.clear();
        _currentPage = 1;
        _totalPages = 1;
        _totalItems = 0;
      });
    } else {
      setState(() => _isLoadingMore = true);
    }

    try {
      final service = ref.read(aiQuestionServiceProvider);
      final response = await service.getMyQuestions(
        page: _currentPage,
        limit: 10,
        status: _selectedStatus,
      );

      setState(() {
        if (reset) _questions.clear();
        _questions.addAll(response.data);
        _totalPages = response.meta.totalPages;
        _totalItems = response.meta.total;
        _isLoading = false;
        _isLoadingMore = false;
        _loadError = null;
      });
    } catch (e) {
      setState(() {
        _loadError = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
        _isLoadingMore = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_isLoadingMore || _currentPage >= _totalPages) return;
    _currentPage++;
    await _loadQuestions();
  }

  void _onStatusChanged(String? newStatus) {
    _selectedStatus = newStatus;
    _loadQuestions(reset: true);
  }

  Future<void> _submitQuestion() async {
    final text = _questionController.text.trim();

    // Frontend validation
    if (text.isEmpty) {
      setState(() => _submitError = 'Savol matnini kiriting');
      return;
    }
    if (text.length < 10) {
      setState(() => _submitError = 'Savol kamida 10 ta belgi bo\'lsin');
      return;
    }
    if (text.length > 3000) {
      setState(() => _submitError = 'Savol 3000 ta belgidan oshmasin');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitError = null;
      _submitSuccess = null;
    });

    try {
      await ref.read(aiQuestionServiceProvider).createQuestion(question: text);

      setState(() {
        _submitSuccess = 'Savolingiz yuborildi.';
        _isSubmitting = false;
      });
      _questionController.clear();

      // Ro'yxatni 1-sahifadan qayta yukla
      await _loadQuestions(reset: true);
    } on ApiException catch (e) {
      setState(() {
        _submitError = e.message;
        _isSubmitting = false;
      });
    } catch (e) {
      setState(() {
        _submitError = e.toString().replaceFirst('Exception: ', '');
        _isSubmitting = false;
      });
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

    if (!authState.isAuthenticated) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI maslahat'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildQuestionForm(),
            _buildFilterChips(),
            Expanded(child: _buildQuestionsList()),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionForm() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // AI info banner
          const AppInfoBox(
            message: 'AI maslahat tavsiya xarakteriga ega. Muhim holatlarda mutaxassis bilan maslahat qiling.',
          ),
          const SizedBox(height: 10),

          // Text input
          TextField(
            controller: _questionController,
            maxLines: 3,
            minLines: 2,
            maxLength: 3000,
            decoration: InputDecoration(
              hintText:
                  'Masalan: Pomidor barglari sarg\'aymoqda, nima qilish kerak?',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              counterStyle: const TextStyle(fontSize: 11),
            ),
            textInputAction: TextInputAction.newline,
          ),

          // Submit error / success
          if (_submitError != null) ...[
            const SizedBox(height: 6),
            AppInfoBox(
              message: _submitError!,
              icon: Icons.error_outline,
              backgroundColor: Colors.red[50],
              foregroundColor: Colors.red[800],
            ),
          ],
          if (_submitSuccess != null) ...[
            const SizedBox(height: 6),
            AppInfoBox(
              message: _submitSuccess!,
              icon: Icons.check_circle_outline,
              backgroundColor: Colors.green[50],
              foregroundColor: Colors.green[800],
            ),
          ],
          const SizedBox(height: 8),

          // Submit button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.send_outlined, size: 18),
              label: Text(_isSubmitting ? 'Yuklanmoqda...' : 'Savol yuborish'),
              onPressed: _isSubmitting ? null : _submitQuestion,
            ),
          ),
        ],
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
            selectedColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            labelStyle: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Theme.of(context).colorScheme.primary : null,
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuestionsList() {
    if (_isLoading) {
      return const AppLoadingState(
        message: 'Yuklanmoqda...',
      );
    }

    if (_loadError != null) {
      return AppErrorState(
        title: 'AI savollarni yuklashda xatolik yuz berdi',
        message: _loadError,
        onRetry: () => _loadQuestions(reset: true),
      );
    }

    if (_questions.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => _loadQuestions(reset: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _questions.length + 1,
        itemBuilder: (context, index) {
          if (index == _questions.length) {
            return _buildLoadMoreSection();
          }
          return _buildQuestionCard(_questions[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final isFiltered = _selectedStatus != null;
    return AppEmptyState(
      title: isFiltered ? 'Bu statusda savollar topilmadi' : 'Hali AI savol yubormagansiz',
      message: isFiltered
          ? 'Boshqa filtr tanlang yoki barcha savollarni ko\'ring'
          : 'Yuqoridagi forma orqali birinchi savolingizni yuboring',
      icon: isFiltered ? Icons.filter_list_off : Icons.psychology_alt,
      onAction: isFiltered ? () => _onStatusChanged(null) : null,
      actionLabel: isFiltered ? 'Filtrni tozalash' : null,
    );
  }

  // ---------------------------------------------------------------------------
  // Load more section
  // ---------------------------------------------------------------------------
  Widget _buildLoadMoreSection() {
    final hasMore = _currentPage < _totalPages;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          Text(
            'Jami: $_totalItems ta savol',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          if (hasMore) ...[
            const SizedBox(height: 10),
            _isLoadingMore
                ? const CircularProgressIndicator()
                : OutlinedButton.icon(
                    icon: const Icon(Icons.expand_more),
                    label: const Text('Yana yuklash'),
                    onPressed: _loadMore,
                  ),
          ] else if (_questions.length > 10) ...[
            const SizedBox(height: 4),
            const Text(
              'Barcha savollar yuklandi',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Single question card
  // ---------------------------------------------------------------------------
  Widget _buildQuestionCard(AiQuestion question) {
    final statusColor = question.statusColor;
    final statusIcon = question.statusIcon;
    final hasAnswer = question.answer != null && question.answer!.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: status badge + date
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Status badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(statusIcon, size: 12, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        question.statusLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ),
                // Date
                Text(
                  question.formattedDate,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Question
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.help_outline,
                          size: 14,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Savol',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _ExpandableText(
                    text: question.question,
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Answer
            if (hasAnswer) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.withValues(alpha: 0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.psychology_alt,
                            size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text(
                          'AI javobi',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    _ExpandableText(
                      text: question.answer!,
                      maxLines: 5,
                    ),
                  ],
                ),
              ),
            ] else ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  question.status == 'FAILED'
                      ? 'AI javob bera olmadi. Iltimos, qayta urinib ko\'ring.'
                      : 'Javob hali tayyor emas',
                  style: TextStyle(
                    fontSize: 13,
                    color: statusColor.withValues(alpha: 0.85),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],

            // Disclaimer info
            if (question.disclaimerShown) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(Icons.shield_outlined,
                      size: 12, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    question.disclaimerText,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expandable text widget
// ---------------------------------------------------------------------------
class _ExpandableText extends StatefulWidget {
  final String text;
  final int maxLines;

  const _ExpandableText({required this.text, required this.maxLines});

  @override
  State<_ExpandableText> createState() => _ExpandableTextState();
}

class _ExpandableTextState extends State<_ExpandableText> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.text,
          style: const TextStyle(fontSize: 13, height: 1.5),
          maxLines: _expanded ? null : widget.maxLines,
          overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        // Show toggle only if text is long
        if (widget.text.length > 120) ...[
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                _expanded ? 'Qisqartirish' : 'To\'liq ko\'rish',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
