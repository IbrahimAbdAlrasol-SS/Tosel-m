import 'package:Tosell/Features/auth/register/providers/registration_provider.dart';
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

class UserInfoTab extends ConsumerStatefulWidget {
  final VoidCallback? onNext;

  const UserInfoTab({super.key, this.onNext});

  @override
  ConsumerState<UserInfoTab> createState() => _UserInfoTabState();
}

class _UserInfoTabState extends ConsumerState<UserInfoTab> {
  final _formKey = GlobalKey<FormState>();
  
  final _fullNameController = TextEditingController();
  final _brandNameController = TextEditingController();
  final _userNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _fullNameFocus = FocusNode();
  final _brandNameFocus = FocusNode();
  final _userNameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(registrationNotifierProvider);
      _fullNameController.text = state.fullName ?? '';
      _brandNameController.text = state.brandName ?? '';
      _userNameController.text = state.userName ?? '';
      _phoneController.text = state.phoneNumber ?? '';
      _passwordController.text = state.password ?? '';
      _confirmPasswordController.text = state.confirmPassword ?? '';
    });
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

  Future<void> _pickImage() async {
    try {
      final XFile? image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        ref.read(registrationNotifierProvider.notifier).setBrandImage(image);
        
        final success = await ref
            .read(registrationNotifierProvider.notifier)
            .uploadBrandImage();
            
        if (success) {
          GlobalToast.showSuccess(message: 'تم رفع الصورة بنجاح');
        }
      }
    } catch (e) {
      GlobalToast.show(
        message: 'فشل في اختيار الصورة',
        backgroundColor: Colors.red,
      );
    }
  }

  void _saveCurrentData() {
    ref.read(registrationNotifierProvider.notifier).updateUserInfo(
          fullName: _fullNameController.text.trim(),
          brandName: _brandNameController.text.trim(),
          userName: _userNameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          password: _passwordController.text,
          confirmPassword: _confirmPasswordController.text,
        );
  }

  Future<void> _handleNext() async {
    _saveCurrentData();

    if (!_formKey.currentState!.validate()) return;

    final isValid = ref
        .read(registrationNotifierProvider.notifier)
        .validateUserInfo();

    if (!isValid) {
      final error = ref.read(registrationNotifierProvider).error;
      if (error != null) {
        GlobalToast.show(message: error, backgroundColor: Colors.red);
      }
      return;
    }

    final state = ref.read(registrationNotifierProvider);
    if (state.brandImage != null && state.uploadedImageUrl == null) {
      final success = await ref
          .read(registrationNotifierProvider.notifier)
          .uploadBrandImage();
          
      if (!success) {
        final error = ref.read(registrationNotifierProvider).error;
        GlobalToast.show(
          message: error ?? 'فشل في رفع الصورة',
          backgroundColor: Colors.red,
        );
        return;
      }
    }

    widget.onNext?.call();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationNotifierProvider);
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // ✅ إزالة Expanded و ListView - استخدام Column مباشرة
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
                final hasLetters = RegExp(r'[a-zA-Z\u0600-\u06FF]').hasMatch(value);
                if (!hasLetters) return "اسم المستخدم يجب أن يحتوي على أحرف";
                return null;
              },
              onChanged: (value) => _saveCurrentData(),
              onFieldSubmitted: (_) => _phoneFocus.requestFocus(),
            ),
            
            const Gap(5),
            
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
            
            CustomTextFormField(
              readOnly: true,
              label: "شعار / صورة المتجر",
              hint: state.brandImage?.name ?? "أضغط هنا",
              validator: (value) {
                if (state.brandImage == null) return "صورة المتجر مطلوبة";
                return null;
              },
              suffixInner: GestureDetector(
                onTap: state.isUploadingImage ? null : _pickImage,
                child: Container(
                  width: 115,
                  height: 55,
                  decoration: BoxDecoration(
                    color: state.isUploadingImage
                        ? Colors.grey
                        : Theme.of(context).colorScheme.primary,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(27),
                      bottomLeft: Radius.circular(27),
                    ),
                  ),
                  child: Center(
                    child: state.isUploadingImage
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
            
            // أزرار التحكم في الأسفل
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
                      isLoading: state.isUploadingImage,
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