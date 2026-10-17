import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hanaki/data/auth_service.dart';
import 'package:hanaki/presentation/pages/login_page.dart';
import 'package:hanaki/presentation/pages/profile_page.dart';
import 'package:hanaki/presentation/pages/register_page.dart';

void main() {
  testWidgets('login form validates inputs and reflows on a narrow screen',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('id'),
          supportedLocales: [Locale('id')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: LoginPage(),
        ),
      ),
    );

    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Masukkan alamat email yang valid.'), findsOneWidget);
    expect(find.text('Masukkan kata sandi.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('password visibility control toggles obscuring', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          locale: Locale('id'),
          supportedLocales: [Locale('id')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: LoginPage(),
        ),
      ),
    );

    final passwordField = find.byType(EditableText).at(1);
    expect(tester.widget<EditableText>(passwordField).obscureText, isTrue);

    await tester.tap(find.byTooltip('Tampilkan kata sandi'));
    await tester.pump();

    expect(tester.widget<EditableText>(passwordField).obscureText, isFalse);
  });

  testWidgets('successful login shows loading and opens the profile',
      (tester) async {
    final request = Completer<void>();
    final authService = _FakeAuthService((_, __) => request.future);
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(
          path: '/login',
          builder: (_, __) => const LoginPage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const Scaffold(body: Text('Profile destination')),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(authService)],
    );
    addTearDown(router.dispose);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('id'),
          supportedLocales: const [Locale('id')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.enterText(
        find.byType(TextFormField).at(0), 'viewer@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Masuk'));
    await tester.pump();

    expect(find.text('Memeriksa akun…'), findsOneWidget);
    final buttonStyle =
        tester.widget<FilledButton>(find.byType(FilledButton)).style!;
    expect(
      buttonStyle.foregroundColor?.resolve({WidgetState.disabled}),
      Colors.white,
    );
    expect(container.read(isAuthenticatedProvider), isFalse);

    request.complete();
    await tester.pumpAndSettle();

    expect(find.text('Profile destination'), findsOneWidget);
    expect(container.read(isAuthenticatedProvider), isTrue);
  });

  testWidgets('login shows a recoverable network error', (tester) async {
    final authService = _FakeAuthService(
      (_, __) async => throw DioException(
        requestOptions: RequestOptions(path: '/auth/login'),
      ),
    );
    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(authService)],
    );
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('id'),
          supportedLocales: [Locale('id')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: LoginPage(),
        ),
      ),
    );
    await tester.enterText(
        find.byType(TextFormField).at(0), 'viewer@example.com');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Tidak dapat terhubung ke server. Periksa koneksi dan pastikan API aktif.',
      ),
      findsOneWidget,
    );
    expect(container.read(isAuthenticatedProvider), isFalse);
  });

  testWidgets('login sign-up action opens the registration route',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/login',
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(
          path: '/register',
          builder: (_, __) =>
              const Scaffold(body: Text('Registration destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('id'),
        supportedLocales: const [Locale('id')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Registration destination'), findsOneWidget);
  });

  testWidgets('registration validates matching passwords and opens profile',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 640);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    String? registeredEmail;
    String? registeredPassword;
    final authService = _FakeAuthService(
      (_, __) async {},
      onRegister: (email, password) async {
        registeredEmail = email;
        registeredPassword = password;
      },
    );
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
        GoRoute(
          path: '/profile',
          builder: (_, __) => const Scaffold(body: Text('Profile destination')),
        ),
      ],
    );
    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(authService)],
    );
    addTearDown(router.dispose);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('id'),
          supportedLocales: const [Locale('id')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'viewer@example.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'different123');
    await tester.ensureVisible(find.text('Daftar'));
    await tester.tap(find.text('Daftar'));
    await tester.pump();
    expect(find.text('Kata sandi tidak cocok.'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.ensureVisible(find.text('Daftar'));
    await tester.tap(find.text('Daftar'));
    await tester.pumpAndSettle();

    expect(registeredEmail, 'viewer@example.com');
    expect(registeredPassword, 'password123');
    expect(find.text('Profile destination'), findsOneWidget);
    expect(container.read(isAuthenticatedProvider), isTrue);
  });

  testWidgets('registration password controls and sign-in link work',
      (tester) async {
    final router = GoRouter(
      initialLocation: '/register',
      routes: [
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
        GoRoute(
          path: '/login',
          builder: (_, __) => const Scaffold(body: Text('Login destination')),
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        locale: const Locale('id'),
        supportedLocales: const [Locale('id')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );

    final fields = find.byType(EditableText);
    expect(tester.widget<EditableText>(fields.at(1)).obscureText, isTrue);
    expect(tester.widget<EditableText>(fields.at(2)).obscureText, isTrue);
    await tester.tap(find.byTooltip('Tampilkan kata sandi').first);
    await tester.pump();
    expect(tester.widget<EditableText>(fields.at(1)).obscureText, isFalse);
    await tester.tap(find.byTooltip('Tampilkan kata sandi'));
    await tester.pump();
    expect(tester.widget<EditableText>(fields.at(2)).obscureText, isFalse);

    await tester.ensureVisible(find.text('Masuk'));
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();
    expect(find.text('Login destination'), findsOneWidget);
  });

  testWidgets('profile sign-in action opens the login route', (tester) async {
    final router = GoRouter(
      initialLocation: '/profile',
      routes: [
        GoRoute(
          path: '/profile',
          builder: (_, __) => const ProfilePage(),
        ),
        GoRoute(
          path: '/login',
          builder: (_, __) => const Scaffold(body: Text('Login destination')),
        ),
      ],
    );
    final container = ProviderContainer();
    addTearDown(router.dispose);
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp.router(
          locale: const Locale('id'),
          supportedLocales: const [Locale('id')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: router,
        ),
      ),
    );
    await tester.tap(find.text('Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Login destination'), findsOneWidget);
  });

  testWidgets('profile sign-out action clears authenticated state',
      (tester) async {
    final authService = _FakeAuthService((_, __) async {});
    final container = ProviderContainer(
      overrides: [authServiceProvider.overrideWithValue(authService)],
    );
    container.read(isAuthenticatedProvider.notifier).state = true;
    addTearDown(container.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const MaterialApp(
          locale: Locale('id'),
          supportedLocales: [Locale('id')],
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: ProfilePage(),
        ),
      ),
    );
    await tester.tap(find.text('Keluar'));
    await tester.pumpAndSettle();

    expect(container.read(isAuthenticatedProvider), isFalse);
  });
}

class _FakeAuthService extends AuthService {
  _FakeAuthService(this._onLogin, {this.onRegister}) : super(Dio());

  final Future<void> Function(String email, String password) _onLogin;
  final Future<void> Function(String email, String password)? onRegister;

  @override
  Future<void> login({
    required String email,
    required String password,
  }) =>
      _onLogin(email, password);

  @override
  Future<void> register({
    required String email,
    required String password,
  }) =>
      onRegister?.call(email, password) ?? Future<void>.value();

  @override
  Future<void> logout() async {}
}
