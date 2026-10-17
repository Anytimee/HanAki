/// Kategori konten HanAki: Anime (JP) | Drakor (KR) | Donghua (CN).
/// J-Drama / movie TIDAK termasuk — jangan tambah varian live-action JP.
enum Country { japan, korea, china }
enum ContentKind { anime, drakor, donghua }

/// Entity katalog. Map locale: id/en/ko/ja/zh.
class CatalogTitle {
  final String id;
  final ContentKind kind;
  final Country country;
  final Map<String, String> titles;
  final Map<String, String> synopses;
  final List<String> genres;
  final int year;
  final double rating;
  final String poster;
  final String banner;
  final int episodes;
  final String status;
  final Map<String, String> trailerUrls;

  const CatalogTitle({
    required this.id,
    required this.kind,
    required this.country,
    required this.titles,
    required this.synopses,
    required this.genres,
    required this.year,
    required this.rating,
    required this.poster,
    required this.banner,
    required this.episodes,
    this.status = 'ONGOING',
    this.trailerUrls = const {},
  });

  String titleFor(String locale) =>
      titles[locale] ?? titles['en'] ?? titles.values.first;
  String synopsisFor(String locale) =>
      synopses[locale] ?? synopses['en'] ?? synopses.values.first;
}

String countryBadge(Country c) => switch (c) {
      Country.japan => '🇯🇵',
      Country.korea => '🇰🇷',
      Country.china => '🇨🇳',
    };

String countryCode(Country c) => switch (c) {
      Country.japan => 'JP',
      Country.korea => 'KR',
      Country.china => 'CN',
    };

