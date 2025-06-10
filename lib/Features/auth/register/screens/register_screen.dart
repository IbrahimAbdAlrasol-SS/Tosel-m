import 'package:gap/gap.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:Tosell/Features/auth/register/screens/user_info_tab.dart';
import 'package:Tosell/Features/auth/register/widgets/build_background.dart';
import 'package:Tosell/Features/auth/register/screens/delivery_info_tab.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/Features/auth/register/providers/registration_provider.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/helpers/SharedPreferencesHelper.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _tabController.addListener(() {
      if (_tabController.index != _currentIndex) {
        setState(() {
          _currentIndex = _tabController.index;
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    // ✅ مسح البيانات عند الخروج من الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(registrationNotifierProvider.notifier).reset();
      }
    });
    super.dispose();
  }

  void _goToNextTab() {
    if (_currentIndex < _tabController.length - 1) {
      _tabController.animateTo(_currentIndex + 1);
    }
  }

  Future<void> _submitRegistration() async {
    final registrationNotifier = ref.read(registrationNotifierProvider.notifier);
    
    if (!registrationNotifier.validateUserInfo() || !registrationNotifier.validateZones()) {
      final error = ref.read(registrationNotifierProvider).error;
      if (error != null) {
        GlobalToast.show(
          message: error,
          backgroundColor: Colors.red,
        );
      }
      return;
    }

    final success = await registrationNotifier.submitRegistration();
    
    if (success) {
      GlobalToast.showSuccess(message: 'تم التسجيل بنجاح! مرحباً بك في توصيل');
      // ✅ حفظ البيانات في SharedPreferences

      
    
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
    
    else {
      final error = ref.read(registrationNotifierProvider).error;
      GlobalToast.show(
        message: error ?? 'فشل في التسجيل',
        backgroundColor: Colors.red,
      );
    }
  }

  // ✅ دالة تأكيد الخروج
  Future<bool> _onWillPop() async {
    final state = ref.read(registrationNotifierProvider);
    
    // إذا كانت هناك بيانات مدخلة، اعرض تأكيد
    if (state.fullName?.isNotEmpty == true || 
        state.brandName?.isNotEmpty == true ||
        state.userName?.isNotEmpty == true ||
        state.phoneNumber?.isNotEmpty == true ||
        state.brandImage != null ||
        state.zones.isNotEmpty) {
      
      return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text(
            'تأكيد الخروج',
            style: TextStyle(fontFamily: "Tajawal"),
          ),
          content: const Text(
            'سيتم فقدان جميع البيانات المدخلة. هل تريد الخروج؟',
            style: TextStyle(fontFamily: "Tajawal"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'إلغاء',
                style: TextStyle(fontFamily: "Tajawal"),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
                // مسح البيانات عند تأكيد الخروج
                ref.read(registrationNotifierProvider.notifier).reset();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text(
                'خروج',
                style: TextStyle(fontFamily: "Tajawal"),
              ),
            ),
          ],
        ),
      ) ?? false;
    }
    
    return true; // السماح بالخروج إذا لم تكن هناك بيانات
  }

  @override
  Widget build(BuildContext context) {
    final registrationState = ref.watch(registrationNotifierProvider);
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && mounted) {
            context.pop();
          }
        }
      },
      child: Scaffold(
        body: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              _buildBackgroundSection(),
              _buildBottomSheetSection(),
              
              if (registrationState.isSubmitting)
                Container(
                  color: Colors.black.withOpacity(0.5),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        Gap(16),
                        Text(
                          'جاري إنشاء الحساب...',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackgroundSection() {
    return Column(
      children: [
        Expanded(
          child: buildBackground(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Gap(25),
                CustomAppBar(
                  titleWidget: Text(
                    'تسجيل دخول', 
                    style: context.textTheme.bodyMedium!.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 16
                    ),
                  ),
                  showBackButton: true,
                  onBackButtonPressed: () async {
                    final shouldPop = await _onWillPop();
                    if (shouldPop && mounted) {
                      context.push(AppRoutes.login);
                    }
                  },
                ),
                _buildLogo(),
                const Gap(10),
                _buildTitle(),
                _buildDescription(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Padding(
      padding: const EdgeInsets.only(right: 20),
      child: SvgPicture.asset("assets/svg/Logo.svg"),
    );
  }

  Widget _buildTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "انشاء حساب جديد",
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 32,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildDescription() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        "مرحبا بك في منصة توصيل، قم بادخال المعلومات ادناه و سيتم انشاء حساب لمتجرك بعد الموافقة و التفعيل.",
        textAlign: TextAlign.right,
        style: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 16,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildBottomSheetSection() {
    return DraggableScrollableSheet(
      initialChildSize: 0.69,
      minChildSize: 0.69,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(  // ✅ تغيير من SingleChildScrollView إلى Column
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Gap(5),
              _buildTabBar(),
              Expanded(  // ✅ إضافة Expanded للـ TabBarView
                child: _buildTabBarView(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: TabBar(
        physics: const NeverScrollableScrollPhysics(),
        controller: _tabController,
        indicator: const BoxDecoration(),
        labelPadding: EdgeInsets.zero,
        dividerColor: Colors.transparent,
        tabs: List.generate(2, (i) {
          final bool isSelected = _currentIndex == i;
          final bool isCompleted = _currentIndex > i;
          final String label = i == 0 ? "معلومات الحساب" : "معلومات التوصيل";

          return Tab(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  height: 8,
                  width: 160.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : isCompleted 
                            ? const Color(0xff8CD98C) 
                            : const Color(0xffE1E7EA),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : isCompleted 
                            ? const Color(0xff8CD98C) 
                            : Theme.of(context).colorScheme.secondary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        SingleChildScrollView(  // ✅ إضافة scroll منفصل لكل tab
          child: UserInfoTab(onNext: _goToNextTab),
        ),
        
        SingleChildScrollView(  // ✅ إضافة scroll منفصل لكل tab
          child: Column(
            children: [
              DeliveryInfoTab(),
              
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    top: BorderSide(color: Theme.of(context).colorScheme.outline),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _tabController.animateTo(0),
                        child: const Text('السابق'),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      flex: 2,
                      child: Consumer(
                        builder: (context, ref, child) {
                          final isSubmitting = ref.watch(
                            registrationNotifierProvider.select((s) => s.isSubmitting)
                          );
                          
                          return FilledButton(
                            onPressed: _submitRegistration,
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('إنشاء الحساب'),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}