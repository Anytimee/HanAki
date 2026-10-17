import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/title.dart';
import 'catalog_provider.dart';

// Query + filter search. Debounce 500ms di SearchPage.
// API: GET /api/search?q=naruto&country=JP,KR,CN&genre=isekai
final searchQueryProvider = StateProvider<String>((_) => '');
final searchCountryProvider = StateProvider<String>((_) => 'all');
final searchYearProvider = StateProvider<int?>((_) => null);
final selectedCategoriesProvider = StateProvider<List<Country>>((_) => []);

final searchResultsProvider = Provider<List<CatalogTitle>>((ref) {
  final all = ref.watch(catalogProvider);
  final q = ref.watch(searchQueryProvider).toLowerCase().trim();
  final quick = ref.watch(searchCountryProvider);
  final cats = ref.watch(selectedCategoriesProvider);
  final year = ref.watch(searchYearProvider);
  const locale = 'id';
  return all.where((t) {
    final matchQ = q.isEmpty ||
        t.titleFor(locale).toLowerCase().contains(q) ||
        t.genres.any((g) => g.toLowerCase().contains(q));
    final matchQuick = quick == 'all' ||
        (quick == 'KR' && t.country == Country.korea) ||
        (quick == 'JP' && t.country == Country.japan) ||
        (quick == 'CN' && t.country == Country.china);
    final matchCats = cats.isEmpty || cats.contains(t.country);
    final matchY = year == null || t.year == year;
    return matchQ && matchQuick && matchCats && matchY;
  }).toList();
});
