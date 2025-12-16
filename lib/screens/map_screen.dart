import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/constants/app_colors.dart';
import '../../services/firebase_service.dart';
import '../../models/place_model.dart';
import '../../widgets/place_detail_sheet.dart';

// --- MARKER OLUŞTURUCU ---
Future<Uint8List> getBytesFromCanvas(String text, IconData iconData, Color color) async {
  final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(pictureRecorder);


  const int iconSize = 80;
  const int textPadding = 15;

  TextPainter textPainter = TextPainter(textDirection: TextDirection.ltr);
  String displayText = text.length > 20 ? "${text.substring(0, 18)}..." : text;

  textPainter.text = TextSpan(
    text: displayText,
    style: const TextStyle(fontSize: 20, color: Colors.black, fontWeight: FontWeight.bold),
  );
  textPainter.layout();

  final double boxWidth = textPainter.width + 30;
  final double boxHeight = textPainter.height + 15;

  final double totalCanvasWidth = boxWidth > iconSize ? boxWidth : iconSize.toDouble();
  final double totalCanvasHeight = iconSize + textPadding + boxHeight + 10;

  final double iconOffsetLeft = (totalCanvasWidth - iconSize) / 2;
  final double boxOffsetLeft = (totalCanvasWidth - boxWidth) / 2;
  final double boxOffsetTop = iconSize.toDouble() + textPadding;

  final Paint circlePaint = Paint()..color = color;
  final Paint borderPaint = Paint()..color = Colors.white..style = PaintingStyle.stroke..strokeWidth = 4;

  canvas.drawCircle(Offset(iconOffsetLeft + iconSize / 2, iconSize / 2), iconSize / 2, circlePaint);
  canvas.drawCircle(Offset(iconOffsetLeft + iconSize / 2, iconSize / 2), iconSize / 2, borderPaint);

  TextPainter iconSymbolPainter = TextPainter(textDirection: TextDirection.ltr);
  iconSymbolPainter.text = TextSpan(
    text: String.fromCharCode(iconData.codePoint),
    style: TextStyle(fontSize: iconSize * 0.5, fontFamily: iconData.fontFamily, color: Colors.white),
  );
  iconSymbolPainter.layout();
  iconSymbolPainter.paint(
      canvas,
      Offset(iconOffsetLeft + (iconSize - iconSymbolPainter.width) / 2, (iconSize - iconSymbolPainter.height) / 2)
  );

  if (text.isNotEmpty) {
    final Paint boxPaint = Paint()..color = Colors.white;
    final Paint boxBorderPaint = Paint()..color = Colors.grey.shade300..style = PaintingStyle.stroke..strokeWidth = 2;

    final RRect boxRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(boxOffsetLeft, boxOffsetTop, boxWidth, boxHeight),
      const Radius.circular(15),
    );

    canvas.drawRRect(boxRect, boxPaint);
    canvas.drawRRect(boxRect, boxBorderPaint);

    textPainter.paint(
        canvas,
        Offset(boxOffsetLeft + 15, boxOffsetTop + 7.5)
    );
  }

  final img = await pictureRecorder.endRecording().toImage(totalCanvasWidth.toInt(), totalCanvasHeight.toInt());
  final data = await img.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

