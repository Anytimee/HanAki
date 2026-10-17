import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/l10n/app_strings.dart';
import '../providers/prefs_provider.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});
  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  final _pc = PageController();
  int _i = 0;

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localeProvider);
    final s = AppStrings(loc);
    final slides = [
      ('🎌', 'onboarding_title_1', 'onboarding_desc_1'),
      ('📱', 'onboarding_title_2', 'onboarding_desc_2'),
      ('🌸', 'onboarding_title_3', 'onboarding_desc_3'),
    ];
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  const Text('HanAki', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _finish(),
                    child: Text(s.get('skip')),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(s.get('choose_language'),
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final c in AppConstants.supportedLocales)
                    ChoiceChip(
                      label: Text('${AppConstants.localeFlags[c]} ${AppConstants.localeLabels[c]}'),
                      selected: loc.languageCode == c,
                      onSelected: (_) async {
                        ref.read(localeProvider.notifier).state = Locale(c);
                        await saveLocale(c);
                      },
                    ),
                ],
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pc,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _i = i),
                  itemBuilder: (_, i) => Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(slides[i].$1, style: const TextStyle(fontSize: 72)),
                      const SizedBox(height: 16),
                      Text(s.get(slides[i].$2),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Text(s.get(slides[i].$3),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (d) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _i == d ? 24 : 8, height: 8,
                  decoration: BoxDecoration(
                    color: _i == d ? AppColors.primary : Colors.grey.withValues(alpha: .4),
                    borderRadius: BorderRadius.circular(99)),
                )),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_i < 2) {
                      _pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
                    } else {
                      _finish();
                    }
                  },
                  child: Text(_i < 2 ? s.get('next') : s.get('get_started')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _finish() async {
    ref.read(onboardedProvider.notifier).state = true;
    await saveOnboarded();
    if (mounted) context.go('/home');
  }
}
