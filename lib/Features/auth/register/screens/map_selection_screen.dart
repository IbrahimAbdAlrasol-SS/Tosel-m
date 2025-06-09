import 'package:flutter/material.dart';
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
  }

  void _confirmLocation() {
    if (selectedLatitude != null && selectedLongitude != null) {
      context.pop({
        'latitude': selectedLatitude,
        'longitude': selectedLongitude,
      });
    }
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
                border: Border.all(color: context.colorScheme.outline),
              ),
              child: ClipRRect(
                borderRadius: AppSpaces.mediumRadius,
                child: Stack(
                  children: [
                    _buildTemporaryMap(),

                    if (isLocationSelected)
                      Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/svg/MapPinLine.svg',
                              color: context.colorScheme.primary,
                              height: 40,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: context.colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'الموقع المحدد',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    Positioned(
                      top: 16,
                      left: 16,
                      right: 16,
                      child: Container(
                        padding: AppSpaces.allSmall,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
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
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (isLocationSelected)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: AppSpaces.allSmall,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.9),
                            borderRadius: AppSpaces.smallRadius,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'الإحداثيات المحددة:',
                                style: context.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Gap(4),
                              Text(
                                'خط الطول: ${selectedLongitude?.toStringAsFixed(6)}',
                                style: context.textTheme.bodySmall,
                              ),
                              Text(
                                'خط العرض: ${selectedLatitude?.toStringAsFixed(6)}',
                                style: context.textTheme.bodySmall,
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

          Container(
            padding: AppSpaces.allMedium,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: context.colorScheme.outline),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.close),
                    label: const Text('إلغاء'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const Gap(AppSpaces.medium),
                Expanded(
                  flex: 2,
                  child: FillButton(
                    label: 'تأكيد الموقع',
                    onPressed:_confirmLocation,
                    isLoading: isLocationSelected ,
                    height: 48,
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
        
        // محاكاة إحداثيات (سيتم استبدالها بخريطة حقيقية)
        final lat = 33.3152 + (localPosition.dy / box.size.height - 0.5) * 0.1;
        final lng = 44.3661 + (localPosition.dx / box.size.width - 0.5) * 0.1;
        
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
                color: Colors.black.withOpacity(0.3),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SvgPicture.asset(
                        'assets/svg/MapPinLine.svg',
                        color: Colors.white,
                        height: 48,
                      ),
                      const Gap(AppSpaces.medium),
                      Text(
                        'اضغط لتحديد الموقع',
                        style: context.textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
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