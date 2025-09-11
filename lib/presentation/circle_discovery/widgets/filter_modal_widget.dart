import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class FilterModalWidget extends StatefulWidget {
  final Map<String, dynamic> currentFilters;
  final ValueChanged<Map<String, dynamic>>? onFiltersChanged;

  const FilterModalWidget({
    super.key,
    required this.currentFilters,
    this.onFiltersChanged,
  });

  @override
  State<FilterModalWidget> createState() => _FilterModalWidgetState();
}

class _FilterModalWidgetState extends State<FilterModalWidget> {
  late Map<String, dynamic> _filters;
  final List<String> _universities = [
    'Tokyo University',
    'Waseda University',
    'Keio University',
    'Sophia University',
    'Meiji University',
    'Rikkyo University',
  ];

  final List<String> _activityTypes = [
    'Sports',
    'Cultural',
    'Academic',
    'Volunteer',
    'Music',
    'Art',
    'Technology',
    'Language',
  ];

  final List<String> _skills = [
    'Leadership',
    'Planning',
    'Creative',
    'Mood Maker',
    'Communication',
    'Organization',
    'Design',
    'Marketing',
  ];

  @override
  void initState() {
    super.initState();
    _filters = Map<String, dynamic>.from(widget.currentFilters);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 90.h,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: EdgeInsets.symmetric(vertical: 2.h),
            decoration: BoxDecoration(
              color: colorScheme.outline,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                Text(
                  'Filters',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearAllFilters,
                  child: Text(
                    'Clear All',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Divider(color: colorScheme.outline),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildUniversitySection(theme, colorScheme),
                  SizedBox(height: 3.h),
                  _buildActivityTypeSection(theme, colorScheme),
                  SizedBox(height: 3.h),
                  _buildCircleSizeSection(theme, colorScheme),
                  SizedBox(height: 3.h),
                  _buildSkillsSection(theme, colorScheme),
                  SizedBox(height: 3.h),
                ],
              ),
            ),
          ),

          // Apply Button
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(
                top: BorderSide(color: colorScheme.outline, width: 1),
              ),
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                  ),
                  child: Text(
                    'Apply Filters',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUniversitySection(ThemeData theme, ColorScheme colorScheme) {
    return ExpansionTile(
      title: Text(
        'University',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      initiallyExpanded: true,
      children: [
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _universities.map((university) {
            final isSelected = (_filters['universities'] as List<String>? ?? [])
                .contains(university);
            return FilterChip(
              label: Text(university),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final universities =
                      _filters['universities'] as List<String>? ?? <String>[];
                  if (selected) {
                    universities.add(university);
                  } else {
                    universities.remove(university);
                  }
                  _filters['universities'] = universities;
                });
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildActivityTypeSection(ThemeData theme, ColorScheme colorScheme) {
    return ExpansionTile(
      title: Text(
        'Activity Type',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      initiallyExpanded: true,
      children: [
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _activityTypes.map((type) {
            final isSelected =
                (_filters['activityTypes'] as List<String>? ?? [])
                    .contains(type);
            return FilterChip(
              label: Text(type),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final types =
                      _filters['activityTypes'] as List<String>? ?? <String>[];
                  if (selected) {
                    types.add(type);
                  } else {
                    types.remove(type);
                  }
                  _filters['activityTypes'] = types;
                });
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCircleSizeSection(ThemeData theme, ColorScheme colorScheme) {
    return ExpansionTile(
      title: Text(
        'Circle Size',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Column(
          children: [
            Text(
              'Member Count: ${(_filters['minMembers'] as int? ?? 0)} - ${(_filters['maxMembers'] as int? ?? 100)}',
              style: theme.textTheme.bodyMedium,
            ),
            RangeSlider(
              values: RangeValues(
                (_filters['minMembers'] as int? ?? 0).toDouble(),
                (_filters['maxMembers'] as int? ?? 100).toDouble(),
              ),
              min: 0,
              max: 100,
              divisions: 20,
              labels: RangeLabels(
                (_filters['minMembers'] as int? ?? 0).toString(),
                (_filters['maxMembers'] as int? ?? 100).toString(),
              ),
              onChanged: (values) {
                setState(() {
                  _filters['minMembers'] = values.start.round();
                  _filters['maxMembers'] = values.end.round();
                });
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSkillsSection(ThemeData theme, ColorScheme colorScheme) {
    return ExpansionTile(
      title: Text(
        'Required Skills',
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Wrap(
          spacing: 2.w,
          runSpacing: 1.h,
          children: _skills.map((skill) {
            final isSelected =
                (_filters['skills'] as List<String>? ?? []).contains(skill);
            return FilterChip(
              label: Text(skill),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final skills =
                      _filters['skills'] as List<String>? ?? <String>[];
                  if (selected) {
                    skills.add(skill);
                  } else {
                    skills.remove(skill);
                  }
                  _filters['skills'] = skills;
                });
              },
              selectedColor: colorScheme.primaryContainer,
              checkmarkColor: colorScheme.onPrimaryContainer,
            );
          }).toList(),
        ),
      ],
    );
  }

  void _clearAllFilters() {
    setState(() {
      _filters = {
        'universities': <String>[],
        'activityTypes': <String>[],
        'skills': <String>[],
        'minMembers': 0,
        'maxMembers': 100,
      };
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged?.call(_filters);
    Navigator.pop(context);
  }
}
