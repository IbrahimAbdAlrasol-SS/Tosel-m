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

  // ✅ المسؤولية الأساسية: ربط الـ Service بالـ UI
  // ✅ إدارة حالة البيانات (loading, success, error)
  // ✅ توفير واجهة موحدة للـ UI

  /// 🎯 جلب جميع الطلبات مع إمكانية الفلترة والصفحات
  Future<ApiResponse<Order>> getAll({
    int page = 1, 
    Map<String, dynamic>? queryParams
  }) async {
    try {
      // ✅ المرور عبر Service فقط - لا HTTP requests مباشرة
      return await _service.getOrders(
        queryParams: queryParams, 
        page: page
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<Order?> getOrderByCode({required String code}) async {
    try {
      return await _service.getOrderByCode(code: code);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Order? order, String? error)> addOrder(AddOrderForm form) async {
    try {
      state = const AsyncValue.loading();

      var result = await _service.addOrder(orderForm: form);

      if (result.$1 != null) {
        state.whenData((currentOrders) {
          final updatedOrders = [result.$1!, ...currentOrders];
          state = AsyncValue.data(updatedOrders);
        });
        return (result.$1, null);
      } else {
        return (null, result.$2);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return (null, e.toString());
    }
  }
  Future<(Order?, String?)> changeOrderState({required String code}) async {
    try {
      var result = await _service.changeOrderState(code: code);
      
      if (result.$1 != null) {
        state.whenData((currentOrders) {
          final updatedOrders = currentOrders.map((order) {
            return order.code == code ? result.$1! : order;
          }).toList();
          state = AsyncValue.data(updatedOrders);
        });
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
      rethrow;
    }
  }

  /// 🎯 إعادة تحديث البيانات
  Future<void> refresh({Map<String, dynamic>? queryParams}) async {
    try {
      state = const AsyncValue.loading();
      final result = await getAll(page: 1, queryParams: queryParams);
      state = AsyncValue.data(result.data ?? []);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  /// 🎯 تصفية الطلبات المحلية (بدون API call)
  List<Order> filterOrdersLocally(String searchTerm) {
    return state.when(
      data: (orders) => orders.where((order) => 
        order.code?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false ||
        (order.customerName != null && order.customerName!.toLowerCase().contains(searchTerm.toLowerCase()))
      ).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

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
@riverpod
class FilteredOrdersNotifier extends _$FilteredOrdersNotifier {
  @override
  List<Order> build(String searchTerm) {
    final ordersState = ref.watch(ordersNotifierProvider);
    return ordersState.when(
      data: (orders) {
        if (searchTerm.isEmpty) return orders;
        return orders.where((order) => 
          order.code?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false ||
          (order.customerName != null && order.customerName!.toLowerCase().contains(searchTerm.toLowerCase()))
        ).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }
}