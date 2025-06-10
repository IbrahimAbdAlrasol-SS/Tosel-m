import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class ZoneService {
  final BaseClient<ZoneObject> baseClient;

  ZoneService()
      : baseClient = BaseClient<ZoneObject>(
            fromJson: (json) => ZoneObject.fromJson(json));

  /// جلب جميع المناطق
  Future<List<Zone>> getAllZones(
      {Map<String, dynamic>? queryParams, int page = 1}) async {
    try {
      var result = await baseClient.getAll(
          endpoint: '/zone', page: page, queryParams: queryParams);
      if (result.data == null) return [];
      return result.data!.map((e) => e.zone!).toList();
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
      // جلب جميع المناطق
      var allZones = await getAllZones(page: page);
      
      // تصفية المناطق حسب المحافظة
      var filteredZones = allZones.where((zone) => 
        zone.governorate?.id == governorateId
      ).toList();
      
      // تصفية حسب البحث إذا كان موجود
      if (query != null && query.trim().isNotEmpty) {
        filteredZones = filteredZones.where((zone) => 
          zone.name?.toLowerCase().contains(query.toLowerCase()) ?? false
        ).toList();
      }
      
      return filteredZones;
    } catch (e) {
      print('Error in getZonesByGovernorateId: $e');
      rethrow;
    }
  }

  /// جلب مناطق المتجر الخاصة بي
  Future<List<Zone>> getMyZones() async {
    try {
      var result = await baseClient.get(endpoint: '/merchantzones/merchant');
      if (result.data == null) return [];
      return result.data!.map((e) => e.zone!).toList();
    } catch (e) {
      rethrow;
    }
  }
}