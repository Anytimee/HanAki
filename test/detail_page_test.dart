import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hanaki/core/l10n/app_strings.dart';
import 'package:hanaki/data/auth_service.dart';
import 'package:hanaki/presentation/pages/detail_page.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory =
        await Directory.systemTemp.createTemp('hanaki-detail-test-');
    Hive.init(hiveDirectory.path);
    await Hive.openBox('prefs');
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  test('episode parser reads episodes from the nested API data object', () {
    final episodes = parseApiEpisodes({
      'success': true,
      'data': {
        'title': 'Solo Leveling',
        'slug': 'solo-leveling',
        'episodes': [
          {
            'id': 'cmvbuixkj0002fpd7go5nf59l',
            'episodeNum': 1,
            'title': 'Awal',
          },
        ],
      },
    });

    expect(episodes, hasLength(1));
    expect(episodes.single.episodeNum, 1);
    expect(episodes.single.title, 'Awal');
    expect(episodes.single.id, 'cmvbuixkj0002fpd7go5nf59l');
  });

  testWidgets('detail resolves the local ID and renders nested API episodes',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final adapter = _DetailApiAdapter();
    final dio = Dio(BaseOptions(baseUrl: 'http://localhost:3000/api'))
      ..httpClientAdapter = adapter;
    final router = GoRouter(
      initialLocation: '/detail/a-solo',
      routes: [
        GoRoute(
          path: '/detail/:id',
          builder: (_, state) => DetailPage(id: state.pathParameters['id']!),
        ),
        GoRoute(
          path: '/player/:id',
          builder: (_, state) => Scaffold(
              body: Text('Player opened: ${state.pathParameters['id']}')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [apiClientProvider.overrideWithValue(dio)],
        child: MaterialApp.router(
          locale: const Locale('id'),
          supportedLocales: AppStrings.supportedLocales,
          localizationsDelegates: const [
            AppStringsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(
      adapter.requests.map((request) => request.uri.path).toList(),
      ['/api/contents/a-solo', '/api/contents', '/api/contents/solo-leveling'],
    );
    expect(adapter.requests[1].uri.queryParameters, {
      'search': 'Solo Leveling',
      'limit': '10',
    });
    await tester.dragUntilVisible(
      find.text('Awal'),
      find.byType(CustomScrollView),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text('Awal'), findsOneWidget);
    expect(find.text('Episode (1)'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Awal'));
    await tester.pumpAndSettle();
    expect(
      find.text('Player opened: cmvbuixkj0002fpd7go5nf59l'),
      findsOneWidget,
    );
  });
}

class _DetailApiAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    if (options.uri.path == '/api/contents/a-solo') {
      return _response(
        {'success': false, 'error': 'Konten tidak ditemukan'},
        404,
      );
    }
    if (options.uri.path == '/api/contents') {
      return _response({
        'success': true,
        'data': {
          'items': [
            {'title': 'Solo Leveling', 'slug': 'solo-leveling'},
          ],
        },
      });
    }
    if (options.uri.path == '/api/contents/solo-leveling') {
      return _response({
        'success': true,
        'data': {
          'title': 'Solo Leveling',
          'slug': 'solo-leveling',
          'episodes': [
            {
              'id': 'cmvbuixkj0002fpd7go5nf59l',
              'episodeNum': 1,
              'title': 'Awal',
            },
          ],
        },
      });
    }
    return _response({'success': false, 'error': 'Unexpected request'}, 404);
  }

  ResponseBody _response(
    Map<String, dynamic> data, [
    int statusCode = 200,
  ]) =>
      ResponseBody.fromString(
        jsonEncode(data),
        statusCode,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );

  @override
  void close({bool force = false}) {}
}
