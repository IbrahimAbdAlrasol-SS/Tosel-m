import 'dart:async';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/services/shipments_service.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shipments_provider.g.dart';

@riverpod
class ShipmentsNotifier extends _$ShipmentsNotifier {
  final ShipmentsService _service = ShipmentsService();

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

  Future<Shipment?> getShipmentById({required String shipmentId}) async {
    try {
      return await _service.getShipmentById(shipmentId);
    } catch (e) {
      rethrow;
    }
  }

  Future<(Shipment?, String?)> createNewShipment({
    required List<String> orderIds,
    bool? delivered,
    String? delegateId,
    String? merchantId,
    int? priority,
  }) async {
    try {
      var result = await _service.createShipment(
        orderIds: orderIds,
        delivered: delivered,
        delegateId: delegateId,
        merchantId: merchantId,
        priority: priority,
      );
      
      if (result.$1 != null) {
        ref.invalidateSelf();
      }
      
      return result;
    } catch (e) {
      return (null, e.toString());
    }
  }

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