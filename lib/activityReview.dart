import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ActivityReview {
  final String userId;
  final String comment;
  final int rating;

  ActivityReview({
    required this.userId,
    required this.comment,
    required this.rating,
  });

  factory ActivityReview.fromMap(Map<String, dynamic> data) {
    return ActivityReview(
      userId: data['userId'] ?? '',
      comment: data['comment'] ?? '',
      rating: data['rating'] ?? 0,
    );
  }
}
