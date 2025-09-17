import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class FacilityFilterModal extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final Function(Map<String, dynamic>) onFiltersChanged;

  const FacilityFilterModal({
    Key? key,
    required this.currentFilters,
    required this.onFiltersChanged,
  }) : super(key: key);

  @override
  State<FacilityFilterModal> createState() => _FacilityFilterModalState();
}

class _FacilityFilterModalState extends State<FacilityFilterModal> {
  late Map<String, dynamic> _filters;
  double _distanceRadius = 10.0;

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
    _distanceRadius = (_filters['distanceRadius'] as double?) ?? 10.0;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 80.h,
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
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Facilities',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text('Clear All'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Facility Type'),
                  SizedBox(height: 1.h),
                  _buildFacilityTypeFilters(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Distance'),
                  SizedBox(height: 1.h),
                  _buildDistanceSlider(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Availability'),
                  SizedBox(height: 1.h),
                  _buildAvailabilityFilters(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Insurance'),
                  SizedBox(height: 1.h),
                  _buildInsuranceFilters(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Languages'),
                  SizedBox(height: 1.h),
                  _buildLanguageFilters(),
                  SizedBox(height: 3.h),
                  _buildSectionTitle('Specialties'),
                  SizedBox(height: 1.h),
                  _buildSpecialtyFilters(),
                  SizedBox(height: 4.h),
                ],
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? AppTheme.borderSubtleDark
                      : AppTheme.borderSubtleLight,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                    ),
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: Text('Apply Filters'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
    );
  }

  Widget _buildFacilityTypeFilters() {
    final List<Map<String, String>> facilityTypes = [
      {'key': 'hospital', 'label': 'Hospitals'},
      {'key': 'urgent_care', 'label': 'Urgent Care'},
      {'key': 'pharmacy', 'label': 'Pharmacies'},
      {'key': 'specialist', 'label': 'Specialists'},
      {'key': 'clinic', 'label': 'Clinics'},
    ];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: facilityTypes.map((type) {
        final bool isSelected =
            (_filters['facilityTypes'] as List?)?.contains(type['key']) ??
                false;
        return FilterChip(
          label: Text(type['label']!),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final List<String> types =
                  List<String>.from(_filters['facilityTypes'] ?? []);
              if (selected) {
                types.add(type['key']!);
              } else {
                types.remove(type['key']!);
              }
              _filters['facilityTypes'] = types;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildDistanceSlider() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Within ${_distanceRadius.toInt()} km',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${_distanceRadius.toInt()} km',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Slider(
          value: _distanceRadius,
          min: 1.0,
          max: 50.0,
          divisions: 49,
          onChanged: (value) {
            setState(() {
              _distanceRadius = value;
              _filters['distanceRadius'] = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildAvailabilityFilters() {
    return Column(
      children: [
        CheckboxListTile(
          title: Text('Open Now'),
          value: _filters['openNow'] as bool? ?? false,
          onChanged: (value) {
            setState(() {
              _filters['openNow'] = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text('24/7 Available'),
          value: _filters['available24_7'] as bool? ?? false,
          onChanged: (value) {
            setState(() {
              _filters['available24_7'] = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
        CheckboxListTile(
          title: Text('Emergency Services'),
          value: _filters['emergencyServices'] as bool? ?? false,
          onChanged: (value) {
            setState(() {
              _filters['emergencyServices'] = value ?? false;
            });
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  Widget _buildInsuranceFilters() {
    final List<String> insuranceOptions = [
      'Medicare',
      'Medicaid',
      'Blue Cross Blue Shield',
      'Aetna',
      'Cigna',
      'UnitedHealth',
    ];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: insuranceOptions.map((insurance) {
        final bool isSelected =
            (_filters['insurance'] as List?)?.contains(insurance) ?? false;
        return FilterChip(
          label: Text(insurance),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final List<String> insuranceList =
                  List<String>.from(_filters['insurance'] ?? []);
              if (selected) {
                insuranceList.add(insurance);
              } else {
                insuranceList.remove(insurance);
              }
              _filters['insurance'] = insuranceList;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildLanguageFilters() {
    final List<String> languages = [
      'English',
      'Spanish',
      'French',
      'German',
      'Chinese',
      'Arabic',
    ];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: languages.map((language) {
        final bool isSelected =
            (_filters['languages'] as List?)?.contains(language) ?? false;
        return FilterChip(
          label: Text(language),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final List<String> languageList =
                  List<String>.from(_filters['languages'] ?? []);
              if (selected) {
                languageList.add(language);
              } else {
                languageList.remove(language);
              }
              _filters['languages'] = languageList;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildSpecialtyFilters() {
    final List<String> specialties = [
      'Cardiology',
      'Dermatology',
      'Neurology',
      'Orthopedics',
      'Pediatrics',
      'Psychiatry',
    ];

    return Wrap(
      spacing: 2.w,
      runSpacing: 1.h,
      children: specialties.map((specialty) {
        final bool isSelected =
            (_filters['specialties'] as List?)?.contains(specialty) ?? false;
        return FilterChip(
          label: Text(specialty),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              final List<String> specialtyList =
                  List<String>.from(_filters['specialties'] ?? []);
              if (selected) {
                specialtyList.add(specialty);
              } else {
                specialtyList.remove(specialty);
              }
              _filters['specialties'] = specialtyList;
            });
          },
        );
      }).toList(),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filters.clear();
      _distanceRadius = 10.0;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(_filters);
    Navigator.pop(context);
  }
}
