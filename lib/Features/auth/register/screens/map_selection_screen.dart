import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:Tosell/core/utils/extensions.dart';
import 'package:Tosell/core/widgets/CustomAppBar.dart';

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
  late final MapController _mapController;
  LatLng? _selectedLocation;
  bool _isLocationSelected = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    // إذا كان هناك موقع محدد مسبقاً
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation =
          LatLng(widget.initialLatitude!, widget.initialLongitude!);
      _isLocationSelected = true;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  void _onMapTapped(LatLng point) {
  print('Location selected: ${point.latitude}, ${point.longitude}'); // أضف هذا
  setState(() {
    _selectedLocation = point;
    _isLocationSelected = true;
  });
  HapticFeedback.lightImpact();
}

  void _confirmLocation() {
    if (_selectedLocation != null) {
      // إرجاع الإحداثيات للصفحة السابقة
      context.pop({
        'latitude': _selectedLocation!.latitude,
        'longitude': _selectedLocation!.longitude,
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
              title: "اختيار الموقع على الخريطة",
              showBackButton: true,
            ),
          ),

          // Map
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isLocationSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.outline,
                  width: _isLocationSelected ? 2 : 1,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Stack(
                  children: [
                    // الخريطة
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _selectedLocation ??
                            LatLng(33.3152, 44.3661), // Baghdad
                        initialZoom: 13.0,
                        onTap: (tapPosition, point) {
  print('Map tapped at: $point'); // للتأكد
  _onMapTapped(point);
},
                        maxZoom: 18.0,
                        minZoom: 5.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.tosell.app',
                        ),

                        // العلامة المحددة
                        if (_selectedLocation != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: context.colorScheme.primary,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                    size: 30,
                                  ),
                                ),
                                point: _selectedLocation!,
                                width: 50,
                                height: 50,
                              ),
                            ],
                          ),
                      ],
                    ),

                    // تعليمات الاستخدام
                    if (!_isLocationSelected)
                      Positioned.fill(
                        child: Container(
                          color: Colors.black.withOpacity(0.4),
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SvgPicture.asset(
                                  'assets/svg/MapPinLine.svg',
                                  color: Colors.white,
                                  height: 48,
                                ),
                                const Gap(16),
                                Text(
                                  'اضغط على الخريطة لتحديد الموقع',
                                  style:
                                      context.textTheme.titleMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                    // معلومات الموقع المحدد
                    if (_isLocationSelected)
                      Positioned(
                        bottom: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.95),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, -2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.location_on,
                                      color: context.colorScheme.primary,
                                      size: 20),
                                  const Gap(8),
                                  Text(
                                    'تم تحديد الموقع بنجاح',
                                    style:
                                        context.textTheme.bodyMedium?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: context.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                              const Gap(8),
                              Text(
                                'خط العرض: ${_selectedLocation!.latitude.toStringAsFixed(4)} | خط الطول: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                                style: context.textTheme.bodySmall?.copyWith(
                                  color: context.colorScheme.onSurface,
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
          ),

          // أزرار التحكم
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: context.colorScheme.outline),
              ),
            ),
            child: Row(
              children: [
                // زر إلغاء
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: context.colorScheme.outline),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),

                const Gap(16),

                // زر موافق
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: _isLocationSelected ? _confirmLocation : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _isLocationSelected
                          ? context.colorScheme.primary
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLocationSelected
                              ? Icons.check
                              : Icons.location_disabled,
                          color: Colors.white,
                          size: 20,
                        ),
                        const Gap(8),
                        Text(
                          _isLocationSelected ? 'موافق' : 'حدد الموقع أولاً',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
