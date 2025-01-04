import '../models/user.dart';

class Post {
  Post({
    this.id,
    required this.userId,
    required this.description,
    this.image,
    this.like,
    this.createdAt,
    this.comment,
    required this.user,
  });

  final int? id;
  final String userId;
  final String? description;
  final String? image;
  final int? like;
  final DateTime? createdAt;
  final dynamic comment;
  final User user;

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json["id"],
      userId: json["userId"],
      description: json["description"],
      image: json["image"],
      like: json["like"],
      createdAt: DateTime.parse(json["createdAt"]),
      comment: json["comment"],
      user: User.fromJson(json["user"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userId": userId,
        "description": description,
        "image": image,
        "like": like,
        "createdAt": createdAt?.toIso8601String(),
        "comment": comment,
        "user": user.toJson(),
      };
}
