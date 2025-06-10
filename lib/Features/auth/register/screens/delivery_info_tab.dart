import 'dart:async';

import 'package:Tosell/Features/profile/services/governorate_service.dart';
import 'package:Tosell/Features/profile/services/zone_service.dart';
import 'package:Tosell/Features/profile/models/zone.dart';
import 'package:gap/gap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomTextFormField.dart';
import 'package:Tosell/core/widgets/custom_search_drop_down.dart';
import 'package:Tosell/core/router/app_router.dart';
import 'package:Tosell/Features/auth/register/providers/registration_provider.dart';

class DeliveryInfoTab extends ConsumerStatefulWidget {
  const DeliveryInfoTab({super.key});

  @override
  ConsumerState<DeliveryInfoTab> createState() => _DeliveryInfoTabState();
}

class _DeliveryInfoTabState extends ConsumerState<DeliveryInfoTab> {
  Set<int> expandedTiles = {};
  final GovernorateService _governorateService = GovernorateService();
  final ZoneService _zoneService = ZoneService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = ref.read(registrationNotifierProvider);
      if (state.zones.isEmpty) {
        ref.read(registrationNotifierProvider.notifier).addMarchentZone();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registrationNotifierProvider);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...state.zones.asMap().entries.map((entry) {
              final index = entry.key;
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6),
                child: _buildLocationCard(index, state.zones[index]),
              );
            }),
            const SizedBox(height: 12),
            _buildAddLocationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(int index, RegistrationZoneInfo zoneInfo) {
    bool isExpanded = expandedTiles.contains(index);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isExpanded ? 16 : 64),
        side: const BorderSide(width: 1, color: Color(0xFFF1F2F4)),
      ),
      child: ExpansionTile(
        title: Row(
          children: [
            Expanded(
              child: Text(
                "عنوان إستلام البضاعة ${index + 1}",
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Tajawal",
                  color: Color(0xFF121416),
                ),
                textAlign: TextAlign.right,
              ),
            ),
            if (ref.watch(registrationNotifierProvider).zones.length > 1)
              IconButton(
                onPressed: () => _removeLocation(index),
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
              ),
          ],
        ),
        trailing: SvgPicture.asset(
          "assets/svg/downrowsvg.svg",
          color: Theme.of(context).colorScheme.primary,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            if (expanded) {
              expandedTiles.add(index);
            } else {
              expandedTiles.remove(index);
            }
          });
        },
        children: [
          Container(height: 1, color: const Color(0xFFF1F2F4)),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildGovernorateDropdown(index, zoneInfo),
                const Gap(5),
                _buildZoneDropdown(index, zoneInfo),
                const Gap(5),
                _buildNearestPointField(index, zoneInfo),
                const Gap(5),
                _buildLocationPicker(index, zoneInfo),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✅ dropdown المحافظات - يستخدم GovernorateService
  Widget _buildGovernorateDropdown(int index, RegistrationZoneInfo zoneInfo) {
    return RegistrationSearchDropDown<Governorate>(
      label: "المحافظة",
      hint: "ابحث عن المحافظة... مثال: 'بغداد'",
      selectedValue: zoneInfo.selectedGovernorate,
      itemAsString: (gov) => gov.name ?? '',
      asyncItems: (query) async {
        try {
          // جلب جميع المحافظات
          final governorates = await _governorateService.getAllZones();
          
          // تصفية حسب البحث إذا كان موجود
          if (query.trim().isNotEmpty) {
            return governorates.where((gov) => 
              gov.name?.toLowerCase().contains(query.toLowerCase()) ?? false
            ).toList();
          }
          
          return governorates;
        } catch (e) {
          print('Error loading governorates: $e');
          return [];
        }
      },
      onChanged: (governorate) {
        final updatedZone = zoneInfo.copyWith(
          selectedGovernorate: governorate,
          selectedZone: null, // مسح المنطقة المختارة عند تغيير المحافظة
        );
        ref
            .read(registrationNotifierProvider.notifier)
            .updateZone(index, updatedZone);
      },
      itemBuilder: (context, governorate) => Row(
        children: [
          Icon(Icons.location_city,
              color: context.colorScheme.primary, size: 18),
          const Gap(8),
          Expanded(
            child: Text(
              governorate.name ?? '',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 16,
                fontFamily: "Tajawal",
              ),
            ),
          ),
        ],
      ),
      emptyText: "لا توجد محافظات",
      errorText: "خطأ في تحميل المحافظات",
      enableRefresh: true,
    );
  }

  /// ✅ dropdown المناطق - حل مبسط بدون selectedValue
  Widget _buildZoneDropdown(int index, RegistrationZoneInfo zoneInfo) {
    final selectedGov = zoneInfo.selectedGovernorate;
    
    return RegistrationSearchDropDown<Zone>(
      label: "المنطقة",
      hint: selectedGov == null
          ? "اختر المحافظة أولاً"
          : zoneInfo.selectedZone?.name ?? "ابحث عن المنطقة...",
      // selectedValue: zoneInfo.selectedZone, // مُعطل مؤقتاً للاختبار
      itemAsString: (zone) => zone.name ?? '',
      asyncItems: (query) async {
        // إذا لم يتم اختيار محافظة، ارجع قائمة فارغة
        if (selectedGov?.id == null) {
          print('❌ لا توجد محافظة مختارة');
          return [];
        }

        try {
          print('🔍 جاري جلب المناطق للمحافظة: ${selectedGov!.name} (ID: ${selectedGov!.id})');
          
          // جلب جميع المناطق
          final allZones = await _zoneService.getAllZones();
          print('📋 تم جلب ${allZones.length} منطقة إجمالي');
          
          if (allZones.isEmpty) {
            print('⚠️ لا توجد مناطق في الـ API');
            return [];
          }
          
          // عرض عينة من البيانات للتأكد من الهيكل
          if (allZones.isNotEmpty) {
            final sampleZone = allZones.first;
            print('📝 عينة من البيانات:');
            print('   اسم المنطقة: ${sampleZone.name}');
            print('   اسم المحافظة: ${sampleZone.governorate?.name}');
            print('   ID المحافظة: ${sampleZone.governorate?.id}');
            print('   نوع المحافظة المطلوب: ${selectedGov!.id}');
          }
          
          // تصفية المناطق حسب المحافظة المختارة
          var filteredZones = allZones.where((zone) {
            final zoneGovId = zone.governorate?.id;
            final selectedGovId = selectedGov!.id;
            
            print('🔍 مقارنة: $zoneGovId == $selectedGovId (${zone.name})');
            
            return zoneGovId == selectedGovId;
          }).toList();
          
          print('🎯 تم العثور على ${filteredZones.length} منطقة للمحافظة ${selectedGov!.name}');
          
          // عرض أسماء المناطق المفلترة
          if (filteredZones.isNotEmpty) {
            print('📍 المناطق المفلترة:');
            for (var zone in filteredZones.take(5)) {
              print('   - ${zone.name}');
            }
          }
          
          // تصفية حسب البحث إذا كان موجود
          if (query.trim().isNotEmpty) {
            final beforeSearch = filteredZones.length;
            filteredZones = filteredZones.where((zone) => 
              zone.name?.toLowerCase().contains(query.toLowerCase()) ?? false
            ).toList();
            print('🔍 بعد البحث عن "$query": ${filteredZones.length} من $beforeSearch');
          }
          
          return filteredZones;
        } catch (e, stackTrace) {
          print('❌ خطأ في جلب المناطق: $e');
          print('📋 Stack trace: $stackTrace');
          return [];
        }
      },
      onChanged: (zone) {
        final updatedZone = zoneInfo.copyWith(selectedZone: zone);
        ref
            .read(registrationNotifierProvider.notifier)
            .updateZone(index, updatedZone);
      },
      itemBuilder: (context, zone) => Row(
        children: [
          Icon(Icons.place, color: context.colorScheme.primary, size: 18),
          const Gap(8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  zone.name ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                    fontFamily: "Tajawal",
                  ),
                ),
                if (zone.type != null)
                  Text(
                    zone.type == 1 ? 'المركز' : 'الأطراف',
                    style: TextStyle(
                      fontSize: 12,
                      color: zone.type == 1 ? Colors.green : Colors.orange,
                      fontFamily: "Tajawal",
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      emptyText: selectedGov == null 
          ? "اختر المحافظة أولاً" 
          : "لا توجد مناطق لهذه المحافظة",
      errorText: "خطأ في تحميل المناطق",
      enableRefresh: true,
    );
  }

  Widget _buildNearestPointField(int index, RegistrationZoneInfo zoneInfo) {
    return CustomTextFormField(
      label: "اقرب نقطة دالة",
      hint: "مثال: 'قرب مطعم الخيمة'",
      selectedValue: zoneInfo.nearestLandmark,
      onChanged: (value) {
        final updatedZone = zoneInfo.copyWith(nearestLandmark: value);
        ref
            .read(registrationNotifierProvider.notifier)
            .updateZone(index, updatedZone);
      },
    );
  }

  Widget _buildLocationPicker(int index, RegistrationZoneInfo zoneInfo) {
    final hasLocation = zoneInfo.latitude != null && zoneInfo.longitude != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الموقع على الخريطة',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
        ),
        const Gap(5),

        // زر تحديد الموقع
        InkWell(
          onTap: () => _openLocationPicker(index, zoneInfo),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: hasLocation
                    ? context.colorScheme.primary
                    : context.colorScheme.outline,
                width: hasLocation ? 2 : 1,
              ),
              color: hasLocation
                  ? context.colorScheme.primary.withOpacity(0.05)
                  : Colors.grey.withOpacity(0.05),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/MapPinLine.svg',
                    color:
                        hasLocation ? context.colorScheme.primary : Colors.grey,
                    height: 24,
                  ),
                  const Gap(15),
                  Text(
                    hasLocation ? 'تم تحديد الموقع' : 'تحديد الموقع',
                    style: context.textTheme.bodyMedium?.copyWith(
                      fontSize: 16,
                      color: hasLocation
                          ? context.colorScheme.primary
                          : Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (hasLocation) ...[
                    const Gap(4),
                    Text(
                      'اضغط للتعديل',
                      style: context.textTheme.bodySmall?.copyWith(
                        color: context.colorScheme.primary.withOpacity(0.7),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        // عرض الإحداثيات
        if (hasLocation) ...[
          const Gap(5),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: context.colorScheme.primary.withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on,
                    color: context.colorScheme.primary, size: 16),
                const Gap(8),
                Expanded(
                  child: Text(
                    'خط العرض: ${zoneInfo.latitude?.toStringAsFixed(4)} | خط الطول: ${zoneInfo.longitude?.toStringAsFixed(4)}',
                    style: context.textTheme.bodySmall?.copyWith(
                      color: context.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddLocationButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 140.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: context.colorScheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(60),
            border: Border.all(color: context.colorScheme.primary),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(60),
            onTap: () {
              ref.read(registrationNotifierProvider.notifier).addMarchentZone();
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    "assets/svg/navigation_add.svg",
                    color: context.colorScheme.primary,
                    height: 20,
                  ),
                  const Gap(5),
                  Text(
                    "إضافة موقع",
                    style: TextStyle(
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      color: context.colorScheme.primary,
                      fontFamily: "Tajawal",
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _removeLocation(int index) {
    ref.read(registrationNotifierProvider.notifier).removeZone(index);
    setState(() {
      expandedTiles.remove(index);
    });
  }

  Future<void> _openLocationPicker(
      int index, RegistrationZoneInfo zoneInfo) async {
    try {
      final result = await context.push(
        AppRoutes.mapSelection,
        extra: {
          'latitude': zoneInfo.latitude,
          'longitude': zoneInfo.longitude,
        },
      );

      if (result != null && result is Map<String, dynamic>) {
        // حفظ الإحداثيات في الـ state
        final updatedZone = zoneInfo.copyWith(
          latitude: result['latitude'],
          longitude: result['longitude'],
        );
        ref
            .read(registrationNotifierProvider.notifier)
            .updateZone(index, updatedZone);

        // إظهار رسالة نجاح
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const Gap(8),
                Text('تم حفظ الموقع بنجاح',
                    style: const TextStyle(fontFamily: "Tajawal")),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في فتح الخريطة',
              style: const TextStyle(fontFamily: "Tajawal")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}