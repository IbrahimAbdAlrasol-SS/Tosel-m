// import 'dart:async';

// import 'package:Tosell/Features/profile/models/zone.dart';
// import 'package:Tosell/Features/profile/services/zone_service.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:riverpod_annotation/riverpod_annotation.dart';
// import 'package:Tosell/Features/auth/Services/Auth_service.dart';
// import 'package:Tosell/core/Client/BaseClient.dart';
// import 'package:Tosell/Features/auth/models/User.dart'; // ✅ إضافة هذا الـ import

// part 'registration_provider.g.dart';

// class RegistrationState {
//   final String? fullName;
//   final String? brandName;
//   final String? userName;
//   final String? phoneNumber;
//   final String? password;
//   final String? confirmPassword;

//   // الصورة
//   final XFile? brandImage;
//   final String? uploadedImageUrl;
//   final bool isUploadingImage;

//   // المناطق
//   final List<RegistrationZoneInfo> zones;
//   final List<Zone> availableZones;
//   final bool isLoadingZones;

//   // حالة التسجيل
//   final bool isSubmitting;
//   final String? error;
//   final User? registeredUser;

//   const RegistrationState({
//     this.fullName,
//     this.brandName,
//     this.userName,
//     this.phoneNumber,
//     this.password,
//     this.confirmPassword,
//     this.brandImage,
//     this.uploadedImageUrl,
//     this.isUploadingImage = false,
//     this.zones = const [],
//     this.availableZones = const [],
//     this.isLoadingZones = false,
//     this.isSubmitting = false,
//     this.error,
//     this.registeredUser, // ✅ إضافة هذا السطر
//   });

//   RegistrationState copyWith({
//     String? fullName,
//     String? brandName,
//     String? userName,
//     String? phoneNumber,
//     String? password,
//     String? confirmPassword,
//     XFile? brandImage,
//     String? uploadedImageUrl,
//     bool? isUploadingImage,
//     List<RegistrationZoneInfo>? zones,
//     List<Zone>? availableZones,
//     bool? isLoadingZones,
//     bool? isSubmitting,
//     String? error,
//     User? registeredUser, // ✅ إضافة هذا السطر
//     int? type,
//   }) {
//     return RegistrationState(
//       fullName: fullName ?? this.fullName,
//       brandName: brandName ?? this.brandName,
//       userName: userName ?? this.userName,
//       phoneNumber: phoneNumber ?? this.phoneNumber,
//       password: password ?? this.password,
//       confirmPassword: confirmPassword ?? this.confirmPassword,
//       brandImage: brandImage ?? this.brandImage,
//       uploadedImageUrl: uploadedImageUrl ?? this.uploadedImageUrl,
//       isUploadingImage: isUploadingImage ?? this.isUploadingImage,
//       zones: zones ?? this.zones,
//       availableZones: availableZones ?? this.availableZones,
//       isLoadingZones: isLoadingZones ?? this.isLoadingZones,
//       isSubmitting: isSubmitting ?? this.isSubmitting,
//       error: error ?? this.error,
//       registeredUser: registeredUser ?? this.registeredUser,
//     );
//   }
// }

// class RegistrationZoneInfo {
//   final Governorate? selectedGovernorate;
//   final Zone? selectedZone;
//   final String nearestLandmark;
//   final double? latitude;
//   final double? longitude;

//   RegistrationZoneInfo({
//     this.selectedGovernorate,
//     this.selectedZone,
//     this.nearestLandmark = '',
//     this.latitude,
//     this.longitude,
//   });

//   RegistrationZoneInfo copyWith({
//     Governorate? selectedGovernorate,
//     Zone? selectedZone,
//     String? nearestLandmark,
//     double? latitude,
//     double? longitude,
//   }) {
//     return RegistrationZoneInfo(
//       selectedGovernorate: selectedGovernorate ?? this.selectedGovernorate,
//       selectedZone: selectedZone ?? this.selectedZone,
//       nearestLandmark: nearestLandmark ?? this.nearestLandmark,
//       latitude: latitude ?? this.latitude,
//       longitude: longitude ?? this.longitude,
//     );
//   }

//   Map<String, dynamic> toJson() => {
//         'zoneId': selectedZone?.id,
//         'nearestLandmark': nearestLandmark,
//         'long': longitude,
//         'lat': latitude,
//       };

