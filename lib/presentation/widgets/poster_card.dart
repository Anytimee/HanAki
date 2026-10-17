import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/responsive.dart';
import '../../domain/entities/title.dart';
import '../providers/prefs_provider.dart';
import '../providers/watchlist_provider.dart';

class PosterCard extends ConsumerWidget {
  final CatalogTitle item;
  const PosterCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider).languageCode;
    final saved = ref.watch(watchlistProvider).contains(item.id);
    return GestureDetector(
      onTap: () => context.push('/detail/${item.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'poster-${item.id}',
            child: AspectRatio(
              aspectRatio: AppConstants.posterAspect,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: CachedNetworkImage(
                      imageUrl: item.poster,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(color: Colors.white),
                      ),
                      errorWidget: (_, __, ___) =>
                          Container(color: Theme.of(context).colorScheme.surfaceContainerHighest),
                    ),
                  ),
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
                      child: Text(countryBadge(item.country), style: const TextStyle(fontSize: 12)),
                    ),
                  ),
                  Positioned(
                    top: 6, right: 6,
                    child: IconButton.filledTonal(
                      onPressed: () => ref.read(watchlistProvider.notifier).toggle(item.id),
                      icon: Icon(saved ? Icons.bookmark : Icons.bookmark_border, size: 18),
                    ),
                  ),
                  Positioned(
                    bottom: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(999)),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(item.rating.toStringAsFixed(1),
                              style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(item.titleFor(locale),
              maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: context.fs(13), fontWeight: FontWeight.w600)),
          Text('${item.year} • ${item.genres.first}',
              style: TextStyle(fontSize: context.fs(11), color: Theme.of(context).hintColor)),
        ],
      ),
    );
  }
}
