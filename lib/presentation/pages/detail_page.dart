import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/l10n/app_strings.dart';
import '../../core/utils/responsive.dart';
import '../../data/auth_service.dart';
import '../providers/catalog_provider.dart';
import '../providers/prefs_provider.dart';
import '../providers/watchlist_provider.dart';

/// Episode asli dari API (GET /api/contents/:slug).
class ApiEpisode {
  const ApiEpisode(
      {required this.id, required this.episodeNum, required this.title});

  factory ApiEpisode.fromJson(Map<String, dynamic> json) => ApiEpisode(
        id: json['id'] as String? ?? '',
        episodeNum: (json['episodeNum'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
      );

  final String id;
  final int episodeNum;
  final String title;
}

List<ApiEpisode> parseApiEpisodes(Map<String, dynamic>? responseData) {
  if (responseData?['success'] != true) {
    throw const FormatException(
      'The content API returned an unsuccessful response.',
    );
  }
  final data = responseData?['data'];
  if (data is! Map) {
    throw const FormatException(
      'The content API response has no data object.',
    );
  }
  final episodes = data['episodes'];
  if (episodes is! List) {
    throw const FormatException(
      'The content API response has no episode list.',
    );
  }
  return episodes.map((row) {
    if (row is! Map) {
      throw const FormatException(
        'The content API returned an invalid episode.',
      );
    }
    return ApiEpisode.fromJson(Map<String, dynamic>.from(row));
  }).toList();
}

Future<List<ApiEpisode>?> fetchApiEpisodes(Dio dio, String slug) async {
  try {
    final response = await dio.get<Map<String, dynamic>>(
      '/contents/${Uri.encodeComponent(slug)}',
    );
    if (kDebugMode) {
      debugPrint('GET ${response.requestOptions.uri}');
      debugPrint(response.data.toString());
    }
    return parseApiEpisodes(response.data);
  } on DioException catch (error) {
    if (error.response?.statusCode == 404) return null;
    rethrow;
  }
}

class DetailPage extends ConsumerStatefulWidget {
  final String id;
  const DetailPage({super.key, required this.id});

  @override
  ConsumerState<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends ConsumerState<DetailPage> {
  /// Episode yang dikembalikan API untuk slug konten ini.
  List<ApiEpisode> _episodes = const [];
  bool _loading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  /// Route detail may contain a local catalog ID, so resolve it to the API slug.
  Future<void> _load() async {
    final dio = ref.read(apiClientProvider);
    final seedList = ref.read(catalogProvider);
    final seedIdx = seedList.indexWhere((t) => t.id == widget.id);
    final seedTitle =
        seedIdx >= 0 ? seedList[seedIdx].titleFor('en') : widget.id;
    try {
      var episodes = await fetchApiEpisodes(dio, widget.id);
      if (episodes == null) {
        final res = await dio.get<Map<String, dynamic>>('/contents',
            queryParameters: {'search': seedTitle, 'limit': 10});
        if (kDebugMode) {
          debugPrint('GET ${res.requestOptions.uri}');
          debugPrint(res.data.toString());
        }
        if (res.data?['success'] != true) {
          throw const FormatException(
            'The content search API returned an unsuccessful response.',
          );
        }
        final data = res.data?['data'];
        final items = data is Map ? data['items'] : null;
        if (items is! List) {
          throw const FormatException(
            'The content search API returned an invalid item list.',
          );
        }
        for (final row in items) {
          if (row is! Map) continue;
          final title = (row['title'] as String? ?? '').toLowerCase();
          if (title == seedTitle.toLowerCase()) {
            final slug = row['slug'] as String?;
            if (slug != null && slug.isNotEmpty) {
              episodes = await fetchApiEpisodes(dio, slug);
            }
            break;
          }
        }
      }
      if (!mounted) return;
      setState(() {
        _episodes = episodes ?? const [];
        _loading = false;
        _loadFailed = false;
      });
    } catch (error, stackTrace) {
      if (kDebugMode) {
        debugPrint('Failed to load episodes for ${widget.id}: $error');
        if (error is DioException && error.response?.data != null) {
          debugPrint(error.response!.data.toString());
        }
        debugPrintStack(stackTrace: stackTrace);
      }
      if (!mounted) return;
      setState(() {
        _loading = false;
        _loadFailed = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(localeProvider).languageCode;
    final s = AppStrings(ref.watch(localeProvider));
    final catalog = ref.watch(catalogProvider);
    final idx = catalog.indexWhere((t) => t.id == widget.id);
    final item = catalog[idx];
    final saved = ref.watch(watchlistProvider).contains(widget.id);
    final epCount = _episodes.length;
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: context.isMobile ? 300 : 420,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                background: Hero(
                  tag: 'poster-${widget.id}',
                  child: CachedNetworkImage(
                      imageUrl: item.banner, fit: BoxFit.cover),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: MaxWidth(
                child: Padding(
                  padding: EdgeInsets.all(context.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: CachedNetworkImage(
                              imageUrl: item.poster,
                              width: context.isMobile ? 96 : 130,
                              height: context.isMobile ? 144 : 195,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.titleFor(loc),
                                    style: TextStyle(
                                        fontSize: context.fs(20),
                                        fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(
                                    '${item.year} - ${item.genres.join(' / ')}',
                                    style: TextStyle(
                                        fontSize: context.fs(13),
                                        color: Theme.of(context).hintColor)),
                                const SizedBox(height: 6),
                                Row(children: [
                                  const Icon(Icons.star,
                                      size: 16, color: Colors.amber),
                                  const SizedBox(width: 4),
                                  Text(item.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700)),
                                ]),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _episodes.isEmpty
                                ? null
                                : () => context.push(
                                      '/player/${_episodes.first.id}',
                                      extra: item.titleFor(loc),
                                    ),
                            icon: const Icon(Icons.play_arrow),
                            label: Text(s.watchNow),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () => ref
                                .read(watchlistProvider.notifier)
                                .toggle(widget.id),
                            icon: Icon(
                                saved ? Icons.bookmark : Icons.bookmark_border),
                            label: Text(saved ? s.inWatchlist : s.addWatchlist),
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),
                      Text(s.synopsis,
                          style: TextStyle(
                              fontSize: context.fs(16),
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Text(item.synopsisFor(loc),
                          style:
                              TextStyle(fontSize: context.fs(14), height: 1.6)),
                      const SizedBox(height: 16),
                      Text('${s.episodes} ($epCount)',
                          style: TextStyle(
                              fontSize: context.fs(16),
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      if (_loading)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(12),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (_episodes.isNotEmpty)
                        _ApiEpisodeGrid(
                            episodes: _episodes, title: item.titleFor(loc))
                      else if (_loadFailed)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.episodesLoadError),
                            TextButton.icon(
                              onPressed: () {
                                setState(() {
                                  _loading = true;
                                  _loadFailed = false;
                                });
                                _load();
                              },
                              icon: const Icon(Icons.refresh),
                              label: Text(s.retry),
                            ),
                          ],
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(s.episodesEmpty),
                        ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Grid episode asli dari API. Hanya ID episode dari backend yang dapat
/// digunakan untuk meminta daftar server video.
class _ApiEpisodeGrid extends StatelessWidget {
  const _ApiEpisodeGrid({required this.episodes, required this.title});

  final List<ApiEpisode> episodes;
  final String title;

  @override
  Widget build(BuildContext context) {
    final cols = context.isMobile
        ? 4
        : context.isTablet
            ? 6
            : 8;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio:
              context.isMobile ? 0.9 : context.isTablet ? 1.2 : 1.4),
      itemCount: episodes.length,
      itemBuilder: (_, i) {
        final ep = episodes[i];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.push('/player/${ep.id}', extra: title),
          child: Container(
            decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${ep.episodeNum}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (ep.title.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      ep.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