//   bool get isValid =>
//       selectedZone != null &&
//       nearestLandmark.isNotEmpty &&
//       latitude != null &&
//       longitude != null;
// }

// @riverpod
// class RegistrationNotifier extends _$RegistrationNotifier {
//   final AuthService _authService = AuthService();
//   final BaseClient _baseClient = BaseClient();
//   final ZoneService _zoneService = ZoneService();

//   @override
//   RegistrationState build() {
//     return const RegistrationState();
//   }

//   void updateUserInfo({
//     String? fullName,
//     String? brandName,
//     String? userName,
//     String? phoneNumber,
//     String? password,
//     String? confirmPassword,
//   }) {
//     state = state.copyWith(
//       fullName: fullName,
//       brandName: brandName,
//       userName: userName,
//       phoneNumber: phoneNumber,
//       password: password,
//       confirmPassword: confirmPassword,
//       error: null,
//     );
//   }

//   void setBrandImage(XFile image) {
//     state = state.copyWith(brandImage: image, error: null);
//   }

//   Future<bool> uploadBrandImage() async {
//     if (state.brandImage == null) return false;

//     state = state.copyWith(isUploadingImage: true, error: null);

//     try {
//       final result = await _baseClient.uploadFile(state.brandImage!.path);
//       if (result.data != null && result.data!.isNotEmpty) {
//         state = state.copyWith(
//           uploadedImageUrl: result.data!.first,
//           isUploadingImage: false,
//         );
//         return true;
//       } else {
//         state = state.copyWith(
//           error: 'فشل في رفع الصورة',
//           isUploadingImage: false,
//         );
//         return false;
//       }
//     } catch (e) {
//       state = state.copyWith(
//         error: 'خطأ في رفع الصورة: ${e.toString()}',
//         isUploadingImage: false,
//       );
//       return false;
//     }
//   }

//   void addMarchentZone() {
//     final newZones = List<RegistrationZoneInfo>.from(state.zones)
//       ..add(RegistrationZoneInfo());
//     state = state.copyWith(zones: newZones);
//   }

//   void updateZone(int index, RegistrationZoneInfo zoneInfo) {
//     if (index >= state.zones.length) return;

//     final newZones = List<RegistrationZoneInfo>.from(state.zones);
//     newZones[index] = zoneInfo;
//     state = state.copyWith(zones: newZones);
//   }

//   void removeZone(int index) {
//     if (index >= state.zones.length || state.zones.length <= 1) return;

//     final newZones = List<RegistrationZoneInfo>.from(state.zones)
//       ..removeAt(index);
//     state = state.copyWith(zones: newZones);
//   }

//   Future<void> loadAvailableZones() async {
//     state = state.copyWith(isLoadingZones: true, error: null);

//     try {
//       final zones = await _zoneService.getAllZones();

//       state = state.copyWith(
//         availableZones: [],
//         isLoadingZones: false,
//       );
//     } catch (e) {
//       state = state.copyWith(
//         error: 'فشل في جلب المناطق: ${e.toString()}',
//         isLoadingZones: false,
//       );
//     }
//   }

//   bool validateUserInfo() {
//     final s = state;
//     if (s.fullName?.isEmpty ?? true) {
//       state = state.copyWith(error: 'اسم صاحب المتجر مطلوب');
//       return false;
//     }
//     if (s.brandName?.isEmpty ?? true) {
//       state = state.copyWith(error: 'اسم المتجر مطلوب');
//       return false;
//     }
//     if (s.userName?.isEmpty ?? true) {
//       state = state.copyWith(error: 'اسم المستخدم مطلوب');
//       return false;
//     }
//     if (s.phoneNumber?.isEmpty ?? true) {
//       state = state.copyWith(error: 'رقم الهاتف مطلوب');
//       return false;
//     }
//     if (s.password?.isEmpty ?? true) {
//       state = state.copyWith(error: 'كلمة المرور مطلوبة');
//       return false;
//     }
//     if (s.password != s.confirmPassword) {
//       state = state.copyWith(error: 'كلمة المرور غير متطابقة');
//       return false;
//     }
//     if (s.brandImage == null) {
//       state = state.copyWith(error: 'صورة المتجر مطلوبة');
//       return false;
//     }

