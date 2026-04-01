import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_second_app/core/network/api_result.dart';
import 'package:my_second_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:my_second_app/features/dashboard/presentation/states/dashboard_state.dart';
import 'package:my_second_app/shared/repositories/dashboard_repository.dart';

class DashboardController extends ChangeNotifier {
  DashboardController()
      : _repository = DashboardRepository(appAuthController.dio),
        state = const DashboardState();

  final DashboardRepository _repository;
  DashboardState state;

  Future<void> load() async {
    state = state.copyWith(loading: true, clearError: true);
    notifyListeners();
    try {
      final results = await Future.wait<dynamic>([
        _repository.fetchSummary(),
        _repository.fetchDepartmentDistribution(),
        _repository.fetchPositionDistribution(),
        _repository.fetchLatestHires(),
      ]);
      state = state.copyWith(
        loading: false,
        summary: results[0],
        departmentDistribution: results[1],
        positionDistribution: results[2],
        latestHires: results[3],
      );
      notifyListeners();
    } on ApiException catch (error) {
      state = state.copyWith(
        loading: false,
        errorMessage: error.message,
      );
      notifyListeners();
    } catch (_) {
      state = state.copyWith(
        loading: false,
        errorMessage: '仪表盘数据加载失败',
      );
      notifyListeners();
    }
  }
}

final dashboardControllerProvider = ChangeNotifierProvider<DashboardController>(
  (ref) => DashboardController(),
);
