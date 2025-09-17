import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_export.dart';
import './widgets/facility_card_widget.dart';
import './widgets/facility_filter_modal.dart';
import './widgets/facility_map_widget.dart';
import './widgets/facility_search_bar.dart';

class HealthcareFacilityLocator extends StatefulWidget {
  const HealthcareFacilityLocator({Key? key}) : super(key: key);

  @override
  State<HealthcareFacilityLocator> createState() =>
      _HealthcareFacilityLocatorState();
}

class _HealthcareFacilityLocatorState extends State<HealthcareFacilityLocator>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  Map<String, dynamic> _activeFilters = {};
  List<Map<String, dynamic>> _facilities = [];
  List<Map<String, dynamic>> _filteredFacilities = [];
  List<String> _searchHistory = [];
  Set<String> _favoriteFacilities = {};
  bool _isLoading = true;
  bool _locationPermissionGranted = false;
  LatLng? _currentLocation;

  final List<String> _searchSuggestions = [
    'Emergency Room',
    'Urgent Care',
    'Pharmacy',
    'Cardiology',
    'Dermatology',
    'Pediatrics',
    'Orthopedics',
    'Mental Health',
    '24 Hour Pharmacy',
    'Walk-in Clinic',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _checkLocationPermission();
    await _loadMockData();
    _applyFilters();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _checkLocationPermission() async {
    try {
      if (!kIsWeb) {
        final permission = await Permission.location.request();
        _locationPermissionGranted = permission.isGranted;
      } else {
        _locationPermissionGranted = true;
      }

      if (_locationPermissionGranted) {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        _currentLocation = LatLng(position.latitude, position.longitude);
      }
    } catch (e) {
      _locationPermissionGranted = false;
      // Fallback to default location
      _currentLocation = const LatLng(37.7749, -122.4194);
    }
  }

  Future<void> _loadMockData() async {
    // Mock healthcare facility data
    _facilities = [
      {
        "id": 1,
        "name": "San Francisco General Hospital",
        "type": "hospital",
        "address": "1001 Potrero Ave, San Francisco, CA 94110",
        "phone": "+1 (415) 206-8000",
        "latitude": 37.7562,
        "longitude": -122.4056,
        "distance": 2.3,
        "rating": 4.2,
        "waitTime": 45,
        "isOpen": true,
        "is24Hours": true,
        "hasEmergency": true,
        "acceptsInsurance": ["Medicare", "Medicaid", "Blue Cross Blue Shield"],
        "languages": ["English", "Spanish", "Chinese"],
        "specialties": ["Emergency Medicine", "Cardiology", "Neurology"],
        "isFavorite": false,
      },
      {
        "id": 2,
        "name": "CVS Pharmacy",
        "type": "pharmacy",
        "address": "2145 Irving St, San Francisco, CA 94122",
        "phone": "+1 (415) 681-3057",
        "latitude": 37.7636,
        "longitude": -122.4830,
        "distance": 1.8,
        "rating": 3.8,
        "waitTime": 15,
        "isOpen": true,
        "is24Hours": false,
        "hasEmergency": false,
        "acceptsInsurance": ["Most Insurance Plans"],
        "languages": ["English", "Spanish"],
        "specialties": ["Prescription Filling", "Vaccinations"],
        "isFavorite": true,
      },
      {
        "id": 3,
        "name": "UCSF Urgent Care",
        "type": "urgent_care",
        "address": "1825 4th St, San Francisco, CA 94158",
        "phone": "+1 (415) 353-2273",
        "latitude": 37.7677,
        "longitude": -122.3892,
        "distance": 3.1,
        "rating": 4.5,
        "waitTime": 25,
        "isOpen": true,
        "is24Hours": false,
        "hasEmergency": false,
        "acceptsInsurance": ["Aetna", "Cigna", "UnitedHealth"],
        "languages": ["English", "Spanish", "French"],
        "specialties": ["Urgent Care", "Minor Injuries"],
        "isFavorite": false,
      },
      {
        "id": 4,
        "name": "Dr. Sarah Johnson - Cardiologist",
        "type": "specialist",
        "address": "450 Sutter St, San Francisco, CA 94108",
        "phone": "+1 (415) 398-2500",
        "latitude": 37.7886,
        "longitude": -122.4075,
        "distance": 4.2,
        "rating": 4.8,
        "waitTime": 0,
        "isOpen": false,
        "is24Hours": false,
        "hasEmergency": false,
        "acceptsInsurance": ["Blue Cross Blue Shield", "Aetna"],
        "languages": ["English"],
        "specialties": ["Cardiology", "Heart Surgery"],
        "isFavorite": false,
      },
      {
        "id": 5,
        "name": "Mission Bay Family Clinic",
        "type": "clinic",
        "address": "1670 Valencia St, San Francisco, CA 94110",
        "phone": "+1 (415) 641-5000",
        "latitude": 37.7493,
        "longitude": -122.4207,
        "distance": 2.7,
        "rating": 4.1,
        "waitTime": 35,
        "isOpen": true,
        "is24Hours": false,
        "hasEmergency": false,
        "acceptsInsurance": ["Medicare", "Medicaid"],
        "languages": ["English", "Spanish", "Arabic"],
        "specialties": ["Family Medicine", "Pediatrics"],
        "isFavorite": false,
      },
      {
        "id": 6,
        "name": "Walgreens Pharmacy",
        "type": "pharmacy",
        "address": "135 Powell St, San Francisco, CA 94102",
        "phone": "+1 (415) 391-7222",
        "latitude": 37.7867,
        "longitude": -122.4081,
        "distance": 1.2,
        "rating": 3.9,
        "waitTime": 10,
        "isOpen": true,
        "is24Hours": true,
        "hasEmergency": false,
        "acceptsInsurance": ["Most Insurance Plans"],
        "languages": ["English", "Spanish", "Chinese"],
        "specialties": ["Prescription Filling", "Health Screenings"],
        "isFavorite": false,
      },
    ];

    // Update favorites from stored set
    for (var facility in _facilities) {
      facility['isFavorite'] =
          _favoriteFacilities.contains(facility['id'].toString());
    }
  }

  void _applyFilters() {
    List<Map<String, dynamic>> filtered = List.from(_facilities);

    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((facility) {
        final name = (facility['name'] as String).toLowerCase();
        final type = (facility['type'] as String).toLowerCase();
        final specialties =
            (facility['specialties'] as List).join(' ').toLowerCase();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            type.contains(query) ||
            specialties.contains(query);
      }).toList();
    }

    // Apply facility type filter
    if (_activeFilters['facilityTypes'] != null &&
        (_activeFilters['facilityTypes'] as List).isNotEmpty) {
      filtered = filtered.where((facility) {
        return (_activeFilters['facilityTypes'] as List)
            .contains(facility['type']);
      }).toList();
    }

    // Apply distance filter
    if (_activeFilters['distanceRadius'] != null) {
      final maxDistance = _activeFilters['distanceRadius'] as double;
      filtered = filtered.where((facility) {
        final distance = (facility['distance'] as num).toDouble();
        return distance <= maxDistance;
      }).toList();
    }

    // Apply open now filter
    if (_activeFilters['openNow'] == true) {
      filtered =
          filtered.where((facility) => facility['isOpen'] == true).toList();
    }

    // Apply 24/7 filter
    if (_activeFilters['available24_7'] == true) {
      filtered =
          filtered.where((facility) => facility['is24Hours'] == true).toList();
    }

    // Apply emergency services filter
    if (_activeFilters['emergencyServices'] == true) {
      filtered = filtered
          .where((facility) => facility['hasEmergency'] == true)
          .toList();
    }

    // Apply insurance filter
    if (_activeFilters['insurance'] != null &&
        (_activeFilters['insurance'] as List).isNotEmpty) {
      filtered = filtered.where((facility) {
        final facilityInsurance = facility['acceptsInsurance'] as List;
        final requiredInsurance = _activeFilters['insurance'] as List;
        return requiredInsurance.any((insurance) =>
            facilityInsurance.any((fi) => (fi as String).contains(insurance)));
      }).toList();
    }

    // Apply language filter
    if (_activeFilters['languages'] != null &&
        (_activeFilters['languages'] as List).isNotEmpty) {
      filtered = filtered.where((facility) {
        final facilityLanguages = facility['languages'] as List;
        final requiredLanguages = _activeFilters['languages'] as List;
        return requiredLanguages
            .any((language) => facilityLanguages.contains(language));
      }).toList();
    }

    // Apply specialty filter
    if (_activeFilters['specialties'] != null &&
        (_activeFilters['specialties'] as List).isNotEmpty) {
      filtered = filtered.where((facility) {
        final facilitySpecialties = facility['specialties'] as List;
        final requiredSpecialties = _activeFilters['specialties'] as List;
        return requiredSpecialties
            .any((specialty) => facilitySpecialties.contains(specialty));
      }).toList();
    }

    // Sort by distance
    filtered.sort((a, b) {
      final distanceA = (a['distance'] as num).toDouble();
      final distanceB = (b['distance'] as num).toDouble();
      return distanceA.compareTo(distanceB);
    });

    setState(() {
      _filteredFacilities = filtered;
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    _applyFilters();

    // Add to search history if not empty and not already present
    if (query.isNotEmpty && !_searchHistory.contains(query)) {
      setState(() {
        _searchHistory.insert(0, query);
        if (_searchHistory.length > 10) {
          _searchHistory = _searchHistory.take(10).toList();
        }
      });
    }
  }

  void _onFiltersChanged(Map<String, dynamic> filters) {
    setState(() {
      _activeFilters = filters;
    });
    _applyFilters();
  }

  void _toggleFavorite(Map<String, dynamic> facility) {
    final facilityId = facility['id'].toString();
    setState(() {
      if (_favoriteFacilities.contains(facilityId)) {
        _favoriteFacilities.remove(facilityId);
        facility['isFavorite'] = false;
      } else {
        _favoriteFacilities.add(facilityId);
        facility['isFavorite'] = true;
      }
    });
  }

  Future<void> _callFacility(Map<String, dynamic> facility) async {
    final phone = facility['phone'] as String?;
    if (phone != null) {
      final uri = Uri.parse('tel:$phone');
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      }
    }
  }

  Future<void> _getDirections(Map<String, dynamic> facility) async {
    final lat = facility['latitude'] as double?;
    final lng = facility['longitude'] as double?;

    if (lat != null && lng != null) {
      final uri = kIsWeb
          ? Uri.parse(
              'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng')
          : Uri.parse('geo:$lat,$lng?q=$lat,$lng');

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _showFacilityDetails(Map<String, dynamic> facility) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFacilityDetailsModal(facility),
    );
  }

  Widget _buildFacilityDetailsModal(Map<String, dynamic> facility) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 70.h,
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceElevatedDark
            : AppTheme.surfaceElevatedLight,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            width: 10.w,
            height: 0.5.h,
            margin: EdgeInsets.only(top: 1.h),
            decoration: BoxDecoration(
              color: isDark
                  ? AppTheme.borderSubtleDark
                  : AppTheme.borderSubtleLight,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          facility['name'] as String,
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      IconButton(
                        onPressed: () => _toggleFavorite(facility),
                        icon: CustomIconWidget(
                          iconName: (facility['isFavorite'] as bool)
                              ? 'favorite'
                              : 'favorite_border',
                          color: (facility['isFavorite'] as bool)
                              ? (isDark
                                  ? AppTheme.errorDark
                                  : AppTheme.errorLight)
                              : (isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight),
                          size: 6.w,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),
                  _buildDetailRow('Address', facility['address'] as String),
                  _buildDetailRow('Phone', facility['phone'] as String),
                  _buildDetailRow(
                      'Distance', '${facility['distance']} km away'),
                  if ((facility['rating'] as double) > 0)
                    _buildDetailRow('Rating', '${facility['rating']}/5.0'),
                  if ((facility['waitTime'] as int) > 0)
                    _buildDetailRow(
                        'Wait Time', '${facility['waitTime']} minutes'),
                  _buildDetailRow('Status',
                      (facility['isOpen'] as bool) ? 'Open' : 'Closed'),
                  if ((facility['specialties'] as List).isNotEmpty)
                    _buildDetailRow('Specialties',
                        (facility['specialties'] as List).join(', ')),
                  if ((facility['languages'] as List).isNotEmpty)
                    _buildDetailRow('Languages',
                        (facility['languages'] as List).join(', ')),
                  if ((facility['acceptsInsurance'] as List).isNotEmpty)
                    _buildDetailRow('Insurance',
                        (facility['acceptsInsurance'] as List).join(', ')),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _callFacility(facility),
                          icon: CustomIconWidget(
                            iconName: 'phone',
                            color: isDark
                                ? AppTheme.primaryDark
                                : AppTheme.primaryLight,
                            size: 4.w,
                          ),
                          label: Text('Call'),
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _getDirections(facility),
                          icon: CustomIconWidget(
                            iconName: 'directions',
                            color: isDark
                                ? AppTheme.onPrimaryDark
                                : AppTheme.onPrimaryLight,
                            size: 4.w,
                          ),
                          label: Text('Directions'),
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
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FacilityFilterModal(
        currentFilters: _activeFilters,
        onFiltersChanged: _onFiltersChanged,
      ),
    );
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Permission Required'),
        content: Text(
          'To show nearby healthcare facilities, we need access to your location. Please enable location permission in your device settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await openAppSettings();
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Healthcare Facilities'),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color:
                isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimaryLight,
            size: 6.w,
          ),
        ),
        actions: [
          if (!_locationPermissionGranted)
            IconButton(
              onPressed: _showLocationPermissionDialog,
              icon: CustomIconWidget(
                iconName: 'location_off',
                color: isDark ? AppTheme.warningDark : AppTheme.warningLight,
                size: 6.w,
              ),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              icon: CustomIconWidget(
                iconName: 'map',
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 5.w,
              ),
              text: 'Map',
            ),
            Tab(
              icon: CustomIconWidget(
                iconName: 'list',
                color: isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                size: 5.w,
              ),
              text: 'List',
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                FacilitySearchBar(
                  initialQuery: _searchQuery,
                  onSearchChanged: _onSearchChanged,
                  onFilterTap: _showFilterModal,
                  suggestions: _searchSuggestions + _searchHistory,
                ),
                if (_activeFilters.isNotEmpty) _buildActiveFiltersChips(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildMapView(),
                      _buildListView(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActiveFiltersChips() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    List<Widget> chips = [];

    if (_activeFilters['facilityTypes'] != null &&
        (_activeFilters['facilityTypes'] as List).isNotEmpty) {
      for (String type in _activeFilters['facilityTypes'] as List) {
        chips.add(
          Chip(
            label: Text(type.replaceAll('_', ' ').toUpperCase()),
            onDeleted: () {
              setState(() {
                (_activeFilters['facilityTypes'] as List).remove(type);
                if ((_activeFilters['facilityTypes'] as List).isEmpty) {
                  _activeFilters.remove('facilityTypes');
                }
              });
              _applyFilters();
            },
          ),
        );
      }
    }

    if (_activeFilters['openNow'] == true) {
      chips.add(
        Chip(
          label: Text('Open Now'),
          onDeleted: () {
            setState(() {
              _activeFilters.remove('openNow');
            });
            _applyFilters();
          },
        ),
      );
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 6.h,
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: chips
            .map((chip) => Padding(
                  padding: EdgeInsets.only(right: 2.w),
                  child: chip,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildMapView() {
    return FacilityMapWidget(
      facilities: _filteredFacilities,
      onFacilityTap: _showFacilityDetails,
      initialLocation: _currentLocation,
    );
  }

  Widget _buildListView() {
    if (_filteredFacilities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'search_off',
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              size: 15.w,
            ),
            SizedBox(height: 2.h),
            Text(
              'No facilities found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            Text(
              'Try adjusting your search or filters',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.only(top: 1.h, bottom: 2.h),
      itemCount: _filteredFacilities.length,
      itemBuilder: (context, index) {
        final facility = _filteredFacilities[index];
        return FacilityCardWidget(
          facility: facility,
          onTap: () => _showFacilityDetails(facility),
          onCall: () => _callFacility(facility),
          onDirections: () => _getDirections(facility),
          onFavorite: () => _toggleFavorite(facility),
        );
      },
    );
  }
}
