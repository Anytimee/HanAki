import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_strings.dart';
import '../providers/catalog_provider.dart';
import '../providers/prefs_provider.dart';
import '../providers/watchlist_provider.dart';
import '../widgets/adaptive.dart';
import '../widgets/poster_card.dart';

class WatchlistPage extends ConsumerWidget {
  const WatchlistPage({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings(ref.watch(localeProvider));
    final ids = ref.watch(watchlistProvider);
    final items = ref
        .watch(catalogProvider)
        .where((t) => ids.contains(t.id))
        .toList();
    return AdaptiveScaffold(
      title: s.watchlistTitle,
      body: items.isEmpty
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('🔖', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 8),
                  Text(s.watchlistEmpty,
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(s.watchlistEmptyDesc,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Theme.of(context).hintColor)),
                ],
              ),
            )
          : CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: SizedBox(height: 12)),
                SliverToBoxAdapter(
                  child: ResponsiveGrid(
                    children: [for (final t in items) PosterCard(item: t)],
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
    );
  }
}
