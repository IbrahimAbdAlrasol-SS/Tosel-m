import 'dart:io';
import 'core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/core/helpers/HttpOverrides.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Tosell/core/helpers/SharedPreferencesHelper.dart';
import 'package:Tosell/Features/auth/Services/account_lock_service.dart';
import 'package:Tosell/Features/auth/Services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  var token = (await SharedPreferencesHelper.getUser())?.token;

  if (token == null) {
    // لا يوجد token، اذهب إلى شاشة تسجيل الدخول
    initialLocation = AppRoutes.login;
  } else {
    // يوجد token، تحقق من حالة النشاط أولاً
    final authService = AuthService();
    final (isActive, error) = await authService.checkAccountStatus();
    
    if (isActive) {
      // الحساب نشط، اذهب إلى الصفحة الرئيسية
      initialLocation = AppRoutes.home;
    } else {
      // الحساب غير نشط أو خطأ 401، تحقق من حالة القفل
      final shouldShowLock = await AccountLockService.shouldShowLockScreen();
      if (shouldShowLock) {
        initialLocation = AppRoutes.accountLock;
      } else {
        // لا توجد حالة قفل، اذهب إلى تسجيل الدخول
        initialLocation = AppRoutes.login;
      }
    }
  }

  runApp(
    ProviderScope(
      child: ScreenUtilInit(
        designSize: const Size(360, 690), // Reference screen size (design size)
        builder: (context, child) {
          return EasyLocalization(
            supportedLocales: const [Locale('en'), Locale('ar')],
            path: 'assets/lang',
            startLocale: const Locale("ar"),
            fallbackLocale: const Locale('ar'),
            child: const MyApp(), // Your root widget
          );
        },
      ),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Flutter Riverpod App',

      routerConfig: appRouter,
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      darkTheme: AppTheme.darkTheme,
      // themeMode: themeMode,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale, // Let EasyLocalization handle this
    );
  }
}
