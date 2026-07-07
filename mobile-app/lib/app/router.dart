import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/features/ai_advice/presentation/ai_advice_placeholder_page.dart';
import 'package:qishloq_ai_mobile/features/auth/presentation/login_page.dart';
import 'package:qishloq_ai_mobile/features/categories/presentation/categories_page.dart';
import 'package:qishloq_ai_mobile/features/home/presentation/home_page.dart';
import 'package:qishloq_ai_mobile/features/listings/presentation/create_listing_placeholder_page.dart';
import 'package:qishloq_ai_mobile/features/listings/presentation/listings_page.dart';
import 'package:qishloq_ai_mobile/features/onboarding/presentation/onboarding_page.dart';
import 'package:qishloq_ai_mobile/features/profile/presentation/profile_placeholder_page.dart';
import 'package:qishloq_ai_mobile/features/splash/presentation/splash_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashPage(),
    ),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesPage(),
    ),
    GoRoute(
      path: '/listings',
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['categoryId'];
        final rawCategoryName = state.uri.queryParameters['categoryName'];
        final categoryName = rawCategoryName != null ? Uri.decodeComponent(rawCategoryName) : null;
        return ListingsPage(categoryId: categoryId, categoryName: categoryName);
      },
    ),
    GoRoute(
      path: '/create-listing',
      builder: (context, state) => const CreateListingPlaceholderPage(),
    ),
    GoRoute(
      path: '/ai-advice',
      builder: (context, state) => const AiAdvicePlaceholderPage(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfilePlaceholderPage(),
    ),
  ],
);
