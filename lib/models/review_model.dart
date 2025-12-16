class Review {
  final String userId;
  final String userName;
  final double rating;
  final String comment;
  final DateTime timestamp;

  Review({
    required this.userId,
    required this.userName,
    required this.rating,
    required this.comment,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'rating': rating,
      'comment': comment,
      'timestamp': timestamp,
    };
  }
}