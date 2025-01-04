import '../models/post.dart';

class User {
  User({
    this.id,
    required this.userName,
    required this.email,
    this.avatar,
    this.initials,
    this.birthDay,
    this.markers,
    this.normalizedUserName,
    this.normalizedEmail,
    this.emailConfirmed,
    this.passwordHash,
    this.securityStamp,
    this.concurrencyStamp,
    this.phoneNumber,
    this.phoneNumberConfirmed,
    this.twoFactorEnabled,
    this.lockoutEnd,
    this.lockoutEnabled,
    this.accessFailedCount,
    this.posts,
  });

  final String? id;
  final String userName;
  final String email;
  final String? avatar;
  final String? initials;
  final DateTime? birthDay;
  final dynamic markers;
  final String? normalizedUserName;
  final String? normalizedEmail;
  final bool? emailConfirmed;
  final String? passwordHash;
  final String? securityStamp;
  final String? concurrencyStamp;
  final String? phoneNumber;
  final bool? phoneNumberConfirmed;
  final bool? twoFactorEnabled;
  final DateTime? lockoutEnd;
  final bool? lockoutEnabled;
  final int? accessFailedCount;
  final List<Post>? posts;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json["id"],
      userName: json["userName"],
      email: json["email"],
      avatar: json["image"],
      initials: json["initials"],
      birthDay:
          json["birthDay"] != null ? DateTime.parse(json["birthDay"]) : null,
      markers: json["markers"],
      normalizedUserName: json["normalizedUserName"],
      normalizedEmail: json["normalizedEmail"],
      emailConfirmed: json["emailConfirmed"],
      passwordHash: json["passwordHash"],
      securityStamp: json["securityStamp"],
      concurrencyStamp: json["concurrencyStamp"],
      phoneNumber: json["phoneNumber"],
      phoneNumberConfirmed: json["phoneNumberConfirmed"],
      twoFactorEnabled: json["twoFactorEnabled"],
      lockoutEnd: json["lockoutEnd"] != null
          ? DateTime.parse(json["lockoutEnd"])
          : null,
      lockoutEnabled: json["lockoutEnabled"],
      accessFailedCount: json["accessFailedCount"],
      posts: json["posts"] != null
          ? List<Post>.from(json["posts"].map((x) => Post.fromJson(x)))
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "userName": userName,
        "email": email,
        "image": avatar,
        "initials": initials,
        "birthDay": birthDay?.toIso8601String(),
        "markers": markers,
        "normalizedUserName": normalizedUserName,
        "normalizedEmail": normalizedEmail,
        "emailConfirmed": emailConfirmed,
        "passwordHash": passwordHash,
        "securityStamp": securityStamp,
        "concurrencyStamp": concurrencyStamp,
        "phoneNumber": phoneNumber,
        "phoneNumberConfirmed": phoneNumberConfirmed,
        "twoFactorEnabled": twoFactorEnabled,
        "lockoutEnd": lockoutEnd?.toIso8601String(),
        "lockoutEnabled": lockoutEnabled,
        "accessFailedCount": accessFailedCount,
        "posts": posts != null
            ? List<dynamic>.from(posts!.map((x) => x.toJson()))
            : null,
      };
}
