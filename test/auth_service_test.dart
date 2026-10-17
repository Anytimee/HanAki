import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hanaki/data/auth_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() {
  late Directory hiveDirectory;

  setUpAll(() async {
    hiveDirectory =
        await Directory.systemTemp.createTemp('hanaki-auth-test-');
    Hive.init(hiveDirectory.path);
    await Hive.openBox('prefs');
  });

  tearDownAll(() async {
    await Hive.close();
    await hiveDirectory.delete(recursive: true);
  });

  setUp(() async {
    await Hive.box('prefs').clear();
  });

  test('login stores JWT and the Dio client adds it to later requests', () async {
    final adapter = _RecordingAdapter();
    final dio = createApiClient()..httpClientAdapter = adapter;
    final auth = AuthService(dio);

    await auth.login(email: 'viewer@example.com', password: 'pass1234');

    expect(adapter.requests.first.method, 'POST');
    expect(
      adapter.requests.first.uri.toString(),
      'http://localhost:3000/api/auth/login',
    );
    expect(adapter.requests.first.data, {
      'email': 'viewer@example.com',
      'password': 'pass1234',
    });
    final token = Hive.box('prefs').get(authTokenKey);
    expect(token, isA<String>());

    await dio.get<void>('/contents');

    final authorization = adapter.requests.last.headers['Authorization'];
    if (authorization is! String || token is! String) {
      fail('The request must include the saved bearer token.');
    }
    expect(authorization, startsWith('Bearer '));
    expect(authorization.substring('Bearer '.length), token);
  });

  test('logout removes the saved JWT', () async {
    await Hive.box('prefs').put(authTokenKey, 'local-value');

    await AuthService(createApiClient()).logout();

    expect(Hive.box('prefs').get(authTokenKey), isNull);
  });

  test('registration posts to the API and stores the returned JWT', () async {
    final adapter = _RecordingAdapter();
    final auth = AuthService(createApiClient()..httpClientAdapter = adapter);

    await auth.register(
      email: 'new-viewer@example.com',
      password: 'password123',
    );

    final request = adapter.requests.single;
    expect(request.method, 'POST');
    expect(
      request.uri.toString(),
      'http://localhost:3000/api/auth/register',
    );
    expect(request.data, {
      'email': 'new-viewer@example.com',
      'password': 'password123',
    });
    expect(Hive.box('prefs').get(authTokenKey), 'local-value');
  });
}

class _RecordingAdapter implements HttpClientAdapter {
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode({
        'success': true,
        'data': {
          'user': {
            'id': 'viewer-id',
            'email': 'viewer@example.com',
            'role': 'USER',
          },
          'token': 'local-value',
        },
      }),
      options.path.endsWith('/register') ? 201 : 200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
