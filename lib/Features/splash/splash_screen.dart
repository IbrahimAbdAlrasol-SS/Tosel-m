import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/helpers/SharedPreferencesHelper.dart';
import 'package:Tosell/Features/auth/Services/account_lock_service.dart';
import 'package:Tosell/Features/auth/login/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkUserStatus();
  }

  Future<void> _checkUserStatus() async {
    await Future.delayed(const Duration(seconds: 2)); // تأخير للشعار

    try {
      // التحقق من وجود مستخدم محفوظ
      final user = await SharedPreferencesHelper.getUser();
      
      if (user == null) {
        // لا يوجد مستخدم - اذهب لتسجيل الدخول
        if (mounted) context.go(AppRoutes.login);
        return;
      }

      // يوجد مستخدم - تحقق من حالة التفعيل
      final (isActive, error) = await ref
          .read(authNotifierProvider.notifier)
          .checkAccountStatus();

      if (error == 'غير مصرح') {
        // التوكن منتهي أو غير صالح
        await SharedPreferencesHelper.removeUser();
        if (mounted) context.go(AppRoutes.login);
        return;
      }

      if (isActive) {
        // الحساب مفعل - اذهب للرئيسية
        await AccountLockService.clearLockStatus();
        if (mounted) context.go(AppRoutes.home);
      } else {
        // الحساب غير مفعل - تحقق من حالة القفل
        final shouldShowLock = await AccountLockService.shouldShowLockScreen();
        
        if (shouldShowLock) {
          if (mounted) context.go(AppRoutes.accountLock);
        } else {
          // لا توجد حالة قفل - أنشئ واحدة
          await AccountLockService.createLockStatus();
          if (mounted) context.go(AppRoutes.accountLock);
        }
      }
    } catch (e) {
      print('خطأ في التحقق من حالة المستخدم: $e');
      if (mounted) context.go(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/svg/Logo.svg",
              height: 120,
              color: Colors.white,
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}