class UserModel {
  final String uid;
  final String email;
  final String username;
  final String userType; // 'brand' or 'creator'
  final String profileImage;
  final String bio;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.userType,
    this.profileImage = '',
    this.bio = '',
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'userType': userType,
      'profileImage': profileImage,
      'bio': bio,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      username: json['username'],
      userType: json['userType'],
      profileImage: json['profileImage'] ?? '',
      bio: json['bio'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
