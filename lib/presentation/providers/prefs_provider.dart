import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/auth_service.dart';

const _box = 'prefs';
const _kLocale = 'locale';
const _kTheme = 'theme';
const _kOnboard = 'onboarded';

final localeProvider = StateProvider<Locale>((_) => const Locale('id'));
final themeModeProvider = StateProvider<ThemeMode>((_) => ThemeMode.system);
final onboardedProvider = StateProvider<bool>((_) => false);

Future<void> loadPrefs(WidgetRef ref) async {
  final b = Hive.box(_box);
  final loc = b.get(_kLocale, defaultValue: 'id') as String;
  final th = b.get(_kTheme, defaultValue: 'system') as String;
  final ob = b.get(_kOnboard, defaultValue: false) as bool;
  final token = b.get(authTokenKey);
  ref.read(localeProvider.notifier).state = Locale(loc);
  ref.read(themeModeProvider.notifier).state =
      th == 'dark' ? ThemeMode.dark : th == 'light' ? ThemeMode.light : ThemeMode.system;
  ref.read(onboardedProvider.notifier).state = ob;
  ref.read(isAuthenticatedProvider.notifier).state =
      token is String && token.isNotEmpty;
}

Future<void> saveLocale(String code) async =>
    Hive.box(_box).put(_kLocale, code);
Future<void> saveTheme(String v) async => Hive.box(_box).put(_kTheme, v);
Future<void> saveOnboarded() async => Hive.box(_box).put(_kOnboard, true);
