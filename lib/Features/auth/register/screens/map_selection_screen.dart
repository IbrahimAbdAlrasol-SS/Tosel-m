import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
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
  late LatLng _currentLocation;
  bool _isLocationSet = false;
  bool _isGettingLocation = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    
    // تحديد الموقع الافتراضي أو الموقع المحدد مسبقاً
    _currentLocation = LatLng(
      widget.initialLatitude ?? 33.3152,  // بغداد
      widget.initialLongitude ?? 44.3661,
    );
    
    // إذا كان هناك موقع محدد مسبقاً، اعتبره محدد
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _isLocationSet = true;
    }
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  // ✅ دالة جديدة للنقر على الخريطة
  void _onMapTap(TapPosition tapPosition, LatLng point) {
    setState(() {
      _currentLocation = point;
      _isLocationSet = true;
    });

    HapticFeedback.lightImpact();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.location_on, color: Colors.white),
            const Gap(8),
            Text('تم تحديد الموقع بنجاح', style: TextStyle(fontFamily: "Tajawal")),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    
    print('Manual Location: ${point.latitude}, ${point.longitude}');
  }

  Future<void> _setCurrentLocation() async {
    setState(() {
      _isGettingLocation = true;
    });

    try {
      // التحقق من الأذونات
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationError('تم رفض إذن الوصول للموقع');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationError('تم رفض إذن الوصول للموقع نهائياً. يرجى تفعيله من الإعدادات');
        return;
      }

      // التحقق من تفعيل خدمات الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationError('خدمات الموقع غير مفعلة. يرجى تفعيلها من الإعدادات');
        return;
      }

      // الحصول على الموقع الحالي
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      );

      // تحديث الموقع على الخريطة
      final newLocation = LatLng(position.latitude, position.longitude);
      
      setState(() {
        _currentLocation = newLocation;
        _isLocationSet = true;
        _isGettingLocation = false;
      });

      // تحريك الخريطة للموقع الجديد
      _mapController.move(newLocation, 16.0);
      
      HapticFeedback.lightImpact();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.location_on, color: Colors.white),
              const Gap(8),
              Text('تم تحديد موقعك الحالي بنجاح', style: TextStyle(fontFamily: "Tajawal")),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
      
      print('Real GPS Location: ${position.latitude}, ${position.longitude}');
      print('Accuracy: ${position.accuracy} meters');
      
    } catch (e) {
      setState(() {
        _isGettingLocation = false;
      });
      
      String errorMessage = 'فشل في تحديد الموقع';
      if (e is TimeoutException) {
        errorMessage = 'انتهت مهلة تحديد الموقع. تأكد من قوة الإشارة';
      } else if (e is LocationServiceDisabledException) {
        errorMessage = 'خدمات الموقع غير مفعلة';
      } else if (e is PermissionDeniedException) {
        errorMessage = 'تم رفض إذن الوصول للموقع';
      }
      
      _showLocationError(errorMessage);
      print('Location Error: $e');
    }
  }

  void _showLocationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            const Gap(8),
            Expanded(
              child: Text(message, style: TextStyle(fontFamily: "Tajawal")),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
        action: SnackBarAction(
          label: 'الإعدادات',
          textColor: Colors.white,
          onPressed: () {
            Geolocator.openAppSettings();
          },
        ),
      ),
    );
  }

  void _confirmLocation() {
    if (_isLocationSet) {
      // إرجاع الإحداثيات للصفحة السابقة
      context.pop({
        'latitude': _currentLocation.latitude,
        'longitude': _currentLocation.longitude,
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('يرجى تحديد الموقع أولاً', style: TextStyle(fontFamily: "Tajawal")),
          backgroundColor: Colors.red,
        ),
      );
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
              title: "تحديد الموقع",
              showBackButton: true,
            ),
          ),

          // Map Container
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _isLocationSet 
                      ? context.colorScheme.primary
                      : context.colorScheme.outline,
                  width: _isLocationSet ? 2 : 1,
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
                        initialCenter: _currentLocation,
                        initialZoom: 13.0,
                        maxZoom: 18.0,
                        minZoom: 5.0,
                        onTap: _onMapTap,  // ✅ إضافة إمكانية النقر
                      ),
                      children: [
                        // طبقة الخريطة
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.tosell.app',
                        ),
                        
                        // العلامة المحددة
                        if (_isLocationSet)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentLocation,
                                width: 50,
                                height: 50,
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
                              ),
                            ],
                          ),
                      ],
                    ),

                    // زر تحديد الموقع الحالي
                    Positioned(
                      bottom: 20,
                      right: 16,
                      child: FloatingActionButton.extended(
                        onPressed: _isGettingLocation ? null : _setCurrentLocation,
                        backgroundColor: _isGettingLocation 
                            ? Colors.grey 
                            : context.colorScheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        icon: _isGettingLocation 
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.my_location),
                        label: Text(
                          _isGettingLocation ? 'جاري التحديد...' : 'تحديد موقعي',
                          style: const TextStyle(
                            fontFamily: "Tajawal",
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                    // معلومات الموقع المحدد
                   
                    // تعليمات الاستخدام
                    if (!_isLocationSet)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/MapPinLine.svg',
                                color: Colors.white,
                                height: 24,
                              ),
                              const Gap(8),
                              Text(
                                'انقر على أي مكان في الخريطة أو استخدم "تحديد موقعي"',
                                style: context.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
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
                    onPressed: _isLocationSet ? _confirmLocation : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: _isLocationSet 
                          ? context.colorScheme.primary 
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _isLocationSet ? Icons.check : Icons.location_disabled,
                          color: Colors.white,
                          size: 20,
                        ),
                        const Gap(8),
                        Text(
                          _isLocationSet ? 'موافق' : 'حدد الموقع أولاً',
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