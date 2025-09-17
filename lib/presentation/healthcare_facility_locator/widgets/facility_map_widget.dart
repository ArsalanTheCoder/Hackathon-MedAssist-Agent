import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FacilityMapWidget extends StatefulWidget {
  final List<Map<String, dynamic>> facilities;
  final Function(Map<String, dynamic>)? onFacilityTap;
  final LatLng? initialLocation;

  const FacilityMapWidget({
    Key? key,
    required this.facilities,
    this.onFacilityTap,
    this.initialLocation,
  }) : super(key: key);

  @override
  State<FacilityMapWidget> createState() => _FacilityMapWidgetState();
}

class _FacilityMapWidgetState extends State<FacilityMapWidget> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  @override
  void didUpdateWidget(FacilityMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.facilities != widget.facilities) {
      _updateMarkers();
    }
  }

  Future<void> _initializeMap() async {
    try {
      await _getCurrentLocation();
      _updateMarkers();
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load map: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      if (widget.initialLocation != null) {
        _currentLocation = widget.initialLocation;
        return;
      }

      if (!kIsWeb) {
        final permission = await Permission.location.request();
        if (!permission.isGranted) {
          throw Exception('Location permission denied');
        }
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      // Fallback to default location (San Francisco)
      setState(() {
        _currentLocation = const LatLng(37.7749, -122.4194);
      });
    }
  }

  void _updateMarkers() {
    final Set<Marker> markers = {};

    // Add user location marker
    if (_currentLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('user_location'),
          position: _currentLocation!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(
            title: 'Your Location',
            snippet: 'You are here',
          ),
        ),
      );
    }

    // Add facility markers
    for (int i = 0; i < widget.facilities.length; i++) {
      final facility = widget.facilities[i];
      final lat = (facility['latitude'] as num?)?.toDouble();
      final lng = (facility['longitude'] as num?)?.toDouble();

      if (lat != null && lng != null) {
        final facilityType =
            (facility['type'] as String? ?? 'hospital').toLowerCase();
        final markerColor = _getMarkerColor(facilityType);

        markers.add(
          Marker(
            markerId: MarkerId('facility_$i'),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(markerColor),
            infoWindow: InfoWindow(
              title: facility['name'] as String? ?? 'Unknown Facility',
              snippet: '${facility['distance'] ?? '0.0'} km away',
              onTap: () {
                if (widget.onFacilityTap != null) {
                  widget.onFacilityTap!(facility);
                }
              },
            ),
            onTap: () {
              if (widget.onFacilityTap != null) {
                widget.onFacilityTap!(facility);
              }
            },
          ),
        );
      }
    }

    setState(() {
      _markers = markers;
    });
  }

  double _getMarkerColor(String facilityType) {
    switch (facilityType) {
      case 'hospital':
        return BitmapDescriptor.hueRed;
      case 'pharmacy':
        return BitmapDescriptor.hueGreen;
      case 'urgent_care':
        return BitmapDescriptor.hueOrange;
      case 'specialist':
        return BitmapDescriptor.hueBlue;
      case 'clinic':
        return BitmapDescriptor.hueViolet;
      default:
        return BitmapDescriptor.hueRed;
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController = controller;
    if (_currentLocation != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 12.0),
      );
    }
  }

  Future<void> _goToCurrentLocation() async {
    if (_mapController != null && _currentLocation != null) {
      await _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 15.0),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading) {
      return Container(
        height: 50.h,
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        height: 50.h,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'error_outline',
                color: isDark ? AppTheme.errorDark : AppTheme.errorLight,
                size: 12.w,
              ),
              SizedBox(height: 2.h),
              Text(
                _errorMessage!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 2.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _initializeMap();
                },
                child: Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: _currentLocation ?? const LatLng(37.7749, -122.4194),
            zoom: 12.0,
          ),
          markers: _markers,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: true,
          trafficEnabled: false,
          buildingsEnabled: true,
          indoorViewEnabled: true,
          mapType: MapType.normal,
        ),
        Positioned(
          right: 4.w,
          bottom: 4.h,
          child: FloatingActionButton(
            onPressed: _goToCurrentLocation,
            mini: true,
            backgroundColor: isDark
                ? AppTheme.surfaceElevatedDark
                : AppTheme.surfaceElevatedLight,
            child: CustomIconWidget(
              iconName: 'my_location',
              color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
              size: 5.w,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
