import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/AccountLockStatus.dart';

class AccountLockService {
  static const String _lockStatusKey = 'account_lock_status';

  static Future<void> saveLockStatus(AccountLockStatus status) async {
    final prefs = await SharedPreferences.getInstance();
    final statusJson = jsonEncode(status.toJson());
    await prefs.setString(_lockStatusKey, statusJson);
  }

  static Future<AccountLockStatus?> getLockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final statusJson = prefs.getString(_lockStatusKey);
    if (statusJson == null) return null;

    try {
      final statusMap = jsonDecode(statusJson) as Map<String, dynamic>;
      return AccountLockStatus.fromJson(statusMap);
    } catch (e) {
      print('خطأ في قراءة حالة القفل: $e');
      return null;
    }
  }

  static Future<void> createLockStatus() async {
    final status = AccountLockStatus(
      registrationTime: DateTime.now(),
    );
    await saveLockStatus(status);
  }

  static Future<void> updateApprovalStatus({
    bool? isApproved,
    bool? isRejected,
  }) async {
    final currentStatus = await getLockStatus();
    if (currentStatus == null) return;

    final updatedStatus = currentStatus.copyWith(
      isApproved: isApproved,
      isRejected: isRejected,
      hasExpired: currentStatus.isExpired,
    );

    await saveLockStatus(updatedStatus);
  }

  // مسح حالة القفل (عند الموافقة أو تسجيل الخروج)
  static Future<void> clearLockStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_lockStatusKey);
  }

  // التحقق من ضرورة عرض شاشة القفل
  static Future<bool> shouldShowLockScreen() async {
    final status = await getLockStatus();
    if (status == null) return false;

    // إذا تمت الموافقة، لا نعرض شاشة القفل
    if (status.isApproved) {
      await clearLockStatus();
      return false;
    }

    // إذا انتهت المهلة أو تم الرفض، نعرض شاشة القفل
    if (status.isExpired || status.isRejected) {
      return true;
    }

    // إذا كان في فترة الانتظار، نعرض شاشة القفل
    return true;
  }

  // تحديث حالة انتهاء المهلة
  static Future<void> updateExpirationStatus() async {
    final status = await getLockStatus();
    if (status == null) return;

    if (status.isExpired && !status.hasExpired) {
      final updatedStatus = status.copyWith(hasExpired: true);
      await saveLockStatus(updatedStatus);
    }
  }
}
