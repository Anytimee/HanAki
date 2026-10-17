import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_id.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('id'),
    Locale('en'),
    Locale('ja'),
    Locale('ko')
  ];

  /// Nama aplikasi
  ///
  /// In id, this message translates to:
  /// **'HanAki'**
  String get app_name;

  /// No description provided for @app_tagline.
  ///
  /// In id, this message translates to:
  /// **'Anime & Drakor favoritmu, kapan saja'**
  String get app_tagline;

  /// No description provided for @home_title.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get home_title;

  /// No description provided for @search_title.
  ///
  /// In id, this message translates to:
  /// **'Cari'**
  String get search_title;

  /// No description provided for @watchlist_title.
  ///
  /// In id, this message translates to:
  /// **'Watchlist'**
  String get watchlist_title;

  /// No description provided for @profile_title.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profile_title;

  /// No description provided for @trending_anime.
  ///
  /// In id, this message translates to:
  /// **'Anime Trending'**
  String get trending_anime;

  /// No description provided for @trending_anime_sub.
  ///
  /// In id, this message translates to:
  /// **'アニメ — Paling banyak ditonton minggu ini'**
  String get trending_anime_sub;

  /// No description provided for @latest_kdrama.
  ///
  /// In id, this message translates to:
  /// **'Drakor Terbaru'**
  String get latest_kdrama;

  /// No description provided for @latest_kdrama_sub.
  ///
  /// In id, this message translates to:
  /// **'한국 드라마 — Episode baru setiap hari'**
  String get latest_kdrama_sub;

  /// No description provided for @jdrama_pick.
  ///
  /// In id, this message translates to:
  /// **'J-Drama Pilihan'**
  String get jdrama_pick;

  /// No description provided for @jdrama_pick_sub.
  ///
  /// In id, this message translates to:
  /// **'日本のドラマ — Kurasi editor'**
  String get jdrama_pick_sub;

  /// No description provided for @continue_watching.
  ///
  /// In id, this message translates to:
  /// **'Lanjut Nonton'**
  String get continue_watching;

  /// No description provided for @watch_now.
  ///
  /// In id, this message translates to:
  /// **'Tonton Sekarang'**
  String get watch_now;

  /// No description provided for @add_watchlist.
  ///
  /// In id, this message translates to:
  /// **'Tambah ke Watchlist'**
  String get add_watchlist;

  /// No description provided for @in_watchlist.
  ///
  /// In id, this message translates to:
  /// **'Ada di Watchlist'**
  String get in_watchlist;

  /// No description provided for @remove_watchlist.
  ///
  /// In id, this message translates to:
  /// **'Hapus dari Watchlist'**
  String get remove_watchlist;

  /// No description provided for @synopsis.
  ///
  /// In id, this message translates to:
  /// **'Sinopsis'**
  String get synopsis;

  /// No description provided for @episodes.
  ///
  /// In id, this message translates to:
  /// **'Episode'**
  String get episodes;

  /// No description provided for @rating.
  ///
  /// In id, this message translates to:
  /// **'Rating'**
  String get rating;

  /// No description provided for @year.
  ///
  /// In id, this message translates to:
  /// **'Tahun'**
  String get year;

  /// No description provided for @genre.
  ///
  /// In id, this message translates to:
  /// **'Genre'**
  String get genre;

  /// No description provided for @country.
  ///
  /// In id, this message translates to:
  /// **'Negara'**
  String get country;

  /// No description provided for @all.
  ///
  /// In id, this message translates to:
  /// **'Semua'**
  String get all;

  /// No description provided for @korea.
  ///
  /// In id, this message translates to:
  /// **'Korea'**
  String get korea;

  /// No description provided for @japan.
  ///
  /// In id, this message translates to:
  /// **'Jepang'**
  String get japan;

  /// No description provided for @search_hint.
  ///
  /// In id, this message translates to:
  /// **'Cari anime, drakor, j-drama…'**
  String get search_hint;

  /// No description provided for @search_empty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada hasil. Coba judul lain.'**
  String get search_empty;

  /// No description provided for @filter_country.
  ///
  /// In id, this message translates to:
  /// **'Negara'**
  String get filter_country;

  /// No description provided for @filter_genre.
  ///
  /// In id, this message translates to:
  /// **'Genre'**
  String get filter_genre;

  /// No description provided for @filter_year.
  ///
  /// In id, this message translates to:
  /// **'Tahun'**
  String get filter_year;

  /// No description provided for @play.
  ///
  /// In id, this message translates to:
  /// **'Putar'**
  String get play;

  /// No description provided for @next_episode.
  ///
  /// In id, this message translates to:
  /// **'Episode Berikutnya'**
  String get next_episode;

  /// No description provided for @subtitles.
  ///
  /// In id, this message translates to:
  /// **'Subtitle'**
  String get subtitles;

  /// No description provided for @quality.
  ///
  /// In id, this message translates to:
  /// **'Kualitas'**
  String get quality;

  /// No description provided for @auto.
  ///
  /// In id, this message translates to:
  /// **'Otomatis'**
  String get auto;

  /// No description provided for @login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// No description provided for @login_heading.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan tontonanmu'**
  String get login_heading;

  /// No description provided for @login_subtitle.
  ///
  /// In id, this message translates to:
  /// **'Masuk untuk kembali ke HanAki.'**
  String get login_subtitle;

  /// No description provided for @login_no_account.
  ///
  /// In id, this message translates to:
  /// **'Belum punya akun?'**
  String get login_no_account;

  /// No description provided for @register_heading.
  ///
  /// In id, this message translates to:
  /// **'Buat akun HanAki'**
  String get register_heading;

  /// No description provided for @register_subtitle.
  ///
  /// In id, this message translates to:
  /// **'Gunakan email dan kata sandi untuk membuat akun.'**
  String get register_subtitle;

  /// No description provided for @register_loading.
  ///
  /// In id, this message translates to:
  /// **'Membuat akun…'**
  String get register_loading;

  /// No description provided for @register_network_error.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat terhubung ke server. Periksa koneksi dan coba lagi.'**
  String get register_network_error;

  /// No description provided for @register_invalid_response.
  ///
  /// In id, this message translates to:
  /// **'Server mengirim respons pendaftaran yang tidak valid.'**
  String get register_invalid_response;

  /// No description provided for @register_password_short.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi harus berisi minimal 8 karakter.'**
  String get register_password_short;

  /// No description provided for @register_confirm_password.
  ///
  /// In id, this message translates to:
  /// **'Ulangi kata sandi'**
  String get register_confirm_password;

  /// No description provided for @register_password_mismatch.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi tidak cocok.'**
  String get register_password_mismatch;

  /// No description provided for @register_have_account.
  ///
  /// In id, this message translates to:
  /// **'Sudah punya akun?'**
  String get register_have_account;

  /// No description provided for @login_loading.
  ///
  /// In id, this message translates to:
  /// **'Memeriksa akun…'**
  String get login_loading;

  /// No description provided for @login_network_error.
  ///
  /// In id, this message translates to:
  /// **'Tidak dapat terhubung ke server. Periksa koneksi dan pastikan API aktif.'**
  String get login_network_error;

  /// No description provided for @login_invalid_response.
  ///
  /// In id, this message translates to:
  /// **'Server mengirim respons login yang tidak valid.'**
  String get login_invalid_response;

  /// No description provided for @email_invalid.
  ///
  /// In id, this message translates to:
  /// **'Masukkan alamat email yang valid.'**
  String get email_invalid;

  /// No description provided for @password_required.
  ///
  /// In id, this message translates to:
  /// **'Masukkan kata sandi.'**
  String get password_required;

  /// No description provided for @show_password.
  ///
  /// In id, this message translates to:
  /// **'Tampilkan kata sandi'**
  String get show_password;

  /// No description provided for @hide_password.
  ///
  /// In id, this message translates to:
  /// **'Sembunyikan kata sandi'**
  String get hide_password;

  /// No description provided for @register.
  ///
  /// In id, this message translates to:
  /// **'Daftar'**
  String get register;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Kata sandi'**
  String get password;

  /// No description provided for @name.
  ///
  /// In id, this message translates to:
  /// **'Nama'**
  String get name;

  /// No description provided for @welcome.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang di HanAki'**
  String get welcome;

  /// No description provided for @onboarding_title_1.
  ///
  /// In id, this message translates to:
  /// **'Anime & Drakor dalam Satu Rumah'**
  String get onboarding_title_1;

  /// No description provided for @onboarding_desc_1.
  ///
  /// In id, this message translates to:
  /// **'Dari アニメ terpanas sampai 한국 드라마 terbaru — semua rapi dalam 4 bahasamu.'**
  String get onboarding_desc_1;

  /// No description provided for @onboarding_title_2.
  ///
  /// In id, this message translates to:
  /// **'Nonton Nyaman di Semua Layar'**
  String get onboarding_title_2;

  /// No description provided for @onboarding_desc_2.
  ///
  /// In id, this message translates to:
  /// **'HP, tablet, atau landscape fullscreen. Poster selalu pas, teks selalu terbaca.'**
  String get onboarding_desc_2;

  /// No description provided for @onboarding_title_3.
  ///
  /// In id, this message translates to:
  /// **'Bahasa & Subtitle Sesukamu'**
  String get onboarding_title_3;

  /// No description provided for @onboarding_desc_3.
  ///
  /// In id, this message translates to:
  /// **'Indonesia, English, 한국어, 日本語 — termasuk subtitle dan font adaptif.'**
  String get onboarding_desc_3;

  /// No description provided for @choose_language.
  ///
  /// In id, this message translates to:
  /// **'Pilih bahasamu'**
  String get choose_language;

  /// No description provided for @get_started.
  ///
  /// In id, this message translates to:
  /// **'Mulai Menonton'**
  String get get_started;

  /// No description provided for @skip.
  ///
  /// In id, this message translates to:
  /// **'Lewati'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get next;

  /// No description provided for @dark_mode.
  ///
  /// In id, this message translates to:
  /// **'Mode Gelap'**
  String get dark_mode;

  /// No description provided for @light_mode.
  ///
  /// In id, this message translates to:
  /// **'Mode Terang'**
  String get light_mode;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @version.
  ///
  /// In id, this message translates to:
  /// **'Versi'**
  String get version;

  /// No description provided for @watchlist_empty.
  ///
  /// In id, this message translates to:
  /// **'Watchlist masih kosong'**
  String get watchlist_empty;

  /// No description provided for @watchlist_empty_desc.
  ///
  /// In id, this message translates to:
  /// **'Ketuk bookmark di poster mana pun untuk menyimpan ke sini.'**
  String get watchlist_empty_desc;

  /// No description provided for @history_empty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat nonton'**
  String get history_empty;

  /// No description provided for @video_load_error.
  ///
  /// In id, this message translates to:
  /// **'Tautan video gagal dimuat. Periksa koneksi lalu coba lagi.'**
  String get video_load_error;

  /// No description provided for @episodes_load_error.
  ///
  /// In id, this message translates to:
  /// **'Daftar episode gagal dimuat. Periksa koneksi lalu coba lagi.'**
  String get episodes_load_error;

  /// No description provided for @episodes_empty.
  ///
  /// In id, this message translates to:
  /// **'Belum ada episode untuk judul ini.'**
  String get episodes_empty;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'id', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'id':
      return AppLocalizationsId();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
