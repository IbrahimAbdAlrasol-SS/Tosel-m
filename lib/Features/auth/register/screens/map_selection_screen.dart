import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:Tosell/core/constants/spaces.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';
import 'package:Tosell/core/widgets/FillButton.dart';

class MapSelectionScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;

  const MapSelectionScreen({
    super.key,
    this.initialLatitude,
    this.initialLongitude,
  });

  @override
  State<MapSelectionScreen> createState() => _MapSelectionScreenState();
}

class _MapSelectionScreenState extends State<MapSelectionScreen> {
  double? selectedLatitude;
  double? selectedLongitude;
  bool isLocationSelected = false;

  @override
  void initState() {
    super.initState();
    selectedLatitude = widget.initialLatitude ?? 33.3152; 
    selectedLongitude = widget.initialLongitude ?? 44.3661;
    isLocationSelected = widget.initialLatitude != null;
  }

  void _onMapTapped(double lat, double lng) {
    setState(() {
      selectedLatitude = lat;
      selectedLongitude = lng;
      isLocationSelected = true;
    });
    
    // إضافة feedback للمستخدم
    HapticFeedback.lightImpact();
  }

  void _confirmLocation() {
    if (selectedLatitude != null && selectedLongitude != null) {
      context.pop({
        'latitude': selectedLatitude,
        'longitude': selectedLongitude,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'يرجى تحديد الموقع أولاً',
            style: TextStyle(fontFamily: "Tajawal"),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _getCurrentLocation() {
    // محاكاة الحصول على الموقع الحالي (سيتم استبداله بـ GPS حقيقي لاحقاً)
    setState(() {
      selectedLatitude = 33.3152 + (0.01 * (DateTime.now().millisecond % 100) / 100);
      selectedLongitude = 44.3661 + (0.01 * (DateTime.now().millisecond % 100) / 100);
      isLocationSelected = true;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white),
            const Gap(8),
            Text(
              'تم تحديد الموقع الحالي',
              style: TextStyle(fontFamily: "Tajawal"),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // App Bar
          const SafeArea(
            child: CustomAppBar(
              title: "اختيار الموقع",
              showBackButton: true,
            ),
          ),

          // Map Container
          Expanded(
            child: Container(
              margin: AppSpaces.allMedium,
              decoration: BoxDecoration(
                borderRadius: AppSpaces.mediumRadius,
                border: Border.all(
                  color: isLocationSelected 
                      ? context.colorScheme.primary
                      : context.colorScheme.outline,
                  width: isLocationSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: AppSpaces.mediumRadius,
                child: Stack(
                  children: [
                    _buildTemporaryMap(),

                    // Pin المكان المحدد
                    if (isLocationSelected)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Pin مع animation
                            TweenAnimationBuilder<double>(
                              tween: Tween(begin: 0.0, end: 1.0),
                              duration: const Duration(milliseconds: 500),
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: 0.8 + (0.2 * value),
                                  child: SvgPicture.asset(
                                    'assets/svg/MapPinLine.svg',
                                    color: context.colorScheme.primary,
                                    height: 40,
                                  ),
                                );
                              },
                            ),
                            const Gap(8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: context.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                'الموقع المحدد',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // معلومات التوجيه
                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: AppSpaces.allSmall,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: AppSpaces.smallRadius,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: context.colorScheme.primary,
                            ),
                            const Gap(AppSpaces.small),
                            Expanded(
                              child: Text(
                                'اضغط على الخريطة لتحديد الموقع',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // زر الموقع الحالي
                    Positioned(
                      top: 80,
                      right: 16,
                      child: FloatingActionButton.small(
                        onPressed: _getCurrentLocation,
                        backgroundColor: Colors.white,
                        foregroundColor: context.colorScheme.primary,
                        elevation: 4,
                        child: const Icon(Icons.my_location),
                      ),
                    ),

                    // عرض الإحداثيات
                    if (isLocationSelected)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: AppSpaces.allMedium,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: AppSpaces.smallRadius,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: context.colorScheme.primary,
                                    size: 18,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'الإحداثيات المحددة:',
                                    style: context.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: context.colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'خط العرض',
                                            style: context.textTheme.bodySmall?.copyWith(
                                              color: context.colorScheme.secondary,
                                            ),
                                          ),
                                          Text(
                                            '${selectedLatitude?.toStringAsFixed(6)}',
                                            style: context.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Gap(8),
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: context.colorScheme.primary.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'خط الطول',
                                            style: context.textTheme.bodySmall?.copyWith(
                                              color: context.colorScheme.secondary,
                                            ),
                                          ),
                                          Text(
                                            '${selectedLongitude?.toStringAsFixed(6)}',
                                            style: context.textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // أزرار التحكم
          Container(
            padding: AppSpaces.allMedium,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: context.colorScheme.outline),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('إلغاء'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: context.colorScheme.outline),
                    ),
                  ),
                ),
                const Gap(AppSpaces.medium),
                Expanded(
                  flex: 2,
                  child: FillButton(
                    label: isLocationSelected ? 'تأكيد الموقع' : 'حدد الموقع أولاً',
                    onPressed: _confirmLocation,
                    isLoading:  isLocationSelected ,
                    height: 48,
                    icon: isLocationSelected 
                        ? const Icon(Icons.check, color: Colors.white)
                        : const Icon(Icons.location_disabled, color: Colors.white54),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTemporaryMap() {
    return GestureDetector(
      onTapDown: (details) {
        final RenderBox box = context.findRenderObject() as RenderBox;
        final localPosition = details.localPosition;
        
        // محاكاة إحداثيات أكثر واقعية (سيتم استبدالها بخريطة حقيقية)
        final lat = 33.3152 + (localPosition.dy / box.size.height - 0.5) * 0.05;
        final lng = 44.3661 + (localPosition.dx / box.size.width - 0.5) * 0.05;
        
        _onMapTapped(lat, lng);
      },
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          image: const DecorationImage(
            image: AssetImage('assets/images/map.png'),
            fit: BoxFit.cover,
          ),
          color: Colors.grey[100],
        ),
        child: !isLocationSelected
            ? Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // أيقونة متحركة
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(seconds: 1),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: 0.8 + (0.2 * value),
                            child: SvgPicture.asset(
                              'assets/svg/MapPinLine.svg',
                              color: Colors.white,
                              height: 48,
                            ),
                          );
                        },
                      ),
                      const Gap(AppSpaces.medium),
                      Text(
                        'اضغط لتحديد الموقع',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Gap(AppSpaces.small),
                      Text(
                        'أو استخدم زر الموقع الحالي',
                        style: context.textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
      ),
    );
  }
}