import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../services/firebase_service.dart';
import '../../../../models/place_model.dart';
import '../../../../widgets/custom_venue_card.dart';
import '../../../../widgets/place_detail_sheet.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final FirebaseService _firebaseService = FirebaseService();
  String selectedCategory = 'all';
  Future<List<Place>>? _placesFuture;

  final List<String> _categories = ['all', 'restaurant', 'cafe', 'faculty', 'dorm', 'health', 'market', 'atm', 'stop'];

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  void _fetchData() {
    setState(() {
      _placesFuture = _firebaseService.getPlaces();
    });
  }

  List<Place> _filterVenues(List<Place> allPlaces) {
    if (selectedCategory == 'all') return allPlaces;
    return allPlaces.where((p) => p.category == selectedCategory).toList();
  }

  void _showPlaceDetail(BuildContext context, Place place) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PlaceDetailSheet(place: place),
    );

  }

  // --- FİLTRE BUTONU TASARIMI ---
  Widget _buildFilterChip(String categoryKey) {
    bool isSelected = selectedCategory == categoryKey;

    String label = categoryKey.toUpperCase();
    IconData icon = Icons.category;

    switch (categoryKey) {
      case 'all': label = 'Tümü'; icon = Icons.layers_outlined; break;
      case 'restaurant': label = 'Yemek'; icon = Icons.restaurant_menu; break;
      case 'cafe': label = 'Kafe'; icon = Icons.local_cafe_outlined; break;
      case 'faculty': label = 'Fakülte'; icon = Icons.school_outlined; break;
      case 'dorm': label = 'Yurt'; icon = Icons.bed_outlined; break;
      case 'health': label = 'Sağlık'; icon = Icons.local_hospital_outlined; break;
      case 'market': label = 'Market'; icon = Icons.shopping_cart_outlined; break;
      case 'atm': label = 'ATM'; icon = Icons.atm; break;
      case 'stop': label = 'Durak'; icon = Icons.directions_bus_filled_outlined; break;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 10.0),
      child: GestureDetector(
        onTap: () {
          if (!isSelected) {
            setState(() => selectedCategory = categoryKey);
          }
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
    return FutureBuilder<List<Place>>(
      future: _placesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: AppColors.scuRed));
        }
        if (snapshot.hasError) {
          return Center(child: Text("Hata: ${snapshot.error}"));
        }

        final placeList = snapshot.data ?? [];
        final filteredVenues = _filterVenues(placeList);

        return Column(
          children: [
            // --- 1. BAŞLIK ALANI ---
            Container(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20,
                  right: 20,
                  bottom: 25
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.scuRed.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                      "KAMPÜSCÜ",
                      style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24, color: AppColors.textPrimary, letterSpacing: 1)
                  ),
                ],
              ),
            ),

            // --- 2. KATEGORİ LİSTESİ ---
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return _buildFilterChip(_categories[index]);
                },
              ),
            ),

            const SizedBox(height: 10),

            // --- 3. MEKAN LİSTESİ ---
            Expanded(
              child: filteredVenues.isEmpty
                  ? const Center(child: Text("Bu kategoride mekan bulunamadı."))
                  : ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 80),
                itemCount: filteredVenues.length,
                itemBuilder: (context, index) {
                  return CustomVenueCard(
                    place: filteredVenues[index],
                    onTap: () => _showPlaceDetail(context, filteredVenues[index]),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}