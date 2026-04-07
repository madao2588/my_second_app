import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_second_app/core/constants/permission_codes.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/auth/presentation/states/auth_state.dart';
import 'package:my_second_app/features/role/presentation/pages/role_list_page.dart';
import 'package:my_second_app/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Interceptor interceptor;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    appAuthController.state = AuthState(
      initialized: true,
      loading: false,
      token: 'token',
      user: const UserModel(
        id: 1,
        username: 'admin',
        realName: '管理员',
        employeeId: null,
        employeeName: null,
        phone: null,
        email: null,
        status: 1,
        roleIds: [],
        roleNames: [],
        lastLoginAt: null,
      ),
      roles: const [],
      permissions: const {
        PermissionCodes.roleView,
        PermissionCodes.roleEdit,
        PermissionCodes.roleDelete,
        PermissionCodes.roleAssignPermission,
      },
      errorMessage: null,
    );
    appAuthController.notifyListeners();

    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == '/permissions/tree') {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'code': 0,
                'message': 'ok',
                'data': [
                  {
                    'id': 1,
                    'perm_code': 'system:user:view',
                    'perm_name': '查看用户',
                    'perm_type': 'button',
                    'parent_id': null,
                    'route_path': null,
                    'icon': null,
                    'sort_order': 1,
                    'status': 1,
                    'children': [],
                  }
                ],
              },
            ),
          );
          return;
        }

        if (options.path == '/roles') {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'code': 0,
                'message': 'ok',
                'data': {
                  'items': [
                    {
                      'id': 1,
                      'role_code': 'admin',
                      'role_name': '系统管理员',
                      'status': 1,
                      'remark': '负责平台配置',
                      'user_count': 3,
                      'permission_count': 12,
                      'permission_ids': [1],
                    }
                  ],
                  'total': 1,
                  'page': 1,
                  'page_size': 20,
                },
              },
            ),
          );
          return;
        }

        handler.next(options);
      },
    );

    appAuthController.dio.interceptors.add(interceptor);
  });

  tearDown(() {
    appAuthController.dio.interceptors.remove(interceptor);
  });

  testWidgets('renders role rows from the API response', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RoleListPage(),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('admin'), findsOneWidget);
    expect(find.text('系统管理员'), findsOneWidget);
    expect(find.text('负责平台配置'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });
}
