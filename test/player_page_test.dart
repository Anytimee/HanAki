import 'package:flutter_test/flutter_test.dart';
import 'package:hanaki/presentation/pages/player/embed_player.dart';
import 'package:hanaki/presentation/pages/player_page.dart';

void main() {
  const serverUrl = 'https://www.dailymotion.com/embed/video/x9f3d2i';

  test('episode server model reads the API url field', () {
    final server = EpisodeServer.fromJson({
      'id': 'server-id',
      'provider': 'Dailymotion',
      'quality': '360p',
      'url': serverUrl,
    });

    expect(server.url, serverUrl);
    expect(server.provider, 'Dailymotion');
    expect(server.quality, '360p');
    expect(server.isHls, isFalse);
  });

  test('episode server model rejects embedUrl in place of url', () {
    expect(
      () => EpisodeServer.fromJson({
        'id': 'server-id',
        'provider': 'Dailymotion',
        'quality': '360p',
        'embedUrl': serverUrl,
      }),
      throwsFormatException,
    );
  });

  test('player builder passes the API url to the embed player', () {
    final server = EpisodeServer.fromJson({
      'id': 'server-id',
      'provider': 'Dailymotion',
      'quality': '360p',
      'url': serverUrl,
    });
    final player = buildEpisodePlayer(
      server,
      playbackErrorMessage: 'Tautan video gagal dimuat.',
    );

    expect(player, isA<EmbedPlayer>());
    if (player is! EmbedPlayer) {
      fail('An embed URL must be rendered in the WebView player.');
    }
    expect(player.url, serverUrl);
  });
}
