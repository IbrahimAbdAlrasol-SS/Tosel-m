import 'package:Tosell/Features/auth/register/models/registration_zone.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class RegistrationZoneService {
  final BaseClient<RegistrationZone> _baseClient;
  List<RegistrationZone>? _allZonesCache;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 3);

  RegistrationZoneService() 
      : _baseClient = BaseClient<RegistrationZone>(
          fromJson: (json) => RegistrationZone.fromJson(json)
        );

  Future<List<RegistrationZone>> _getAllZonesWithoutFilter({bool forceRefresh = false}) async {
    try {
      final now = DateTime.now();
      final isCacheValid = !forceRefresh && 
          _allZonesCache != null && 
          _cacheTime != null && 
          now.difference(_cacheTime!) < _cacheDuration;
      
      if (isCacheValid) {
        return _allZonesCache!;
      }

      Map<String, dynamic> queryParams = {
        'pageSize': 1000,
        'timestamp': now.millisecondsSinceEpoch,
      };

      final result = await _baseClient.getAll(
        endpoint: '/zone',
        queryParams: queryParams,
      );
      
      // حفظ البيانات الجديدة في الكاش
      _allZonesCache = result.getList;
      _cacheTime = now;
      return _allZonesCache!;
    } catch (e) {
      // في حالة الخطأ، إرجاع الكاش الموجود أو قائمة فارغة
      return _allZonesCache ?? [];
    }
  }

  // ✅ تحديث دالة جلب المحافظات لتعرض 10 افتراضياً
  Future<List<RegistrationGovernorate>> getGovernorates({
    String? query, 
    bool forceRefresh = false
  }) async {
    try {
      final queryText = query?.trim() ?? '';
      final zones = await _getAllZonesWithoutFilter(forceRefresh: forceRefresh);
      final Map<int, RegistrationGovernorate> uniqueGovernorates = {};
      
      // استخراج المحافظات الفريدة من المناطق
      for (final zone in zones) {
        if (zone.governorate != null && zone.governorate!.id != null) {
          final gov = zone.governorate!;
          uniqueGovernorates[gov.id!] = gov;
        }
      }
      
      var allGovernorates = uniqueGovernorates.values.toList();
      allGovernorates.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      
      if (queryText.isNotEmpty) {
        final searchQuery = queryText.toLowerCase();
        allGovernorates = allGovernorates.where((gov) {
          final govName = (gov.name ?? '').toLowerCase();
          return govName.contains(searchQuery) || 
                 govName.startsWith(searchQuery) ||
                 _isArabicMatch(govName, searchQuery);
        }).toList();
        
        // ترتيب النتائج: الذي يبدأ بالبحث أولاً
        allGovernorates.sort((a, b) {
          final aName = (a.name ?? '').toLowerCase();
          final bName = (b.name ?? '').toLowerCase();
          final aStarts = aName.startsWith(searchQuery);
          final bStarts = bName.startsWith(searchQuery);
          
          if (aStarts && !bStarts) return -1;
          if (!aStarts && bStarts) return 1;
          return aName.compareTo(bName);
        });
      } else {
        // ✅ عرض 10 محافظات افتراضياً بدلاً من كل المحافظات
        allGovernorates = allGovernorates.take(10).toList();
      }   
      
      return allGovernorates;
    } catch (e) {
      return [];
    }
  }

  // ✅ تحديث دالة جلب المناطق بحسب المحافظة
  Future<List<RegistrationZone>> getZonesByGovernorate({
    required int governorateId,
    String? query,
    bool forceRefresh = false,
  }) async {
    try {
      final queryText = query?.trim() ?? '';
      final allZones = await _getAllZonesWithoutFilter(forceRefresh: forceRefresh); 
      
      // فلترة المناطق حسب المحافظة المحددة
      var zonesInGovernorate = allZones.where((zone) => 
        zone.governorate?.id == governorateId
      ).toList();
      
      zonesInGovernorate.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      
      // البحث في المناطق إذا تم إدخال نص بحث
      if (queryText.isNotEmpty) {
        final searchQuery = queryText.toLowerCase();
        zonesInGovernorate = zonesInGovernorate.where((zone) {
          final zoneName = (zone.name ?? '').toLowerCase();
          return zoneName.contains(searchQuery) || 
                 zoneName.startsWith(searchQuery) ||
                 _isArabicMatch(zoneName, searchQuery);
        }).toList();
        
        // ترتيب النتائج
        zonesInGovernorate.sort((a, b) {
          final aName = (a.name ?? '').toLowerCase();
          final bName = (b.name ?? '').toLowerCase();
          final aStarts = aName.startsWith(searchQuery);
          final bStarts = bName.startsWith(searchQuery);
          
          if (aStarts && !bStarts) return -1;
          if (!aStarts && bStarts) return 1;
          return aName.compareTo(bName);
        });
      } else {
        // عرض 10 مناطق افتراضياً
        zonesInGovernorate = zonesInGovernorate.take(10).toList();
      } 
      
      return zonesInGovernorate;
    } catch (e) {
      return [];
    }
  }
  
  // دالة تحسين البحث العربي
  bool _isArabicMatch(String text, String query) {
    final cleanText = text.replaceAll(RegExp(r'[ًٌٍَُِّْ\s]+'), '');  
    final cleanQuery = query.replaceAll(RegExp(r'[ًٌٍَُِّْ\s]+'), ''); 
    
    final textWords = cleanText.split(' ').where((w) => w.isNotEmpty);
    final queryWords = cleanQuery.split(' ').where((w) => w.isNotEmpty);
    
    return queryWords.every((queryWord) => 
        textWords.any((textWord) => textWord.contains(queryWord))
    );
  }
  
  // مسح الكاش
  void clearCache() {
    _allZonesCache = null;
    _cacheTime = null;
  }

  // تحديث البيانات بقوة
  Future<void> refreshData() async {
    clearCache();
    await _getAllZonesWithoutFilter(forceRefresh: true);
  }
}