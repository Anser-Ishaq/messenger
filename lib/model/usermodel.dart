class UserModel {
  String? uid;
  String? username;
  String? pfpURL;
  String? videoPath;
  List<String>? friends;
  bool? played;

  UserModel({
    this.uid,
    this.username,
    this.pfpURL,
    this.videoPath,
    this.played,
    List<String>? friends,
  }) : friends = friends ?? [];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      username: json['username'],
      pfpURL: json['pfpURL'],
      friends: (json['friends'] as List<dynamic>?)?.map((item) => item as String).toList() ?? [],
      videoPath: json['videoPath'],
      played: json['played'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['uid'] = uid;
    data['username'] = username;
    data['pfpURL'] = pfpURL;
    data['friends'] = friends;
    data['videoPath'] = videoPath;
    data['played'] = played;
    return data;
  }
}
