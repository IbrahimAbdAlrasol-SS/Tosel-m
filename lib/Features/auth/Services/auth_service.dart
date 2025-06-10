// lib/Features/auth/Services/auth_service.dart
import 'dart:async';
import 'package:Tosell/Features/auth/models/User.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class AuthService {
  final BaseClient<User> baseClient;

  AuthService()
      : baseClient = BaseClient<User>(fromJson: (json) => User.fromJson(json));

  /// دالة تسجيل الدخول - تعمل بشكل جيد (لا تغيير)
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

  /// ✅ دالة تسجيل التاجر مع التعامل الصحيح مع الاستجابة
  Future<(User? data, String? error)> register({
    required String fullName,
    required String brandName,
    required String userName,
    required String phoneNumber,
    required String password,
    required String brandImg, // ✅ يجب أن يكون URL من رفع الصورة
    required List<Map<String, dynamic>> zones,
    required int type,
  }) async {
    try {
      print('🚀 AuthService: بدء تسجيل التاجر...');
      
      // ✅ تدقيق البيانات الأساسية
      print('📝 التحقق من البيانات الأساسية:');
      print('   - fullName: "$fullName" ${fullName.isNotEmpty ? '✅' : '❌ فارغ'}');
      print('   - brandName: "$brandName" ${brandName.isNotEmpty ? '✅' : '❌ فارغ'}');
      print('   - userName: "$userName" ${userName.isNotEmpty ? '✅' : '❌ فارغ'}');
      print('   - phoneNumber: "$phoneNumber" ${phoneNumber.isNotEmpty ? '✅' : '❌ فارغ'}');
      print('   - password: "${password.isNotEmpty ? '***' : 'فارغ'}" ${password.isNotEmpty ? '✅' : '❌ فارغ'}');
      
      // ✅ تدقيق رابط الصورة
      print('🖼️ التحقق من الصورة:');
      print('   - brandImg: "$brandImg"');
      print('   - الطول: ${brandImg.length} حرف');
      
      // ✅ التحقق من أنه URL كامل
      final isValidUrl = brandImg.startsWith('https://') || brandImg.startsWith('http://');
      
      if (!isValidUrl) {
        print('❌ خطأ: brandImg ليس URL كامل');
        print('   الرابط المستلم: "$brandImg"');
        print('   المتوقع: رابط يبدأ بـ http:// أو https://');
        return (null, 'صورة المتجر لم يتم معالجتها بشكل صحيح');
      }
      
      print('   ✅ رابط صحيح وكامل');
      print('   🌐 النطاق: ${brandImg.contains('toseel-api.future-wave.co') ? 'موقع توصيل' : 'خارجي'}');

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
        print('      - zoneId: ${zone['zoneId']} ${zone['zoneId'] != null && zone['zoneId'] > 0 ? '✅' : '❌'}');
        print('      - nearestLandmark: "${zone['nearestLandmark']}" ${zone['nearestLandmark']?.toString().isNotEmpty == true ? '✅' : '❌'}');
        print('      - lat: ${zone['lat']} ${zone['lat'] != null ? '✅' : '❌'}');
        print('      - long: ${zone['long']} ${zone['long'] != null ? '✅' : '❌'}');
        
        // ✅ التحقق من صحة بيانات المنطقة
        if (zone['zoneId'] == null || zone['zoneId'] <= 0) {
          print('❌ خطأ: zoneId غير صحيح في المنطقة ${i + 1}');
          return (null, 'معرف المنطقة غير صحيح');
        }
        
        if (zone['nearestLandmark'] == null || zone['nearestLandmark'].toString().trim().isEmpty) {
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
      print('🌐 إرسال الطلب إلى /auth/merchant-register...');
      var result = await baseClient.create(
        endpoint: '/auth/merchant-register',
        data: requestData,
      );

      print('📨 استجابة الباك اند:');
      print('📊 كود الحالة: ${result.code}');
      print('💬 الرسالة: ${result.message}');
      
      // ✅ طباعة مفصلة للاستجابة
      print('📋 تحليل الاستجابة:');
      print('   - data (List): ${result.data?.length ?? 0} عنصر');
      print('   - singleData: ${result.singleData != null ? 'موجودة' : 'غير موجودة'}');
      print('   - pagination: ${result.pagination != null ? 'موجودة' : 'غير موجودة'}');
      print('   - errors: ${result.errors}');

      // ✅ التعامل الصحيح مع الاستجابة
      if (result.code == 200 && result.message == "Operation successful") {
        print('✅ AuthService: تم التسجيل بنجاح - في انتظار التفعيل الإداري');
        
        // ✅ إرجاع حالة خاصة للتمييز
        return (null, "REGISTRATION_SUCCESS_PENDING_APPROVAL");
      }
      
      // ✅ البحث عن بيانات المستخدم في الاستجابة (في حالة وجودها)
      User? user;
      if (result.singleData != null) {
        user = result.singleData;
        print('✅ تم العثور على المستخدم في singleData');
        print('👤 بيانات المستخدم:');
        
        print('✅ AuthService: نجح التسجيل كاملاً - ');
        return (user, null);
        
      } else if (result.data != null && result.data!.isNotEmpty) {
        user = result.data!.first;
        print('✅ تم العثور على المستخدم في data[0]');
        print('👤 بيانات المستخدم: ${user.toJson()}');
        
        print('✅ AuthService: نجح التسجيل كاملاً - ${user.fullName}');
        return (user, null);
      }

      // ✅ حالة أخرى: رسالة من الباك اند
      print('⚠️ AuthService: استجابة غير متوقعة');
      return (null, result.message ?? 'استجابة غير متوقعة من الخادم');
      
    } catch (e) {
      print('💥 AuthService Exception: $e');
      print('📍 Stack trace: ${StackTrace.current}');
      return (null, 'خطأ في التسجيل: ${e.toString()}');
    }
  }
}