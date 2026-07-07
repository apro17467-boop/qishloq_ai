import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/features/ai_advice/presentation/ai_advice_page.dart';
import 'package:qishloq_ai_mobile/features/auth/presentation/login_page.dart';
import 'package:qishloq_ai_mobile/features/categories/presentation/categories_page.dart';
import 'package:qishloq_ai_mobile/features/favorites/presentation/favorites_page.dart';
import 'package:qishloq_ai_mobile/features/home/presentation/home_page.dart';
import 'package:qishloq_ai_mobile/features/listings/presentation/create_listing_page.dart';
import 'package:qishloq_ai_mobile/features/listings/presentation/listings_page.dart';
import 'package:qishloq_ai_mobile/features/listings/presentation/listing_detail_page.dart';
import 'package:qishloq_ai_mobile/features/listings/presentation/listing_image_upload_page.dart';
import 'package:qishloq_ai_mobile/features/listings/presentation/my_listings_page.dart';
import 'package:qishloq_ai_mobile/features/onboarding/presentation/onboarding_page.dart';
import 'package:qishloq_ai_mobile/features/profile/presentation/profile_page.dart';
import 'package:qishloq_ai_mobile/features/sellers/presentation/seller_profile_page.dart';
import 'package:qishloq_ai_mobile/features/splash/presentation/splash_page.dart';
import 'package:qishloq_ai_mobile/features/chat/presentation/chat_list_page.dart';
import 'package:qishloq_ai_mobile/features/chat/presentation/chat_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SplashPage()),
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
    GoRoute(
      path: '/categories',
      builder: (context, state) => const CategoriesPage(),
    ),
    GoRoute(
      path: '/listings',
      builder: (context, state) {
        final categoryId = state.uri.queryParameters['categoryId'];
        final rawCategoryName = state.uri.queryParameters['categoryName'];
        final categoryName = rawCategoryName != null
            ? Uri.decodeComponent(rawCategoryName)
            : null;
        return ListingsPage(categoryId: categoryId, categoryName: categoryName);
      },
    ),
    GoRoute(
      path: '/listings/:id/images',
      builder: (context, state) {
        final listingId = state.pathParameters['id'] ?? '';
        final listingTitle = state.uri.queryParameters['title'];
        return ListingImageUploadPage(
          listingId: listingId,
          listingTitle: listingTitle,
        );
      },
    ),
    GoRoute(
      path: '/listings/:id',
      builder: (context, state) {
        final listingId = state.pathParameters['id'] ?? '';
        return ListingDetailPage(listingId: listingId);
      },
    ),
    GoRoute(
      path: '/create-listing',
      builder: (context, state) => const CreateListingPage(),
    ),
    GoRoute(
      path: '/my-listings',
      builder: (context, state) => const MyListingsPage(),
    ),
    GoRoute(
      path: '/favorites',
      builder: (context, state) => const FavoritesPage(),
    ),
    GoRoute(
      path: '/sellers/:sellerId',
      builder: (context, state) {
        final sellerId = state.pathParameters['sellerId'] ?? '';
        return SellerProfilePage(sellerId: sellerId);
      },
    ),
    GoRoute(
      path: '/ai-advice',
      builder: (context, state) => const AiAdvicePage(),
    ),
    GoRoute(path: '/profile', builder: (context, state) => const ProfilePage()),
    GoRoute(
      path: '/chat',
      builder: (context, state) => const ChatListPage(),
    ),
    GoRoute(
      path: '/chat/:conversationId',
      builder: (context, state) {
        final conversationId = state.pathParameters['conversationId'] ?? '';
        return ChatPage(conversationId: conversationId);
      },
    ),
  ],
);
