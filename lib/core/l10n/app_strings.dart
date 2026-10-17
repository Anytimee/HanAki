import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

part 'strings_id.dart';
part 'strings_en.dart';
part 'strings_ko.dart';
part 'strings_ja.dart';
part 'strings_zh.dart';

/// Strings HanAki — mirror 1:1 dari ARB di `lib/core/l10n/*.arb`.
/// ARB tetap source of truth; file ini membuat app jalan tanpa codegen.
class AppStrings {
  final Locale locale;
  const AppStrings(this.locale);

  static const supportedLocales = [
    Locale('id'),
    Locale('en'),
    Locale('ko'),
    Locale('ja'),
    Locale('zh'),
  ];

  Map<String, String> get _map => switch (locale.languageCode) {
        'en' => _en,
        'ko' => _ko,
        'ja' => _ja,
        'zh' => _zh,
        _ => _id,
      };

  String get(String key) => _map[key] ?? _id[key] ?? key;

  String get appName => get('app_name');
  String get appTagline => get('app_tagline');
  String get homeTitle => get('home_title');
  String get searchTitle => get('search_title');
  String get watchlistTitle => get('watchlist_title');
  String get profileTitle => get('profile_title');
  String get trendingAnime => get('trending_anime');
  String get trendingAnimeSub => get('trending_anime_sub');
  String get latestKdrama => get('latest_kdrama');
  String get latestKdramaSub => get('latest_kdrama_sub');
  String get jdramaPick => get('jdrama_pick');
  String get jdramaPickSub => get('jdrama_pick_sub');
  String get continueWatching => get('continue_watching');
  String get watchNow => get('watch_now');
  String get addWatchlist => get('add_watchlist');
  String get inWatchlist => get('in_watchlist');
  String get searchHint => get('search_hint');
  String get searchEmpty => get('search_empty');
  String get synopsis => get('synopsis');
  String get episodes => get('episodes');
  String get play => get('play');
  String get nextEpisode => get('next_episode');
  String get subtitles => get('subtitles');
  String get quality => get('quality');
  String get login => get('login');
  String get register => get('register');
  String get logout => get('logout');
  String get chooseLanguage => get('choose_language');
  String get getStarted => get('get_started');
  String get skip => get('skip');
  String get next => get('next');
  String get language => get('language');
  String get darkMode => get('dark_mode');
  String get watchlistEmpty => get('watchlist_empty');
  String get watchlistEmptyDesc => get('watchlist_empty_desc');
  String get welcome => get('welcome');
  // Tab kategori Home.
  String get tabAnime => get('tab_anime');
  String get tabDrakor => get('tab_drakor');
  String get tabDonghua => get('tab_donghua');
  String get tabAll => get('tab_all');
  String get donghuaPopular => get('donghua_popular');
  String get donghuaPopularSub => get('donghua_popular_sub');
  // Player: pesan saat API tidak mengembalikan link stream.
  String get videoNotAvailable => get('video_not_available');
  String get videoLoadError => get('video_load_error');
  String get episodesLoadError => get('episodes_load_error');
  String get episodesEmpty => get('episodes_empty');
  String get retry => get('retry');
}

class AppStringsDelegate extends LocalizationsDelegate<AppStrings> {
  const AppStringsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['id', 'en', 'ko', 'ja', 'zh'].contains(locale.languageCode);

  @override
  Future<AppStrings> load(Locale locale) =>
      SynchronousFuture(AppStrings(locale));

  @override
  bool shouldReload(AppStringsDelegate old) => false;
}

extension StringsX on BuildContext {
  AppStrings get str {
    final s = Localizations.of<AppStrings>(this, AppStrings);
    assert(s != null, 'AppStrings hilang — cek localizationDelegates');
    return s!;
  }
}
