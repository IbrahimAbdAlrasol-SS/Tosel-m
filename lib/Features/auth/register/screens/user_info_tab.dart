// lib/Features/auth/register/screens/user_info_tab.dart
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/widgets/FillButton.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Tosell/core/utils/GlobalToast.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

class UserInfoTab extends ConsumerStatefulWidget {
  final VoidCallback? onNext;
  final Function({
    String? fullName,
    String? brandName,
    String? userName,
    String? phoneNumber,
    String? password,
    String? brandImg,
  }) onUserInfoChanged;
  final Map<String, dynamic> initialData;

  const UserInfoTab({
    super.key,
    this.onNext,
    required this.onUserInfoChanged,
    this.initialData = const {},
  });

  @override
  ConsumerState<UserInfoTab> createState() => _UserInfoTabState();
}

class _UserInfoTabState extends ConsumerState<UserInfoTab> {
  final _formKey = GlobalKey<FormState>();
  
  // ✅ Controllers للنصوص
  final _fullNameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // ✅ Focus nodes للتنقل بين الحقول
  final _fullNameFocus = FocusNode();
  final _brandNameFocus = FocusNode();
  final _userNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  // ✅ متغيرات حالة الصورة وكلمات المرور
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  XFile? _brandImage;
  String? _uploadedImageUrl;
  bool _isUploadingImage = false;

