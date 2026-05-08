import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../core/constants/app_constants.dart';

class LocationState {
  final double? latitude;
  final double? longitude;
  final String? address;
  final String? city;
  final bool isLoading;
  final String? error;

  const LocationState({
    this.latitude, this.longitude, this.address, this.city,
    this.isLoading = false, this.error,
  });

  bool get hasLocation => latitude != null && longitude != null;

  LocationState copyWith({
    double? latitude, double? longitude, String? address,
    String? city, bool? isLoading, String? error,
  }) => LocationState(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        address: address ?? this.address,
        city: city ?? this.city,
        isLoading: isLoading ?? this.isLoading,
        error: error,
      );
}

class LocationNotifier extends StateNotifier<LocationState> {
  LocationNotifier() : super(const LocationState(
    latitude: AppConstants.defaultLat,
    longitude: AppConstants.defaultLng,
    city: 'New Delhi',
  ));

  Future<void> detectLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = state.copyWith(isLoading: false, error: 'Location services disabled');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          state = state.copyWith(isLoading: false, error: 'Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        state = state.copyWith(isLoading: false, error: 'Location permission permanently denied');
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      String? address;
      String? city;
      try {
        final placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          final p = placemarks.first;
          city = p.locality ?? p.subAdministrativeArea;
          address = [p.street, p.subLocality, p.locality].where((s) => s != null && s.isNotEmpty).join(', ');
        }
      } catch (_) {}

      state = state.copyWith(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
        city: city,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void setManualLocation(double lat, double lng, String city) {
    state = state.copyWith(latitude: lat, longitude: lng, city: city);
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier();
});
