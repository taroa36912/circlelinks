import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class LocationSection extends StatefulWidget {
  final TextEditingController locationController;
  final LatLng? selectedLocation;
  final Function(LatLng?) onLocationChanged;

  const LocationSection({
    super.key,
    required this.locationController,
    required this.selectedLocation,
    required this.onLocationChanged,
  });

  @override
  State<LocationSection> createState() => _LocationSectionState();
}

class _LocationSectionState extends State<LocationSection> {
  bool _showMap = false;
  GoogleMapController? _mapController;

  final List<Map<String, dynamic>> suggestedLocations = [
    {
      'name': '大学第1体育館',
      'address': '東京都渋谷区神南1-1-1',
      'location': const LatLng(35.6586, 139.7016),
      'type': 'university',
    },
    {
      'name': '学生会館',
      'address': '東京都渋谷区神南1-2-1',
      'location': const LatLng(35.6596, 139.7026),
      'type': 'university',
    },
    {
      'name': 'カラオケ館 渋谷店',
      'address': '東京都渋谷区道玄坂2-3-1',
      'location': const LatLng(35.6580, 139.6989),
      'type': 'entertainment',
    },
    {
      'name': '居酒屋 鳥貴族 渋谷店',
      'address': '東京都渋谷区宇田川町25-4',
      'location': const LatLng(35.6615, 139.6982),
      'type': 'restaurant',
    },
    {
      'name': '渋谷スカイ',
      'address': '東京都渋谷区渋谷2-24-12',
      'location': const LatLng(35.6598, 139.7036),
      'type': 'venue',
    },
  ];

  List<Map<String, dynamic>> _filteredLocations = [];

  @override
  void initState() {
    super.initState();
    _filteredLocations = suggestedLocations;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Padding(
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '場所',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                ),
                TextButton.icon(
                  onPressed: () => setState(() => _showMap = !_showMap),
                  icon: CustomIconWidget(
                    iconName: _showMap ? 'keyboard_arrow_up' : 'map',
                    color: AppTheme.lightTheme.colorScheme.primary,
                    size: 20,
                  ),
                  label: Text(
                    _showMap ? '地図を閉じる' : '地図で選択',
                    style: TextStyle(
                      color: AppTheme.lightTheme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),

            // Location Input with Autocomplete
            TextField(
              controller: widget.locationController,
              decoration: InputDecoration(
                labelText: '場所を入力',
                hintText: '例：大学体育館、カラオケ館',
                prefixIcon: Icon(
                  Icons.location_on_rounded,
                  color: AppTheme.lightTheme.colorScheme.primary,
                  size: 20,
                ),
                suffixIcon: widget.locationController.text.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          widget.locationController.clear();
                          widget.onLocationChanged(null);
                          setState(
                              () => _filteredLocations = suggestedLocations);
                        },
                        icon: CustomIconWidget(
                          iconName: 'clear',
                          color: AppTheme.textSecondary,
                          size: 20,
                        ),
                      )
                    : null,
              ),
              onChanged: _filterLocations,
            ),

            // Location Suggestions
            if (widget.locationController.text.isNotEmpty &&
                _filteredLocations.isNotEmpty) ...[
              SizedBox(height: 1.h),
              Container(
                constraints: BoxConstraints(maxHeight: 25.h),
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filteredLocations.length,
                  separatorBuilder: (context, index) => Divider(
                    height: 1,
                    color: AppTheme.outline.withValues(alpha: 0.3),
                  ),
                  itemBuilder: (context, index) {
                    final location = _filteredLocations[index];
                    return ListTile(
                      leading: Container(
                        width: 8.w,
                        height: 8.w,
                        decoration: BoxDecoration(
                          color: _getLocationTypeColor(location['type'])
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: _getLocationTypeIcon(location['type']),
                          color: _getLocationTypeColor(location['type']),
                          size: 18,
                        ),
                      ),
                      title: Text(
                        location['name'],
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      subtitle: Text(
                        location['address'],
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textSecondary,
                            ),
                      ),
                      onTap: () => _selectLocation(location),
                    );
                  },
                ),
              ),
            ],

