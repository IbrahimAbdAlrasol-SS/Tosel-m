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
      final data = {
        'merchantId': null, // يتم توليده من الباك اند
        'fullName': fullName,
        'brandName': brandName,
        'brandImg': brandImg,
        'userName': userName,
        'phoneNumber': phoneNumber,
        'img': brandImg, // نفس الصورة حسب التوضيح
        'zones': zones,
        'password': password,
        'type': type,
      };

      var result = await baseClient.create(
        endpoint: '/auth/merchant-register',
        data: data,
      );

      if (result.singleData == null) return (null, result.message);
      return (result.getSingle, null);
    } catch (e) {
      return (null, e.toString());
    }
  }
}
