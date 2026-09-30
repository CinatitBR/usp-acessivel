import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show Locale;
import 'package:geocoding/geocoding.dart';

class GeocodingService {
  static final Map<String, String> _cache = {};
  static final Geocoding _geocoding = Geocoding();

  /// Resolves (lat, lon) to a human-readable street/neighborhood address.
  /// Uses native platform geocoding on Android (Geocoder) and iOS (CLGeocoder).
  /// Falls back cleanly to [fallback] or formatted coordinates if offline or unsupported.
  static Future<String> getAddressFromCoordinates(
    double lat,
    double lon, {
    String? fallback,
  }) async {
    final key = '${lat.toStringAsFixed(5)},${lon.toStringAsFixed(5)}';
    if (_cache.containsKey(key)) return _cache[key]!;

    try {
      final placemarks = await _geocoding.placemarkFromCoordinates(
        lat,
        lon,
        locale: const Locale('pt', 'BR'),
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final street = (p.thoroughfare != null && p.thoroughfare!.trim().isNotEmpty)
            ? p.thoroughfare!.trim()
            : ((p.street != null && p.street!.trim().isNotEmpty)
                ? p.street!.trim()
                : null);

        final neighborhood =
            (p.subLocality != null && p.subLocality!.trim().isNotEmpty)
                ? p.subLocality!.trim()
                : ((p.subAdministrativeArea != null &&
                        p.subAdministrativeArea!.trim().isNotEmpty)
                    ? p.subAdministrativeArea!.trim()
                    : null);

        if (street != null && neighborhood != null) {
          final formatted = '$street, $neighborhood';
          _cache[key] = formatted;
          return formatted;
        } else if (street != null) {
          _cache[key] = street;
          return street;
        }
      }
    } catch (e) {
      debugPrint('Native geocoding not available or failed: $e');
    }

    final defaultFallback =
        fallback ?? '${lat.toStringAsFixed(6)}, ${lon.toStringAsFixed(6)}';
    _cache[key] = defaultFallback;
    return defaultFallback;
  }
}
