import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/core/providers/core_providers.dart';
import 'package:qishloq_ai_mobile/features/auth/application/auth_state.dart';
import 'package:qishloq_ai_mobile/features/categories/data/category_models.dart';
import 'package:qishloq_ai_mobile/shared/widgets/app_state_widgets.dart';

final categoriesFutureProvider = FutureProvider.autoDispose<List<Category>>((ref) {
  final service = ref.watch(categoryServiceProvider);
  return service.getCategories();
});

const Map<String, String> _typeLabels = {
  'MACHINERY_RENT': 'Texnika ijarasi',
  'PRODUCT_SALE': 'Dehqon mahsulotlari',
  'LIVESTOCK_SALE': 'Chorva savdosi',
  'MACHINERY_SALE': 'Texnika savdosi',
  'SERVICE': 'Agro xizmatlar',
};

String _getTypeLabel(String type) {
  return _typeLabels[type] ?? type;
}

class CategoriesPage extends ConsumerStatefulWidget {
  const CategoriesPage({super.key});

  @override
  ConsumerState<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends ConsumerState<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isAuthenticated = ref.read(authControllerProvider).isAuthenticated;
      if (!isAuthenticated) {
        context.go('/login');
      }
    });
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

    final categoriesAsync = ref.watch(categoriesFutureProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kategoriyalar'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: categoriesAsync.when(
            loading: () => const AppLoadingState(
              message: 'Kategoriyalar yuklanmoqda...',
            ),
            error: (error, stackTrace) => AppErrorState(
              title: 'Kategoriyalarni yuklashda xatolik',
              message: error.toString(),
              onRetry: () => ref.refresh(categoriesFutureProvider),
            ),
            data: (categories) {
              final activeCategories = categories.where((c) => c.isActive).toList();

              if (activeCategories.isEmpty) {
                return AppEmptyState(
                  title: 'Kategoriyalar topilmadi',
                  message: 'Hozircha faol kategoriyalar mavjud emas',
                  icon: Icons.category_outlined,
                  onAction: () => ref.refresh(categoriesFutureProvider),
                  actionLabel: 'Yangilash',
                );
              }

              return ListView.builder(
                itemCount: activeCategories.length,
                itemBuilder: (context, index) {
                  final category = activeCategories[index];
                  return Card(
                    elevation: 0,
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        context.go('/listings?categoryId=${category.id}&categoryName=${Uri.encodeComponent(category.nameUz)}');
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    category.nameUz,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).colorScheme.primaryContainer,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    _getTypeLabel(category.type),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Slug: ${category.slug}',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
