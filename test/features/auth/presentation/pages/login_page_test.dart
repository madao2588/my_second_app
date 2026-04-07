import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_second_app/features/auth/presentation/pages/login_page.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/auth/presentation/states/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appAuthController.state = const AuthState(
      initialized: true,
      loading: false,
      token: null,
      user: null,
      roles: [],
      permissions: {},
      errorMessage: null,
    );
    appAuthController.notifyListeners();
  });

  testWidgets('shows validation messages when credentials are empty',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), '');
    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.ensureVisible(find.text('登录系统'));
    await tester.tap(find.text('登录系统'));
    await tester.pump();

    expect(find.text('请输入账号'), findsOneWidget);
    expect(find.text('请输入密码'), findsOneWidget);
  });

  testWidgets('renders auth error messages from controller state',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    appAuthController.state = const AuthState(
      initialized: true,
      loading: false,
      token: null,
      user: null,
      roles: [],
      permissions: {},
      errorMessage: '登录失败，请稍后重试',
    );
    appAuthController.notifyListeners();

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginPage(),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('登录失败，请稍后重试'), findsOneWidget);
  });
}
