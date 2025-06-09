import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:Tosell/Features/auth/Services/Auth_service.dart';
import 'package:Tosell/Features/auth/register/models/registration_zone.dart';
import 'package:Tosell/Features/auth/register/services/registration_zone_service.dart';
import 'package:Tosell/core/Client/BaseClient.dart';

part 'registration_provider.g.dart';

/// حالة التسجيل
class RegistrationState {
  // معلومات المستخدم
  final String? fullName;
  final String? brandName;
  final String? userName;
  final String? phoneNumber;
  final String? password;
  final String? confirmPassword;
  
  // الصورة
  final XFile? brandImage;
  final String? uploadedImageUrl;
  final bool isUploadingImage;
  
  // المناطق
  final List<RegistrationZoneInfo> zones;
  final List<RegistrationZone> availableZones;
  final bool isLoadingZones;
  
  // حالة التسجيل
  final bool isSubmitting;
  final String? error;

  const RegistrationState({
    this.fullName,
    this.brandName,
    this.userName,
    this.phoneNumber,
    this.password,
    this.confirmPassword,
    this.brandImage,
    this.uploadedImageUrl,
    this.isUploadingImage = false,
    this.zones = const [],
    this.availableZones = const [],
    this.isLoadingZones = false,
    this.isSubmitting = false,
    this.error,
  });

  RegistrationState copyWith({
    String? fullName,
    String? brandName,
    String? userName,
    String? phoneNumber,
    String? password,
    String? confirmPassword,
    XFile? brandImage,
    String? uploadedImageUrl,
    bool? isUploadingImage,
    List<RegistrationZoneInfo>? zones,
    List<RegistrationZone>? availableZones,
    bool? isLoadingZones,
    bool? isSubmitting,
    String? error,
    int? type,
  }) {
    return RegistrationState(
      fullName: fullName ?? this.fullName,
      brandName: brandName ?? this.brandName,
      userName: userName ?? this.userName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      brandImage: brandImage ?? this.brandImage,
      uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
      isUploadingImage: isUploadingImage ?? this.isUploadingImage,
      zones: zones ?? this.zones,
      availableZones: availableZones ?? this.availableZones,
      isLoadingZones: isLoadingZones ?? this.isLoadingZones,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error ?? this.error,
    );
  }
}

/// معلومات المنطقة للتسجيل
class RegistrationZoneInfo {
  final RegistrationGovernorate? selectedGovernorate;
  final RegistrationZone? selectedZone;
  final String nearestLandmark;
  final double? latitude;
  final double? longitude;

  RegistrationZoneInfo({
    this.selectedGovernorate,
    this.selectedZone,
    this.nearestLandmark = '',
    this.latitude,
    this.longitude,
  });

