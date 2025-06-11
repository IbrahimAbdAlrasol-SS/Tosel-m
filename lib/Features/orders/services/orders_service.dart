import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:Tosell/Features/orders/models/Order.dart';
import 'package:Tosell/Features/order/models/add_order_form.dart';
class OrdersService {
  final BaseClient<Order> _baseClient;

  OrdersService()
      : _baseClient = BaseClient<Order>(
          fromJson: (json) => Order.fromJson(json),
        );

  Future<ApiResponse<Order>> getOrders({
    int page = 1, 
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await _baseClient.getAll(
        endpoint: '/order/merchant',
        page: page,
        queryParams: queryParams,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }


  Future<(Order?, String?)> changeOrderState({required String code}) async {
    try {
      final result = await _baseClient.update(
        endpoint: '/order/$code/advance-step',
      );
      return (result.singleData, result.message);
    } catch (e) {
      return (null, e.toString());
    }
  }

  Future<Order?> getOrderByCode({required String code}) async {
    try {
      final result = await _baseClient.getById(
        endpoint: '/order',
        id: code,
      );
      return result.singleData;
    } catch (e) {
      return null;
    }
  }

  Future<bool> validateCode({required String code}) async {
    try {
      final result = await BaseClient<bool>().get(
        endpoint: '/order/$code/available', // ✅ إصلاح endpoint
      );
      return result.singleData ?? false;
    } catch (e) {

      return false;
    }
  }

  Future<(Order?, String?)> addOrder({
    required AddOrderForm orderForm,
  }) async {
    try {
      final result = await _baseClient.create(
        endpoint: '/order',
        data: orderForm.toJson(),
      );

      if (result.singleData == null) {
        return (null, result.message ?? 'فشل في إنشاء الطلب');
      }

      return (result.singleData, null);
    } catch (e) {
      return (null, e.toString());
    }
  }

  Future<ApiResponse<Order>> searchOrders({
    required String searchTerm,
    int page = 1,
  }) async {
    try {
      final queryParams = {
        'search': searchTerm,
      };

      final result = await _baseClient.getAll(
        endpoint: '/order/merchant/search',
        page: page,
        queryParams: queryParams,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<Order?> getOrderDetails({required String orderId}) async {
    try {
      final result = await _baseClient.getById(
        endpoint: '/order/details',
        id: orderId,
      );
      return result.singleData;
    } catch (e) {
      return null;
    }
  }
}