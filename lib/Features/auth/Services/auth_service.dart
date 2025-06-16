// lib/Features/auth/Services/auth_service.dart
import 'dart:async';
import 'package:Tosell/Features/auth/models/User.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class AuthService {
  final BaseClient<User> baseClient;
  final BaseClient<bool> boolClient;

  AuthService()
      : baseClient = BaseClient<User>(fromJson: (json) => User.fromJson(json)),
        boolClient = BaseClient<bool>();

  Future<(User? data, String? error)> login(
      {String? phoneNumber, required String password}) async {
    try {
      var result = await baseClient.create(endpoint: '/auth/login', data: {
        'phoneNumber': phoneNumber,
        'password': password,
      });

      if (result.singleData == null) return (null, result.message);
      return (result.getSingle, null);
    } catch (e) {
      return (null, e.toString());
    }
  }

  Future<(User? data, String? error)> register({
    required String fullName,
    required String brandName,
    required String userName,
    required String phoneNumber,
    required String password,
    required String brandImg, 
    required List<Map<String, dynamic>> zones,
    required int type,
  }) async {
    try {
      print('🚀 AuthService: بدء تسجيل التاجر...');

      // ✅ تدقيق البيانات الأساسية
      print('📝 التحقق من البيانات الأساسية:');
      print(
          '   - fullName: "$fullName" ${fullName.isNotEmpty ? '✅' : '❌ فارغ'}');
      print(
          '   - brandName: "$brandName" ${brandName.isNotEmpty ? '✅' : '❌ فارغ'}');
      print(
          '   - userName: "$userName" ${userName.isNotEmpty ? '✅' : '❌ فارغ'}');
      print(
          '   - phoneNumber: "$phoneNumber" ${phoneNumber.isNotEmpty ? '✅' : '❌ فارغ'}');
      print(
          '   - password: "${password.isNotEmpty ? '***' : 'فارغ'}" ${password.isNotEmpty ? '✅' : '❌ فارغ'}');

      // ✅ تدقيق رابط الصورة
      print('🖼️ التحقق من الصورة:');
      print('   - brandImg: "$brandImg"');
      print('   - الطول: ${brandImg.length} حرف');

      // ✅ التحقق من أنه URL كامل
      final isValidUrl =
          brandImg.startsWith('https://') || brandImg.startsWith('http://');

      if (!isValidUrl) {
        print('❌ خطأ: brandImg ليس URL كامل');
        print('   الرابط المستلم: "$brandImg"');
        print('   المتوقع: رابط يبدأ بـ http:// أو https://');
        return (null, 'صورة المتجر لم يتم معالجتها بشكل صحيح');
      }

      print('   ✅ رابط صحيح وكامل');
      print(
          '   🌐 النطاق: ${brandImg.contains('toseel-api.future-wave.co') ? 'موقع توصيل' : 'خارجي'}');

      // ✅ تدقيق المناطق
      print('🌍 التحقق من المناطق:');
      print('   - عدد المناطق: ${zones.length}');

      if (zones.isEmpty) {
        print('❌ خطأ: لا توجد مناطق');
        return (null, 'يجب اختيار منطقة واحدة على الأقل');
      }

      for (int i = 0; i < zones.length; i++) {
        final zone = zones[i];
        print('   📍 المنطقة ${i + 1}:');
        print(
            '      - zoneId: ${zone['zoneId']} ${zone['zoneId'] != null && zone['zoneId'] > 0 ? '✅' : '❌'}');
        print(
            '      - nearestLandmark: "${zone['nearestLandmark']}" ${zone['nearestLandmark']?.toString().isNotEmpty == true ? '✅' : '❌'}');
        print('      - lat: ${zone['lat']} ${zone['lat'] != null ? '✅' : '❌'}');
        print(
            '      - long: ${zone['long']} ${zone['long'] != null ? '✅' : '❌'}');

        // ✅ التحقق من صحة بيانات المنطقة
        if (zone['zoneId'] == null || zone['zoneId'] <= 0) {
          print('❌ خطأ: zoneId غير صحيح في المنطقة ${i + 1}');
          return (null, 'معرف المنطقة غير صحيح');
        }

        if (zone['nearestLandmark'] == null ||
            zone['nearestLandmark'].toString().trim().isEmpty) {
          print('❌ خطأ: nearestLandmark فارغ في المنطقة ${i + 1}');
          return (null, 'أقرب نقطة دالة مطلوبة لكل منطقة');
        }

        if (zone['lat'] == null || zone['long'] == null) {
          print('❌ خطأ: إحداثيات ناقصة في المنطقة ${i + 1}');
          return (null, 'يجب تحديد الموقع على الخريطة لكل منطقة');
        }
      }

      // ✅ تدقيق النوع
      print('🏷️ التحقق من النوع:');
      print('   - type: $type');
      if (type != 1 && type != 2) {
        print('⚠️ تحذير: type = $type (مقبول لكن غير معتاد، المتوقع: 1 أو 2)');
      } else {
        print('   - المعنى: ${type == 1 ? 'مركز' : 'أطراف'} ✅');
      }

      // ✅ تحضير البيانات بالشكل المطلوب تماماً
      final requestData = {
        'merchantId': null, // ✅ null كما طلب
        'fullName': fullName,
        'brandName': brandName,
        'brandImg': brandImg, // ✅ URL من رفع الصورة
        'userName': userName,
        'phoneNumber': phoneNumber,
        'img': brandImg, // ✅ نفس brandImg كما مطلوب
        'zones': zones, // ✅ قائمة بالشكل المطلوب
        'password': password,
        'type': type, // ✅ نوع المنطقة
      };

      print('📤 البيانات النهائية المرسلة:');
      print('📋 JSON كامل:');
      print(requestData);

      // ✅ طباعة حجم البيانات للتأكد
      print('📏 إحصائيات:');
      print('   - حجم zones: ${zones.length} منطقة');
      print('   - طول brandImg: ${brandImg.length} حرف');
      print('   - طول fullName: ${fullName.length} حرف');
      print('   - طول brandName: ${brandName.length} حرف');

      // ✅ إرسال الطلب
      var result = await baseClient.create(
        endpoint: '/auth/merchant-register',
        data: requestData,
      );

      if (result.code == 200 && result.message == "Operation successful") {
        // ✅ إرجاع حالة خاصة للتمييز
        return (null, "REGISTRATION_SUCCESS_PENDING_APPROVAL");
      }

      User? user;
      if (result.singleData != null) {
        user = result.singleData;

        return (user, null);
      } else if (result.data != null && result.data!.isNotEmpty) {
        user = result.data!.first;

        return (user, null);
      }

      return (null, result.message ?? 'استجابة غير متوقعة من الخادم');
    } catch (e) {
      return (null, 'خطأ في التسجيل: ${e.toString()}');
    }
  }

  /// دالة التحقق من حالة نشاط الحساب
  Future<(bool isActive, String? error)> checkAccountStatus() async {
    try {
      final response = await boolClient.get(endpoint: '/auth/is-active');
      
      // إذا كان الرد ناجح (200) وكان البيانات true
      if (response.code == 200) {
        // التحقق من البيانات المرجعة
        if (response.data != null && response.data!.isNotEmpty) {
          return (response.data!.first, null);
        }
        // إذا لم تكن هناك بيانات، نعتبر الحساب غير نشط
        return (false, null);
      }
      
      // إذا كان الرد 401 (غير مصرح)
      if (response.code == 401) {
        return (false, 'غير مصرح');
      }
      
      // أي رد آخر يعتبر خطأ
      return (false, response.message ?? 'خطأ في التحقق من حالة الحساب');
    } catch (e) {
      // في حالة حدوث خطأ في الشبكة أو أي خطأ آخر
      return (false, 'خطأ في الاتصال: ${e.toString()}');
    }
  }
}
