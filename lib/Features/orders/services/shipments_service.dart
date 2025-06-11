import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
class ShipmentsService {
  final BaseClient<Shipment> _baseClient;
  ShipmentsService()
      : _baseClient = BaseClient<Shipment>(
          fromJson: (json) => Shipment.fromJson(json),
        );
  Future<ApiResponse<Shipment>> getAll({
    int page = 1, 
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      final result = await _baseClient.getAll(
        endpoint: '/shipment/merchant/my-shipments',
        page: page,
        queryParams: queryParams,
      );
      return result;
    } catch (e) {

      rethrow;
    }
  }
  Future<Shipment?> getShipmentById(String shipmentId) async {
    try {
      final result = await _baseClient.getById(
        endpoint: '/api/shipment',
        id: shipmentId,
      );
      return result.singleData;
    } catch (e) {
      return null;
    }
  }
  Future<(Shipment?, String?)> createPickupShipment(
    Map<String, dynamic> shipmentData,
  ) async {
    try {
      final result = await _baseClient.create(
        endpoint: '/shipment/pick-up',
        data: shipmentData,
      );

      if (_isSuccessResponse(result.code)) {
        return (result.singleData, null);
      } else {
        return (null, result.message ?? 'فشل في إنشاء الشحنة');
      }
    } catch (e) {
      return (null, e.toString());
    }
  }
  Future<(Shipment?, String?)> createShipment(Shipment shipment) async {
    try {
      final result = await _baseClient.create(
        endpoint: '/shipment/pick-up',
        data: shipment.toJson(),
      );

      if (_isSuccessResponse(result.code)) {
        return (result.singleData, null);
      } else {
        return (null, result.message ?? 'فشل في إنشاء الشحنة');
      }
    } catch (e) {
      return (null, e.toString());
    }
  }
  Future<ApiResponse<dynamic>> getShipmentOrders({
    required String shipmentId,
    int page = 1,
  }) async {
    try {
      final result = await BaseClient().getAll(
        endpoint: '/shipment/$shipmentId/orders', // ✅ تحسين endpoint
        page: page,
      );
      return result;
    } catch (e) {
      rethrow;
    }
  }
  Future<(Shipment?, String?)> updateShipmentStatus({
    required String shipmentId,
    required int newStatus,
  }) async {
    try {
      final result = await _baseClient.update(
        endpoint: '/shipment/$shipmentId/status',
        data: {'status': newStatus},
      );
      if (_isSuccessResponse(result.code)) {
        return (result.singleData, null);
      } else {
        return (null, result.message ?? 'فشل في تحديث حالة الشحنة');
      }
    } catch (e) {
      return (null, e.toString());
    }
  }
  bool _isSuccessResponse(int? code) {
    return code == 200 || code == 201;
  }
}