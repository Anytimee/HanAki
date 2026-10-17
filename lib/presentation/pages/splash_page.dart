import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../providers/prefs_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});
  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    // Navigasi dijalankan sekali + dibungkus try-catch: bila Hive/error
    // apapun terjadi, splash tetap lanjut (fallback onboarding) dan
    // TIDAK stuck di logo selamanya.
    Future.microtask(() async {
      try {
        await loadPrefs(ref).timeout(const Duration(seconds: 5));
      } catch (_) {
        // prefs korup / box belum siap -> pakai default, tetap lanjut.
      }
      await Future.delayed(const Duration(milliseconds: 1400));
      if (!mounted || _leaving) return;
      _leaving = true;
      if (!mounted) return;
      final ob = ref.read(onboardedProvider);
      context.go(ob ? '/home' : '/onboarding');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBg,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96, height: 96,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.japanAccent]),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text('華', style: TextStyle(fontSize: 48, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 16),
            const Text('HanAki',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: Colors.white)),
            const SizedBox(height: 6),
            const Text('アニメ • 한국 드라마 • 日本のドラマ',
                style: TextStyle(color: Colors.white60, fontSize: 13)),
            const SizedBox(height: 24),
            const SizedBox(
              width: 28, height: 28,
              child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.koreaAccent),
            ),
          ],
        ),
      ),
    );
  }
}
