import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class MedicalFormWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onFormChanged;

  const MedicalFormWidget({
    Key? key,
    required this.onFormChanged,
  }) : super(key: key);

  @override
  State<MedicalFormWidget> createState() => _MedicalFormWidgetState();
}

class _MedicalFormWidgetState extends State<MedicalFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  DateTime? _selectedDate;
  String _selectedGender = '';
  String _selectedBloodType = '';
  String _heightUnit = 'cm';
  String _weightUnit = 'kg';
  bool _isHistoryExpanded = false;

  List<String> _medications = [];
  List<String> _allergies = [];
  List<String> _chronicConditions = [];

  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();

  final List<String> _bloodTypes = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-'
  ];

  final List<String> _commonConditions = [
    'Diabetes',
    'Hypertension',
    'Asthma',
    'Heart Disease',
    'Arthritis',
    'Depression',
    'Anxiety',
    'Allergies',
    'Migraine',
    'Thyroid Disorder'
  ];

  @override
  void initState() {
    super.initState();
    _fullNameController.addListener(_updateForm);
    _emergencyContactController.addListener(_updateForm);
    _heightController.addListener(_updateForm);
    _weightController.addListener(_updateForm);
    _medicalHistoryController.addListener(_updateForm);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emergencyContactController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _medicalHistoryController.dispose();
    _medicationController.dispose();
    _allergyController.dispose();
    super.dispose();
  }

  void _updateForm() {
    final formData = {
      'fullName': _fullNameController.text,
      'dateOfBirth': _selectedDate?.toIso8601String(),
      'gender': _selectedGender,
      'height': _heightController.text,
      'heightUnit': _heightUnit,
      'weight': _weightController.text,
      'weightUnit': _weightUnit,
      'bloodType': _selectedBloodType,
      'emergencyContact': _emergencyContactController.text,
      'medications': _medications,
      'allergies': _allergies,
      'chronicConditions': _chronicConditions,
      'medicalHistory': _medicalHistoryController.text,
    };
    widget.onFormChanged(formData);
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 365 * 25)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: AppTheme.lightTheme,
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _updateForm();
    }
  }

  void _addMedication() {
    if (_medicationController.text.isNotEmpty) {
      setState(() {
        _medications.add(_medicationController.text);
        _medicationController.clear();
      });
      _updateForm();
    }
  }

  void _removeMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
    _updateForm();
  }

  void _addAllergy() {
    if (_allergyController.text.isNotEmpty) {
      setState(() {
        _allergies.add(_allergyController.text);
        _allergyController.clear();
      });
      _updateForm();
    }
  }

  void _removeAllergy(int index) {
    setState(() {
      _allergies.removeAt(index);
    });
    _updateForm();
  }

  void _toggleCondition(String condition) {
    setState(() {
      if (_chronicConditions.contains(condition)) {
        _chronicConditions.remove(condition);
      } else {
        _chronicConditions.add(condition);
      }
    });
    _updateForm();
  }

  Widget _buildRequiredLabel(String text) {
    return RichText(
      text: TextSpan(
        text: text,
        style: AppTheme.lightTheme.textTheme.bodyMedium,
        children: [
          TextSpan(
            text: ' *',
            style: TextStyle(
              color: AppTheme.lightTheme.colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildRequiredLabel('Gender'),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = 'Male';
                  });
                  _updateForm();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'Male'
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.surface,
                    border: Border.all(
                      color: _selectedGender == 'Male'
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Male',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: _selectedGender == 'Male'
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = 'Female';
                  });
                  _updateForm();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'Female'
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.surface,
                    border: Border.all(
                      color: _selectedGender == 'Female'
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Female',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: _selectedGender == 'Female'
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedGender = 'Other';
                  });
                  _updateForm();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  decoration: BoxDecoration(
                    color: _selectedGender == 'Other'
                        ? AppTheme.lightTheme.colorScheme.primary
                        : AppTheme.lightTheme.colorScheme.surface,
                    border: Border.all(
                      color: _selectedGender == 'Other'
                          ? AppTheme.lightTheme.colorScheme.primary
                          : AppTheme.lightTheme.colorScheme.outline,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Other',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: _selectedGender == 'Other'
                            ? AppTheme.lightTheme.colorScheme.onPrimary
                            : AppTheme.lightTheme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMedicationsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Current Medications',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _medicationController,
                decoration: InputDecoration(
                  hintText: 'Enter medication name',
                  suffixIcon: IconButton(
                    onPressed: _addMedication,
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                onFieldSubmitted: (_) => _addMedication(),
              ),
            ),
          ],
        ),
        if (_medications.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _medications.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value),
                deleteIcon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 16,
                ),
                onDeleted: () => _removeMedication(entry.key),
                backgroundColor:
                    AppTheme.lightTheme.colorScheme.secondaryContainer,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildAllergiesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Known Allergies',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        SizedBox(height: 1.h),
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _allergyController,
                decoration: InputDecoration(
                  hintText: 'Enter allergy',
                  suffixIcon: IconButton(
                    onPressed: _addAllergy,
                    icon: CustomIconWidget(
                      iconName: 'add',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                  ),
                ),
                onFieldSubmitted: (_) => _addAllergy(),
              ),
            ),
          ],
        ),
        if (_allergies.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Wrap(
            spacing: 2.w,
            runSpacing: 1.h,
            children: _allergies.asMap().entries.map((entry) {
              return Chip(
                label: Text(entry.value),
                deleteIcon: CustomIconWidget(
                  iconName: 'close',
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                  size: 16,
                ),
                onDeleted: () => _removeAllergy(entry.key),
                backgroundColor:
                    AppTheme.lightTheme.colorScheme.secondaryContainer,
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildConditionsChecklist() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chronic Conditions',
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        SizedBox(height: 1.h),
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _commonConditions.map((condition) {
            final isSelected = _chronicConditions.contains(condition);
            return FilterChip(
              label: Text(condition),
              selected: isSelected,
              onSelected: (_) => _toggleCondition(condition),
              selectedColor: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.2),
              checkmarkColor: AppTheme.lightTheme.colorScheme.primary,
            );
          }).toList(),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Full Name
          _buildRequiredLabel('Full Name'),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _fullNameController,
            decoration: InputDecoration(
              hintText: 'Enter your full name',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          SizedBox(height: 3.h),

          // Date of Birth
          _buildRequiredLabel('Date of Birth'),
          SizedBox(height: 1.h),
          GestureDetector(
            onTap: _selectDate,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.lightTheme.colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
                color: AppTheme.lightTheme.colorScheme.surface,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _selectedDate != null
                        ? '${_selectedDate!.month}/${_selectedDate!.day}/${_selectedDate!.year}'
                        : 'Select date of birth',
                    style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                      color: _selectedDate != null
                          ? AppTheme.lightTheme.colorScheme.onSurface
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  CustomIconWidget(
                    iconName: 'calendar_today',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 3.h),

          // Gender
          _buildGenderSelector(),
          SizedBox(height: 3.h),

          // Height and Weight
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Height',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _heightController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]')),
                            ],
                            decoration: InputDecoration(
                              hintText: '170',
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _heightUnit,
                            decoration: InputDecoration(),
                            items: ['cm', 'ft'].map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _heightUnit = value!;
                              });
                              _updateForm();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Weight',
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _weightController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                  RegExp(r'[0-9.]')),
                            ],
                            decoration: InputDecoration(
                              hintText: '70',
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _weightUnit,
                            decoration: InputDecoration(),
                            items: ['kg', 'lbs'].map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _weightUnit = value!;
                              });
                              _updateForm();
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Blood Type
          Text(
            'Blood Type',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          SizedBox(height: 1.h),
          DropdownButtonFormField<String>(
            value: _selectedBloodType.isEmpty ? null : _selectedBloodType,
            decoration: InputDecoration(
              hintText: 'Select blood type',
            ),
            items: _bloodTypes.map((bloodType) {
              return DropdownMenuItem(
                value: bloodType,
                child: Text(bloodType),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBloodType = value ?? '';
              });
              _updateForm();
            },
          ),
          SizedBox(height: 3.h),

          // Emergency Contact
          _buildRequiredLabel('Emergency Contact'),
          SizedBox(height: 1.h),
          TextFormField(
            controller: _emergencyContactController,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              hintText: 'Enter emergency contact number',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter emergency contact';
              }
              return null;
            },
          ),
          SizedBox(height: 3.h),

          // Medications
          _buildMedicationsList(),
          SizedBox(height: 3.h),

          // Allergies
          _buildAllergiesList(),
          SizedBox(height: 3.h),

          // Chronic Conditions
          _buildConditionsChecklist(),
          SizedBox(height: 3.h),

          // Medical History
          ExpansionTile(
            title: Text(
              'Medical History',
              style: AppTheme.lightTheme.textTheme.bodyMedium,
            ),
            initiallyExpanded: _isHistoryExpanded,
            onExpansionChanged: (expanded) {
              setState(() {
                _isHistoryExpanded = expanded;
              });
            },
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w),
                child: TextFormField(
                  controller: _medicalHistoryController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText:
                        'Describe any relevant medical history, surgeries, or conditions...',
                    alignLabelWithHint: true,
                  ),
                ),
              ),
              SizedBox(height: 2.h),
            ],
          ),
        ],
      ),
    );
  }
}
