import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../models/review_model.dart';
import '../core/constants/app_colors.dart';

class ReviewListWidget extends StatelessWidget {
  final String placeId;
  const ReviewListWidget({super.key, required this.placeId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Review>>(
      future: FirebaseService().getReviews(placeId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.scuRed));
        if (snapshot.hasError) return Center(child: Text('Yüklenemedi: ${snapshot.error}'));
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.inputFill, borderRadius: BorderRadius.circular(16)), child: const Center(child: Text('Henüz yorum yok. İlk yorumu sen yap!', style: TextStyle(color: AppColors.textSecondary))));
        }

        return ListView.builder(
          shrinkWrap: true,
          // KAYDIRMA ÖZELLİĞİNİ AÇTIK (Parent SingleChildScrollView olduğu için NeverScrollable da olur ama güvenli olsun diye physics kapalı, parent kaydıracak)
          physics: const NeverScrollableScrollPhysics(),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final review = snapshot.data![index];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    CircleAvatar(radius: 16, backgroundColor: AppColors.scuRed.withOpacity(0.2), child: Text(review.userName.isNotEmpty ? review.userName[0].toUpperCase() : '?', style: const TextStyle(color: AppColors.scuRed, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 10),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(review.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text("${review.timestamp.day}.${review.timestamp.month}.${review.timestamp.year}", style: const TextStyle(fontSize: 10, color: Colors.grey))])
                  ]),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.amber.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Row(children: [const Icon(Icons.star, size: 14, color: Colors.amber), const SizedBox(width: 4), Text(review.rating.toString(), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.deepOrange))]))
                ]),
                const SizedBox(height: 12),
                Text(review.comment, style: const TextStyle(color: AppColors.textPrimary, height: 1.4))
              ]),
            );
          },
        );
      },
    );
  }
}