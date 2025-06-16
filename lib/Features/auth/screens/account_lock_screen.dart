import 'package:Tosell/core/utils/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../providers/account_lock_provider.dart';
import '../widgets/countdown_timer_widget.dart';
import '../register/widgets/build_background.dart';
import '../../../core/widgets/FillButton.dart';
import '../../../core/router/app_router.dart';
import '../../../core/helpers/SharedPreferencesHelper.dart';
// Remove unused import since app_spaces.dart doesn't exist

class AccountLockScreen extends ConsumerStatefulWidget {
  const AccountLockScreen({super.key});

  @override
  ConsumerState<AccountLockScreen> createState() => _AccountLockScreenState();
}

class _AccountLockScreenState extends ConsumerState<AccountLockScreen> {
  @override
  void initState() {
    super.initState();
    // تحديث حالة انتهاء المهلة عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountLockNotifierProvider.notifier).build();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lockStatusAsync = ref.watch(accountLockNotifierProvider);

    return Scaffold(
      body: lockStatusAsync.when(
        data: (lockStatus) {
          if (lockStatus == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              context.go(AppRoutes.home);
            });
            return const Center(child: CircularProgressIndicator());
          }

          return _buildLockScreen(context, lockStatus);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const Gap(16),
              Text('حدث خطأ: $error'),
              const Gap(16),
              FillButton(
                label: 'إعادة المحاولة',
                onPressed: () {
                  ref.invalidate(accountLockNotifierProvider);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLockScreen(BuildContext context, lockStatus) {
    final isExpired = lockStatus.isExpired;
    final isRejected = lockStatus.isRejected;

    return buildBackground(
      height: MediaQuery.of(context).size.height,
      child: SafeArea(
        child: Column(
          children: [
            // الشريط العلوي
            _buildTopBar(context),

            // المحتوى الرئيسي
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const Gap(20),
                      // شعار التطبيق
                      SvgPicture.asset(
                        "assets/svg/Logo.svg",
                        height: 80,
                      ),
                      const Gap(15),

                      Image.asset(
                        "assets/svg/cuick.gif",
                        height: 200,
                        width: 240,
                      ),
                      const Gap(10),

                      Text(
                        isExpired || isRejected
                            ? 'لم يتم التفعيل، تواصل مع الدعم'
                            : 'حسابك قيد التفعيل',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const Gap(10),
                      if (!isExpired && !isRejected)
                        _buildCustomTimer(lockStatus)
                      else
                        _buildExpiredMessage(),

                      _buildSupportButton(context),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // معلومات المتجر على اليمين (start)
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  "assets/svg/store.svg",
                  height: 24,
                  width: 24,
                  color: Colors.white,
                ),
              ),
              const Gap(8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'متجر ليف',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    '0771 333 4545',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),

          GestureDetector(
            onTap: () {
              //Navigator.of(context).pop();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.arrow_back,
                size: 18,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomTimer(lockStatus) {
    final duration = lockStatus.remainingTime;
    final hours = duration.inHours;
    final minutes = (duration.inMinutes % 60);
    final seconds = (duration.inSeconds % 60);

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeBox(seconds.toString().padLeft(2, '0'), 'ثانية'),
              const Text(' : ',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              _buildTimeBox(minutes.toString().padLeft(2, '0'), 'دقيقة'),
              const Text(' : ',
                  style: TextStyle(color: Colors.white, fontSize: 24)),
              _buildTimeBox(hours.toString().padLeft(2, '0'), 'ساعة'),
            ],
          ),
          const Gap(16),
          const Text(
            'نقوم بمراجعة طلبك وسنقوم بتفعيل حسابك قريباً. يمكنك التواصل معنا إذا كنت بحاجة إلى أي مساعدة.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white70,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // بناء صندوق الوقت
  Widget _buildTimeBox(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ),
        const Gap(8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // بناء رسالة انتهاء الوقت
  Widget _buildExpiredMessage() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/svg/cancle.gif",
            height: 60,
            width: 60,
          ),
          const Gap(16),
          const Text(
            'انتهت مهلة الموافقة',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  // بناء زر الدعم
  Widget _buildSupportButton(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: context.colorScheme.primary,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                "assets/svg/support.svg",
                height: 24,
                width: 24,
                color: const Color.fromARGB(255, 255, 255, 255),
              ),
              const Gap(8),
              GestureDetector(
                onTap: () => _showSupportDialog(context),
                child: const Text(
                  'تواصل مع الدعم الفني',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 8,
          left: 16,
          right: 16,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ],
    );
  }

  void _showSupportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تواصل مع الدعم الفني'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('يمكنك التواصل معنا عبر:'),
            Gap(8),
            Text('📞 الهاتف: 077 123 4567'),
            Text('📧 البريد: support@tosell.com'),
            Text('💬 واتساب: 077 123 4567'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    try {
      // مسح بيانات المستخدم وحالة القفل
      await SharedPreferencesHelper.removeUser();
      await ref.read(accountLockNotifierProvider.notifier).clearLockStatus();

      // الانتقال إلى شاشة تسجيل الدخول
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    } catch (e) {
      print('خطأ في تسجيل الخروج: $e');
    }
  }
}
