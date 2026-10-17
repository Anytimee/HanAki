abstract final class AppConstants {
  static const appName = 'HanAki';
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;

  static const double padMobile = 16;
  static const double padTablet = 24;

  static const posterAspect = 2 / 3;

  static const supportedLocales = ['id', 'en', 'ko', 'ja', 'zh'];

  static const Map<String, String> localeLabels = {
    'id': 'Indonesia',
    'en': 'English',
    'ko': '한국어',
    'ja': '日本語',
    'zh': '中文',
  };

  static const Map<String, String> localeFlags = {
    'id': '🇮🇩',
    'en': '🇬🇧',
    'ko': '🇰🇷',
    'ja': '🇯🇵',
    'zh': '🇨🇳',
  };

  /// Genre dinamis per kategori — dipakai Home tab + Search filter sheet.
  /// J-Drama tidak ada; kategori hanya Anime | Drakor | Donghua.
  static const Map<String, List<String>> genresByCategory = {
    'anime': [
      'Action', 'Adventure', 'Comedy', 'Drama', 'Fantasy', 'Horror',
      'Isekai', 'Mecha', 'Romance', 'School', 'Sci-Fi', 'Shounen',
      'Seinen', 'Slice of Life', 'Sports', 'Supernatural',
    ],
    'drakor': [
      'Romance', 'Sageuk', 'Thriller', 'Comedy', 'Fantasy', 'Medical',
      'Legal', 'Action', 'Family', 'Mystery', 'School', 'Melodrama',
      'Time Travel', 'Revenge', 'Office',
    ],
    'donghua': [
      'Wuxia', 'Xianxia', 'Xuanhuan', 'Cultivation', 'Historical',
      'Romance', 'Comedy', 'Adventure', 'Fantasy', 'Action',
      'Supernatural', 'Mecha', 'School', 'Isekai',
    ],
  };

  // Alias lama: gabungan semua genre — untuk file yang belum migrasi.
  static const List<String> genres = [
    'Action',
    'Romance',
    'Fantasy',
    'Thriller',
    'Comedy',
    'Drama',
    'Slice of Life',
    'Mystery',
  ];

  static const List<int> years = [2026, 2025, 2024, 2023, 2022, 2021];
}
