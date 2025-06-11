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

  Future<ApiResponse<Order>> getAll(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    return (await _service.getOrders(queryParams: queryParams, page: page));
  }

  Future<Order?>? getOrderByCode({required String code}) async {
    return (await _service.getOrderByCode(code: code));
  }
   /// 🎯 إعادة تحديث البيانات مع معالجة أفضل للأخطاء
  Future<void> refresh({Map<String, dynamic>? queryParams}) async {
    try {
      // ✅ عدم إظهار loading إذا كانت هناك بيانات موجودة
      final hasData = state.hasValue && state.value!.isNotEmpty;
      
      if (!hasData) {
        state = const AsyncValue.loading();
      }

      final result = await getAll(page: 1, queryParams: queryParams);
      state = AsyncValue.data(result.data ?? []);
    } catch (e) {
      // ✅ إذا كانت هناك بيانات موجودة، احتفظ بها مع إظهار خطأ
      final currentData = state.valueOrNull;
      if (currentData != null && currentData.isNotEmpty) {
        // احتفظ بالبيانات الحالية ولكن اعرض خطأ
        state = AsyncValue.error(e, StackTrace.current);
      } else {
        // لا توجد بيانات، اعرض خطأ فقط
        state = AsyncValue.error(e, StackTrace.current);
      }
    }
  }

  Future<(Order? order, String? error)> addOrder(AddOrderForm form) async {
    // Set the state to loading before starting the async operation
    state = const AsyncValue.loading();

    //? Added To Object

    try {
      // Perform the API call to add the order
      var result = await _service.addOrder(orderForm: form);

      // Update the state with the result if successful
      state = const AsyncValue.data([]);
      if (result.$1 == null) return (null, result.$2);
      return (result.$1, null); // success result
    } catch (e) {
      // If there's an error, update the state with an error
      state = AsyncError(e, StackTrace.current);
      return (null, e.toString()); // return error
    }
  }

  @override
  FutureOr<List<Order>> build() async {
    var result = await getAll();
    return result.data ?? [];
  }
}
