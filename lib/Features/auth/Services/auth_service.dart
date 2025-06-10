import 'dart:async';

import 'package:Tosell/Features/auth/models/User.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class AuthService {
  final BaseClient<User> baseClient;

  AuthService()
      : baseClient = BaseClient<User>(fromJson: (json) => User.fromJson(json));

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

  // ✅ تعديل دالة register لتتطابق مع API المطلوب
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
      print('🚀 AuthService: إرسال البيانات إلى /auth/merchant-register');
      
      final data = {
        'merchantId': null, // يتم توليده من الباك اند
        'fullName': fullName,
        'brandName': brandName,
        'brandImg': brandImg,
        'userName': userName,
        'phoneNumber': phoneNumber,
        'img': brandImg, // نفس الصورة حسب المتطلبات
        'zones': zones,
        'password': password,
        'type': type,
      };

      print('📦 البيانات المرسلة: $data');

      var result = await baseClient.create(
        endpoint: '/auth/merchant-register',
        data: data,
      );

      print('📨 استجابة الباك اند:');
      print('📊 Status Code: ${result.code}');
      print('💬 Message: ${result.message}');
      print('📄 Single Data: ${result.singleData}');
      print('❌ Errors: ${result.errors}');

      if (result.singleData == null) {
        print('❌ AuthService: فشل التسجيل - ${result.message}');
        return (null, result.message);
      }
      
      print('✅ AuthService: نجح التسجيل');
      return (result.getSingle, null);
    } catch (e) {
      print('💥 AuthService Exception: $e');
      return (null, e.toString());
    }
  }
}