// lib/Features/profile/services/zone_service.dart
import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class ZoneService {
  final BaseClient<Zone> baseClient;

  ZoneService()
      : baseClient = BaseClient<Zone>(fromJson: (json) => Zone.fromJson(json));

  /// جلب جميع المناطق من الباك اند
  Future<List<Zone>> getAllZones({
    Map<String, dynamic>? queryParams, 
    int page = 1
  }) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/zone', page: page, queryParams: queryParams);

      if (result.data == null || result.data!.isEmpty) {
        return [];
      }

      return result.data!;
    } catch (e) {
      rethrow;
    }
  }

  /// جلب المناطق حسب ID المحافظة مع إمكانية البحث
  Future<List<Zone>> getZonesByGovernorateId({
    required int governorateId, 
    String? query, 
    int page = 1
  }) async {
    try {
      // جلب جميع المناطق أولاً
      var allZones = await getAllZones(page: page);

      // تصفية المناطق حسب المحافظة
      var filteredZones = allZones.where((zone) {
        return zone.governorate?.id == governorateId;
      }).toList();

      // تطبيق البحث إذا كان موجوداً
      if (query != null && query.trim().isNotEmpty) {
        filteredZones = filteredZones
            .where((zone) =>
                zone.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
            .toList();
      }

      return filteredZones;
    } catch (e) {
      rethrow;
    }
  }

  /// جلب مناطق محددة حسب قائمة من الـ IDs
  Future<List<Zone>> getZonesByIds(List<int> zoneIds) async {
    try {
      final allZones = await getAllZones();
      final filteredZones =
          allZones.where((zone) => zoneIds.contains(zone.id)).toList();

      return filteredZones;
    } catch (e) {
      rethrow;
    }
  }

  /// البحث في المناطق بالاسم
  Future<List<Zone>> searchZones(String query, {int page = 1}) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllZones(page: page);
      }

      final allZones = await getAllZones(page: page);
      final searchResults = allZones
          .where((zone) =>
              zone.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();

      return searchResults;
    } catch (e) {
      rethrow;
    }
  }

  /// جلب المناطق الخاصة بالتاجر الحالي
  Future<List<Zone>> getMyZones() async {
    try {
      // لهذا endpoint نحتاج ZoneObject لأنه يرجع { zone: {...} }
      final zoneObjectClient =
          BaseClient<ZoneObject>(fromJson: (json) => ZoneObject.fromJson(json));

      var result =
          await zoneObjectClient.get(endpoint: '/merchantzones/merchant');

      if (result.data == null) {
        return [];
      }

      final zones = result.data!.map((e) => e.zone!).toList();
      return zones;
    } catch (e) {
      rethrow;
    }
  }
}