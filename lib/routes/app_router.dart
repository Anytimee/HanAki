import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import '../presentation/pages/splash_page.dart';
import '../presentation/pages/onboarding_page.dart';
import '../presentation/pages/login_page.dart';
import '../presentation/pages/register_page.dart';
import '../presentation/pages/shell_page.dart';
import '../presentation/pages/home_page.dart';
import '../presentation/pages/search_page.dart';
import '../presentation/pages/watchlist_page.dart';
import '../presentation/pages/profile_page.dart';
import '../presentation/pages/detail_page.dart';
import '../presentation/pages/player_page.dart';

GoRouter buildRouter() => GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/onboarding', builder: (_, __) => const OnboardingPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
        ShellRoute(
          builder: (_, __, child) => ShellPage(child: child),
          routes: [
            GoRoute(path: '/home', builder: (_, __) => const HomePage()),
            GoRoute(path: '/search', builder: (_, __) => const SearchPage()),
            GoRoute(path: '/watchlist', builder: (_, __) => const WatchlistPage()),
            GoRoute(path: '/profile', builder: (_, __) => const ProfilePage()),
          ],
        ),
        GoRoute(
          path: '/detail/:id',
          pageBuilder: (ctx, st) => CustomTransitionPage(
            key: st.pageKey,
            child: DetailPage(id: st.pathParameters['id']!),
            transitionsBuilder: (_, anim, __, child) {
              // Slide khas KR, Fade khas JP — pilih via query ?tr=fade
              final fade = st.uri.queryParameters['tr'] == 'fade';
              if (fade) return FadeTransition(opacity: anim, child: child);
              return SlideTransition(
                position: Tween(begin: const Offset(1, 0), end: Offset.zero)
                    .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                child: child,
              );
            },
          ),
        ),
        GoRoute(
          path: '/player/:id',
          builder: (_, st) => PlayerPage(id: st.pathParameters['id']!, title: st.extra as String?),
        ),
      ],
    );
