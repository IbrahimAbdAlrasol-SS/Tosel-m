import 'package:Tosell/Features/auth/login/providers/auth_provider.dart';
import 'package:Tosell/Features/profile/models/zone.dart';
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
  bool _isSubmitting = false;

  String? fullName;
  String? brandName;
  String? userName;
  String? phoneNumber;
  String? password;
  String? brandImg;

  List<Zone> selectedZones = [];
  double? latitude;
  double? longitude;
  String? nearestLandmark;

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
    super.dispose();
  }

  void _goToNextTab() {
    if (_currentIndex < _tabController.length - 1) {
      _tabController.animateTo(_currentIndex + 1);
    }
  }

  void _updateUserInfo({
    String? fullName,
    String? brandName,
    String? userName,
    String? phoneNumber,
    String? password,
    String? brandImg,
  }) {
    setState(() {
      if (fullName != null) this.fullName = fullName;
      if (brandName != null) this.brandName = brandName;
      if (userName != null) this.userName = userName;
      if (phoneNumber != null) this.phoneNumber = phoneNumber;
      if (password != null) this.password = password;
      if (brandImg != null) this.brandImg = brandImg;
    });

    print('📝 تحديث بيانات المستخدم:');
    print('   الاسم: ${this.fullName}');
    print('   المتجر: ${this.brandName}');
    print('   اسم المستخدم: ${this.userName}');
    print('   الهاتف: ${this.phoneNumber}');
    print('   الصورة: ${this.brandImg?.isNotEmpty == true ? 'موجودة' : 'غير موجودة'}');
  }

  /// ✅ تحديث المناطق والإحداثيات من DeliveryInfoTab
  void _updateZonesWithLocation({
    required List<Zone> zones,
    double? latitude,
    double? longitude,
    String? nearestLandmark,
  }) {
    setState(() {
      selectedZones = zones;
      this.latitude = latitude;
      this.longitude = longitude;
      this.nearestLandmark = nearestLandmark;
    });

    print('🌍 تحديث المناطق والإحداثيات:');
    print('   عدد المناطق: ${zones.length}');
    print('   الإحداثيات: $latitude, $longitude');
    print('   أقرب نقطة: $nearestLandmark');
  }

  bool _validateData() {
    if (fullName?.isEmpty ?? true) {
      GlobalToast.show(message: 'اسم صاحب المتجر مطلوب', backgroundColor: Colors.red);
      _tabController.animateTo(0);
      return false;
    }
    if (brandName?.isEmpty ?? true) {
      GlobalToast.show(message: 'اسم المتجر مطلوب', backgroundColor: Colors.red);
      _tabController.animateTo(0);
      return false;
    }
    if (userName?.isEmpty ?? true) {
      GlobalToast.show(message: 'اسم المستخدم مطلوب', backgroundColor: Colors.red);
      _tabController.animateTo(0);
      return false;
    }
    if (phoneNumber?.isEmpty ?? true) {
      GlobalToast.show(message: 'رقم الهاتف مطلوب', backgroundColor: Colors.red);
      _tabController.animateTo(0);
      return false;
    }
    if (password?.isEmpty ?? true) {
      GlobalToast.show(message: 'كلمة المرور مطلوبة', backgroundColor: Colors.red);
      _tabController.animateTo(0);
      return false;
    }
    if (brandImg?.isEmpty ?? true) {
      GlobalToast.show(message: 'صورة المتجر مطلوبة', backgroundColor: Colors.red);
      _tabController.animateTo(0);
      return false;
    }
    if (selectedZones.isEmpty) {
      GlobalToast.show(message: 'يجب إضافة منطقة واحدة على الأقل', backgroundColor: Colors.red);
      _tabController.animateTo(1);
      return false;
    }

    return true;
  }

  Future<void> _submitRegistration() async {
    if (!_validateData()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      print('🚀 بدء عملية التسجيل...');
      print('📋 البيانات النهائية:');
      print('   الاسم الكامل: $fullName');
      print('   اسم المتجر: $brandName');
      print('   اسم المستخدم: $userName');
      print('   رقم الهاتف: $phoneNumber');
      print('   صورة الشعار: $brandImg');
      print('   عدد المناطق: ${selectedZones.length}');
      print('   الإحداثيات: $latitude, $longitude');
      print('   أقرب نقطة: $nearestLandmark');

      // ✅ استخدام auth_provider.register المحدث
      final result = await ref.read(authNotifierProvider.notifier).register(
        fullName: fullName!,
        brandName: brandName!,
        userName: userName!,
        phoneNumber: phoneNumber!,
        password: password!,
        brandImg: brandImg!,
        zones: selectedZones,
        latitude: latitude,
        longitude: longitude,
        nearestLandmark: nearestLandmark,
      );

      if (result.$2 == "REGISTRATION_SUCCESS_PENDING_APPROVAL") {
        // ✅ تم التسجيل بنجاح - في انتظار الموافقة الإدارية
        
        
        await Future.delayed(const Duration(seconds: 3));
        
        if (mounted) {
          context.go(AppRoutes.login);
        }
        
      } else if (result.$1 != null) {
        // ✅ حالة مثالية: تم التسجيل والحصول على بيانات المستخدم مباشرة
        print('✅ نجح التسجيل مع بيانات المستخدم: ${result.$1!.fullName}');
        
        await SharedPreferencesHelper.saveUser(result.$1!);
        
        GlobalToast.showSuccess(
          message: 'مرحباً بك في توصيل! تم تفعيل حسابك بنجاح',
          durationInSeconds: 3,
        );
        
        await Future.delayed(const Duration(seconds: 1));
        
        if (mounted) {
          context.go(AppRoutes.home);
        }
        
      } else {
        // ❌ خطأ حقيقي في التسجيل
        print('❌ فشل التسجيل: ${result.$2}');
        GlobalToast.show(
          message: result.$2 ?? 'فشل في التسجيل',
          backgroundColor: Colors.red,
          durationInSeconds: 4,
        );
      }
      
    } catch (e) {
      print('💥 خطأ في التسجيل: $e');
      GlobalToast.show(
        message: 'خطأ في التسجيل: ${e.toString()}',
        backgroundColor: Colors.red,
        durationInSeconds: 4,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  /// ✅ دالة التحقق من الخروج مع وجود بيانات
  Future<bool> _onWillPop() async {
    if (fullName?.isNotEmpty == true || 
        brandName?.isNotEmpty == true ||
        userName?.isNotEmpty == true ||
        phoneNumber?.isNotEmpty == true ||
        brandImg?.isNotEmpty == true ||
        selectedZones.isNotEmpty) {
      
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
              child: const Text('إلغاء', style: TextStyle(fontFamily: "Tajawal")),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('خروج', style: TextStyle(fontFamily: "Tajawal")),
            ),
          ],
        ),
      ) ?? false;
    }
    
    return true;
  }

  @override
  Widget build(BuildContext context) {
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
              
              if (_isSubmitting)
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
                            fontFamily: "Tajawal",
                          ),
                        ),
                        Gap(8),
                        Text(
                          'يرجى الانتظار لحظات',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontFamily: "Tajawal",
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
      initialChildSize: 0.6,
      minChildSize: 0.6,
      maxChildSize: 0.7,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildTabBar(),
              Expanded(
                
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
                const Gap(5),
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
        SingleChildScrollView(
          child: UserInfoTab(
            onNext: _goToNextTab,
            onUserInfoChanged: _updateUserInfo,
            initialData: {
              'fullName': fullName,
              'brandName': brandName,
              'userName': userName,
              'phoneNumber': phoneNumber,
              'password': password,
              'brandImg': brandImg,
            },
          ),
        ),
        
        SingleChildScrollView(
          child: Column(
            children: [
              // ****************************************
              DeliveryInfoTab(
                onZonesChangedWithLocation: _updateZonesWithLocation,
                initialZones: selectedZones,
              ),
              // ****************************************
              
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
                        onPressed: _isSubmitting ? null : () => _tabController.animateTo(0),
                        child: const Text('السابق'),
                      ),
                    ),
                    const Gap(16),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _submitRegistration,
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('إنشاء الحساب'),
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