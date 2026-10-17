import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/title.dart';
import '../providers/catalog_provider.dart';
import '../providers/prefs_provider.dart';
import '../widgets/adaptive.dart';
import '../widgets/banner_carousel.dart';
import '../widgets/poster_card.dart';

// PROMPT 1 — Home Anime | Drakor | Donghua | Semua. Tanpa J-Drama.
class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings(ref.watch(localeProvider));
    final tab = ref.watch(selectedTabProvider);
    const tabs = ['anime', 'drakor', 'donghua', 'all'];
    final labels = [s.tabAnime, s.tabDrakor, s.tabDonghua, s.tabAll];
    const flags = ['JPN', 'KOR', 'CHN', 'ALL'];
    final idx = tabs.indexOf(tab).clamp(0, 3);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('HanAki',
              style: TextStyle(fontWeight: FontWeight.w800)),
          actions: [
            IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => context.go('/search')),
            IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {}),
          ],
        ),
        body: Column(
          children: [
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: tabs.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ChoiceChip(
                  label: Text('${flags[i]} ${labels[i]}'),
                  selected: idx == i,
                  onSelected: (_) => ref
                      .read(selectedTabProvider.notifier)
                      .state = tabs[i],
                ),
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(catalogProvider);
                  await Future.delayed(
                      const Duration(milliseconds: 400));
                },
                child: switch (tab) {
                  'anime' => const AnimeTabContent(),
                  'drakor' => const DrakorTabContent(),
                  'donghua' => const DonghuaTabContent(),
                  _ => const AllTabContent(),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AnimeTabContent extends ConsumerWidget {
  const AnimeTabContent({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings(ref.watch(localeProvider));
    final items = filterByGenre(
        ref.watch(animeHomeProvider), ref.watch(genreFilterProvider));
    return _TabScroll(category: 'anime', banner: items,
        title: s.trendingAnime, sub: s.trendingAnimeSub,
        accent: AppColors.anime, items: items);
  }
}

class DrakorTabContent extends ConsumerWidget {
  const DrakorTabContent({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings(ref.watch(localeProvider));
    final items = filterByGenre(
        ref.watch(drakorHomeProvider), ref.watch(genreFilterProvider));
    return _TabScroll(category: 'drakor', banner: items,
        title: s.latestKdrama, sub: s.latestKdramaSub,
        accent: AppColors.drakor, items: items);
  }
}

class DonghuaTabContent extends ConsumerWidget {
  const DonghuaTabContent({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = AppStrings(ref.watch(localeProvider));
    final items = filterByGenre(
        ref.watch(donghuaHomeProvider), ref.watch(genreFilterProvider));
    return _TabScroll(category: 'donghua', banner: items,
        title: s.donghuaPopular, sub: s.donghuaPopularSub,
        accent: AppColors.donghua, items: items);
  }
}

class AllTabContent extends ConsumerWidget {
  const AllTabContent({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = ref.watch(catalogProvider);
    return ListView(
      padding: EdgeInsets.all(context.pagePadding),
      children: [
        BannerCarousel(items: all.take(5).toList()),
        const SizedBox(height: 16),
        ResponsiveGrid(
          children: [for (final t in all) PosterCard(item: t)],
        ),
      ],
    );
  }
}

class _TabScroll extends ConsumerWidget {
  final String category;
  final List<CatalogTitle> banner;
  final String title;
  final String sub;
  final Color accent;
  final List<CatalogTitle> items;
  const _TabScroll({required this.category, required this.banner,
    required this.title, required this.sub, required this.accent,
    required this.items});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final genres = ['Semua', ...AppConstants.genresByCategory[category]!];
    final sel = ref.watch(genreFilterProvider);
    return ListView(
      padding: EdgeInsets.all(context.pagePadding),
      children: [
        if (banner.isNotEmpty)
          BannerCarousel(items: banner.take(5).toList()),
        const SizedBox(height: 16),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: genres.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) => ChoiceChip(
              label: Text(genres[i]),
              selected: sel == genres[i],
              onSelected: (_) => ref
                  .read(genreFilterProvider.notifier).state = genres[i],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionHeader(title: title, subtitle: sub, accent: accent),
        const SizedBox(height: 10),
        if (items.isEmpty)
          const Text('Belum ada judul di section ini.')
        else
          ResponsiveGrid(
            children: [for (final t in items) PosterCard(item: t)],
          ),
      ],
    );
  }
}
