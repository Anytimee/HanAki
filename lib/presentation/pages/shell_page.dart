import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../providers/prefs_provider.dart';

class ShellPage extends ConsumerWidget {
  final Widget child;
  const ShellPage({super.key, required this.child});

  int _idx(BuildContext ctx) {
    final loc = GoRouterState.of(ctx).uri.path;
    if (loc.startsWith('/search')) return 1;
    if (loc.startsWith('/watchlist')) return 2;
    if (loc.startsWith('/profile')) return 3;
    return 0;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings(ref.watch(localeProvider));
    return SafeArea(
      top: false,
      child: Scaffold(
        body: child,
        bottomNavigationBar: NavigationBar(
          selectedIndex: _idx(context),
          onDestinationSelected: (i) => context.go(
              ['/home', '/search', '/watchlist', '/profile'][i]),
          destinations: [
            NavigationDestination(icon: const Icon(Icons.home_outlined),
                selectedIcon: const Icon(Icons.home), label: s.homeTitle),
            NavigationDestination(icon: const Icon(Icons.search_outlined),
                selectedIcon: const Icon(Icons.search), label: s.searchTitle),
            NavigationDestination(icon: const Icon(Icons.bookmark_outline),
                selectedIcon: const Icon(Icons.bookmark), label: s.watchlistTitle),
            NavigationDestination(icon: const Icon(Icons.person_outline),
                selectedIcon: const Icon(Icons.person), label: s.profileTitle),
          ],
        ),
      ),
    );
  }
}
