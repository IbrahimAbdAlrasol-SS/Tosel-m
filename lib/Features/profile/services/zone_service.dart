// lib/Features/profile/services/zone_service.dart
import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class ZoneService {
  // ✅ استخدام Zone بدلاً من ZoneObject للبساطة
  final BaseClient<Zone> baseClient;

  ZoneService()
      : baseClient = BaseClient<Zone>(
            fromJson: (json) => Zone.fromJson(json));

  /// ✅ جلب جميع المناطق من الباك اند
  Future<List<Zone>> getAllZones({
    Map<String, dynamic>? queryParams, 
    int page = 1
  }) async {
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

      final zones = result.data!;
      
      print('✅ ZoneService: تم معالجة ${zones.length} منطقة');
      
      // ✅ عرض عينة من البيانات للتأكد
      if (zones.isNotEmpty) {
        final firstZone = zones.first;
        print('📝 عينة من البيانات:');
        print('   اسم المنطقة: ${firstZone.name}');
        print('   اسم المحافظة: ${firstZone.governorate?.name}');
        print('   ID المحافظة: ${firstZone.governorate?.id}');
        print('   نوع المنطقة: ${firstZone.type} (${firstZone.type == 1 ? 'مركز' : 'أطراف'})');
      }
      
      return zones;
    } catch (e) {
      print('❌ ZoneService Error: $e');
      rethrow;
    }
  }

  /// ✅ جلب المناطق حسب ID المحافظة مع إمكانية البحث
  Future<List<Zone>> getZonesByGovernorateId({
    required int governorateId,
    String? query,
    int page = 1
  }) async {
    try {
      print('🔍 جاري جلب مناطق المحافظة ID: $governorateId');
      
      // ✅ جلب جميع المناطق أولاً
      var allZones = await getAllZones(page: page);
      
      print('📋 تم جلب ${allZones.length} منطقة إجمالي');
      
      // ✅ تصفية المناطق حسب المحافظة
      var filteredZones = allZones.where((zone) {
        final matches = zone.governorate?.id == governorateId;
        if (matches) {
          print('✅ منطقة مطابقة: ${zone.name} في ${zone.governorate?.name}');
        }
        return matches;
      }).toList();
      
      print('🎯 تم العثور على ${filteredZones.length} منطقة للمحافظة');
      
      // ✅ تطبيق البحث إذا كان موجوداً
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

  /// ✅ جلب مناطق محددة حسب قائمة من الـ IDs
  Future<List<Zone>> getZonesByIds(List<int> zoneIds) async {
    try {
      print('🔍 جاري جلب المناطق حسب IDs: $zoneIds');
      
      final allZones = await getAllZones();
      final filteredZones = allZones.where((zone) => 
        zoneIds.contains(zone.id)
      ).toList();
      
      print('✅ تم العثور على ${filteredZones.length} منطقة من ${zoneIds.length} مطلوبة');
      
      return filteredZones;
    } catch (e) {
      print('❌ Error in getZonesByIds: $e');
      rethrow;
    }
  }

  /// ✅ البحث في المناطق بالاسم
  Future<List<Zone>> searchZones(String query, {int page = 1}) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllZones(page: page);
      }
      
      print('🔍 البحث عن المناطق: "$query"');
      
      final allZones = await getAllZones(page: page);
      final searchResults = allZones.where((zone) =>
        zone.name?.toLowerCase().contains(query.toLowerCase()) ?? false
      ).toList();
      
      print('🎯 نتائج البحث: ${searchResults.length} منطقة');
      
      return searchResults;
    } catch (e) {
      print('❌ Error in searchZones: $e');
      rethrow;
    }
  }

  /// ✅ جلب المناطق الخاصة بالتاجر الحالي (إذا كان محتاجاً لاحقاً)
  Future<List<Zone>> getMyZones() async {
    try {
      print('🔍 جاري جلب مناطق التاجر...');
      
      // ✅ لهذا endpoint نحتاج ZoneObject لأنه يرجع { zone: {...} }
      final zoneObjectClient = BaseClient<ZoneObject>(
          fromJson: (json) => ZoneObject.fromJson(json));
          
      var result = await zoneObjectClient.get(endpoint: '/merchantzones/merchant');
      
      if (result.data == null) {
        print('⚠️ لا توجد مناطق للتاجر');
        return [];
      }
      
      final zones = result.data!.map((e) => e.zone!).toList();
      print('✅ تم جلب ${zones.length} منطقة للتاجر');
      
      return zones;
    } catch (e) {
      print('❌ Error in getMyZones: $e');
      rethrow;
    }
  }
}