import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../data/auth_service.dart';
import '../providers/prefs_provider.dart';
import '../widgets/adaptive.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = ref.watch(localeProvider);
    final s = AppStrings(loc);
    final mode = ref.watch(themeModeProvider);
    final authed = ref.watch(isAuthenticatedProvider);
    return AdaptiveScaffold(
      title: s.profileTitle,
      body: ListView(
        children: [
          const SizedBox(height: 12),
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  child: Text(
                    authed ? 'H' : '🍜',
                    style: const TextStyle(fontSize: 28),
                  ),
                ),
                const SizedBox(height: 8),
                Text(s.welcome,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                Text('HanAki v1.0.0',
                    style: TextStyle(color: Theme.of(context).hintColor)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(s.language),
            subtitle: Text(
                '${AppConstants.localeFlags[loc.languageCode]} ${AppConstants.localeLabels[loc.languageCode]}'),
            trailing: DropdownButton<String>(
              value: loc.languageCode,
              underline: const SizedBox(),
              items: [
                for (final c in AppConstants.supportedLocales)
                  DropdownMenuItem(
                      value: c,
                      child: Text(
                          '${AppConstants.localeFlags[c]} ${AppConstants.localeLabels[c]}')),
              ],
              onChanged: (v) async {
                if (v == null) return;
                ref.read(localeProvider.notifier).state = Locale(v);
                await saveLocale(v);
              },
            ),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title: Text(s.darkMode),
            value: mode == ThemeMode.dark,
            onChanged: (v) async {
              ref.read(themeModeProvider.notifier).state =
                  v ? ThemeMode.dark : ThemeMode.light;
              await saveTheme(v ? 'dark' : 'light');
            },
          ),
          const Divider(),
          if (!authed)
            FilledButton.icon(
              onPressed: () => context.push('/login'),
              icon: const Icon(Icons.login),
              label: Text(s.login),
            )
          else
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authServiceProvider).logout();
                if (!context.mounted) return;
                ref.read(isAuthenticatedProvider.notifier).state = false;
              },
              icon: const Icon(Icons.logout),
              label: Text(s.logout),
            ),
        ],
      ),
    );
  }
}
