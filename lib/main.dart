import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/l10n/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'presentation/providers/prefs_provider.dart';
import 'routes/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('prefs');
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const ProviderScope(child: HanAkiApp()));
}

class HanAkiApp extends ConsumerStatefulWidget {
  const HanAkiApp({super.key});

  @override
  ConsumerState<HanAkiApp> createState() => _HanAkiAppState();
}

class _HanAkiAppState extends ConsumerState<HanAkiApp> {
  // Router dibuat SEKALI di initState. Jangan panggil buildRouter() di
  // dalam build(): setiap rebuild bikin router baru yang kembali ke
  // initialLocation '/splash' -> aplikasi terlihat stuck di logo.
  late final _router = buildRouter();

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);
    final mode = ref.watch(themeModeProvider);
    return MaterialApp.router(
      title: 'HanAki',
      debugShowCheckedModeBanner: false,
      locale: locale,
      supportedLocales: AppStrings.supportedLocales,
      localizationsDelegates: const [
        AppStringsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: buildHanakiTheme(dark: false, localeCode: locale.languageCode),
      darkTheme: buildHanakiTheme(dark: true, localeCode: locale.languageCode),
      themeMode: mode,
      routerConfig: _router,
    );
  }
}
