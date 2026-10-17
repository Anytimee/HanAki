import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/catalog_seed.dart';
import '../../domain/entities/title.dart';

// Tab Home: anime | drakor | donghua | all.
final selectedTabProvider = StateProvider<String>((_) => 'anime');

final catalogProvider = Provider<List<CatalogTitle>>((_) => seedCatalog());

final genreFilterProvider = StateProvider<String>((_) => 'Semua');

List<CatalogTitle> filterByGenre(List<CatalogTitle> all, String genre) {
  if (genre == 'Semua' || genre == 'All') return all;
  return all.where((t) => t.genres.contains(genre)).toList();
}

// Provider per kategori — dipakai tab Anime/Drakor/Donghua.
// Produksi: ganti dengan AsyncNotifier + GET /api/contents?country=JP&type=ANIME
final animeHomeProvider =
    Provider<List<CatalogTitle>>((ref) => byKind(ref.watch(catalogProvider), ContentKind.anime));

final drakorHomeProvider =
    Provider<List<CatalogTitle>>((ref) => byKind(ref.watch(catalogProvider), ContentKind.drakor));

final donghuaHomeProvider =
    Provider<List<CatalogTitle>>((ref) => byKind(ref.watch(catalogProvider), ContentKind.donghua));

// Progress nonton lokal: {contentId: episodeKe}. Hive sync menyusul.
final continueWatchingProvider =
    StateProvider<Map<String, int>>((_) => {'a-solo': 4, 'k-queen': 7});
