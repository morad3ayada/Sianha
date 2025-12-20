// location_picker_service.dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerService {
  // 1. طلب الصلاحيات مع تحسين رسائل الخطأ
  static Future<Map<String, dynamic>?> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    try {
      // التحقق من تفعيل خدمة الموقع (GPS)
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'error': 'GPS غير مفعل',
          'message': 'يرجى تفعيل خدمة الموقع (GPS) في إعدادات جهازك'
        };
      }

      // التحقق من حالة الصلاحية
      permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        // طلب الصلاحية من المستخدم
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'error': 'تم رفض الصلاحية',
            'message': 'يجب منح صلاحية الموقع لتحديد موقعك'
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'error': 'تم رفض الصلاحية بشكل دائم',
          'message': 'يرجى منح صلاحية الموقع من إعدادات التطبيق'
        };
      }

      return null; // لا يوجد خطأ
    } catch (e) {
      return {'error': 'خطأ في الصلاحيات', 'message': 'حدث خطأ غير متوقع: $e'};
    }
  }

  // 2. الحصول على الموقع الحالي مع معالجة أفضل للأخطاء
  static Future<Map<String, dynamic>?> getCurrentLocation() async {
    try {
      // التحقق من الصلاحيات أولاً
      final permissionResult = await _handleLocationPermission();
      if (permissionResult != null) {
        return permissionResult; // إرجاع رسالة الخطأ
      }

      // الحصول على الموقع الحالي مع مهلة انتظار
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        timeLimit: const Duration(seconds: 15), // مهلة 15 ثانية
      ).timeout(const Duration(seconds: 20));

      // محاولة الحصول على العنوان
      String address =
          'الموقع: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        ).timeout(const Duration(seconds: 10));

        if (placemarks.isNotEmpty) {
          Placemark place = placemarks.first;
          address = _buildAddress(place);
        }
      } catch (e) {
        print('خطأ في الحصول على العنوان: $e');
        // نستمر باستخدام الإحداثيات إذا فشل الحصول على العنوان
      }

      return {
        'success': true,
        'location': {
          'latitude': position.latitude,
          'longitude': position.longitude,
        },
        'address': address,
      };
    } catch (e) {
      return {
        'error': 'فشل في تحديد الموقع',
        'message':
            'تعذر الوصول إلى خدمة الموقع. تأكد من تفعيل GPS والاتصال بالإنترنت'
      };
    }
  }

  // بناء العنوان من بيانات المكان
  static String _buildAddress(Placemark place) {
    List<String> addressParts = [];

    if (place.street != null && place.street!.isNotEmpty) {
      addressParts.add(place.street!);
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      addressParts.add(place.subLocality!);
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      addressParts.add(place.locality!);
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      addressParts.add(place.administrativeArea!);
    }

    return addressParts.isNotEmpty ? addressParts.join(', ') : 'موقع غير معروف';
  }

  // 3. دالة مساعدة للتحقق من حالة الموقع
  static Future<Map<String, dynamic>> checkLocationStatus() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      return {
        'gps_enabled': serviceEnabled,
        'permission_granted': permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always,
        'permission_status': permission.toString(),
      };
    } catch (e) {
      return {
        'gps_enabled': false,
        'permission_granted': false,
        'error': e.toString(),
      };
    }
  }
}
