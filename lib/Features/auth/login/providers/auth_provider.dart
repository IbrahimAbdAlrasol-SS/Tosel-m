import 'dart:async';
import 'package:Tosell/Features/auth/Services/Auth_service.dart';
import 'package:Tosell/Features/auth/models/User.dart';
import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:Tosell/core/helpers/SharedPreferencesHelper.dart';
import 'package:Tosell/core/Client/BaseClient.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class authNotifier extends _$authNotifier {
  final AuthService _service = AuthService();
  final BaseClient _baseClient = BaseClient();

  // ✅ دالة رفع الصورة
 
  // ✅ دالة التسجيل الرئيسية مع zones كاملة
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

      print('🚀 AuthProvider: بدء عملية التسجيل');
      print('📝 الاسم الكامل: $fullName');
      print('🏪 اسم المتجر: $brandName');
      print('👤 اسم المستخدم: $userName');
      print('📱 رقم الهاتف: $phoneNumber');
      print('🖼️ رابط الصورة: $brandImg');
      print('🌍 عدد المناطق: ${zones.length}');

      // ✅ تحويل zones إلى الشكل المطلوب للـ API
      final zonesData = zones.map((zone) {
        return {
          'zoneId': zone.id,
          'nearestLandmark': nearestLandmark ?? 'نقطة مرجعية',
          'long': longitude ?? 44.3661, // قيمة افتراضية (بغداد)
          'lat': latitude ?? 33.3152, // قيمة افتراضية (بغداد)
        };
      }).toList();

      print('📍 بيانات المناطق المرسلة: $zonesData');

   
      final firstZoneType = zones.isNotEmpty ? (zones.first.type ?? 1) : 1;
      print('🏷️ نوع المنطقة: $firstZoneType');

      final (user, error) = await _service.register(
          user: User(
        fullName: fullName,
        brandName: brandName,
        userName: userName,
        phoneNumber: phoneNumber,
        password: password,
        brandImg: brandImg,
        zones: zonesData,
        type: firstZoneType,
      ));

      if (user == null) {
        state = const AsyncValue.data(null);
        print('❌ AuthProvider: فشل التسجيل - $error');
        return (null, error);
      }

      print('✅ AuthProvider: نجح التسجيل - ${user.fullName}');
      await SharedPreferencesHelper.saveUser(user);
      state = AsyncValue.data(user);
      return (user, null);
    } catch (e, stackTrace) {
      print('💥 AuthProvider Exception: $e');
      state = AsyncValue.error(e, stackTrace);
      return (null, e.toString());
    }
  }



  // ✅ دالة تسجيل الدخول (بدون تغيير)
  Future<(User? data, String? error)> login({
    String? phonNumber,
    required String passWord,
  }) async {
    try {
      state = const AsyncValue.loading();

      print('🔐 AuthProvider: محاولة تسجيل الدخول للرقم: $phonNumber');

      final (user, error) = await _service.login(
        phoneNumber: phonNumber,
        password: passWord,
      );

      if (user == null) {
        state = const AsyncValue.data(null);
        print('❌ AuthProvider: فشل تسجيل الدخول - $error');
        return (null, error);
      }

      await SharedPreferencesHelper.saveUser(user);
      state = AsyncValue.data(user);
      return (user, null);
    } catch (e, stackTrace) {
      print('💥 AuthProvider login Exception: $e');
      state = AsyncValue.error(e, stackTrace);
      return (null, e.toString());
    }
  }
  

  Future<void> logout() async {
    try {
      print('🚪 AuthProvider: تسجيل الخروج');
      await SharedPreferencesHelper.removeUser();
      state = const AsyncValue.data(null);
    } catch (e) {
      print('💥 AuthProvider logout Exception: $e');
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final user = await SharedPreferencesHelper.getUser();
      if (user != null) {
        state = AsyncValue.data(user);
      }
      return user;
    } catch (e) {
      print('💥 AuthProvider getCurrentUser Exception: $e');
      return null;
    }
  }

  void updateUserState(User? user) {
    if (user != null) {
      state = AsyncValue.data(user);
    } else {
      state = const AsyncValue.data(null);
    }
  }

  @override
  FutureOr<void> build() async {
    await getCurrentUser();
    return;
  }
}
