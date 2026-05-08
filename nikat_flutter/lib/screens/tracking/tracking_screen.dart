import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../models/order_model.dart';

class TrackingScreen extends ConsumerStatefulWidget {
  const TrackingScreen({super.key, required this.orderId});
  final String orderId;

  @override
  ConsumerState<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends ConsumerState<TrackingScreen> {
  GoogleMapController? _mapController;
  StreamSubscription<Position>? _locationStream;
  LatLng? _userLocation;
  LatLng? _providerLocation;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    try {
      final permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;

      _locationStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      ).listen((position) {
        setState(() {
          _userLocation = LatLng(position.latitude, position.longitude);
          _updateMarkers();
        });
        _animateCamera();
      });
    } catch (e) {
      debugPrint('Tracking error: $e');
    }
  }

  void _updateMarkers() {
    _markers.clear();
    if (_userLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId('user'),
        position: _userLocation!,
        infoWindow: const InfoWindow(title: 'Your Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ));
    }
    if (_providerLocation != null) {
      _markers.add(Marker(
        markerId: const MarkerId('provider'),
        position: _providerLocation!,
        infoWindow: const InfoWindow(title: 'Service Provider'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ));

      if (_userLocation != null) {
        _polylines.clear();
        _polylines.add(Polyline(
          polylineId: const PolylineId('route'),
          points: [_userLocation!, _providerLocation!],
          color: AppColors.primary,
          width: 4,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ));
      }
    }
  }

  void _animateCamera() {
    if (!_mapReady || _mapController == null) return;
    if (_userLocation != null && _providerLocation != null) {
      final bounds = LatLngBounds(
        southwest: LatLng(
          _userLocation!.latitude < _providerLocation!.latitude ? _userLocation!.latitude : _providerLocation!.latitude,
          _userLocation!.longitude < _providerLocation!.longitude ? _userLocation!.longitude : _providerLocation!.longitude,
        ),
        northeast: LatLng(
          _userLocation!.latitude > _providerLocation!.latitude ? _userLocation!.latitude : _providerLocation!.latitude,
          _userLocation!.longitude > _providerLocation!.longitude ? _userLocation!.longitude : _providerLocation!.longitude,
        ),
      );
      _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } else if (_userLocation != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLng(_userLocation!));
    }
  }

  double? _calculateDistance() {
    if (_userLocation == null || _providerLocation == null) return null;
    return Geolocator.distanceBetween(
      _userLocation!.latitude, _userLocation!.longitude,
      _providerLocation!.latitude, _providerLocation!.longitude,
    ) / 1000;
  }

  @override
  void dispose() {
    _locationStream?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Live Tracking')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection(AppConstants.ordersCollection)
            .doc(widget.orderId)
            .snapshots(),
        builder: (context, snapshot) {
          OrderModel? order;
          if (snapshot.hasData && snapshot.data!.exists) {
            order = OrderModel.fromFirestore(snapshot.data!);
            if (order.providerLatitude != null && order.providerLongitude != null) {
              _providerLocation = LatLng(order.providerLatitude!, order.providerLongitude!);
              _updateMarkers();
            }
          }

          final distance = _calculateDistance();

          return Column(
            children: [
              // Map section
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    GoogleMap(
                      initialCameraPosition: CameraPosition(
                        target: _userLocation ?? const LatLng(AppConstants.defaultLat, AppConstants.defaultLng),
                        zoom: 14,
                      ),
                      mapType: MapType.normal,
                      markers: _markers,
                      polylines: _polylines,
                      myLocationEnabled: true,
                      myLocationButtonEnabled: false,
                      zoomControlsEnabled: false,
                      onMapCreated: (controller) {
                        _mapController = controller;
                        _mapReady = true;
                        controller.setMapStyle(_darkMapStyle);
                        _animateCamera();
                      },
                    ),
                    // Recenter button
                    Positioned(
                      right: 16,
                      bottom: 16,
                      child: FloatingActionButton.small(
                        onPressed: _animateCamera,
                        backgroundColor: AppColors.surface,
                        child: const Icon(Icons.my_location, color: AppColors.primary),
                      ),
                    ),
                    // Distance chip
                    if (distance != null)
                      Positioned(
                        top: 12,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.surface.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Text(
                              '${distance.toStringAsFixed(1)} km away',
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primary),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              // Order info panel
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: AppColors.surface,
                    border: Border(top: BorderSide(color: AppColors.border)),
                  ),
                  child: order == null
                      ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(order.shopName,
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                _StatusBadge(status: order.status),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              order.serviceName ?? 'General Service',
                              style: const TextStyle(color: AppColors.onSurfaceMuted, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            _OrderTimeline(order: order),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.phone, size: 16),
                                    label: const Text('Call Provider'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {},
                                    icon: const Icon(Icons.chat, size: 16),
                                    label: const Text('Chat'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case 'confirmed': color = AppColors.info; label = '✅ Confirmed'; break;
      case 'on_the_way': color = AppColors.warning; label = '🚗 On the way'; break;
      case 'delivered': color = AppColors.success; label = '🎉 Delivered'; break;
      default: color = AppColors.onSurfaceMuted; label = status;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
      child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }
}

class _OrderTimeline extends StatelessWidget {
  const _OrderTimeline({required this.order});
  final OrderModel order;

  @override
  Widget build(BuildContext context) {
    final steps = ['Placed', 'Confirmed', 'On The Way', 'Delivered'];
    return Row(
      children: steps.asMap().entries.map((e) {
        final isDone = e.key <= order.statusStep;
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: isDone ? AppColors.primary : AppColors.surfaceVariant,
                  shape: BoxShape.circle,
                ),
                child: isDone ? const Icon(Icons.check, size: 14, color: Colors.black) : null,
              ),
              if (e.key < steps.length - 1)
                Expanded(child: Container(height: 2, color: isDone ? AppColors.primary : AppColors.surfaceVariant)),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Dark map style for Google Maps
const String _darkMapStyle = '''
[{"elementType":"geometry","stylers":[{"color":"#212121"}]},
{"elementType":"labels.icon","stylers":[{"visibility":"off"}]},
{"elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
{"elementType":"labels.text.stroke","stylers":[{"color":"#212121"}]},
{"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#757575"}]},
{"featureType":"administrative.country","elementType":"labels.text.fill","stylers":[{"color":"#9e9e9e"}]},
{"featureType":"administrative.land_parcel","stylers":[{"visibility":"off"}]},
{"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#bdbdbd"}]},
{"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
{"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#181818"}]},
{"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
{"featureType":"poi.park","elementType":"labels.text.stroke","stylers":[{"color":"#1b1b1b"}]},
{"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#2c2c2c"}]},
{"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#8a8a8a"}]},
{"featureType":"road.arterial","elementType":"geometry","stylers":[{"color":"#373737"}]},
{"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#3c3c3c"}]},
{"featureType":"road.highway.controlled_access","elementType":"geometry","stylers":[{"color":"#4e4e4e"}]},
{"featureType":"road.local","elementType":"labels.text.fill","stylers":[{"color":"#616161"}]},
{"featureType":"transit","elementType":"labels.text.fill","stylers":[{"color":"#757575"}]},
{"featureType":"water","elementType":"geometry","stylers":[{"color":"#000000"}]},
{"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#3d3d3d"}]}]
''';
