import 'dart:async';
import 'package:Tosell/Features/auth/Services/Auth_service.dart';
import 'package:Tosell/Features/auth/models/User.dart';
import 'package:Tosell/core/helpers/SharedPreferencesHelper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_provider.g.dart';

@riverpod
class authNotifier extends _$authNotifier {
  final AuthService _service = AuthService();


 Future<(User? data, String? error)> rehister({
 required User user,
  }) async {
      state = const AsyncValue.loading();
      final (result, error) = await _service.register(
        // phoneNumber: user.phoneNumber!,
        // password: user.password,
        // userName: user.userName!,
        // img: user.image,
        // address: user.address,
        // lat: user.lat,
        // long: user.long,
        // isAdmin: user.isAdmin,
        // isVerified: user.isVerified,
        user:user,
      );
     

      return (user, error);


    
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
