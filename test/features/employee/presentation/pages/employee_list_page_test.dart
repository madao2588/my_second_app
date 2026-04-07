import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_second_app/core/constants/permission_codes.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/auth/presentation/states/auth_state.dart';
import 'package:my_second_app/features/employee/presentation/pages/employee_list_page.dart';
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
        PermissionCodes.empView,
        PermissionCodes.empEdit,
        PermissionCodes.empDelete,
      },
      errorMessage: null,
    );
    appAuthController.notifyListeners();

    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == '/departments/options') {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'code': 0,
                'message': 'ok',
                'data': [
                  {'id': 1, 'dept_name': '研发部'}
                ],
              },
            ),
          );
          return;
        }

        if (options.path == '/positions/options') {
          handler.resolve(
            Response(
              requestOptions: options,
              statusCode: 200,
              data: {
                'code': 0,
                'message': 'ok',
                'data': [
                  {'id': 1, 'position_name': '工程师'}
                ],
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

  testWidgets('renders employee rows from the API response', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: EmployeeListPage(),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();

    expect(find.text('E001'), findsOneWidget);
    expect(find.text('张三'), findsOneWidget);
    expect(find.text('研发部'), findsOneWidget);
    expect(find.text('工程师'), findsOneWidget);
  });
}
