import 'package:go_router/go_router.dart';
import 'package:qishloq_ai_mobile/features/auth/presentation/login_page.dart';
import 'package:qishloq_ai_mobile/features/home/presentation/home_page.dart';
import 'package:qishloq_ai_mobile/features/onboarding/presentation/onboarding_page.dart';
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
  ],
);
