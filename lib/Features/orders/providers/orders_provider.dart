import 'dart:async';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Tosell/Features/order/models/add_order_form.dart';
import 'package:Tosell/Features/orders/services/orders_service.dart';

part 'orders_provider.g.dart';

@riverpod
class OrdersNotifier extends _$OrdersNotifier {
  final OrdersService _service = OrdersService();

  /// 🎯 جلب جميع الطلبات
  Future<ApiResponse<Order>> getAll({
    int page = 1, 
    Map<String, dynamic>? queryParams
  }) async {
    try {
      return await _service.getOrders(queryParams: queryParams, page: page);
    } catch (e) {
      rethrow;
    }
  }

  /// 🎯 جلب طلب واحد بالكود
  Future<Order?> getOrderByCode({required String code}) async {
    try {
      return await _service.getOrderByCode(code: code);
    } catch (e) {
      rethrow;
    }
  }

  /// 🎯 إضافة طلب جديد
  Future<(Order? order, String? error)> addOrder(AddOrderForm form) async {
    try {
      state = const AsyncValue.loading();
      var result = await _service.addOrder(orderForm: form);

      if (result.$1 != null) {
        await refresh(); // Refresh the entire list
        return (result.$1, null);
      } else {
        return (null, result.$2);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return (null, e.toString());
    }
  }

  /// 🎯 تغيير حالة الطلب
  Future<(Order?, String?)> changeOrderState({required String code}) async {
    try {
      var result = await _service.changeOrderState(code: code);
      
      if (result.$1 != null) {
        await refresh(); // Refresh the entire list
      }
      
      return result;
    } catch (e) {
      rethrow;
    }
  }

  /// 🎯 التحقق من صحة الكود
  Future<bool> validateCode({required String code}) async {
    try {
      return await _service.validateCode(code: code);
    } catch (e) {
      return false;
    }
  }

  /// 🎯 إعادة تحديث البيانات
  Future<void> refresh({Map<String, dynamic>? queryParams}) async {
    try {
      // Don't show loading if we have data
      final hasData = state.hasValue && state.value!.isNotEmpty;
      
      if (!hasData) {
        state = const AsyncValue.loading();
      }

      final result = await getAll(page: 1, queryParams: queryParams);
      state = AsyncValue.data(result.data ?? []);
    } catch (e) {
      // Keep current data if we have it, otherwise show error
      final currentData = state.valueOrNull;
      if (currentData == null || currentData.isEmpty) {
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  /// 🎯 البحث في الطلبات
  Future<void> search(String searchTerm) async {
    try {
      state = const AsyncValue.loading();
      
      final queryParams = searchTerm.isNotEmpty 
          ? {'code': searchTerm}
          : <String, dynamic>{};
          
      final result = await getAll(page: 1, queryParams: queryParams);
      state = AsyncValue.data(result.data ?? []);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// ✅ البناء الأولي للـ Provider
  @override
  FutureOr<List<Order>> build() async {
    try {
      var result = await getAll();
      return result.data ?? [];
    } catch (e) {
      throw e;
    }
  }
}