Map<String, dynamic> getCategoryStyle(String category) {
  switch (category) {
    case 'restaurant': return {'icon': Icons.restaurant, 'color': const Color(0xFFFF7043)};
    case 'cafe':       return {'icon': Icons.local_cafe, 'color': const Color(0xFFFFA726)};
    case 'faculty':    return {'icon': Icons.school, 'color': const Color(0xFF42A5F5)};
    case 'dorm':       return {'icon': Icons.bed, 'color': const Color(0xFF7E57C2)};
    case 'health':     return {'icon': Icons.local_hospital, 'color': const Color(0xFFEF5350)};
    case 'market':     return {'icon': Icons.shopping_cart, 'color': const Color(0xFF66BB6A)};
    case 'atm':        return {'icon': Icons.atm, 'color': const Color(0xFF26A69A)};
    case 'stop':       return {'icon': Icons.directions_bus, 'color': const Color(0xFF5C6BC0)};
    case 'user':       return {'icon': Icons.person_pin_circle, 'color': AppColors.scuRed};
    default:           return {'icon': Icons.location_on, 'color': Colors.grey};
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  Set<Marker> _markers = {};
  Set<Marker> _placeMarkers = {};
  Marker? _userMarker;
  String _selectedCategory = 'all';
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  // 🔥 DÜZELTME: Zoom seviyesi arttırıldı (15 -> 16.5) - Daha yakın başlayacak
  static const CameraPosition _initialPosition = CameraPosition(
    target: LatLng(39.7062, 37.0260),
    zoom: 16.5,
  );

  final String _mapStyle = '''[
    { "featureType": "poi", "stylers": [{"visibility": "off"}] },
    { "featureType": "transit", "stylers": [{"visibility": "off"}] },
    { "featureType": "road", "elementType": "labels.icon", "stylers": [{"visibility": "off"}] }
  ]''';

  @override
  void initState() {
    super.initState();
    _getUserLocation(moveCamera: false);
    _loadPlaces();
    _searchController.addListener(() {
      if (_searchText != _searchController.text) {
        setState(() => _searchText = _searchController.text);
        _filterPlaces();
      }
    });
  }

  Future<void> _getUserLocation({bool moveCamera = true}) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    final style = getCategoryStyle('user');
    final BitmapDescriptor userIcon = BitmapDescriptor.fromBytes(
        await getBytesFromCanvas("Sen", style['icon'], style['color'])
    );

    setState(() {
      _userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: LatLng(position.latitude, position.longitude),
        icon: userIcon,
        zIndex: 2,
      );
      _updateAllMarkers();
    });

    if (moveCamera && _mapController != null) {
      _mapController!.animateCamera(CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 16.5));
    }
  }

  void _loadPlaces() async {
    List<Place> allPlaces = await _firebaseService.getPlaces();
    Set<Marker> tempPlaceMarkers = {};

    for (var place in allPlaces) {
      final style = getCategoryStyle(place.category);
      final Uint8List markerBytes = await getBytesFromCanvas(place.name, style['icon'], style['color']);
      final BitmapDescriptor customIcon = BitmapDescriptor.fromBytes(markerBytes);

      tempPlaceMarkers.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.latitude, place.longitude),
          icon: customIcon,
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => PlaceDetailSheet(place: place),
            );
          },
        ),
      );
    }

    if (mounted) {
      setState(() {
        _placeMarkers = tempPlaceMarkers;
        _filterPlaces();
      });
    }
  }

  void _filterPlaces() async {
    List<Place> allPlaces = await _firebaseService.getPlaces();
    Set<Marker> filtered = {};

    for (var place in allPlaces) {
      if (_selectedCategory != 'all' && place.category != _selectedCategory) continue;
      if (_searchText.isNotEmpty && !place.name.toLowerCase().contains(_searchText.toLowerCase())) continue;

      final style = getCategoryStyle(place.category);
      final Uint8List markerBytes = await getBytesFromCanvas(place.name, style['icon'], style['color']);

      filtered.add(
        Marker(
          markerId: MarkerId(place.id),
          position: LatLng(place.latitude, place.longitude),
          icon: BitmapDescriptor.fromBytes(markerBytes),
          onTap: () => showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => PlaceDetailSheet(place: place),
          ),
        ),
      );
    }

    setState(() {
      _placeMarkers = filtered;
      _updateAllMarkers();
    });
  }

  void _updateAllMarkers() {
    Set<Marker> finalMarkers = Set.from(_placeMarkers);
    if (_userMarker != null) finalMarkers.add(_userMarker!);
    _markers = finalMarkers;
  }

  Widget _buildFilterChip(String category, String label, IconData icon) {
    bool isSelected = _selectedCategory == category;
    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: GestureDetector(
        onTap: () {
          if (isSelected) return;
          setState(() => _selectedCategory = category);
          _filterPlaces();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.scuRed : Colors.white,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: isSelected ? AppColors.scuRed.withOpacity(0.4) : Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 3),
              )
            ],
            border: isSelected ? null : Border.all(color: Colors.grey.shade300),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isSelected ? Colors.white : AppColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            markers: _markers,
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            mapType: MapType.normal,
            zoomControlsEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              controller.setMapStyle(_mapStyle);
            },
          ),
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Kampüste ne arıyorsun?',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.scuRed),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Tümü', Icons.layers_outlined),
                      _buildFilterChip('restaurant', 'Yemek', Icons.restaurant_menu),
                      _buildFilterChip('cafe', 'Kafe', Icons.local_cafe_outlined),
                      _buildFilterChip('faculty', 'Fakülte', Icons.school_outlined),
                      _buildFilterChip('dorm', 'Yurt', Icons.bed_outlined),
                      _buildFilterChip('health', 'Sağlık', Icons.local_hospital_outlined),
                      _buildFilterChip('market', 'Market', Icons.shopping_cart_outlined),
                      _buildFilterChip('atm', 'ATM', Icons.atm),
                      _buildFilterChip('stop', 'Durak', Icons.directions_bus_filled_outlined),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: FloatingActionButton(
          onPressed: () async { await _getUserLocation(moveCamera: true); },
          backgroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: const Icon(Icons.my_location, color: AppColors.textPrimary),
        ),
      ),
    );
  }
}