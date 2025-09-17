import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class FacilitySearchBar extends StatefulWidget {
  final String? initialQuery;
  final Function(String) onSearchChanged;
  final VoidCallback? onFilterTap;
  final List<String> suggestions;

  const FacilitySearchBar({
    Key? key,
    this.initialQuery,
    required this.onSearchChanged,
    this.onFilterTap,
    this.suggestions = const [],
  }) : super(key: key);

  @override
  State<FacilitySearchBar> createState() => _FacilitySearchBarState();
}

class _FacilitySearchBarState extends State<FacilitySearchBar> {
  late TextEditingController _searchController;
  bool _showSuggestions = false;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.initialQuery);
    _searchController.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _showSuggestions = false;
        _filteredSuggestions = [];
      } else {
        _filteredSuggestions = widget.suggestions
            .where((suggestion) => suggestion.toLowerCase().contains(query))
            .take(5)
            .toList();
        _showSuggestions = _filteredSuggestions.isNotEmpty;
      }
    });
    widget.onSearchChanged(_searchController.text);
  }

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    setState(() {
      _showSuggestions = false;
    });
    widget.onSearchChanged(suggestion);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: isDark
                ? AppTheme.surfaceElevatedDark
                : AppTheme.surfaceElevatedLight,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search hospitals, pharmacies, clinics...',
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(3.w),
                      child: CustomIconWidget(
                        iconName: 'search',
                        color: isDark
                            ? AppTheme.textSecondaryDark
                            : AppTheme.textSecondaryLight,
                        size: 5.w,
                      ),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _showSuggestions = false;
                              });
                            },
                            icon: CustomIconWidget(
                              iconName: 'clear',
                              color: isDark
                                  ? AppTheme.textSecondaryDark
                                  : AppTheme.textSecondaryLight,
                              size: 5.w,
                            ),
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                  onTap: () {
                    if (_filteredSuggestions.isNotEmpty) {
                      setState(() {
                        _showSuggestions = true;
                      });
                    }
                  },
                ),
              ),
              if (widget.onFilterTap != null) ...[
                Container(
                  width: 1,
                  height: 6.h,
                  color: isDark
                      ? AppTheme.borderSubtleDark
                      : AppTheme.borderSubtleLight,
                ),
                IconButton(
                  onPressed: widget.onFilterTap,
                  icon: CustomIconWidget(
                    iconName: 'tune',
                    color:
                        isDark ? AppTheme.primaryDark : AppTheme.primaryLight,
                    size: 5.w,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_showSuggestions) _buildSuggestionsList(),
      ],
    );
  }

  Widget _buildSuggestionsList() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      decoration: BoxDecoration(
        color: isDark
            ? AppTheme.surfaceElevatedDark
            : AppTheme.surfaceElevatedLight,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppTheme.shadowDark : AppTheme.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _filteredSuggestions.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color:
              isDark ? AppTheme.borderSubtleDark : AppTheme.borderSubtleLight,
        ),
        itemBuilder: (context, index) {
          final suggestion = _filteredSuggestions[index];
          return ListTile(
            leading: CustomIconWidget(
              iconName: 'search',
              color: isDark
                  ? AppTheme.textSecondaryDark
                  : AppTheme.textSecondaryLight,
              size: 4.w,
            ),
            title: Text(
              suggestion,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            onTap: () => _selectSuggestion(suggestion),
            dense: true,
          );
        },
      ),
    );
  }
}