  RegistrationZoneInfo copyWith({
    RegistrationGovernorate? selectedGovernorate,
    RegistrationZone? selectedZone,
    String? nearestLandmark,
    double? latitude,
    double? longitude,
  }) {
    return RegistrationZoneInfo(
      selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
      selectedZone: selectedZone ?? this.selectedZone,
      nearestLandmark: nearestLandmark ?? this.nearestLandmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  Map<String, dynamic> toJson() => {
        'zoneId': selectedZone?.id,
        'nearestLandmark': nearestLandmark,
        'long': longitude,
        'lat': latitude,
      };

  bool get isValid =>
      selectedZone != null &&
      nearestLandmark.isNotEmpty &&
      latitude != null &&
      longitude != null;
}

@riverpod
class RegistrationNotifier extends _$RegistrationNotifier {
  final AuthService _authService = AuthService();
  final BaseClient _baseClient = BaseClient();
  final RegistrationZoneService _zoneService = RegistrationZoneService();

  @override
  RegistrationState build() {
    return const RegistrationState();
  }

  /// تحديث معلومات المستخدم
  void updateUserInfo({
    String? fullName,
    String? brandName,
    String? userName,
    String? phoneNumber,
    String? password,
    String? confirmPassword,
  }) {
    state = state.copyWith(
      fullName: fullName,
      brandName: brandName,
      userName: userName,
      phoneNumber: phoneNumber,
      password: password,
      confirmPassword: confirmPassword,
      error: null,
    );
  }

  /// تحديد صورة العلامة التجارية
  void setBrandImage(XFile image) {
    state = state.copyWith(brandImage: image, error: null);
  }

  /// رفع الصورة
  Future<bool> uploadBrandImage() async {
    if (state.brandImage == null) return false;

    state = state.copyWith(isUploadingImage: true, error: null);

    try {
      final result = await _baseClient.uploadFile(state.brandImage!.path);
      if (result.data != null && result.data!.isNotEmpty) {
        state = state.copyWith(
          uploadedImageUrl: result.data!.first,
          isUploadingImage: false,
        );
        return true;
      } else {
        state = state.copyWith(
          error: 'فشل في رفع الصورة',
          isUploadingImage: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'خطأ في رفع الصورة: ${e.toString()}',
        isUploadingImage: false,
      );
      return false;
    }
  }

  /// إضافة منطقة جديدة
  void addZone() {
    final newZones = List<RegistrationZoneInfo>.from(state.zones)..add(RegistrationZoneInfo());
    state = state.copyWith(zones: newZones);
  }

  /// تحديث معلومات منطقة
  void updateZone(int index, RegistrationZoneInfo zoneInfo) {
    if (index >= state.zones.length) return;

    final newZones = List<RegistrationZoneInfo>.from(state.zones);
    newZones[index] = zoneInfo;
    state = state.copyWith(zones: newZones);
  }

  /// حذف منطقة
  void removeZone(int index) {
    if (index >= state.zones.length || state.zones.length <= 1) return;

    final newZones = List<RegistrationZoneInfo>.from(state.zones)..removeAt(index);
    state = state.copyWith(zones: newZones);
  }

  /// جلب المناطق المتاحة
  Future<void> loadAvailableZones() async {
    state = state.copyWith(isLoadingZones: true, error: null);

    try {
      // استخدام RegistrationZoneService الموجود
      final zones = await _zoneService.getGovernorates();
      
      state = state.copyWith(
        availableZones: [],
        isLoadingZones: false,
      );
    } catch (e) {
      state = state.copyWith(
        error: 'فشل في جلب المناطق: ${e.toString()}',
        isLoadingZones: false,
      );
    }
  }

  /// التحقق من صحة بيانات الخطوة الأولى
  bool validateUserInfo() {
    final s = state;
    if (s.fullName?.isEmpty ?? true) {
      state = state.copyWith(error: 'اسم صاحب المتجر مطلوب');
      return false;
    }
    if (s.brandName?.isEmpty ?? true) {
      state = state.copyWith(error: 'اسم المتجر مطلوب');
      return false;
    }
    if (s.userName?.isEmpty ?? true) {
      state = state.copyWith(error: 'اسم المستخدم مطلوب');
      return false;
    }
    if (s.phoneNumber?.isEmpty ?? true) {
      state = state.copyWith(error: 'رقم الهاتف مطلوب');
      return false;
    }
    if (s.password?.isEmpty ?? true) {
      state = state.copyWith(error: 'كلمة المرور مطلوبة');
      return false;
    }
    if (s.password != s.confirmPassword) {
      state = state.copyWith(error: 'كلمة المرور غير متطابقة');
      return false;
    }
    if (s.brandImage == null) {
      state = state.copyWith(error: 'صورة المتجر مطلوبة');
      return false;
    }

    state = state.copyWith(error: null);
    return true;
  }

  /// التحقق من صحة بيانات المناطق
  bool validateZones() {
    if (state.zones.isEmpty) {
      state = state.copyWith(error: 'يجب إضافة منطقة واحدة على الأقل');
      return false;
    }

    for (int i = 0; i < state.zones.length; i++) {
      if (!state.zones[i].isValid) {
        state = state.copyWith(error: 'يجب إكمال معلومات المنطقة ${i + 1}');
        return false;
      }
    }

    state = state.copyWith(error: null);
    return true;
  }

  /// إرسال التسجيل
  Future<bool> submitRegistration() async {
    // التحقق من البيانات
    if (!validateUserInfo() || !validateZones()) {
      return false;
    }

    // التأكد من رفع الصورة
    if (state.uploadedImageUrl == null) {
      final uploaded = await uploadBrandImage();
      if (!uploaded) return false;
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final zonesData = state.zones.map((z) => z.toJson()).toList();
      
      // تحديد النوع بناءً على المنطقة الأولى
      final  firstZoneType = state.zones.first.selectedZone?.type ?? 1;

      final (user, error) = await _authService.register(
        fullName: state.fullName!,
        brandName: state.brandName!,
        userName: state.userName!,
        phoneNumber: state.phoneNumber!,
        password: state.password!,
        brandImg: state.uploadedImageUrl!,
        zones: zonesData,
        type: firstZoneType,
      );

      if (user != null) {
        state = state.copyWith(isSubmitting: false);
        return true;
      } else {
        state = state.copyWith(
          error: error ?? 'فشل في التسجيل',
          isSubmitting: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        error: 'خطأ في التسجيل: ${e.toString()}',
        isSubmitting: false,
      );
      return false;
    }
  }

  /// إعادة تعيين الحالة
  void reset() {
    state = const RegistrationState();
  }
}