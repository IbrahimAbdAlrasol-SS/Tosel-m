import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/AccountLockStatus.dart';
import '../Services/account_lock_service.dart';

part 'account_lock_provider.g.dart';

@riverpod
class AccountLockNotifier extends _$AccountLockNotifier {
  Timer? _timer;

  @override
  Future<AccountLockStatus?> build() async {
    // جلب حالة القفل عند بناء الـ provider
    final status = await AccountLockService.getLockStatus();

    // بدء المؤقت إذا كانت هناك حالة قفل نشطة
    if (status != null && !status.isApproved && !status.isExpired) {
      _startTimer();
    }

    return status;
  }

  // بدء المؤقت لتحديث العد التنازلي كل ثانية
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      final currentStatus = await AccountLockService.getLockStatus();
      if (currentStatus == null) {
        timer.cancel();
        return;
      }

      // تحديث الحالة إذا انتهت المهلة
      if (currentStatus.isExpired) {
        await AccountLockService.updateExpirationStatus();
        timer.cancel();
      }

      // تحديث الـ state لإعادة بناء الواجهة
      state = AsyncValue.data(currentStatus);
    });
  }

  // إنشاء حالة قفل جديدة
  Future<void> createLockStatus() async {
    await AccountLockService.createLockStatus();
    final newStatus = await AccountLockService.getLockStatus();
    state = AsyncValue.data(newStatus);

    if (newStatus != null) {
      _startTimer();
    }
  }
  
  Future<void> updateApprovalStatus({
    bool? isApproved,
    bool? isRejected,
  }) async {
    await AccountLockService.updateApprovalStatus(
      isApproved: isApproved,
      isRejected: isRejected,
    );

    final updatedStatus = await AccountLockService.getLockStatus();
    state = AsyncValue.data(updatedStatus);

    if (isApproved == true) {
      _timer?.cancel();
    }
  }

  Future<void> clearLockStatus() async {
    await AccountLockService.clearLockStatus();
    _timer?.cancel();
    state = const AsyncValue.data(null);
  }

  Future<bool> shouldShowLockScreen() async {
    return await AccountLockService.shouldShowLockScreen();
  }

  @override
  void dispose() {
    _timer?.cancel();
    // No need to call super.dispose() since there's no dispose() in superclass
  }
}

@riverpod
Future<bool> shouldShowLockScreen(ShouldShowLockScreenRef ref) async {
  return await AccountLockService.shouldShowLockScreen();
}
