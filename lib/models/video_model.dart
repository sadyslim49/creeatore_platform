class VideoModel {
  final String id;
  final String creatorId;
  final String brandId;
  final String videoUrl;
  final String thumbnailUrl;
  final String title;
  final String description;
  final String status; // 'pending', 'accepted', 'rejected'
  final DateTime createdAt;
  final int views;
  final List<String> likes;
  final bool isActive;

  VideoModel({
    required this.id,
    required this.creatorId,
    required this.brandId,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
    this.views = 0,
    required this.likes,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creatorId': creatorId,
      'brandId': brandId,
      'videoUrl': videoUrl,
      'thumbnailUrl': thumbnailUrl,
      'title': title,
      'description': description,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'views': views,
      'likes': likes,
      'isActive': isActive,
    };
  }

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'],
      creatorId: json['creatorId'],
      brandId: json['brandId'],
      videoUrl: json['videoUrl'],
      thumbnailUrl: json['thumbnailUrl'],
      title: json['title'],
      description: json['description'],
      status: json['status'],
      createdAt: DateTime.parse(json['createdAt']),
      views: json['views'] ?? 0,
      likes: List<String>.from(json['likes'] ?? []),
      isActive: json['isActive'] ?? true,
    );
  }
}
