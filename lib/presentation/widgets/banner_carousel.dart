import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/title.dart';
import '../providers/prefs_provider.dart';

class BannerCarousel extends ConsumerStatefulWidget {
  final List<CatalogTitle> items;
  const BannerCarousel({super.key, required this.items});
  @override
  ConsumerState<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends ConsumerState<BannerCarousel> {
  int _i = 0;
  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localeProvider).languageCode;
    final h = context.isMobile ? 200.0 : context.isTablet ? 280.0 : 340.0;
    return Column(
      children: [
        CarouselSlider.builder(
          itemCount: widget.items.length,
          itemBuilder: (_, idx, __) {
            final t = widget.items[idx];
            return GestureDetector(
              onTap: () => context.push('/detail/${t.id}'),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(24)),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(imageUrl: t.banner, fit: BoxFit.cover),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter, end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: .78)],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 16, right: 16, bottom: 14,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                            child: Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: .14),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: .25)),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('${countryBadge(t.country)}  ${t.titleFor(loc)}',
                                            maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: TextStyle(color: Colors.white,
                                                fontSize: context.fs(16), fontWeight: FontWeight.w800)),
                                        Text('${t.year} • ${t.genres.join(' / ')}',
                                            style: TextStyle(color: Colors.white70, fontSize: context.fs(12))),
                                      ],
                                    ),
                                  ),
                                  FilledButton(
                                    style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
                                    onPressed: () => context.push('/detail/${t.id}'),
                                    child: const Icon(Icons.play_arrow),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: h, autoPlay: true, autoPlayInterval: const Duration(seconds: 5),
            enlargeCenterPage: true, viewportFraction: context.isMobile ? .92 : .7,
            onPageChanged: (i, _) => setState(() => _i = i),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.items.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 250), margin: const EdgeInsets.symmetric(horizontal: 3),
            width: _i == i ? 22 : 7, height: 7,
            decoration: BoxDecoration(
              color: _i == i ? AppColors.primary : Colors.grey.withValues(alpha: .4),
              borderRadius: BorderRadius.circular(99)),
          )),
        ),
      ],
    );
  }
}
