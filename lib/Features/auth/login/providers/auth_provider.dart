import 'dart:async';
import 'package:Tosell/Features/auth/Services/Auth_service.dart';
import 'package:Tosell/Features/auth/models/User.dart';
import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:Tosell/core/helpers/SharedPreferencesHelper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class authNotifier extends _$authNotifier {
  final AuthService _service = AuthService();

  // ✅ تحديث دالة register لتتطابق مع API المطلوب
  Future<(User? data, String? error)> register({
    required String fullName,
    required String brandName,
    required String userName,
    required String phoneNumber,
    required String password,
    required String brandImg,
    required List<Zone> zones, // List<Zone> بدلاً من Map
    double? latitude,
    double? longitude,
    String? nearestLandmark,
  }) async {
    try {
      state = const AsyncValue.loading();
      
      print('🔍 AuthProvider: تحضير بيانات التسجيل');
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
          'lat': latitude ?? 33.3152,   // قيمة افتراضية (بغداد)
        };
      }).toList();

      print('📍 بيانات المناطق المرسلة: $zonesData');

      // ✅ تحديد نوع المنطقة (أول منطقة)
      final firstZoneType = zones.isNotEmpty ? (zones.first.type ?? 1) : 1;
      print('🏷️ نوع المنطقة: $firstZoneType');

      final (user, error) = await _service.register(
        fullName: fullName,
        brandName: brandName,
        userName: userName,
        phoneNumber: phoneNumber,
        password: password,
        brandImg: brandImg,
        zones: zonesData,
        type: firstZoneType,
      );

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

  // ✅ دالة مبسطة للتسجيل (للاستخدام مع المناطق البسيطة)
  Future<(User? data, String? error)> registerSimple({
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
      state = const AsyncValue.loading();

      final (user, error) = await _service.register(
        fullName: fullName,
        brandName: brandName,
        userName: userName,
        phoneNumber: phoneNumber,
        password: password,
        brandImg: brandImg,
        zones: zones,
        type: type,
      );

      if (user == null) {
        state = const AsyncValue.data(null);
        return (null, error);
      }

      await SharedPreferencesHelper.saveUser(user);
      state = AsyncValue.data(user);
      return (user, null);
    } catch (e, stackTrace) {
      state = AsyncValue.error(e, stackTrace);
      return (null, e.toString());
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

  @override
  FutureOr<void> build() async {
    return;
  }
}