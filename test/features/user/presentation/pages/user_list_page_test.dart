import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_second_app/core/constants/permission_codes.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/auth/presentation/states/auth_state.dart';
import 'package:my_second_app/features/user/presentation/pages/user_list_page.dart';
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
        PermissionCodes.userView,
        PermissionCodes.userEdit,
        PermissionCodes.userDelete,
        PermissionCodes.userAssignRole,
      },
      errorMessage: null,
    );
    appAuthController.notifyListeners();

    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
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
                      'remark': '默认角色',
                      'user_count': 1,
                      'permission_count': 12,
                      'permission_ids': [1, 2],
                    }
                  ],
                  'total': 1,
                  'page': 1,
                  'page_size': 100,
                },
              },
            ),
          );
          return;
        }

        if (options.path == '/employees') {
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
                      'emp_no': 'E001',
                      'name': '张三',
                      'gender': 'male',
                      'phone': '13800138000',
                      'email': 'zhangsan@example.com',
                      'dept_id': 1,
                      'dept_name': '研发部',
                      'position_id': 1,
                      'position_name': '工程师',
                      'leader_id': null,
                      'leader_name': null,
                      'status': 'active',
                      'hire_date': '2026-01-10',
                    }
                  ],
                  'total': 1,
                  'page': 1,
                  'page_size': 100,
                },
              },
            ),
          );
          return;
        }

        if (options.path == '/users') {
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
                      'id': 2,
                      'username': 'zhangsan',
                      'real_name': '张三',
                      'employee_id': 1,
                      'employee_name': '张三',
                      'phone': '13800138000',
                      'email': 'zhangsan@example.com',
                      'status': 1,
                      'role_ids': [1],
                      'role_names': ['系统管理员'],
                      'last_login_at': '2026-04-03T09:30:00',
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

  testWidgets('renders user rows from the API response', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: UserListPage(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('zhangsan'), findsOneWidget);
    expect(find.text('张三'), findsWidgets);
    expect(find.text('系统管理员'), findsOneWidget);
    expect(find.text('2026-04-03 09:30:00'), findsOneWidget);
  });
}
