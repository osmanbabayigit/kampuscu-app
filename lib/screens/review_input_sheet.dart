import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:firebase_auth/firebase_auth.dart'; // FirebaseAuth eklendi
import '../core/constants/app_colors.dart';
import '../services/firebase_service.dart';
import '../models/review_model.dart';

class ReviewInputSheet extends StatefulWidget {
  final String placeId;

  const ReviewInputSheet({super.key, required this.placeId});

  @override
  State<ReviewInputSheet> createState() => _ReviewInputSheetState();
}

class _ReviewInputSheetState extends State<ReviewInputSheet> {
  final TextEditingController _commentController = TextEditingController();
  double _currentRating = 3.0;
  final FirebaseService _service = FirebaseService();
  bool _isLoading = false;

  void _submit() async {
    if (_commentController.text.isEmpty || _currentRating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Yorum ve puan boş bırakılamaz.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    //Gerçek Kullanıcı Bilgilerini Alıyoruz
    final user = FirebaseAuth.instance.currentUser;
    final String currentUserId = user?.uid ?? 'guest';
    // Eğer isim yoksa e-postanın başını al, o da yoksa Misafir yaz
    final String currentUserName = user?.displayName ?? user?.email?.split('@')[0] ?? 'Misafir Kullanıcı';

    final newReview = Review(
      userId: currentUserId,
      userName: currentUserName, // Artık gerçek isim gidiyor!
      rating: _currentRating,
      comment: _commentController.text,
      timestamp: DateTime.now(),
    );

    try {
      await _service.submitReview(widget.placeId, newReview);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Yorumunuz başarıyla gönderildi!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        // ...
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text("Puan Ver ve Yorum Yap", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 20),

          Center(
            child: RatingBar.builder(
              initialRating: _currentRating,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              itemCount: 5,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              itemBuilder: (context, _) => const Icon(Icons.star_rounded, color: Colors.amber), // İkonu yumuşattım
              onRatingUpdate: (rating) { _currentRating = rating; },
            ),
          ),
          const SizedBox(height: 20),

          TextField(
            controller: _commentController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Deneyimini diğer öğrencilerle paylaş...",
              filled: true,
              fillColor: AppColors.inputFill,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _isLoading ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.scuRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text("Yorumu Paylaş", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}