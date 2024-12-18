import 'package:cloud_firestore/cloud_firestore.dart';

class Reel {
  final String id;
  final String creatorId;
  final String videoUrl;
  final String? caption;
  final String? thumbnailUrl;
  final DateTime createdAt;
  final int likes;
  final int views;

  Reel({
    required this.id,
    required this.creatorId,
    required this.videoUrl,
    this.caption,
    this.thumbnailUrl,
    required this.createdAt,
    this.likes = 0,
    this.views = 0,
  });

  factory Reel.fromMap(Map<String, dynamic> map, String id) {
    // Handle createdAt field which could be a Timestamp or null
    DateTime parseCreatedAt() {
      final createdAt = map['createdAt'];
      if (createdAt == null) return DateTime.now();
      if (createdAt is Timestamp) return createdAt.toDate();
      return DateTime.now();
    }

    return Reel(
      id: id,
      creatorId: map['creatorId'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
      caption: map['caption'] as String?,
      thumbnailUrl: map['thumbnailUrl'] as String?,
      createdAt: parseCreatedAt(),
      likes: int.tryParse(map['likes']?.toString() ?? '0') ?? 0,
      views: int.tryParse(map['views']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'creatorId': creatorId,
      'videoUrl': videoUrl,
      'caption': caption,
      'thumbnailUrl': thumbnailUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'likes': likes.toString(),
      'views': views.toString(),
    };
  }
}
