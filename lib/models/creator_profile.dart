import 'package:cloud_firestore/cloud_firestore.dart';

class CreatorProfile {
  final String uid;
  final String email;
  String displayName;
  String? photoUrl;
  String? bio;
  final DateTime createdAt;
  DateTime updatedAt;

  CreatorProfile({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static CreatorProfile fromMap(Map<String, dynamic> map) {
    return CreatorProfile(
      uid: map['uid'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String,
      photoUrl: map['photoUrl'] as String?,
      bio: map['bio'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  CreatorProfile copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
  }) {
    return CreatorProfile(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}