            // Selected Location Display
            if (widget.selectedLocation != null) ...[
              SizedBox(height: 2.h),
              Container(
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.primaryContainer
                      .withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.lightTheme.colorScheme.primary
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CustomIconWidget(
                      iconName: 'location_on',
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '選択された場所',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color:
                                      AppTheme.lightTheme.colorScheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            widget.locationController.text,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          Text(
                            '緯度: ${widget.selectedLocation!.latitude.toStringAsFixed(4)}, 経度: ${widget.selectedLocation!.longitude.toStringAsFixed(4)}',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Map View
            if (_showMap) ...[
              SizedBox(height: 2.h),
              Container(
                height: 30.h,
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.outline),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: _buildMapPicker(),
                ),
              ),
            ],

            // Quick Location Buttons
            SizedBox(height: 2.h),
            Text(
              'よく使われる場所',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textPrimary,
                  ),
            ),
            SizedBox(height: 1.h),

            Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: suggestedLocations.take(4).map((location) {
                return GestureDetector(
                  onTap: () => _selectLocation(location),
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceVariant,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.outline),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CustomIconWidget(
                          iconName: _getLocationTypeIcon(location['type']),
                          color: _getLocationTypeColor(location['type']),
                          size: 16,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          location['name'],
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapPicker() {
    if (kIsWeb) {
      return Container(
        color: AppTheme.surfaceVariant,
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'map',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 32,
            ),
            SizedBox(height: 1.h),
            Text(
              'Web版では地図を表示できません',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 0.5.h),
            Text(
              '場所名の入力または下の候補から選択してください。',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: widget.selectedLocation ?? const LatLng(35.6586, 139.7016),
        zoom: 15,
      ),
      markers: _buildMapMarkers(),
      onMapCreated: (GoogleMapController controller) {
        _mapController = controller;
      },
      onTap: (LatLng location) {
        widget.onLocationChanged(location);
        widget.locationController.text =
            'カスタム位置 (${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)})';
        setState(() {});
      },
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      zoomControlsEnabled: true,
      mapToolbarEnabled: false,
    );
  }

  void _filterLocations(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredLocations = suggestedLocations;
      } else {
        _filteredLocations = suggestedLocations.where((location) {
          return location['name'].toLowerCase().contains(query.toLowerCase()) ||
              location['address'].toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _selectLocation(Map<String, dynamic> location) {
    widget.locationController.text = location['name'];
    widget.onLocationChanged(location['location']);
    setState(() => _filteredLocations = []);

    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(location['location'], 16),
      );
    }
  }

  Set<Marker> _buildMapMarkers() {
    final markers = <Marker>{};

    // Add selected location marker
    if (widget.selectedLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected_location'),
          position: widget.selectedLocation!,
          infoWindow: InfoWindow(
            title: 'イベント会場',
            snippet: widget.locationController.text,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );
    }

    // Add suggested location markers
    for (int i = 0; i < suggestedLocations.length; i++) {
      final location = suggestedLocations[i];
      markers.add(
        Marker(
          markerId: MarkerId('suggestion_$i'),
          position: location['location'],
          infoWindow: InfoWindow(
            title: location['name'],
            snippet: location['address'],
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            _getLocationTypeHue(location['type']),
          ),
          onTap: () => _selectLocation(location),
        ),
      );
    }

    return markers;
  }

  String _getLocationTypeIcon(String type) {
    switch (type) {
      case 'university':
        return 'school';
      case 'entertainment':
        return 'music_note';
      case 'restaurant':
        return 'restaurant';
      case 'venue':
        return 'place';
      default:
        return 'location_on';
    }
  }

  Color _getLocationTypeColor(String type) {
    switch (type) {
      case 'university':
        return AppTheme.lightTheme.colorScheme.primary;
      case 'entertainment':
        return AppTheme.lightTheme.colorScheme.secondary;
      case 'restaurant':
        return AppTheme.success;
      case 'venue':
        return AppTheme.warning;
      default:
        return AppTheme.textSecondary;
    }
  }

  double _getLocationTypeHue(String type) {
    switch (type) {
      case 'university':
        return BitmapDescriptor.hueBlue;
      case 'entertainment':
        return BitmapDescriptor.hueViolet;
      case 'restaurant':
        return BitmapDescriptor.hueGreen;
      case 'venue':
        return BitmapDescriptor.hueOrange;
      default:
        return BitmapDescriptor.hueRed;
    }
  }
}
