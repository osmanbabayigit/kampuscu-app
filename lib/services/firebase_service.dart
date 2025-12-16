import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/place_model.dart';
import '../models/review_model.dart';
import 'dart:math'; // Rastgele sayı üretmek için

class FirebaseService {
  final CollectionReference _placesRef =
  FirebaseFirestore.instance.collection('places');

  // 1. MEKANLARI ÇEKME
  Future<List<Place>> getPlaces() async {
    try {
      QuerySnapshot snapshot = await _placesRef.get();
      return snapshot.docs.map((doc) {
        return Place.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    } catch (e) {
      print("Veri çekme hatası: $e");
      return [];
    }
  }

  // 2. YORUM GÖNDERME
  Future<void> submitReview(String placeId, Review review) async {
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference placeRef = _placesRef.doc(placeId);
      DocumentSnapshot placeSnapshot = await transaction.get(placeRef);

      if (!placeSnapshot.exists) throw Exception("Mekan bulunamadı!");

      Map<String, dynamic> data = placeSnapshot.data() as Map<String, dynamic>;
      double oldRating = (data['rating'] as num? ?? 0.0).toDouble();
      int reviewCount = (data['reviewCount'] as num? ?? 0).toInt();

      double newTotalRating = (oldRating * reviewCount) + review.rating;
      int newReviewCount = reviewCount + 1;
      double newAverageRating = newTotalRating / newReviewCount;

      await placeRef.collection('reviews').add(review.toMap());

      transaction.update(placeRef, {
        'rating': newAverageRating,
        'reviewCount': newReviewCount,
      });
    });
  }

  // 3. YORUMLARI ÇEKME
  Future<List<Review>> getReviews(String placeId) async {
    try {
      QuerySnapshot snapshot = await _placesRef
          .doc(placeId)
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Review(
          userId: data['userId'],
          userName: data['userName'],
          rating: (data['rating'] as num? ?? 0.0).toDouble(),
          comment: data['comment'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print("Yorum çekme hatası: $e");
      return [];
    }
  }

  // 4. KULLANICI YORUMLARI
  Future<List<Review>> getUserReviews(String userId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collectionGroup('reviews')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return Review(
          userId: data['userId'],
          userName: data['userName'],
          rating: (data['rating'] as num? ?? 0.0).toDouble(),
          comment: data['comment'] ?? '',
          timestamp: (data['timestamp'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print("Kullanıcı yorumları hatası: $e");
      return [];
    }
  }



  Future<void> uploadCategoryBasedReviews() async {
    final List<String> restaurantComments = [
      "Yemekler efsane, bayıldım! 😋",
      "Porsiyonlar gayet doyurucu.",
      "Servis hızlıydı.",
      "Arkadaşlarımla geldik, memnun kaldık.",
      "Sivas'ta yediğim en iyi yemeklerden.",
      "Öğle arası için ideal.",
      "Lezzet 10/10.",
    ];

    final List<String> cafeComments = [
      "Ders çalışmak için harika bir ortam. 📚",
      "Kahveleri taze.",
      "İnterneti hızlı.",
      "Ortam çok keyifli.",
      "Priz sorunu yok.",
      "Arkadaşlarla sohbet için iyi.",
      "Çayları taze.",
    ];

    final List<String> generalComments = [
      "Hizmet kalitesi yerinde.",
      "Konumu çok merkezi.",
      "Temiz ve düzenli.",
      "Beklediğimden iyiydi.",
      "Fiyatlar uygun.",
    ];

    final List<String> dummyNames = [
      "Ahmet Y.",
      "Ayşe K.",
      "Mehmet T.",
      "Zeynep B.",
      "Ali V.",
      "Fatma S.",
      "Burak D.",
      "Selin A."
    ];

    QuerySnapshot placesSnapshot = await _placesRef.get();
    Random random = Random();

    for (var doc in placesSnapshot.docs) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      String category = data['category'] ?? 'all';

      List<String> targetComments;
      if (category == 'restaurant') {
        targetComments = restaurantComments;
      } else if (category == 'cafe' || category == 'faculty') {
        targetComments = cafeComments;
      } else {
        targetComments = generalComments;
      }

      // 🔥 AYAR: Her mekana sadece 1, 2 veya 3 yorum at.
      int reviewCountToAdd = 1 + random.nextInt(3);

      for (var i = 0; i < reviewCountToAdd; i++) {
        await _placesRef.doc(doc.id).collection('reviews').add({
          'userId': 'bot_user_$i',
          'userName': dummyNames[random.nextInt(dummyNames.length)],
          'rating': 3.5 + (random.nextDouble() * 1.5), // 3.5 - 5.0 arası puan
          'comment': targetComments[random.nextInt(targetComments.length)],
          'timestamp':
          DateTime.now().subtract(Duration(days: random.nextInt(30))),
        });
      }
      print(
          "${data['name']} ($category) için $reviewCountToAdd adet yorum eklendi.");
    }
    print("--- AZ SAYIDA AKILLI YORUM YÜKLENDİ! 🚀 ---");
  }
}
