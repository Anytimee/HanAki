import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/app_constants.dart';
import '../../core/l10n/app_strings.dart';
import '../../data/auth_service.dart';
import '../providers/prefs_provider.dart';
import 'player/embed_player.dart';

/// Baris server stream dari GET /api/episodes/:id/servers (data[]).
class EpisodeServer {
  const EpisodeServer({
    required this.id,
    required this.provider,
    required this.quality,
    required this.url,
    required this.isPremium,
    required this.renderAs,
  });

  factory EpisodeServer.fromJson(Map<String, dynamic> json) => EpisodeServer(
        id: json['id'] as String? ?? '',
        provider: json['provider'] as String? ?? 'Unknown',
        quality: json['quality'] as String? ?? 'Auto',
        url: _parseServerUrl(json['url']),
        isPremium: json['isPremium'] as bool? ?? false,
        renderAs: json['renderAs'] as String? ?? 'webview',
      );

  final String id;
  final String provider;
  final String quality;
  final String url;
  final bool isPremium;
  final String renderAs; // 'webview' | 'hls' (dihitung backend).

  bool get isHls =>
      renderAs == 'hls' || Uri.parse(url).path.toLowerCase().endsWith('.m3u8');
}

String _parseServerUrl(Object? value) {
  if (value is! String || value.isEmpty) {
    throw const FormatException('Server video URL is missing.');
  }
  final uri = Uri.tryParse(value);
  if (uri == null ||
      !uri.hasAuthority ||
      (uri.scheme != 'http' && uri.scheme != 'https')) {
    throw const FormatException('Server video URL is invalid.');
  }
  return value;
}

Widget buildEpisodePlayer(
  EpisodeServer server, {
  required String playbackErrorMessage,
}) {
  if (server.isHls) {
    return _HlsPlayer(
      key: ValueKey(server.url),
      url: server.url,
      errorMessage: playbackErrorMessage,
    );
  }
  return EmbedPlayer(key: ValueKey(server.url), url: server.url);
}

/// Tanpa mock — fetch nyata dari API.
final episodeServersProvider = FutureProvider.autoDispose
    .family<List<EpisodeServer>, String>((ref, episodeId) async {
  final dio = ref.watch(apiClientProvider);
  final res = await dio.get<Map<String, dynamic>>(
    '/episodes/${Uri.encodeComponent(episodeId)}/servers',
  );
  if (res.data?['success'] != true) {
    throw const FormatException('Server returned an unsuccessful response.');
  }
  final data = res.data?['data'];
  if (data is! List) {
    throw const FormatException('Server video list is malformed.');
  }
  return data.map((row) {
    if (row is! Map) {
      throw const FormatException('Server video row is malformed.');
    }
    return EpisodeServer.fromJson(Map<String, dynamic>.from(row));
  }).toList();
});

class PlayerPage extends ConsumerStatefulWidget {
  const PlayerPage({super.key, required this.id, this.title});

  final String id; // ID episode dari API (bukan ID konten seed).
  final String? title; // Judul konten — dikirim via `extra` route.

  @override
  ConsumerState<PlayerPage> createState() => _PlayerPageState();
}
class _PlayerPageState extends ConsumerState<PlayerPage> {
  String? _selectedServerId;

  @override
  Widget build(BuildContext context) {
    final s = AppStrings(ref.watch(localeProvider));
    final serversAsync = ref.watch(episodeServersProvider(widget.id));
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text(widget.title ?? AppConstants.appName,
              style: const TextStyle(color: Colors.white)),
        ),
        body: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: serversAsync.when(
                loading: () => const Center(
                    child: CircularProgressIndicator(color: Colors.white)),
                error: (_, __) => _Unavailable(s.videoLoadError),
                data: (servers) {
                  if (servers.isEmpty) return _Unavailable(s.videoNotAvailable);
                  final server = servers.firstWhere(
                    (x) => x.id == _selectedServerId,
                    orElse: () => servers.first,
                  );
                  return buildEpisodePlayer(
                    server,
                    playbackErrorMessage: s.videoLoadError,
                  );
                },
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                color: Theme.of(context).scaffoldBackgroundColor,
                child: serversAsync.when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => Center(
                      child: Text(s.videoLoadError,
                          style: const TextStyle(color: Colors.white70))),
                  data: (servers) => ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: servers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final server = servers[i];
                      final selected =
                          server.id == (_selectedServerId ?? servers.first.id);
                      return ListTile(
                        selected: selected,
                        selectedTileColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        leading: Icon(
                          server.isPremium ? Icons.star : Icons.play_circle,
                          color: server.isPremium ? Colors.amber : null,
                        ),
                        title: Text('${server.provider} • ${server.quality}'),
                        subtitle: Text(server.url,
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        trailing: server.isPremium
                            ? const Chip(label: Text('VIP'))
                            : null,
                        onTap: () =>
                            setState(() => _selectedServerId = server.id),
                      );
                    },
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
/// Player HLS (.m3u8) via Chewie — link video langsung, bukan halaman embed.
class _HlsPlayer extends StatefulWidget {
  const _HlsPlayer(
      {super.key, required this.url, required this.errorMessage});

  final String url;
  final String errorMessage;

  @override
  State<_HlsPlayer> createState() => _HlsPlayerState();
}

class _HlsPlayerState extends State<_HlsPlayer> {
  VideoPlayerController? _vc;
  ChewieController? _cc;
  Object? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final vc = VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await vc.initialize();
      final cc = ChewieController(
        videoPlayerController: vc,
        autoPlay: true,
        allowFullScreen: true,
      );
      if (!mounted) {
        cc.dispose();
        vc.dispose();
        return;
      }
      setState(() {
        _vc = vc;
        _cc = cc;
      });
    } catch (e) {
      if (mounted) setState(() => _error = e);
    }
  }

  @override
  void dispose() {
    _cc?.dispose();
    _vc?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) return _Unavailable(widget.errorMessage);
    final cc = _cc;
    if (cc == null) {
      return const Center(
          child: CircularProgressIndicator(color: Colors.white));
    }
    return Chewie(controller: cc);
  }
}

class _Unavailable extends StatelessWidget {
  const _Unavailable(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70)),
      ),
    );
  }
}