//     state = state.copyWith(error: null);
//     return true;
//   }

//   bool validateZones() {
//     if (state.zones.isEmpty) {
//       state = state.copyWith(error: 'يجب إضافة منطقة واحدة على الأقل');
//       return false;
//     }

//     for (int i = 0; i < state.zones.length; i++) {
//       if (!state.zones[i].isValid) {
//         state = state.copyWith(error: 'يجب إكمال معلومات المنطقة ${i + 1}');
//         return false;
//       }
//     }

//     state = state.copyWith(error: null);
//     return true;
//   }

//   // في registration_provider.dart - دالة submitRegistration

  
// Future<bool> submitRegistration() async {
//   if (!validateUserInfo() || !validateZones()) {
//     return false;
//   }

//   if (state.uploadedImageUrl == null) {
//     final uploaded = await uploadBrandImage();
//     if (!uploaded) return false;
//   }

//   state = state.copyWith(isSubmitting: true, error: null);

//   try {
//     final zonesData = state.zones.map((z) => z.toJson()).toList();
//     final firstZoneType = state.zones.first.selectedZone?.type ?? 1;

//     // ✅ طباعة البيانات قبل الإرسال للتشخيص
//     print('🔍 البيانات المرسلة للباك اند:');
//     print('📝 الاسم الكامل: ${state.fullName}');
//     print('🏪 اسم المتجر: ${state.brandName}');
//     print('👤 اسم المستخدم: ${state.userName}');
//     print('📱 رقم الهاتف: ${state.phoneNumber}');
//     print('🖼️ رابط الصورة: ${state.uploadedImageUrl}');
//     print('🌍 عدد المناطق: ${zonesData.length}');
//     print('📍 بيانات المناطق: $zonesData');
//     print('🏷️ نوع المنطقة: $firstZoneType');

//     final requestData = {
//       'merchantId': null,
//       'fullName': state.fullName!,
//       'brandName': state.brandName!,
//       'brandImg': state.uploadedImageUrl!,
//       'userName': state.userName!,
//       'phoneNumber': state.phoneNumber!,
//       'img': state.uploadedImageUrl!,
//       'zones': zonesData,
//       'password': state.password!,
//       'type': firstZoneType,
//     };
    
//     print('📤 JSON المرسل كاملاً: $requestData');

//     final (user, error) = await _authService.register(
//       fullName: state.fullName!,
//       brandName: state.brandName!,
//       userName: state.userName!,
//       phoneNumber: state.phoneNumber!,
//       password: state.password!,
//       brandImg: state.uploadedImageUrl!,
//       zones: zonesData,
//       type: firstZoneType,
//     );

//     if (user != null) {
//       print('✅ نجح التسجيل: ${user.fullName}');
//       state = state.copyWith(
//         isSubmitting: false,
//         registeredUser: user,
//       );
//       return true;
//     } else {
//       print('❌ فشل التسجيل: $error');
//       state = state.copyWith(
//         error: error ?? 'فشل في التسجيل',
//         isSubmitting: false,
//       );
//       return false;
//     }
//   } catch (e) {
//     print('💥 خطأ استثنائي: $e');
//     state = state.copyWith(
//       error: 'خطأ في التسجيل: ${e.toString()}',
//       isSubmitting: false,
//     );
//     return false;
//   }
// }

//   void reset() {
//     state = const RegistrationState();
//   }

//   void addNewZone() {
//     final newZones = List<RegistrationZoneInfo>.from(state.zones)
//       ..add(RegistrationZoneInfo());
//     state = state.copyWith(zones: newZones);
//   }

//   void updateZoneInfo(int index, RegistrationZoneInfo zoneInfo) {
//     if (index >= state.zones.length) return;

//     final newZones = List<RegistrationZoneInfo>.from(state.zones);
//     newZones[index] = zoneInfo;
//     state = state.copyWith(zones: newZones, error: null);
//   }

//   void deleteZone(int index) {
//     if (index >= state.zones.length || state.zones.length <= 1) return;

//     final newZones = List<RegistrationZoneInfo>.from(state.zones)
//       ..removeAt(index);
//     state = state.copyWith(zones: newZones);
//   }
// }

// إضافة هذه الدالة إلى RegistrationNotifier