  // ✅ BaseClient لرفع الصور
  final BaseClient _baseClient = BaseClient();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _brandNameController.dispose();
    _userNameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    
    _fullNameFocus.dispose();
    _brandNameFocus.dispose();
    _userNameFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }

  /// ✅ تحميل البيانات الأولية إذا كانت موجودة
  void _loadInitialData() {
    _fullNameController.text = widget.initialData['fullName'] ?? '';
    _brandNameController.text = widget.initialData['brandName'] ?? '';
    _userNameController.text = widget.initialData['userName'] ?? '';
    _phoneController.text = widget.initialData['phoneNumber'] ?? '';
    _passwordController.text = widget.initialData['password'] ?? '';
    _uploadedImageUrl = widget.initialData['brandImg'];
  }

  /// ✅ دالة اختيار الصورة ورفعها
  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _brandImage = image;
          _isUploadingImage = true;
        });

        print('🖼️ بدء رفع الصورة: ${image.name}');
        
        // ✅ رفع الصورة باستخدام BaseClient
        final result = await _baseClient.uploadFile(image.path);
        
        if (result.data != null && result.data!.isNotEmpty) {
          setState(() {
            _uploadedImageUrl = result.data!.first;
            _isUploadingImage = false;
          });
          
          print('✅ تم رفع الصورة بنجاح: $_uploadedImageUrl');
          GlobalToast.showSuccess(message: 'تم رفع الصورة بنجاح');
          
          // ✅ تحديث البيانات في الـ parent
          _saveCurrentData();
        } else {
          throw Exception('فشل في رفع الصورة');
        }
      }
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
        _brandImage = null;
      });
      
      print('❌ خطأ في رفع الصورة: $e');
      GlobalToast.show(
        message: 'فشل في رفع الصورة: ${e.toString()}',
        backgroundColor: Colors.red,
      );
    }
  }

  /// ✅ حفظ البيانات الحالية وإرسالها للـ parent
  void _saveCurrentData() {
    widget.onUserInfoChanged(
      fullName: _fullNameController.text.trim(),
      brandName: _brandNameController.text.trim(),
      userName: _userNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      password: _passwordController.text,
      brandImg: _uploadedImageUrl,
    );
  }

  /// ✅ دالة التحقق والانتقال للخطوة التالية
  Future<void> _handleNext() async {
    // ✅ حفظ البيانات أولاً
    _saveCurrentData();

    // ✅ التحقق من صحة النموذج
    if (!_formKey.currentState!.validate()) return;

    // ✅ التحقق من رفع الصورة
    if (_uploadedImageUrl == null) {
      GlobalToast.show(
        message: 'يجب رفع صورة المتجر أولاً',
        backgroundColor: Colors.red,
      );
      return;
    }

    // ✅ التحقق من تطابق كلمات المرور
    if (_passwordController.text != _confirmPasswordController.text) {
      GlobalToast.show(
        message: 'كلمة المرور غير متطابقة',
        backgroundColor: Colors.red,
      );
      return;
    }

    print('✅ تم التحقق من بيانات المستخدم بنجاح');
    widget.onNext?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // ✅ حقل اسم صاحب المتجر
            CustomTextFormField(
              controller: _fullNameController,
              focusNode: _fullNameFocus,
              label: "أسم صاحب المتجر",
              hint: "مثال: \"محمد حسين\"",
              prefixInner: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  "assets/svg/User.svg",
                  width: 24,
                  height: 24,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return "اسم صاحب المتجر مطلوب";
                if (value!.trim().length < 2) return "اسم صاحب المتجر قصير جداً";
                return null;
              },
              onChanged: (value) => _saveCurrentData(),
              onFieldSubmitted: (_) => _brandNameFocus.requestFocus(),
            ),
            
            const Gap(5),
            
            // ✅ حقل اسم المتجر
            CustomTextFormField(
              controller: _brandNameController,
              focusNode: _brandNameFocus,
              label: "اسم المتجر",
              hint: "مثال: \"معرض الأخوين\"",
              prefixInner: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  "assets/svg/12. Storefront.svg",
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return "اسم المتجر مطلوب";
                if (value!.trim().length < 2) return "اسم المتجر قصير جداً";
                return null;
              },
              onChanged: (value) => _saveCurrentData(),
              onFieldSubmitted: (_) => _userNameFocus.requestFocus(),
            ),
            
            const Gap(5),
            
            // ✅ حقل اسم المستخدم
            CustomTextFormField(
              controller: _userNameController,
              focusNode: _userNameFocus,
              label: "اسم المستخدم",
              hint: "مثال: \"ahmad_store\"",
              prefixInner: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  "assets/svg/User.svg",
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return "اسم المستخدم مطلوب";
                if (value!.trim().length < 3) return "اسم المستخدم قصير جداً";
                // ✅ التحقق من وجود أحرف وليس رموز فقط
                final hasLetters = RegExp(r'[a-zA-Z\u0600-\u06FF]').hasMatch(value);
                if (!hasLetters) return "اسم المستخدم يجب أن يحتوي على أحرف";
                return null;
              },
              onChanged: (value) => _saveCurrentData(),
              onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
            ),
            
            const Gap(5),
            
            // ✅ حقل رقم الهاتف
            CustomTextFormField(
              controller: _phoneController,
              focusNode: _phoneFocus,
              label: "رقم هاتف المتجر",
              hint: "07xx Xxx Xxx",
              keyboardType: TextInputType.phone,
              prefixInner: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  "assets/svg/08. Phone.svg",
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              validator: (value) {
                if (value?.trim().isEmpty ?? true) return "رقم الهاتف مطلوب";
                final phoneRegex = RegExp(r'^(07[0-9]{9}|07[0-9]{8})$');
                if (!phoneRegex.hasMatch(value!.replaceAll(' ', ''))) {
                  return "رقم الهاتف غير صحيح";
                }
                return null;
              },
              onChanged: (value) => _saveCurrentData(),
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            
            const Gap(5),
            
            // ✅ حقل رفع الصورة
            CustomTextFormField(
              readOnly: true,
              label: "شعار / صورة المتجر",
              hint: _brandImage?.name ?? _uploadedImageUrl?.split('/').last ?? "أضغط هنا",
              validator: (value) {
                if (_uploadedImageUrl == null) return "صورة المتجر مطلوبة";
                return null;
              },
              suffixInner: GestureDetector(
                onTap: _isUploadingImage ? null : _pickAndUploadImage,
                child: Container(
                  width: 115,
                  height: 55,
                  decoration: BoxDecoration(
                    color: _isUploadingImage
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(27),
                      bottomLeft: Radius.circular(27),
                    ),
                  ),
                  child: Center(
                    child: _isUploadingImage
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "تحميل الصورة",
                            style: TextStyle(
                              color: Color(0XFFFAFEFD),
                              fontSize: 16,
                              fontFamily: "Tajawal",
                            ),
                          ),
                  ),
                ),
              ),
            ),
            
            const Gap(5),
            
            // ✅ حقل كلمة المرور
            CustomTextFormField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              label: "الرمز السري",
              hint: "أدخل كلمة المرور",
              obscureText: _obscurePassword,
              prefixInner: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  "assets/svg/09. Password.svg",
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              suffixInner: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                  child: SvgPicture.asset(
                    _obscurePassword
                        ? "assets/svg/10. EyeSlash.svg"
                        : "assets/svg/10. EyeSlash.svg", 
                  ),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return "كلمة المرور مطلوبة";
                if (value!.length < 6) return "كلمة المرور قصيرة جداً (6 أحرف على الأقل)";
                return null;
              },
              onChanged: (value) => _saveCurrentData(),
              onFieldSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
            ),
            
            const Gap(5),
            
            // ✅ حقل تأكيد كلمة المرور
            CustomTextFormField(
              controller: _confirmPasswordController,
              focusNode: _confirmPasswordFocus,
              label: "تأكيد الرمز السري",
              hint: "أعد كتابة كلمة المرور",
              obscureText: _obscureConfirmPassword,
              prefixInner: Padding(
                padding: const EdgeInsets.all(10.0),
                child: SvgPicture.asset(
                  "assets/svg/09. Password.svg",
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              suffixInner: Padding(
                padding: const EdgeInsets.all(10.0),
                child: GestureDetector(
                  onTap: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                  child: SvgPicture.asset(
                    _obscureConfirmPassword
                        ? "assets/svg/10. EyeSlash.svg"
                        : "assets/svg/10. EyeSlash.svg",
                  ),
                ),
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) return "تأكيد كلمة المرور مطلوب";
                if (value != _passwordController.text) return "كلمة المرور غير متطابقة";
                return null;
              },
              onChanged: (value) => _saveCurrentData(),
              onFieldSubmitted: (_) => _handleNext(),
            ),
            
            const Gap(50),
            
            // ✅ أزرار التحكم في الأسفل
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: FillButton(
                      label: "التالي",
                      width: 150,
                      height: 50,
                      isLoading: _isUploadingImage,
                      onPressed: _handleNext,
                    ),
                  ),
                  
                  const Gap(20),
                  
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "هل لديك حساب؟",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      const Gap(5),
                      GestureDetector(
                        onTap: () => context.go(AppRoutes.login),
                        child: Text(
                          "تسجيل الدخول",
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}