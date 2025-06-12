// lib/Features/orders/services/shipments_service.dart
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';

class ShipmentsService {
  final BaseClient<Shipment> baseClient;

  ShipmentsService()
      : baseClient =
            BaseClient<Shipment>(fromJson: (json) => Shipment.fromJson(json));

  Future<ApiResponse<Shipment>> getAll(
      {int page = 1, Map<String, dynamic>? queryParams}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: 'shipment/merchant/my-shipments',
          page: page,
          queryParams: queryParams);
      return result;
    } catch (e) {
      rethrow;
    }
  }

  Future<Shipment?> getShipmentById(String shipmentId) async {
    try {
      var result =
          await baseClient.getById(endpoint: '/shipment', id: shipmentId);
      return result.singleData;
    } catch (e) {
      print('Error fetching shipment by ID: $e');
      return null;
    }
  }



  Future<(Shipment?, String?)> createShipment({
    required List<String> orderIds,
    bool? delivered,
    String? delegateId,
    String? merchantId,
    int? priority,
  }) async {
    try {
      List<OrderRequest> orders = orderIds
          .map((orderId) => OrderRequest(orderId: orderId))
          .toList();

      CreateShipmentRequest request = CreateShipmentRequest(
        orders: orders,
        delivered: delivered,
        delegateId: delegateId,
        merchantId: merchantId,
        priority: priority,
      );

      var result = await baseClient.create(
          endpoint: 'shipment/pick-up', data: request.toJson());

      if (result.code == 200 || result.code == 201) {
        return (result.singleData, null);
      } else {
        return (null, result.message ?? 'فشل في إنشاء الشحنة');
      }
    } catch (e) {
      return (null, e.toString());
    }
  }

}