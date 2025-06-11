import 'dart:async';
import 'package:Tosell/Features/orders/models/Shipment.dart';
import 'package:Tosell/Features/orders/services/shipments_service.dart';
import 'package:Tosell/core/Client/ApiResponse.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'shipments_provider.g.dart';

/// 🎯 Provider Layer - إدارة حالة الشحنات
/// ✅ المسؤوليات:
/// - ربط الـ ShipmentsService بالـ UI بطريقة reactive
/// - إدارة حالة البيانات (loading, success, error)
/// - تخزين البيانات مؤقتاً في الذاكرة
/// - توفير واجهة موحدة للـ UI للتفاعل مع بيانات الشحنات
/// 
/// ❌ ما لا يحتويه:
/// - HTTP requests مباشرة - يمر عبر ShipmentsService
/// - معالجة UI أو widgets
/// - منطق العرض أو التصميم
/// - تفاصيل الـ API endpoints
@riverpod
class ShipmentsNotifier extends _$ShipmentsNotifier {
  final ShipmentsService _service = ShipmentsService();

  /// 🎯 جلب جميع الشحنات مع إمكانية الفلترة والصفحات
  Future<ApiResponse<Shipment>> getAll({
    int page = 1, 
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      // ✅ المرور عبر Service فقط - لا HTTP requests مباشرة
      return await _service.getAll(
        page: page,
        queryParams: queryParams,
      );
    } catch (e) {
      // ✅ إدارة الأخطاء على مستوى Provider
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

  /// 🎯 إنشاء شحنة استحصال جديدة مع إدارة حالة reactive
  Future<(Shipment?, String?)> createPickupShipment({
    required Map<String, dynamic> shipmentData,
  }) async {
    try {
      // ✅ تحديث الحالة إلى loading
      state = const AsyncValue.loading();

      // ✅ إجراء العملية عبر Service
      var result = await _service.createPickupShipment(shipmentData);

      if (result.$1 != null) {
        // ✅ تحديث الحالة عند النجاح - إضافة الشحنة الجديدة للقائمة
        state.whenData((currentShipments) {
          final updatedShipments = [result.$1!, ...currentShipments];
          state = AsyncValue.data(updatedShipments);
        });
        
        return (result.$1, null);
      } else {
        // ✅ إعادة الحالة السابقة عند الفشل
        return (null, result.$2);
      }
    } catch (e) {
      // ✅ تحديث الحالة عند حدوث خطأ
      state = AsyncValue.error(e, StackTrace.current);
      return (null, e.toString());
    }
  }

  /// 🎯 إنشاء شحنة من نموذج Shipment
  Future<(Shipment?, String?)> createShipment({
    required Shipment shipment,
  }) async {
    try {
      state = const AsyncValue.loading();

      var result = await _service.createShipment(shipment);

      if (result.$1 != null) {
        // ✅ تحديث القائمة بالشحنة الجديدة
        state.whenData((currentShipments) {
          final updatedShipments = [result.$1!, ...currentShipments];
          state = AsyncValue.data(updatedShipments);
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
        // ✅ تحديث الشحنة في القائمة الحالية
        state.whenData((currentShipments) {
          final updatedShipments = currentShipments.map((shipment) {
            return shipment.id == shipmentId ? result.$1! : shipment;
          }).toList();
          state = AsyncValue.data(updatedShipments);
        });
      }
      
      return result;
    } catch (e) {
      return (null, e.toString());
    }
  }


  Future<void> refresh({Map<String, dynamic>? queryParams}) async {
    try {
      state = const AsyncValue.loading();
      final result = await getAll(page: 1, queryParams: queryParams);
      state = AsyncValue.data(result.data ?? []);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

//اجتهاد شخصي , بعدني مفاهم فكرته بس جهزت بحث  او فلتر 
  List<Shipment> filterShipmentsLocally(String searchTerm) {
    return state.when(
      data: (shipments) => shipments.where((shipment) => 
        shipment.code?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false
      ).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }


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
      // ✅ جلب البيانات الأولية عبر Service
      var result = await getAll();
      return result.data ?? [];
    } catch (e) {
      // ✅ إدارة الأخطاء
      throw e;
    }
  }
}

// 🎯 Provider إضافي للشحنات المفلترة لتجنب إعادة البناء غير الضرورية
@riverpod
class FilteredShipmentsNotifier extends _$FilteredShipmentsNotifier {
  @override
  List<Shipment> build(String searchTerm) {
    final shipmentsState = ref.watch(shipmentsNotifierProvider);
    
    return shipmentsState.when(
      data: (shipments) {
        if (searchTerm.isEmpty) return shipments;
        return shipments.where((shipment) => 
          shipment.code?.toLowerCase().contains(searchTerm.toLowerCase()) ?? false
        ).toList();
      },
      loading: () => [],
      error: (_, __) => [],
    );
  }
}


