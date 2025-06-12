import 'dart:async';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/services/shipments_service.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shipments_provider.g.dart';

@riverpod
class ShipmentsNotifier extends _$ShipmentsNotifier {
  final ShipmentsService _service = ShipmentsService();

  /// 🎯 جلب جميع الشحنات
  Future<ApiResponse<Shipment>> getAll({
    int page = 1, 
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      return await _service.getAll(page: page, queryParams: queryParams);
    } catch (e) {
      rethrow;
    }
  }

  /// 🎯 جلب شحنة واحدة بالمعرف
  Future<Shipment?> getShipmentById({required String shipmentId}) async {
    try {
      return await _service.getShipmentById(shipmentId);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Shipment?, String?)> createShipment({
    required Shipment shipment,
  }) async {
    try {
      state = const AsyncValue.loading();
      var result = await _service.createShipment(shipment);

      if (result.$1 != null) {
        await refresh();
        return (result.$1, null);
      } else {
        return (null, result.$2);
      }
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      return (null, e.toString());
    }
  }

  /// 🎯 تحديث حالة الشحنة
  Future<(Shipment?, String?)> updateShipmentStatus({
    required String shipmentId,
    required int newStatus,
  }) async {
    try {
      var result = await _service.updateShipmentStatus(
        shipmentId: shipmentId,
        newStatus: newStatus,
      );
      
      if (result.$1 != null) {
        await refresh(); // Refresh the entire list
      }
      
      return result;
    } catch (e) {
      return (null, e.toString());
    }
  }

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

  /// 🎯 البحث في الشحنات
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

  /// 🎯 جلب طلبات الشحنة
  Future<ApiResponse<dynamic>> getShipmentOrders({
    required String shipmentId,
    int page = 1,
  }) async {
    try {
      return await _service.getShipmentOrders(
        shipmentId: shipmentId,
        page: page,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// ✅ البناء الأولي للـ Provider
  @override
  FutureOr<List<Shipment>> build() async {
    try {
      var result = await getAll();
      return result.data ?? [];
    } catch (e) {
      throw e;
    }
  }
}