import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class ZoneService {
  // ✅ التغيير الأساسي: استخدام Zone بدلاً من ZoneObject
  final BaseClient<Zone> baseClient;

  ZoneService()
      : baseClient = BaseClient<Zone>(
            fromJson: (json) => Zone.fromJson(json)); // ✅ استخدام Zone.fromJson مباشرة

  /// جلب جميع المناطق
  Future<List<Zone>> getAllZones(
      {Map<String, dynamic>? queryParams, int page = 1}) async {
    try {
      print('🔍 ZoneService: جاري جلب المناطق من /zone...');
      
      var result = await baseClient.getAll(
          endpoint: '/zone', page: page, queryParams: queryParams);
      
      print('📋 ZoneService: استلام البيانات من API');
      print('📊 عدد العناصر: ${result.data?.length ?? 0}');
      
      if (result.data == null || result.data!.isEmpty) {
        print('⚠️ ZoneService: لا توجد بيانات مناطق');
        return [];
      }

      // ✅ التغيير: إرجاع البيانات مباشرة بدون .zone
      final zones = result.data!;
      
      print('✅ ZoneService: تم معالجة ${zones.length} منطقة');
      
      // عرض عينة من البيانات للتأكد
      if (zones.isNotEmpty) {
        final firstZone = zones.first;
        print('📝 عينة من البيانات:');
        print('   اسم المنطقة: ${firstZone.name}');
        print('   اسم المحافظة: ${firstZone.governorate?.name}');
        print('   ID المحافظة: ${firstZone.governorate?.id}');
        print('   نوع المنطقة: ${firstZone.type}');
      }
      
      return zones;
    } catch (e) {
      print('❌ ZoneService Error: $e');
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
      print('🔍 جاري جلب مناطق المحافظة ID: $governorateId');
      
      // جلب جميع المناطق
      var allZones = await getAllZones(page: page);
      
      print('📋 تم جلب ${allZones.length} منطقة إجمالي');
      
      // تصفية المناطق حسب المحافظة
      var filteredZones = allZones.where((zone) {
        final matches = zone.governorate?.id == governorateId;
        if (matches) {
          print('✅ منطقة مطابقة: ${zone.name} في ${zone.governorate?.name}');
        }
        return matches;
      }).toList();
      
      print('🎯 تم العثور على ${filteredZones.length} منطقة للمحافظة');
      
      // تصفية حسب البحث إذا كان موجود
      if (query != null && query.trim().isNotEmpty) {
        final beforeSearch = filteredZones.length;
        filteredZones = filteredZones.where((zone) => 
          zone.name?.toLowerCase().contains(query.toLowerCase()) ?? false
        ).toList();
        print('🔍 بعد البحث عن "$query": ${filteredZones.length} من $beforeSearch');
      }
      
      return filteredZones;
    } catch (e) {
      print('❌ Error in getZonesByGovernorateId: $e');
      rethrow;
    }
  }

  /// جلب مناطق المتجر الخاصة بي
  Future<List<Zone>> getMyZones() async {
    try {
      // ✅ هذا endpoint يحتاج ZoneObject لأنه يرجع { zone: {...} }
      final zoneObjectClient = BaseClient<ZoneObject>(
          fromJson: (json) => ZoneObject.fromJson(json));
          
      var result = await zoneObjectClient.get(endpoint: '/merchantzones/merchant');
      if (result.data == null) return [];
      return result.data!.map((e) => e.zone!).toList();
    } catch (e) {
      rethrow;
    }
  }
}