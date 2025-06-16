import 'dart:async';
import 'package:Tosell/Features/auth/Services/Auth_service.dart';
import 'package:Tosell/Features/auth/Services/account_lock_service.dart';
import 'package:Tosell/Features/auth/models/User.dart';
import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:Tosell/core/helpers/SharedPreferencesHelper.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class authNotifier extends _$authNotifier {
  final AuthService _service = AuthService();

  String _buildFullImageUrl(String imagePath) {
    if (imagePath.startsWith('http://') || imagePath.startsWith('https://')) {
      return imagePath;
    } else if (imagePath.startsWith('/')) {
      return '$imageUrl${imagePath.substring(1)}';
    } else {
      return '$imageUrl$imagePath';
    }
  }

  Future<(User? data, String? error)> register({
    required String fullName,
    required String brandName,
    required String userName,
    required String phoneNumber,
    required String password,
    required String brandImg,
    required List<Zone> zones,
    double? latitude,
    double? longitude,
    String? nearestLandmark,
  }) async {
    try {
      state = const AsyncValue.loading();

      if (fullName.trim().isEmpty) {
        const errorMsg = 'اسم صاحب المتجر مطلوب';
        state = const AsyncValue.data(null);
        return (null, errorMsg);
      }

      if (brandName.trim().isEmpty) {
        const errorMsg = 'اسم المتجر مطلوب';
        state = const AsyncValue.data(null);
        return (null, errorMsg);
      }

      if (userName.trim().isEmpty) {
        const errorMsg = 'اسم المستخدم مطلوب';
        state = const AsyncValue.data(null);
        return (null, errorMsg);
      }

      if (phoneNumber.trim().isEmpty) {
        const errorMsg = 'رقم الهاتف مطلوب';
        state = const AsyncValue.data(null);

        return (null, errorMsg);
      }

      if (password.isEmpty) {
        const errorMsg = 'كلمة المرور مطلوبة';
        state = const AsyncValue.data(null);
        return (null, errorMsg);
      }

      if (brandImg.trim().isEmpty) {
        const errorMsg = 'صورة المتجر مطلوبة';
        state = const AsyncValue.data(null);
        return (null, errorMsg);
      }

      final fullImageUrl = _buildFullImageUrl(brandImg);

      if (zones.isEmpty) {
        const errorMsg = 'يجب اختيار منطقة واحدة على الأقل';
        state = const AsyncValue.data(null);
        return (null, errorMsg);
      }

      final zonesData = <Map<String, dynamic>>[];

      for (int i = 0; i < zones.length; i++) {
        final zone = zones[i];

        if (zone.id == null || zone.id! <= 0) {
          final errorMsg = 'معرف المنطقة ${i + 1} غير صحيح';
          state = const AsyncValue.data(null);
          return (null, errorMsg);
        }

        final zoneData = {
          'zoneId': zone.id!,
          'nearestLandmark': nearestLandmark?.trim().isNotEmpty == true
              ? nearestLandmark!.trim()
              : 'نقطة مرجعية ${i + 1}',
          'long': longitude ?? 44.3661,
          'lat': latitude ?? 33.3152,
        };

        zonesData.add(zoneData);

        print('      - أقرب نقطة: ${zoneData['nearestLandmark']}');
        print(
            '      - الإحداثيات: lat=${zoneData['lat']}, long=${zoneData['long']}');
      }

      print('✅ تم تحضير ${zonesData.length} منطقة بنجاح');

      // ✅ تحديد نوع المنطقة من أول منطقة مختارة
      final firstZoneType = zones.first.type ?? 1;
      print(
          '🏷️ نوع المنطقة المحدد: $firstZoneType (${firstZoneType == 1 ? 'مركز' : firstZoneType == 2 ? 'أطراف' : 'غير معروف'})');

      // ✅ طباعة ملخص البيانات قبل الإرسال
      print('📊 ملخص البيانات النهائية:');
      print('   - الاسم الكامل: "$fullName"');
      print('   - اسم المتجر: "$brandName"');
      print('   - اسم المستخدم: "$userName"');
      print('   - رقم الهاتف: "$phoneNumber"');
      print('   - صورة المتجر: URL كامل ✅');
      print('   - عدد المناطق: ${zonesData.length}');
      print('   - نوع المنطقة: $firstZoneType');
      print('   - كلمة المرور: محمية ✅');

      // ✅ استدعاء AuthService مع URL الصورة الكامل
      print('🚀 إرسال البيانات إلى AuthService...');
      final (user, error) = await _service.register(
        fullName: fullName.trim(),
        brandName: brandName.trim(),
        userName: userName.trim(),
        phoneNumber: phoneNumber.trim(),
        password: password,
        brandImg: fullImageUrl, // ✅ استخدام URL الكامل
        zones: zonesData,
        type: firstZoneType,
      );

      // ✅ التعامل مع الحالات المختلفة
      if (error == "REGISTRATION_SUCCESS_PENDING_APPROVAL") {
        // ✅ تسجيل ناجح لكن يحتاج موافقة إدارية - إنشاء حالة قفل
        print('✅ AuthProvider: تم التسجيل بنجاح - في انتظار الموافقة الإدارية');
        // إنشاء حالة قفل للحساب الجديد
        await _createAccountLockStatus();
        state = const AsyncValue.data(null);
        return (null, "REGISTRATION_SUCCESS_PENDING_APPROVAL");
      }

      if (user == null) {
        state = const AsyncValue.data(null);
        print('❌ AuthProvider: فشل التسجيل - $error');
        return (null, error);
      }

      // ✅ حالة مثالية: حفظ بيانات المستخدم محلياً بعد نجاح التسجيل
      print('✅ AuthProvider: نجح التسجيل كاملاً - ${user.fullName}');
      await SharedPreferencesHelper.saveUser(user);
      state = AsyncValue.data(user);

      return (user, null);
    } catch (e, stackTrace) {
      print('💥 AuthProvider Exception: $e');
      print('📍 Stack trace: $stackTrace');
      state = AsyncValue.error(e, stackTrace);
      return (null, 'خطأ غير متوقع: ${e.toString()}');
    }
  }

  Future<(User? data, String? error)> login({
    String? phonNumber,
    required String passWord,
  }) async {
    try {
      state = const AsyncValue.loading();
      final (user, error) = await _service.login(
        phoneNumber: phonNumber,
        password: passWord,
      );
      if (user == null) {
        state = const AsyncValue.data(null);
        return (null, error);
      }
      await SharedPreferencesHelper.saveUser(user);
      state = AsyncValue.data(user);
      return (user, error);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return (null, e.toString());
    }
  }

  // ✅ دالة إنشاء حالة قفل للحساب الجديد
  Future<void> _createAccountLockStatus() async {
    try {
      await AccountLockService.createLockStatus();
      print('✅ تم إنشاء حالة قفل للحساب الجديد');
    } catch (e) {
      print('❌ خطأ في إنشاء حالة القفل: $e');
    }
  }

  /// دالة التحقق من حالة نشاط الحساب
  Future<(bool isActive, String? error)> checkAccountStatus() async {
    try {
      final (isActive, error) = await _service.checkAccountStatus();
      return (isActive, error);
    } catch (e) {
      return (false, 'خطأ غير متوقع: ${e.toString()}');
    }
  }

  @override
  FutureOr<void> build() async {
    return;
  }
}
