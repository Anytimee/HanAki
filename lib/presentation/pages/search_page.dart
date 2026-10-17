import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/l10n/app_strings.dart';
import '../providers/prefs_provider.dart';
import '../providers/search_provider.dart';
import '../widgets/adaptive.dart';
import '../widgets/poster_card.dart';

class SearchPage extends ConsumerStatefulWidget {
  const SearchPage({super.key});
  @override
  ConsumerState<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends ConsumerState<SearchPage> {
  final _ctrl = TextEditingController();
  Timer? _deb;

  @override
  void dispose() {
    _deb?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    _deb?.cancel();
    _deb = Timer(const Duration(milliseconds: 350), () {
      ref.read(searchQueryProvider.notifier).state = v;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(ref.watch(localeProvider));
    final results = ref.watch(searchResultsProvider);
    final country = ref.watch(searchCountryProvider);
    final year = ref.watch(searchYearProvider);

    return AdaptiveScaffold(
      title: s.searchTitle,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: TextField(
                controller: _ctrl,
                onChanged: _onChanged,
                decoration: InputDecoration(
                  hintText: s.searchHint,
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Wrap(
              spacing: 8, runSpacing: 8,
              children: [
                for (final c in ['all', 'KR', 'JP'])
                  ChoiceChip(
                    label: Text(c == 'all' ? '🌏 All' : c == 'KR' ? '🇰🇷 KR' : '🇯🇵 JP'),
                    selected: country == c,
                    onSelected: (_) =>
                        ref.read(searchCountryProvider.notifier).state = c,
                  ),
                ActionChip(
                  label: Text(year == null ? '📅 Year' : '📅 $year ✕'),
                  onPressed: () async {
                    if (year != null) {
                      ref.read(searchYearProvider.notifier).state = null;
                      return;
                    }
                    final y = await showModalBottomSheet<int>(
                      context: context,
                      builder: (_) => SafeArea(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final yy in [2026, 2025, 2024, 2023, 2022])
                              ListTile(
                                title: Text('$yy'),
                                onTap: () => Navigator.pop(context, yy),
                              ),
                          ],
                        ),
                      ),
                    );
                    if (y != null) {
                      ref.read(searchYearProvider.notifier).state = y;
                    }
                  },
                ),
              ],
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 14)),
          if (results.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    const Text('🔍', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    Text(s.searchEmpty),
                  ],
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: ResponsiveGrid(
                children: [for (final t in results) PosterCard(item: t)],
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }
}
